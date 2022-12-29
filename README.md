# Briefcase Mission

The briefcase mission script is a FiveM script made by Petris and was inspired by the GTA:O mission named Hostile Takeover.

## Description

The script provides a briefcase mission to entertain your server players. The briefcase mission is inspired by the Hostile Takeover VIP Work mission from GTA Online but is more advanced. The briefcase mission will start at a random time of the day. Once started, all players on the server receive a message from Martin which says to them to go to search an area to find the briefcase. Once the briefcase is found by a player, it will be displayed to all players on the map. Once collected, all players will be notified that a player carries the briefcase. The first one to bring the briefcase to the drop-off location alive gets the reward.

## Features
* Synced to all server players (even the ones who join after the mission start)
* Exploit Protection no possibility to cheat on this mission. Triggers are protected.
* GTA:O Materials used. Notifications, messages, sounds & timer bars like GTA ones.
* Live Briefcase Holder Blip which updates its location fast, so you can’t miss the current carrier.
* Fully Optimized script. All threads/functions are optimized so you can enjoy your gameplay.
* Random Start Time System which uses cron and a custom JSON memory system.
* Fully Configurable script with many configuration details.
* Briefcase Prop Holding for all the briefcase carriers.
* Animations on briefcase collection & delivery.

## Installation

Download the file as a ZIP. Extract it into your resources folder. Then go to your server.cfg and start the resource.

```cfg
ensure BriefcaseMission
```

## Usage

```lua
-- Mission Start Export
exports["petris-briefcasemission"]:StartBriefcaseMission()

-- Mission End Export
exports["petris-briefcasemission"]:StopBriefcaseMission()
```

## Credits

* Special thanks to Daudeuf for letting me use his [Timer Bars project](https://github.com/Daudeuf/clm_ProgressBar).

## License

Distributed under the [MIT License](https://github.com/PetrisGR/FiveM-BriefcaseMission/blob/master/LICENSE.txt).
