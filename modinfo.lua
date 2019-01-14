name = "Starting Item Tuner"
description = "Let you set starting items you want."
author = "Yakumo Yukari"
version = "1.0.0"
forumthread = ""
api_version = 6
api_version_dst = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true 

icon_atlas = "modicon.xml"
icon = "modicon.tex"

server_filter_tags = {"serveradmin", "startingitem"}
local on_off = {
	{ description = "true", data = true },
	{ description = "false", data = false },
}

configuration_options = {
	{
		name = "ShouldOverrideVanila",
		description = "If true, default starting items of vanila charachers will be removed and replaced. Otherwise, will be added to default starting items.",
		options = on_off,
		default = false,
	},
	{
		name = "ShouldOverrideMod",
		description = "Same with the above, but it's only for mod characters.",
		options = on_off,
		default = false,
	},
	{
		name = "datatable",
		description = "You have to add settings in data.lua in the mod folder.",
		default = {
			["AllPlayers"] = {
				--["spring"] = {
					-- "grass_umbrella", "*rainhat"
					-- gives 1 pretty parasol and unlock rainhat's recipe when is spring. 

					-- You can unlock specific item's recipe by writing "*" in the keyword.
					-- If you want blue print instead, add "_blueprint" instead. ex) rainhat_blueprint
				--},
				--["summer"] = { },
				--["autumn"] = { },
				--["winter"] = { },
				--["always"] = { 
					-- four seasons.
					-- same as "springsummerautumnwinter", "".
					-- ""; if no season keyword is given, consider it as four seasons.
					-- Don't be confused. This is only just cover FOUR SEASONS.
				--},  

				--["day"] = { },
				--["dusk"] = { },
				--["night"] = { },
				--["anytime"] = { 
					-- same as "daydusknight"
					-- if no season keyword is given, consider it anytime(day + dusk + night).
				--},
				
				--["newspawn"] = { 
					-- if neither this keyword nor other condition below is given, consider it exist.
					-- For example, "day" is same as "daynewspawn".
					-- "dayrespawn" is not same as "dayrespawnnewspawn"
					
				--},

				-- [""] = { } -- same as "anytimealwaysnewspawn"
				--------------------------------------------------------------------------------------
				
				["respawnnight"] = { 
					-- when the character is resurrected(including touchstone, but not telltale heart or life giving amulet.) and it's night.
					"torch", "sanity", 30 
					-- you can give the specific amount of stats.
					
					-- same as "respawnalways", "portaltouchstoneeffigy", "portaltouchstoneeffigyalways"
				},
				-- ["portal"] -- only when the character is ressurected by Florid Postern (multiplayer portal)
				-- ["touchstone"] = { } -- ~ by Touchstone
				-- ["effigy"] = { } -- ~ by Meat Effigy
				
				-- ["revived"] = { } -- when the character is revived by something else.
				-- ["heart"] -- only when the character is revived by telltale heart.
				-- ["amulet"] -- ~ by life giving amulet
				-- ["debug"] = { } -- ~ via console or by other method.
				
				-- ["change"] = { }, -- when you change character with Moon Rock Idol.
				
				-- ["respawnrevivedspringsummer"] = {} -- you can combine multiple options. and keyword order is not important.
			},

			["wilson"] = {
				[""] = {"beardhair", 4} -- gives 4 beards when first spawn.
			},
			-- ["yakumoyukari"] = { [""] = {"humanmeat", 4, "schemetool"} }, 
			-- also supports mod characters and mod items(but you have to put prefab(console) name).
		},
	},
}