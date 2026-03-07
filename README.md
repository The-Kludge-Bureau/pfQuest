# pfQuest

<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/mode.png" float="right" align="right" width="25%">

pfQuest is a quest helper and database browser for World of Warcraft Vanilla (1.12), The Burning Crusade (2.4.3), and Wrath of the Lich King (3.3.5a). Accept a quest and the relevant NPCs, monsters, and objects are automatically pinned on your world map and minimap. Open the database browser to look up any unit, item, or game object in the game — or use the chat commands to build macros for tracking gathering nodes.

The goal is to provide an accurate in-game equivalent of [AoWoW](http://db.vanillagaming.org/) or [Wowhead](http://www.wowhead.com/), not a quest guide or turn-by-turn assistant. The Vanilla database is powered by [VMaNGOS](https://github.com/vmangos). The Burning Crusade version uses data from [CMaNGOS](https://github.com/cmangos) with translations from [MaNGOS Extras](https://github.com/MangosExtras).

pfQuest is the successor of [ShaguQuest](https://shagu.org/ShaguQuest/), written from scratch with no dependency on any specific map or questlog addon. It is designed to work alongside the default UI and any other addon. If you run into a conflict, please open an issue on the bugtracker.

You can check the [Latest Changes](https://github.com/The-Kludge-Bureau/pfQuest/commits/main) page to see what has changed recently.

## Before You Install

pfQuest ships a complete database of all spawns, objects, items, and quests. The full package is approximately 80 MB and is loaded into memory once at login — memory usage is stable after that and does not grow during play.

On Vanilla clients, WoW will show a warning if an addon exceeds the default memory limit. **Before installing, set Script Memory to `0` (no limit)** in the AddOns panel of the character selection screen. This is a one-time step. A [screenshot showing where to find the setting](https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/addons-memory.png) is available if you are unsure where to look.

## Downloads

### World of Warcraft: Vanilla

1. **[Download pfQuest (full)](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-full.zip)**
2. Unpack the zip file
3. Move the `pfQuest` folder into `Wow-Directory\Interface\AddOns`
4. Restart WoW

Slim packages (single language): [English](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-enUS.zip) · [German](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-deDE.zip) · [French](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-frFR.zip) · [Spanish](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-esES.zip) · [Korean](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-koKR.zip) · [Chinese](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-zhCN.zip) · [Russian](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-ruRU.zip)

### World of Warcraft: The Burning Crusade

1. **[Download pfQuest (full)](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-full-tbc.zip)**
2. Unpack the zip file
3. Move the `pfQuest-tbc` folder into `Wow-Directory\Interface\AddOns`
4. Restart WoW

Slim packages (single language): [English](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-enUS-tbc.zip) · [German](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-deDE-tbc.zip) · [French](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-frFR-tbc.zip) · [Spanish](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-esES-tbc.zip) · [Korean](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-koKR-tbc.zip) · [Chinese](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-zhCN-tbc.zip) · [Russian](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-ruRU-tbc.zip)

### World of Warcraft: Wrath of the Lich King

> [!IMPORTANT]
>
> **This is a BETA version of pfQuest**
>
> It is able to run on a WotLK (3.3.5a) client, but does not yet ship a WotLK database.
> All available content is limited to Vanilla & TBC as of now.

1. **[Download pfQuest (full)](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-full-wotlk.zip)**
2. Unpack the zip file
3. Move the `pfQuest-wotlk` folder into `Wow-Directory\Interface\AddOns`
4. Restart WoW

Slim packages (single language): [English](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-enUS-wotlk.zip) · [German](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-deDE-wotlk.zip) · [French](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-frFR-wotlk.zip) · [Spanish](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-esES-wotlk.zip) · [Korean](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-koKR-wotlk.zip) · [Chinese](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-zhCN-wotlk.zip) · [Russian](https://github.com/The-Kludge-Bureau/pfQuest/releases/latest/download/pfQuest-ruRU-wotlk.zip)

### Development Version

The development version includes databases for all languages and all client expansions in a single folder. It will work in both Vanilla and TBC mode depending on the folder name. Due to the amount of included data, expect higher RAM and disk usage and slightly longer load times compared to the release packages.

- Clone via Git: [`https://github.com/The-Kludge-Bureau/pfQuest.git`](https://github.com/The-Kludge-Bureau/pfQuest.git)
- Download as zip: **[main.zip](https://github.com/The-Kludge-Bureau/pfQuest/archive/main.zip)**

## Controls

Nodes on the world map can be **clicked** to cycle through display colors, making it easy to mark progress visually.

When multiple spawn points are close together they are grouped into a single **cluster** icon to reduce clutter. Holding **\<ctrl\>** on the world map temporarily breaks clusters apart so you can see individual locations. Hovering the minimap and holding **\<ctrl\>** hides minimap nodes entirely.

| Action                                             | Result                                  |
| -------------------------------------------------- | --------------------------------------- |
| **Click** a node on the world map                  | Cycle node color                        |
| **\<Shift\>-click** a quest giver on the world map | Remove completed quest from the map     |
| Hold **\<Ctrl\>** on the world map                 | Temporarily expand clusters / hide them |
| Hover minimap + hold **\<Ctrl\>**                  | Temporarily hide all minimap nodes      |
| **\<Shift\>-drag** the minimap button              | Move the minimap button                 |
| **\<Shift\>-drag** the arrow frame                 | Move the quest arrow                    |

## Map & Minimap Nodes

<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/arrow.png" width="35.8%" align="left">
<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/minimap-nodes.png" width="59.25%">
<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/map-quests.png" width="55.35%" align="left">
<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/map-spawnpoints.png" width="39.65%">

Quest objectives, spawn points, and points of interest are plotted directly on the world map and minimap. The directional arrow (top left) points toward your nearest active objective and updates as you move. Nodes are color-coded by type and quest state — available quests, objectives in progress, and turn-in locations each use distinct icons.

## Auto-Tracking

<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/map-autotrack.png" float="right" align="right" width="30%">

pfQuest supports four tracking modes that control how quest objectives are shown on the map. The active mode is selected from the dropdown menu in the top-right corner of the world map.

#### All Quests

Every quest in your log is automatically shown and updated on the map. This is the default mode.

#### Tracked Quests

Only quests you have manually tracked via Shift-Click in the questlog are shown and updated.

#### Manual Selection

Only quests you have explicitly shown using the **Show** button in the questlog are displayed. Completed objectives are still automatically removed from the map.

#### Hide Quests

Same as Manual Selection, but quest givers are also hidden and completed objectives remain on the map. This mode makes no changes to existing map nodes.

## Database Browser

<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/browser-spawn.png" align="left" width="30%">
<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/browser-quests.png" align="left" width="30%">
<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/browser-items.png" align="center" width="33%">

The database browser lets you search and bookmark units, game objects, items, and quests from the full pfQuest database. Open it by clicking the pfQuest minimap icon or with `/db show`. Each tab shows up to 100 results — use the scroll wheel or the up/down arrows to navigate. If an entry is marked with `[?]`, that object or unit is not currently available on your realm.

## Questlog Integration

### Questlinks

<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/questlink.png" float="right" align="right" width="30%">

On servers that support questlinks, Shift-clicking a selected quest in the questlog inserts a clickable questlink into chat. These links are compatible with those produced by [ShaguQuest](https://shagu.org/ShaguQuest/), [Questie](https://github.com/AeroScripts/QuestieDev), and [QuestLink](http://addons.us.to/addon/questlink-0). Links sent between pfQuest users are locale-independent and use the Quest ID directly.

Some servers (e.g. Kronos) block questlinks entirely. In that case, disable the questlink feature in the pfQuest settings and the quest name will be inserted as plain text instead.

Hovering a questlink displays a tooltip showing your current progress, the objective text, the full quest description, the suggested level, and the minimum required level.

### Questlog Buttons

<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/questlog-integration.png" align="left" width="300">

Each quest in the questlog has four additional buttons for manual map control. These buttons only affect nodes placed by pfQuest's quest tracking — they do not touch anything you have placed manually through the database browser.

**Show** — Adds the quest objectives for the selected quest to the map.

**Hide** — Removes the selected quest from the map.

**Clean** — Removes all nodes placed by pfQuest from the map.

**Reset** — Restores the default node visibility to match the current auto-tracking mode (e.g. re-shows all quests if the mode is set to "All Quests").

## Chat / Macro CLI

<img src="https://raw.githubusercontent.com/The-Kludge-Bureau/pfQuest/main/_img/chat-cli.png">

All pfQuest features are accessible from chat or macros using `/db`. For example, `/db object Iron Deposit` plots all Iron Deposit locations on the map, and `/db track mines 150 225` shows only mines that require a Mining skill between 150 and 225. The commands `/shagu`, `/pfquest`, and `/pfdb` are all aliases for `/db`.

### General

```
/db lock                Lock/unlock the map tracker position
/db tracker             Show the map tracker
/db journal             Show the quest journal
/db arrow               Toggle the quest arrow
/db show                Open the database browser
/db config              Open the settings panel
/db locale              Display the active addon locales
/db scan                Scan the server for custom items
/db debug               Toggle debug output
```

### Questing

```
/db reset               Reload all quest nodes on the map
/db query               Query the server for completed quests
/db clean               Remove all database search results from the map
```

### Database Search

```
/db unit <name>         Find spawn locations for a unit (e.g. Thrall)
/db object <name>       Find locations for a game object (e.g. Iron Deposit)
/db item <name>         Find units and objects that drop an item (e.g. Runecloth)
/db vendor <name>       Find vendors that sell a specific item (e.g. Jagged Arrow)
/db quest <name>        Search for a quest by name
```

### Tracking Lists

Tracking lists let you pin all instances of a category on the map at once.

```
/db track               Show all available tracking lists
/db track clean         Remove all tracked list nodes from the map
/db track <list>        Show all objects in <list> on the map
/db track <list> clean  Remove all objects in <list> from the map
```

The `mines` and `herbs` lists support an optional skill range and an `auto` shortcut that uses your current skill level:

```
/db track mines         Show all mines
/db track mines auto    Show mines within your current skill range
/db track mines 50 150  Show mines requiring skill 50–150
/db track mines clean   Remove all mine nodes from the map
```

Available tracking lists: `auctioneer`, `banker`, `battlemaster`, `chests`, `fish`, `flight`, `herbs`, `innkeeper`, `mailbox`, `meetingstone`, `mines`, `rares`, `repair`, `spirithealer`, `stablemaster`, `vendor`
