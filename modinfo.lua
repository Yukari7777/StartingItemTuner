name = "Ultimate Starting Item Tuner"
description = "Let you set starting items you want. Ultimately."
author = "Yakumo Yukari"
version = "1.0.1"
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

local text = "Please read descriptions in \n(DST install folder)/"..folder_name.."/modinfo.lua."
local on_off = {
	{ description = "true", data = true },
	{ description = "false", data = false },
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
		description = "Same with the above, but it's only for mod characters.",
		options = on_off,
		default = false,
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