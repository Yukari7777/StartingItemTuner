# StartingItemTuner
![download](https://user-images.githubusercontent.com/16526080/182504841-6a1c5ae8-08c3-49a7-a1c8-75285b3ccb84.gif)\
Public repositry for developing Scheme mod.

You can play my mod via Steam Workshop page.\
https://steamcommunity.com/sharedfiles/filedetails/?id=1627929571

## Usage
You have to config data file(`data.lua` or `modoverrides.lua`) to apply settings. \
Modify it with any text tools. Notepad is also OK. \
Just edit it with correct rules and save it.\
Ensure backup your file if you don't want to lose your great settings.\

Your Mod Folder is at :\
`(DST Install Folder)/mods/workshop-1627929571/`

Your modoverrides.lua is at : \
`Documents/Klei/DoNotStarveTogether/(userid/)Cluster_#/`

Here's basic example of data file. And it's default setting if you just have applied this mod.
```
GLOBAL.SIT_DATA_RAW = {
	["AllPlayers"] = {
		["respawnnight"] = { 
			"torch",
		},
	},
}
```

"AllPlayers" means all players(including mod characters). This is described as `doer keywords`. \
You can put (prefab)name of the subject. Or the subject could be "admin". 

"respawnnight" is compound of "respawn" + "night" which is `situational keywords`\
"respawn" is also compound of "portal" + "touchstone" + "effigy" \
You can confine or include various situation by simplely concatenate them. 

"torch" one is what to give. This is where `execution keywords` to be put.\
You can set 'number property' on right next to the give. \
If you set like 	"torch", 3		this, this will give 3 torches. \
You can also give the specific amount of status or unlock recipes you want. 


### doer keywords
Available Keywords : 
`AllPlayers, admin, (any prefab name that is player)`

- "AllPlayers" will apply to all players.
- "admin" will apply to all admins.

(any prefab name that is player) means, 
- if you want Wilson, put "wilson".
- if you want Maxwell, put "waxwell" (you have to know its prefab name)
- if you want Wigfrid, put "wathgrithr".
- if you want Yakumo Yukari the mod character, put "yakumoyukari".


### situational keywords
Available Keywords :
```
time = { "anytime", "day", "dusk", "night" },
season = { "always", "spring", "summer", "autumn", "winter" },
respawn = { "respawn", "portal", "touchstone", "effigy" }, 
revived = { "revived", "heart", "amulet", "debug", "other" },
other = { "onload", "cave", "change", "newspawn" }
```
There're some sort keys in keywords but only values that is covered by "" will only work. Don't be confused.

- "day" is day, "dusk" is dusk. and so on. \
"anytime" will be converted to "daydusknight". \
So you can confine which time or season to do stuff. \
└ And "always", "respawn", "revived" does same.("respawn" => "portaltouchstoneeffigy")

- "heart" is when the character is resurrected by Telltale Heart. \
ㄴ "touchstone", "effigy" does same. \

- "amulet" is when the character is resurrected by Life Giving Amulet.
- "debug" is when the character is ressurected by console commands.
- "other" is when the character is ressurected by unkown sources.
- "portal" is when the character is 'resurrected' by multiplayer portal(Floid Postern). Don't be confused with newspawn.
- "change" is when the characher is spawned after using Moon Rock Idol on Celestial Portal.

- if you compound multiple keys, you are 'including' the multiple situations.
"daydusk" will execute the stuff when it's 'day OR dusk'. \
"springsummer" will execute when it's 'spring OR summer'. \

- "onload" is when the prefab(player) gets loaded.
Be cautious that prefab will do loaded everytime you go to cave or exit from cave. \
So giving items in "onload" situation is inappropriate. 

- if none of values in time and season is given, it will be considered "anytime" and "always" each.
So "respawnnight" is same condition of "respawnnightanytimealways" or "respawnnightalways". (will run both if you seperate them though.)

- if none of values in respawn and revived is given, "newspawn" key will be added automatically.
So "onload" is same condition of "onloadnewspawn". (will run both if you seperate them though.)

### execution keywords
Available Keywords :
```
(any prefab name that is inventory item), *(any prefab name that can be crafted), *ALL, *(any Tech(all uppercase) that is currently exist on your server)
**CREATIVE, **GODMODE, **SUPERGODMODE, **NOATTACK
```
Tech = { "SCIENCE", "MAGIC", "ANCIENT", "CELESTIAL", "SHADOW", "CARTOGRAPHY", "SCULPTING", "ORPHANAGE", "PERDOFFERING", "WARGOFFERING", "MADSCIENCE", (other Tech name added by mod which should be all upper-cased)}

You can search some items' prefab name in here : http://dontstarve.wikia.com/wiki/Console/Prefab_List \
Or you can search the item on the wiki and the prefab name is written at "DebugSpawn" \
If you put a numeric key next to the keyword, that will be "number property". \
if number property is not given, default is 1.

- If the keyword is an inventory item. Number property means how much to give item. \
└ "torch", 3 means "give 3 torches"

- If the keyword is written with *(prefab name), the recipe of its item will be unlocked. Number property will be ignored. \
└ "*goldenpickaxe" will unlock the recipe of golden pickaxe(Opulent Pickaxe). \
└ However even you unlock pick/axe's recipe by "*multitool_axe_pickaxe", You still need Ancient Pseudoscience Station on near to craft. \
  Any other recipes that need special condition will also be applied same.

- If the keyword is written with *(Tech), the recipe that requires the tech will be unlocked. Number property means the level of tech. \
└ You have to write Tech in uppercase or it'll be considered an item name. Refer Listed Tech above. \
└ "*SCIENCE", 2 will unlock all recipes that requires level 2 science machine(Alchemy Engine). \
└ If you don't put the number property, level 1 of the Tech will be unlocked. \
└ However even you unlock ANCIENT Tech, You still need Ancient Pseudoscience Station on near to craft. \
  Any other recipes that need special condition will also be applied same. \
  Also, mini Ancient Station's Tech level is 2 not 1. Full Station's Tech level is 4 not 2. 
  
- If the keyword is "*ALL", all recipes will be unlocked. 

- If the keyword is "**CREATIVE", you will go to free-build-mode. (same with console command c_freecrafting())

- If the keyword is "**GODMODE", you will go to godmode. (same with console command c_godmode())

- If the keyword is "**SUPERGODMODE", you will go to supergodmode. (same with console command c_supergodmode())
└ The difference with godmode is when you become supergodmoded, you'll be fully restored and stay your stats maxed out.

- If the keyword is "**NOATTACK", you will not be targetted. (same with console command c_makeinvisible())
