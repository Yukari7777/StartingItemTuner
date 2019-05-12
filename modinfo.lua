name = "Ultimate Starting Item Tuner"
description = "Let you set starting items you want. Ultimately."
author = "Yakumo Yukari"
version = "1.1"
forumthread = ""
api_version = 6
api_version_dst = 10
dst_compatible = true
dont_starve_compatible = false
reign_of_giants_compatible = false
all_clients_require_mod = true 
icon_atlas = "modicon.xml"
icon = "modicon.tex"
server_filter_tags = {"startingitems"}
folder_name = folder_name or ""

if not folder_name:find("workshop-") then
    name = "UST - Test"
end

local text = "Please read descriptions in \n(DST install folder)/"..folder_name.."/modinfo.lua."
local on_off = {
	{ description = "false", data = false },
	{ description = "true", data = true },
}

configuration_options = {
	{
		name = "ShouldOverrideVanila",
		hover = text,
		description = "If true, default starting items of vanila charachers will be removed and replaced."
					.."Otherwise, will be added to default starting items.",
		options = on_off,
		default = false,
	},
	{
		name = "ShouldOverrideMod",
		hover = text,
		description = "Same with the above, but it's applied only for mod characters.",
		options = on_off,
		default = false,
	},
	{
		name = "ForceLoadData",
		hover = text,
		description = "If both data.lua and modoverrides.lua data is written, modoverrides.lua's data overrides the data.lua's by default."
					.."Which means modoverrides.lua data is applied in that case."
					.."Forcibly set which one is to load.",
		options = {
			{ description = "default", data = 0 },
			{ description = "modoverrides.lua", data = 1 },
			{ description = "data.lua", data = 2 },
		},
		default = 0,
	},
	{
		name = "Data",
		description = "You have to add settings in data.lua in the mod folder."
					.."Or you can make modoverride config which has higher priority."
					.."If both data exist, modoverride's will be applied."
					.."read howto.txt to see description.",
		default = {},
	},
}