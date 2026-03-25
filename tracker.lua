-- multi api compat
local compat = pfQuestCompat

-- Performance: cache frequently-used globals
local pairs = pairs
local min, max = math.min, math.max
local getn, sort = table.getn, table.sort
local GetTime = GetTime

local fontsize = 12
local panelheight = 16
local entryheight = 20

local function HideTooltip()
  GameTooltip:Hide()
end

local function ShowTooltip()
  if this.tooltip then
    GameTooltip:ClearLines()
    GameTooltip_SetDefaultAnchor(GameTooltip, this)
    if this.text then
      GameTooltip:SetText(this.text:GetText())
      GameTooltip:SetText(this.text:GetText(), this.text:GetTextColor())
    else
      GameTooltip:SetText("|cff33ffccpf|cffffffffQuest")
    end

    if this.node and this.node.questid then
      if
        pfDB["quests"]
        and pfDB["quests"]["loc"]
        and pfDB["quests"]["loc"][this.node.questid]
        and pfDB["quests"]["loc"][this.node.questid]["O"]
      then
        GameTooltip:AddLine(pfDatabase:FormatQuestText(pfDB["quests"]["loc"][this.node.questid]["O"]), 1, 1, 1, 1)
        GameTooltip:AddLine(" ")
      end

      local qlogid = pfQuest.questlog[this.node.questid] and pfQuest.questlog[this.node.questid].qlogid
      if qlogid then
        local objectives = GetNumQuestLeaderBoards(qlogid)
        if objectives and objectives > 0 then
          for i = 1, objectives, 1 do
            local text, _, done = GetQuestLogLeaderBoard(i, qlogid)
            local _, _, obj, cur, req = strfind(gsub(text, "\239\188\154", ":"), "(.*):%s*([%d]+)%s*/%s*([%d]+)")
            if done then
              GameTooltip:AddLine(" - " .. text, 0, 1, 0)
            elseif cur and req then
              local r, g, b = pfMap.tooltip:GetColor(cur, req)
              GameTooltip:AddLine(" - " .. text, r, g, b)
            else
              GameTooltip:AddLine(" - " .. text, 1, 0, 0)
            end
          end
          GameTooltip:AddLine(" ")
        end
      end
    end

    GameTooltip:AddLine(this.tooltip, 1, 1, 1)
    GameTooltip:Show()
  end
end

local expand_states = {}

local function GetQuestSortMode()
  return pfQuest_config["trackerquestsort"] == "distance" and "distance" or "level"
end

-- Old-client Lua can misbehave with math.huge in sort fallbacks; use a plain
-- numeric sentinel so "no distance" always sorts last without nil comparisons.
local DIST_FAR = 99999999

local function UpdateSortButton()
  if not tracker or not tracker.btnsort then
    return
  end

  if tracker.mode == "QUEST_TRACKING" then
    tracker.btnsort:Show()
    if GetQuestSortMode() == "distance" then
      tracker.btnsort.label:SetText("N")
      tracker.btnsort.tooltip = "Quest Sort: Nearest First\n|cff33ffcc<Click>|r Sort By Level"
    else
      tracker.btnsort.label:SetText("L")
      tracker.btnsort.tooltip = "Quest Sort: Level First\n|cff33ffcc<Click>|r Sort By Nearest"
    end
  else
    tracker.btnsort:Hide()
  end
end

local function UpdateQuestDistances()
  if tracker.mode ~= "QUEST_TRACKING" or GetQuestSortMode() ~= "distance" then
    return
  end

  local changed = nil
  local nearest = {}
  -- Some tracker entries fall back to title keys instead of numeric questids,
  -- so nearest-mode needs both maps to keep tracker and route ordering aligned.
  local nearestByTitle = {}
  for _, data in ipairs((pfQuest.route and pfQuest.route.coords) or {}) do
    local questid = data[6] or (data[3] and data[3].questid)
    local distance = data[4]
    if questid and distance and (not nearest[questid] or distance < nearest[questid]) then
      nearest[questid] = distance
    end
    local title = data[3] and data[3].title
    if title and distance and (not nearestByTitle[title] or distance < nearestByTitle[title]) then
      nearestByTitle[title] = distance
    end
  end

  for _, button in pairs(tracker.buttons) do
    if not button.empty then
      local distance = nearest[button.questid] or nearestByTitle[button.title]
      if button.distance ~= distance then
        button.distance = distance
        changed = true
      end
    elseif button.distance then
      button.distance = nil
    end
  end

  if changed then
    tracker.needsSort = true
  end
end

tracker = CreateFrame("Frame", "pfQuestMapTracker", UIParent)
tracker:Hide()
tracker:SetPoint("LEFT", UIParent, "LEFT", 0, 0)
tracker:SetWidth(200)
tracker:SetMovable(true)
tracker:EnableMouse(true)
tracker:SetClampedToScreen(true)
tracker:RegisterEvent("PLAYER_ENTERING_WORLD")
tracker:SetScript("OnEvent", function()
  -- update font sizes according to config
  fontsize = tonumber(pfQuest_config["trackerfontsize"]) or 12
  entryheight = ceil(fontsize * 1.6)

  -- restore tracker state
  if pfQuest_config["showtracker"] and pfQuest_config["showtracker"] == "0" then
    this:Hide()
  else
    this:Show()
  end

  UpdateSortButton()
end)

tracker:SetScript("OnMouseDown", function()
  if not pfQuest_config.lock then
    this:StartMoving()
  end
end)

tracker:SetScript("OnMouseUp", function()
  this:StopMovingOrSizing()
  local anchor, x, y = pfUI.api.ConvertFrameAnchor(this, pfUI.api.GetBestAnchor(this))
  this:ClearAllPoints()
  this:SetPoint(anchor, x, y)

  -- save position
  pfQuest_config.trackerpos = { anchor, x, y }
end)

tracker:SetScript("OnUpdate", function()
  if WorldMapFrame:IsShown() then
    if this.strata ~= "FULLSCREEN_DIALOG" then
      this:SetFrameStrata("FULLSCREEN_DIALOG")
      this.strata = "FULLSCREEN_DIALOG"
    end
  else
    if this.strata ~= "BACKGROUND" then
      this:SetFrameStrata("BACKGROUND")
      this.strata = "BACKGROUND"
    end
  end

  local alpha = this.backdrop:GetAlpha()
  local content = tracker.buttons[1] and not tracker.buttons[1].empty and true or nil
  local goal = (content and not MouseIsOver(this)) and 0 or not content and not MouseIsOver(this) and 0.5 or 1
  if ceil(alpha * 10) ~= ceil(goal * 10) then
    this.backdrop:SetAlpha(alpha + ((goal - alpha) > 0 and 0.1 or (goal - alpha) < 0 and -0.1 or 0))
  end

  if pfQuestCompat.QuestWatchFrame:IsShown() then
    pfQuestCompat.QuestWatchFrame:Hide()
  end

  if tracker.mode == "QUEST_TRACKING" and GetQuestSortMode() == "distance" then
    if not this.distanceTick or this.distanceTick < GetTime() then
      this.distanceTick = GetTime() + 0.2
      UpdateQuestDistances()
    end
  else
    this.distanceTick = nil
  end

  if tracker.needsSort then
    tracker.DoLayout()
  end
end)

tracker:SetScript("OnShow", function()
  pfQuest_config["showtracker"] = "1"

  -- load tracker position if exists
  if pfQuest_config.trackerpos then
    this:ClearAllPoints()
    this:SetPoint(unpack(pfQuest_config.trackerpos))
  end
end)

tracker:SetScript("OnHide", function()
  pfQuest_config["showtracker"] = "0"
end)

tracker.buttons = {}
tracker.buttonByTitle = {} -- reverse map: title → button index, for O(1) duplicate detection
tracker.mode = "QUEST_TRACKING"

function tracker.RefreshNearestDistances()
  if tracker.mode ~= "QUEST_TRACKING" or GetQuestSortMode() ~= "distance" then
    return
  end

  tracker.distanceTick = GetTime() + 0.2
  UpdateQuestDistances()

  if tracker.needsSort then
    tracker.DoLayout()
  end
end

tracker.backdrop = CreateFrame("Frame", nil, tracker)
tracker.backdrop:SetAllPoints(tracker)
tracker.backdrop.bg = tracker.backdrop:CreateTexture(nil, "BACKGROUND")
tracker.backdrop.bg:SetTexture(0, 0, 0, 0.2)
tracker.backdrop.bg:SetAllPoints()

do -- button panel
  tracker.panel = CreateFrame("Frame", nil, tracker.backdrop)
  tracker.panel:SetPoint("TOPLEFT", 0, 0)
  tracker.panel:SetPoint("TOPRIGHT", 0, 0)
  tracker.panel:SetHeight(panelheight)

  local anchors = {}
  local buttons = {}
  local function CreateButton(icon, anchor, tooltip, func)
    anchors[anchor] = anchors[anchor] and anchors[anchor] + 1 or 0
    local pos = 1 + (panelheight + 1) * anchors[anchor]
    pos = anchor == "TOPLEFT" and pos or pos * -1
    local func = func

    local b = CreateFrame("Button", nil, tracker.panel)
    b.tooltip = tooltip
    b.icon = b:CreateTexture(nil, "BACKGROUND")
    b.icon:SetAllPoints()
    b.icon:SetTexture(pfQuestConfig.path .. "\\img\\tracker_" .. icon)
    if table.getn(buttons) == 0 then
      b.icon:SetVertexColor(0.2, 1, 0.8)
    end

    b:SetPoint(anchor, pos, -1)
    b:SetWidth(panelheight - 2)
    b:SetHeight(panelheight - 2)

    b:SetScript("OnEnter", ShowTooltip)
    b:SetScript("OnLeave", HideTooltip)

    if anchor == "TOPLEFT" then
      table.insert(buttons, b)
      b:SetScript("OnClick", function()
        if func then
          func()
        end
        for id, button in pairs(buttons) do
          button.icon:SetVertexColor(1, 1, 1)
        end
        this.icon:SetVertexColor(0.2, 1, 0.8)
      end)
    else
      b:SetScript("OnClick", func)
    end

    return b
  end

  tracker.btnquest = CreateButton("quests", "TOPLEFT", pfQuest_Loc["Show Current Quests"], function()
    tracker.mode = "QUEST_TRACKING"
    UpdateSortButton()
    pfMap:UpdateNodes()
  end)

  tracker.btndatabase = CreateButton("database", "TOPLEFT", pfQuest_Loc["Show Database Results"], function()
    tracker.mode = "DATABASE_TRACKING"
    UpdateSortButton()
    pfMap:UpdateNodes()
  end)

  tracker.btngiver = CreateButton("giver", "TOPLEFT", pfQuest_Loc["Show Quest Givers"], function()
    tracker.mode = "GIVER_TRACKING"
    UpdateSortButton()
    pfMap:UpdateNodes()
  end)

  tracker.btnsort = CreateFrame("Button", nil, tracker.panel)
  tracker.btnsort:SetPoint("TOPRIGHT", -69, -1)
  tracker.btnsort:SetWidth(panelheight - 2)
  tracker.btnsort:SetHeight(panelheight - 2)
  tracker.btnsort.tooltip = "Quest Sort"
  tracker.btnsort.bg = tracker.btnsort:CreateTexture(nil, "BACKGROUND")
  tracker.btnsort.bg:SetAllPoints()
  tracker.btnsort.bg:SetTexture(0, 0, 0, 0)
  tracker.btnsort.label = tracker.btnsort:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  tracker.btnsort.label:SetAllPoints()
  tracker.btnsort.label:SetFont(pfUI.font_default, 11)
  tracker.btnsort.label:SetTextColor(0.9, 0.9, 0.9, 1)
  tracker.btnsort:SetScript("OnEnter", ShowTooltip)
  tracker.btnsort:SetScript("OnLeave", HideTooltip)
  tracker.btnsort:SetScript("OnClick", function()
    if GetQuestSortMode() == "distance" then
      pfQuest_config["trackerquestsort"] = "level"
    else
      pfQuest_config["trackerquestsort"] = "distance"
    end

    UpdateSortButton()
    tracker.needsSort = true
    tracker.distanceTick = 0
    if pfQuest.route then
      pfQuest.route.recalculate = nil
      pfQuest.route.firstnode = nil
    end
    pfMap.queue_update = GetTime()
  end)

  tracker.btnclose = CreateButton("close", "TOPRIGHT", pfQuest_Loc["Close Tracker"], function()
    DEFAULT_CHAT_FRAME:AddMessage(
      pfQuest_Loc["|cff33ffccpf|cffffffffQuest: Tracker is now hidden. Type `/db tracker` to show."]
    )
    tracker:Hide()
  end)

  tracker.btnsettings = CreateButton("settings", "TOPRIGHT", pfQuest_Loc["Open Settings"], function()
    if pfQuestConfig then
      pfQuestConfig:Show()
    end
  end)

  tracker.btnclean = CreateButton("clean", "TOPRIGHT", pfQuest_Loc["Clean Database Results"], function()
    pfMap:DeleteNode("PFDB")
    pfMap:UpdateNodes()
  end)

  tracker.btnsearch = CreateButton("search", "TOPRIGHT", pfQuest_Loc["Open Database Browser"], function()
    if pfBrowser then
      pfBrowser:Show()
    end
  end)
end

function tracker.ButtonEnter()
  pfMap.highlight = this.title
  ShowTooltip()
end

function tracker.ButtonLeave()
  pfMap.highlight = nil
  HideTooltip()
end

function tracker.ButtonUpdate()
  local alpha = tonumber((pfQuest_config["trackeralpha"] or 0.2)) or 0.2

  if not this.alpha or this.alpha ~= alpha then
    this.bg:SetTexture(0, 0, 0, alpha)
    this.bg:SetAlpha(alpha)
    this.alpha = alpha
  end

  if pfMap.highlight and pfMap.highlight == this.title then
    if not this.highlight then
      this.bg:SetTexture(1, 1, 1, math.max(0.2, alpha))
      this.bg:SetAlpha(math.max(0.5, alpha))
      this.highlight = true
    end
  elseif this.highlight then
    this.bg:SetTexture(0, 0, 0, alpha)
    this.bg:SetAlpha(alpha)
    this.highlight = nil
  end
end

function tracker.ButtonClick()
  if arg1 == "RightButton" then
    for questid, data in pairs(pfQuest.questlog) do
      if data.title == this.title then
        -- show questlog
        HideUIPanel(QuestLogFrame)
        SelectQuestLogEntry(data.qlogid)
        ShowUIPanel(QuestLogFrame)
        break
      end
    end
  elseif IsShiftKeyDown() then
    -- mark as done if node is quest and not in questlog
    if this.node.questid and not this.node.qlogid then
      -- mark as done in history
      pfQuest_history[this.node.questid] = { time(), UnitLevel("player") }
      UIErrorsFrame:AddMessage(
        string.format("The Quest |cffffcc00[%s]|r (id:%s) is now marked as done.", this.title, this.node.questid),
        1,
        1,
        1
      )
    end

    pfMap:DeleteNode(this.node.addon, this.title)
    pfMap:UpdateNodes()

    pfQuest.updateQuestGivers = true
  elseif IsControlKeyDown() and not WorldMapFrame:IsShown() then
    -- show world map
    if ToggleWorldMap then
      -- vanilla & tbc
      ToggleWorldMap()
    else
      -- wotlk
      WorldMapFrame:Show()
    end
  elseif IsControlKeyDown() and pfQuest_config["spawncolors"] == "0" then
    -- switch color
    pfQuest_colors[this.title] = { pfMap.str2rgb(this.title .. GetTime()) }
    pfMap:UpdateNodes()
  elseif expand_states[this.title] == 0 then
    expand_states[this.title] = 1
    tracker.ButtonEvent(this)
  elseif expand_states[this.title] == 1 then
    expand_states[this.title] = 0
    tracker.ButtonEvent(this)
  end
end

local function trackersort(a, b)
  if a.empty then
    return false
  elseif (a.tracked and 1 or -1) ~= (b.tracked and 1 or -1) then
    return (a.tracked and 1 or -1) > (b.tracked and 1 or -1)
  elseif (a.inLocalZone and 1 or -1) ~= (b.inLocalZone and 1 or -1) then
    return (a.inLocalZone and 1 or -1) > (b.inLocalZone and 1 or -1)
  elseif tracker.mode == "QUEST_TRACKING" and GetQuestSortMode() == "distance"
         and (a.distance or DIST_FAR) ~= (b.distance or DIST_FAR) then
    return (a.distance or DIST_FAR) < (b.distance or DIST_FAR)
  elseif (a.level or -1) ~= (b.level or -1) then
    return (a.level or -1) > (b.level or -1)
  elseif tracker.mode == "QUEST_TRACKING" and (a.distance or DIST_FAR) ~= (b.distance or DIST_FAR) then
    return (a.distance or DIST_FAR) < (b.distance or DIST_FAR)
  elseif (a.perc or -1) ~= (b.perc or -1) then
    return (a.perc or -1) > (b.perc or -1)
  elseif (a.title or "") ~= (b.title or "") then
    return (a.title or "") < (b.title or "")
  else
    return false
  end
end

-- Reusable cache for GetQuestLogLeaderBoard results within a single ButtonEvent
-- call. Avoids calling the API twice per objective (once for progress, once for
-- display). Cleared at the start of each ButtonEvent invocation.
local board_cache = {}

function tracker.ButtonEvent(self)
  local self = self or this
  local title = self.title
  local node = self.node
  local id = self.id
  local qid = self.questid

  self:SetHeight(0)

  -- we got an event on a hidden button
  if not title then
    return
  end
  if self.empty then
    return
  end

  self:SetHeight(entryheight)

  -- initialize and hide all objectives
  self.objectives = self.objectives or {}
  for id, obj in pairs(self.objectives) do
    obj:Hide()
  end

  -- update button icon
  if node.mode5local then
    self.icon:SetTexture(pfQuestConfig.path .. "\\img\\node")
    self.icon:SetVertexColor(pfMap.str2rgb(title))
  elseif node.texture then
    self.icon:SetTexture(node.texture)

    local r, g, b = unpack(node.vertex or { 0, 0, 0 })
    if r > 0 or g > 0 or b > 0 then
      self.icon:SetVertexColor(unpack(node.vertex))
    else
      self.icon:SetVertexColor(1, 1, 1, 1)
    end
  elseif pfQuest_config["spawncolors"] == "1" then
    self.icon:SetTexture(pfQuestConfig.path .. "\\img\\available_c")
    self.icon:SetVertexColor(1, 1, 1, 1)
  else
    self.icon:SetTexture(pfQuestConfig.path .. "\\img\\node")
    self.icon:SetVertexColor(pfMap.str2rgb(title))
  end

  if tracker.mode == "QUEST_TRACKING" then
    if pfQuest.questlog[qid] and pfQuest.questlog[qid].collapsed then
      self:SetHeight(0)
      return
    end
    local qlogid = pfQuest.questlog[qid] and pfQuest.questlog[qid].qlogid or 0
    local qtitle, level, tag, header, collapsed, complete = compat.GetQuestLogTitle(qlogid)
    -- If qlogid is stale (quest shifted due to collapse/expand), suppress
    -- objectives to avoid briefly showing wrong data from the wrong slot.
    -- UpdateQuestlog will fix the qlogid shortly via RELOAD_QLOGID.
    local stale = qtitle ~= title
    if stale then complete = nil end
    local objectives = stale and 0 or GetNumQuestLeaderBoards(qlogid)
    local watched = stale and nil or IsQuestWatched(qlogid)
    local color = pfQuestCompat.GetDifficultyColor(level)
    local cur, max = 0, 0
    local percent = 0

    -- write expand state
    if not expand_states[title] then
      expand_states[title] = pfQuest_config["trackerexpand"] == "1" and 1 or 0
    end

    local expanded = expand_states[title] == 1 and true or nil

    if objectives and objectives > 0 then
      -- populate cache and compute progress in one pass
      for i = 1, objectives, 1 do
        local text, type, done = GetQuestLogLeaderBoard(i, qlogid)
        board_cache[i] = { text, type, done }
        local _, _, obj, objNum, objNeeded = strfind(gsub(text, "\239\188\154", ":"), "(.*):%s*([%d]+)%s*/%s*([%d]+)")
        if objNum and objNeeded then
          max = max + objNeeded
          cur = cur + objNum
        elseif not done then
          max = max + 1
        end
      end
      -- clear stale entries beyond current objective count
      for i = objectives + 1, table.getn(board_cache) do
        board_cache[i] = nil
      end
    end

    if cur == max or complete then
      cur, max = 1, 1
      percent = 100
    else
      percent = cur / max * 100
    end

    -- expand button to show objectives
    if objectives and (expanded or (percent > 0 and percent < 100)) then
      self:SetHeight(entryheight + objectives * fontsize)

      for i = 1, objectives, 1 do
        -- read from cache instead of calling GetQuestLogLeaderBoard again
        local entry = board_cache[i]
        local text, _, done = entry[1], entry[2], entry[3]
        local _, _, obj, objNum, objNeeded = strfind(gsub(text, "\239\188\154", ":"), "(.*):%s*([%d]+)%s*/%s*([%d]+)")

        if not self.objectives[i] then
          self.objectives[i] = self:CreateFontString(nil, "HIGH", "GameFontNormal")
          self.objectives[i]:SetFont(pfUI.font_default, fontsize)
          self.objectives[i]:SetJustifyH("LEFT")
          self.objectives[i]:SetPoint("TOPLEFT", 20, -fontsize * i - 6)
          self.objectives[i]:SetPoint("TOPRIGHT", -10, -fontsize * i - 6)
        end

        if objNum and objNeeded then
          local r, g, b = pfMap.tooltip:GetColor(objNum, objNeeded)
          self.objectives[i]:SetTextColor(r + 0.2, g + 0.2, b + 0.2)
          self.objectives[i]:SetText(string.format("|cffffffff- %s:|r %s/%s", obj, objNum, objNeeded))
        else
          self.objectives[i]:SetTextColor(0.8, 0.8, 0.8)
          self.objectives[i]:SetText("|cffffffff- " .. text)
        end

        self.objectives[i]:Show()
      end
    end

    local r, g, b = pfMap.tooltip:GetColor(cur, max)
    local colorperc = string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
    local showlevel = pfQuest_config["trackerlevel"] == "1" and "[" .. (level or "??") .. (tag and "+" or "") .. "] "
      or ""

    self.tracked = watched
    self.level = tonumber(level)
    self.perc = percent
    self.text:SetText(
      string.format("%s%s |cffaaaaaa(%s%s%%|cffaaaaaa)|r", showlevel, title or "", colorperc or "", ceil(percent))
    )
    self.text:SetTextColor(color.r, color.g, color.b)
    self.tooltip =
      pfQuest_Loc["|cff33ffcc<Click>|r Unfold/Fold Objectives\n|cff33ffcc<Right-Click>|r Show In QuestLog\n|cff33ffcc<Ctrl-Click>|r Show Map / Toggle Color\n|cff33ffcc<Shift-Click>|r Hide Nodes"]
  elseif tracker.mode == "GIVER_TRACKING" then
    local level = node.qlvl or node.level or UnitLevel("player")
    local color = pfQuestCompat.GetDifficultyColor(level)

    -- red quests
    if node.qmin and node.qmin > UnitLevel("player") then
      color = { r = 1, g = 0, b = 0 }
    end

    -- detect daily quests
    if node.qmin and node.qlvl and math.abs(node.qmin - node.qlvl) >= 30 then
      level, color = 0, { r = 0.2, g = 0.8, b = 1 }
    end

    local showlevel = pfQuest_config["trackerlevel"] == "1" and "[" .. (level or "??") .. "] " or ""
    self.text:SetTextColor(color.r, color.g, color.b)
    self.text:SetText(showlevel .. title)
    self.level = tonumber(level)
    self.tooltip =
      pfQuest_Loc["|cff33ffcc<Ctrl-Click>|r Show Map / Toggle Color\n|cff33ffcc<Shift-Click>|r Mark As Done"]
  elseif tracker.mode == "DATABASE_TRACKING" then
    self.text:SetText(title)
    self.text:SetTextColor(1, 1, 1, 1)
    self.text:SetTextColor(pfMap.str2rgb(title))
    self.tooltip = pfQuest_Loc["|cff33ffcc<Ctrl-Click>|r Show Map / Toggle Color\n|cff33ffcc<Shift-Click>|r Hide Nodes"]
  end

  -- Mark for sort instead of sorting immediately (deferred)
  tracker.needsSort = true
  self:Show()
end

-- Separate function for layout (only called when needed)
function tracker.DoLayout()
  -- Sort all tracker entries if needed
  if tracker.needsSort then
    sort(tracker.buttons, trackersort)
    tracker.needsSort = nil
  end

  -- resize window and align buttons
  local height = panelheight
  local width = 100

  for bid, button in pairs(tracker.buttons) do
    button:ClearAllPoints()
    button:SetPoint("TOPRIGHT", tracker, "TOPRIGHT", 0, -height)
    button:SetPoint("TOPLEFT", tracker, "TOPLEFT", 0, -height)
    if not button.empty then
      height = height + button:GetHeight()

      -- Cache GetStringWidth result (avoid calling twice)
      local textWidth = button.text:GetStringWidth()
      if textWidth > width then
        width = textWidth
      end

      for id, objective in pairs(button.objectives) do
        if objective:IsShown() then
          local objWidth = objective:GetStringWidth()
          if objWidth > width then
            width = objWidth
          end
        end
      end
    end
  end

  width = min(width, 300) + 30
  tracker:SetHeight(height)
  tracker:SetWidth(width)
end

function tracker.RefreshZoneTracker()
  if pfQuest_config["trackingmethod"] ~= 5 then return end
  tracker.Reset()

  local seen = {}
  local playerZone = pfMap.playerZone
  local localQuestNodes = {}

  -- Collect one representative real node per quest in the player's current
  -- zone so tracker entries can reuse the same icon metadata as map pins.
  if playerZone and pfMap.nodes["PFQUEST"] and pfMap.nodes["PFQUEST"][playerZone] then
    for coords, coordNode in pairs(pfMap.nodes["PFQUEST"][playerZone]) do
      for title, node in pairs(coordNode) do
        local qid = node.questid or title
        if pfQuest.questlog[qid] and not pfQuest.questlog[qid].collapsed then
          local current = localQuestNodes[qid]
          if not current or ((not current.texture and node.texture) or (current.dummy and not node.dummy)) then
            localQuestNodes[qid] = node
          end
        end
      end
    end
  end

  -- Always include watched quests, even when their objectives are outside the
  -- current zone. The existing sort puts watched quests at the top.
  for qid, data in pairs(pfQuest.questlog or {}) do
    local qtitle, _, _, _, _, complete = compat.GetQuestLogTitle(data.qlogid)
    if qtitle == data.title and IsQuestWatched(data.qlogid) then
      seen[qid] = true
      if localQuestNodes[qid] then
        localQuestNodes[qid].mode5local = true
        tracker.ButtonAdd(data.title, localQuestNodes[qid])
      else
        local img = complete and pfQuestConfig.path .. "\\img\\complete_c"
          or pfQuestConfig.path .. "\\img\\complete"
        tracker.ButtonAdd(data.title, {
          dummy = true, addon = "PFQUEST", texture = img, questid = qid, force = true
        })
      end
    end
  end

  -- Add remaining current-zone quests using their real node data so the
  -- tracker icon matches the actual PFQUEST pin/minimap representation.
  for qid, node in pairs(localQuestNodes) do
    if not seen[qid] then
      local data = pfQuest.questlog[qid]
      local qtitle = data and compat.GetQuestLogTitle(data.qlogid)
      if data and qtitle == data.title then
        seen[qid] = true
        node.mode5local = true
        tracker.ButtonAdd(data.title, node)
      end
    end
  end

  tracker.needsSort = true
  UpdateQuestDistances()
  tracker.DoLayout()
end

function tracker.ButtonAdd(title, node)
  if not title or not node then
    return
  end

  -- Mode 5: only block real quest nodes from UpdateNodes while the quest tab
  -- is active. Other tracker tabs still need real nodes to populate.
  if tracker.mode == "QUEST_TRACKING" and pfQuest_config["trackingmethod"] == 5
     and not node.dummy and not node.mode5local then
    return
  end

  -- O(1) questid lookup: node.questid is set for all PFQUEST nodes from the DB.
  -- For the rare case it's missing or not in questlog (title-keyed quests), fall
  -- back to the linear scan so correctness is preserved.
  local questid = node.questid or title
  if node.questid and not pfQuest.questlog[node.questid] then
    questid = title
    for qid, data in pairs(pfQuest.questlog) do
      if data.title == title then
        questid = qid
        break
      end
    end
  end

  if tracker.mode == "QUEST_TRACKING" then -- skip everything that isn't in questlog
    if node.addon ~= "PFQUEST" then
      return
    end
    if not pfQuest.questlog or not pfQuest.questlog[questid] then
      return
    end
    if pfQuest.questlog[questid].collapsed and not node.force then
      return
    end
  elseif tracker.mode == "GIVER_TRACKING" then -- skip everything that isn't a questgiver
    if node.addon ~= "PFQUEST" then
      return
    end
    -- break on already taken quests
    if not pfQuest.questlog or pfQuest.questlog[questid] then
      return
    end
    -- every layer above 2 is not a questgiver
    if not node.layer or node.layer > 2 then
      return
    end
  elseif tracker.mode == "DATABASE_TRACKING" then -- skip everything that isn't db query
    if node.addon ~= "PFDB" then
      return
    end
  end

  local id

  -- O(1) duplicate check via reverse map (replaces linear scan of tracker.buttons)
  local existing = tracker.buttonByTitle[title]
  if existing then
    local button = tracker.buttons[existing]
    if node.dummy or not node.texture then
      id = existing -- node icon takes slot
    elseif node.cluster and (not button.node or button.node.texture) then
      id = existing -- cluster icon, acceptable
    else
      button.inLocalZone = true
      return -- no icon update needed
    end
  end

  if not id then
    -- use maxcount + 1 as default id
    id = table.getn(tracker.buttons) + 1

    -- detect a reusable button
    for bid, button in pairs(tracker.buttons) do
      if button.empty then
        id = bid
        break
      end
    end
  end

  if id > 25 then
    return
  end

  -- create one if required
  if not tracker.buttons[id] then
    tracker.buttons[id] = CreateFrame("Button", "pfQuestMapButton" .. id, tracker)
    tracker.buttons[id]:SetHeight(entryheight)

    tracker.buttons[id].bg = tracker.buttons[id]:CreateTexture(nil, "BACKGROUND")
    tracker.buttons[id].bg:SetTexture(1, 1, 1, 0.2)
    tracker.buttons[id].bg:SetAllPoints()
    tracker.buttons[id].bg:SetAlpha(0)

    tracker.buttons[id].text = tracker.buttons[id]:CreateFontString("pfQuestIDButton", "HIGH", "GameFontNormal")
    tracker.buttons[id].text:SetFont(pfUI.font_default, fontsize)
    tracker.buttons[id].text:SetJustifyH("LEFT")
    tracker.buttons[id].text:SetPoint("TOPLEFT", 16, -4)
    tracker.buttons[id].text:SetPoint("TOPRIGHT", -10, -4)

    tracker.buttons[id].icon = tracker.buttons[id]:CreateTexture(nil, "BORDER")
    tracker.buttons[id].icon:SetPoint("TOPLEFT", 2, -4)
    tracker.buttons[id].icon:SetWidth(12)
    tracker.buttons[id].icon:SetHeight(12)

    tracker.buttons[id]:RegisterEvent("QUEST_WATCH_UPDATE")
    tracker.buttons[id]:RegisterEvent("QUEST_LOG_UPDATE")
    tracker.buttons[id]:RegisterEvent("QUEST_FINISHED")

    tracker.buttons[id]:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    tracker.buttons[id]:SetScript("OnEnter", tracker.ButtonEnter)
    tracker.buttons[id]:SetScript("OnLeave", tracker.ButtonLeave)
    tracker.buttons[id]:SetScript("OnUpdate", tracker.ButtonUpdate)
    tracker.buttons[id]:SetScript("OnEvent", tracker.ButtonEvent)
    tracker.buttons[id]:SetScript("OnClick", tracker.ButtonClick)
  end

  -- set required data
  tracker.buttons[id].empty = nil
  tracker.buttons[id].title = title
  tracker.buttons[id].node = node
  tracker.buttons[id].questid = questid

  -- keep reverse map in sync
  tracker.buttonByTitle[title] = id

  -- reload button data
  tracker.ButtonEvent(tracker.buttons[id])
end

function tracker.Reset()
  tracker:SetHeight(panelheight)
  for id, button in pairs(tracker.buttons) do
    button.distance = nil
    button.level = nil
    button.title = nil
    button.perc = nil
    button.inLocalZone = nil
    button.empty = true
    button:SetHeight(0)
    button:Hide()
  end
  -- reverse map is only valid while buttons hold titles; clear on full reset
  for k in pairs(tracker.buttonByTitle) do
    tracker.buttonByTitle[k] = nil
  end

  -- add tracked quests
  local _, numQuests = GetNumQuestLogEntries()
  local found = 0

  if pfQuest_config["trackingmethod"] == 5 then
    -- "Current Zone" mode: skip dummy buttons here.
    -- RefreshZoneTracker populates from the player's physical zone.
  elseif pfQuest_config["trackingmethod"] == 1 then
    -- In "All Quests" mode, add a dummy button for every active quest so it
    -- appears in the tracker immediately on acceptance, even when objectives
    -- are in a different zone and no map pins exist for the current map.
    -- Use pfQuest.questlog (keyed by numeric questid for DB quests, title for
    -- unknowns) so ButtonAdd can resolve the quest from pfQuest.questlog.
    for questid, data in pairs(pfQuest.questlog) do
      if not data.collapsed then
        local _, _, _, _, _, complete = compat.GetQuestLogTitle(data.qlogid)
        local img = complete and pfQuestConfig.path .. "\\img\\complete_c" or pfQuestConfig.path .. "\\img\\complete"
        pfQuest.tracker.ButtonAdd(data.title, { dummy = true, addon = "PFQUEST", texture = img, questid = questid })
      end
    end
  else
    -- In other modes, only add dummy buttons for watched quests.
    local underCollapsedHeader = false
    for qlogid = 1, 40 do
      local title, level, tag, header, collapsed, complete = compat.GetQuestLogTitle(qlogid)
      if header then
        underCollapsedHeader = collapsed and true or false
      elseif title then
        local isCollapsed = underCollapsedHeader or (collapsed and true or false)
        if not isCollapsed then
          local watched = IsQuestWatched(qlogid)
          if watched then
            local img = complete and pfQuestConfig.path .. "\\img\\complete_c" or pfQuestConfig.path .. "\\img\\complete"
            pfQuest.tracker.ButtonAdd(title, { dummy = true, addon = "PFQUEST", texture = img })
          end
        end

        found = found + 1
        if found >= numQuests then
          break
        end
      end
    end
  end
  UpdateSortButton()
  -- Note: DoLayout is called by UpdateNodes after all ButtonAdd calls complete
end

-- make global available
pfQuest.tracker = tracker
