PrefabFiles = { }

local assert = GLOBAL.assert
local Prefabs = GLOBAL.Prefabs
local KnownModIndex = GLOBAL.KnownModIndex
local modname = KnownModIndex:GetModActualName("Ztarting Item Tuner")

GLOBAL.STARTING_ITEM_TUNER_MODNAME = modname
local function GetModDefaultConfigData(optionname, modname)
	local config = KnownModIndex.savedata.known_mods[modname].modinfo.configuration_options
	if config and type(config) == "table" then
		for i,v in pairs(config) do
			if v.name == optionname then
				return v.default
			end
		end
	end
end

GLOBAL.STARTINGITEMS = GetModDefaultConfigData("datatable", modname)
local ShouldOverrideVanilla = GetModDefaultConfigData("ShouldOverrideVanila", modname)
local ShouldOverrideMod = GetModDefaultConfigData("ShouldOverrideMod", modname)

local CharacterList = {}
for k, v in pairs(GLOBAL.STARTINGITEMS) do
	table.insert(CharacterList, k)
end

local AllPlayers = {}
local Characters = {}
for _, charname in pairs(CharacterList) do
	if charname ~= "AllPlayers" then
		table.insert(AllPlayers, k)
	else
		table.insert(Characters, k)
	end
end

local data = {}
local function Dataization()
	
end


GLOBAL.SIT_EVENTS = {
	{ "_nullevent" } -- Lua is not zero-indexed but #table's index starts from 0. I have to put this because I want Event.id to start from 1.
}

local keywords = {
	time = { "anytime", "day", "dusk", "night" },
	season = { "always", "spring", "summer", "autumn", "winter" },
	respawn = { "respawn", "portal", "touchstone", "effigy" }, 
	revived = { "revived", "heart", "amulet", "debug" },

	other = { "change" }, -- do not check whether overlaps
}

local function DeserializeKeywords(key)
	local keysfound = {}
	local keywordsraw = {}
	for k, v in pairs(keywords) do
		for k2, v2 in pairs(v) do
			table.insert(keywordsraw, v2)
		end
	end

	for i, v in ipairs(keywordsraw) do
		local i1, i2 = string.find(tofind, v)

		if i1 ~= nil and i2 ~= nil then
			local key = string.sub(tofind, i1, i2)
			table.insert(keysfound, key)

			tofind = tofind:gsub(key, "")
		end
	end

	if tofind ~= "" then
		print("[Starting Item Tuner] Unkown keyword "..tofind) -- This needs to be improved because it just return the leftover text...
	end

end

local function GetWorldTags(tags)
	local result = {}
	for k, v in pairs(keywordsrawworld) do
		for k2, v2 in pairs(tags) do
			if v == v2 then
				table.insert(result, v2)
			end
		end
	end

	result = #result == 0 and nil or result

	return result
end

local function CheckWorldState(id)
	local TheWorld = GLOBAL.TheWorld
	if TheWorld == nil then return false end

	local worldtags = GLOBAL.SIT_EVENTS[id].worldtags
	if worldtags == nil then return true end
	
	local shouldtrigger = true
	local raw = table.concat(GLOBAL.SIT_EVENTS[id].tags)
	local HasTag = function(tag) -- Just for optimization.
		return string.find(raw, tag) ~= nil
	end
	
	if HasTag("spring") or HasTag("summer") or HasTag("autumn") or HasTag("winter") then -- check if season tags exist. otherwise, true.
		shouldtrigger = HasTag(TheWorld.state.season)
	end

	if HasTag("day") or HasTag("dusk") or HasTag("night") then
		shouldtrigger = shouldtrigger and HasTag(TheWorld.state.phase) -- need test in cave since it does have cavephase.
	end

	return shouldtrigger
end

local function RegisterEvent(inst, _fn, ...)
	local Event = {}
	Event.id = #GLOBAL.SIT_EVENTS
	Event.doer = inst.prefab
	Event.tags = {...}
	Event.worldtags = GetWorldTags({...})
	Event.fn = function(inst, id)
		if CheckWorldState(id) then
			_fn(inst)
		end
	end

	table.insert(GLOBAL.SIT_EVENTS, Event)
end

local function HasTagInEvent(inst, ...)
	-- it's quite brute-forcy right now. I have no idea how to handle events with tag.
	local result = {}
	for i, v in ipairs(GLOBAL.SIT_EVENTS) do
		local raw = table.concat(v.tags)
		for i2, v2 in ipairs({...}) do
			if string.find(raw, v2) ~= nil then
				table.insert(result, v.id)
			end
		end
	end

	result = #result == 0 and nil or result
	return result
end

local function OnEventListen(inst, ...)
	local id = HasTagInEvent(inst, ...)
	if id ~= nil then
		for i, v in ipairs(id) do
			GLOBAL.SIT_EVENTS[id].fn(inst, id) -- TODO?
		end
	end
end