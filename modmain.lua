PrefabFiles = { }

local assert = GLOBAL.assert
local require = GLOBAL.require
local tonumber = GLOBAL.tonumber
local Prefabs = GLOBAL.Prefabs
local KnownModIndex = GLOBAL.KnownModIndex
local SpawnPrefab = GLOBAL.SpawnPrefab
local modname = KnownModIndex:GetModActualName("Starting Item Tuner")

local ShouldOverrideVanilla = GetModConfigData("ShouldOverrideVanila", modname)
local ShouldOverrideMod = GetModConfigData("ShouldOverrideMod", modname)

local raw = require("data")
GLOBAL.SIT_DATA = {}
GLOBAL.SIT_EVENTS = {}
-- Validate execution keys
for k, v in pairs(raw) do
	local _data = {}
	for k2, v2 in pairs(v) do
		local data = {}
		local dindex, rindex = 1, 1
		repeat
			local c1 = tonumber(raw[k][k2][rindex]) == nil
			local c2 = tonumber(raw[k][k2][rindex+1]) == nil
			if rindex == 1 and not c1 then
				print("wrong data at "..k.."."..k2.." #"..rindex..", first key should not be numeric.")
				rindex = rindex + 1
			elseif c1 and c2 then
				data[dindex] = raw[k][k2][rindex]
				data[dindex+1] = 1
				rindex = rindex + 1
				dindex = dindex + 2
			elseif c1 and not c2 then
				data[dindex] = raw[k][k2][rindex]
				data[dindex+1] = raw[k][k2][rindex+1]
				rindex = rindex + 2
				dindex = dindex + 2
			else
				print("wrong data at #"..rindex..", numeric data was given two times in a row.")
				rindex = rindex + 1
			end
		until rindex > #raw[k][k2]

		_data[k2] = data
	end
	GLOBAL.SIT_DATA[k] = _data
end

local _KEYWORDS = {
	time = { "anytime", "day", "dusk", "night" },
	season = { "always", "spring", "summer", "autumn", "winter" },
	respawn = { "respawn", "portal", "touchstone", "effigy" }, 
	revived = { "revived", "heart", "amulet", "debug" },

	other = { "change", "cave" }, -- do not check whether overlaps
}

local WORDTAGS = { "cave" }
for k, t in pairs(_KEYWORDS) do
	if k == "time" or k == "season" then
		for i, v in ipairs(t) do
			table.insert(WORDTAGS, v)
		end
	end
end

local function GetFirstKey(list, tag)
	for i, v in ipairs(list) do
		if v:find(tag) then return v end
	end
end

local function HasKey(list, tag)
	if type(list) == "table" then
		return GetFirstKey(list, tag) ~= nil
	else
		return string.find(list, tag) ~= nil
	end
end

local function RemoveKey(list, tag)
	for i, v in ipairs(list) do
		if v:find(tag) then table.remove(list, i) end
	end
end

local function AddKey(list, tag)
	table.insert(list, tag)
end

local function DeleteOverlaps(list)
	for i, v in ipairs(list) do
		local tofind = list[i]
		for j = i + 1, #list do
			if list[j] == tofind then
				table.remove(list, i)
			end
		end
	end
end

local function GetWorldTags(tags)
	local result = {}
	local serialized = table.concat(tags)
	for i, tag in ipairs(WORDTAGS) do
		if HasKey(serialized, tag) then
			table.insert(result, tag)
		end
	end
	
	if #result == 0 then
		return nil
	else
		return result
	end
end

local function RegisterEvent(name, data, tags)
	local Event = {}
	Event.id = #GLOBAL.SIT_EVENTS + 1
	Event.doer = name
	Event.tags = tags
	Event.data = data
	Event.worldtags = GetWorldTags(tags)
	Event.fn = function(inst)
		if CheckWorldState(Event.id) then
			Excute(inst, Event.data)
		end
	end

	table.insert(GLOBAL.SIT_EVENTS, Event)
end
-- Register Events
for name, conditions in pairs(GLOBAL.SIT_DATA) do
	for condition, data in pairs(conditions) do
		local keyraw = condition
		local leftover = keyraw
		local tags = {}

		for sort, keys in pairs(_KEYWORDS) do
			for _, key in ipairs(keys) do -- find keys in raw condition keys written in modinfo.
				local i, j = string.find(leftover, key)

				if i ~= nil and j ~= nil then
					local tag = string.sub(leftover, i, j)
					table.insert(tags, tag)

					leftover = leftover:gsub(tag, "")
				end
			end
			-- create tags
			if sort ~= "other" and HasKey(tags, keys[1]) then -- "anytime", "always", ...
				RemoveKey(tags, keys[1])
				for i = 2, #keys do
					AddKey(tags, keys[i])
				end
				DeleteOverlaps(tags)
			end
		end

		if leftover ~= "" then
			print("[Starting Item Tuner] Unkown condition key \""..leftover.."\" in \""..keyraw.."\" in "..(name == "AllPlayers" and "AllPlayers" or "character "..name))
		end

		RegisterEvent(name, data, tags)
	end
end
	
local function HasKeyInEvent(inst, tags)
	-- it's quite brute-forcy right now. I have no idea how to handle events with tag.
	local result = {}
	for i, v in ipairs(GLOBAL.SIT_EVENTS) do
		local raw = table.concat(v.tags)
		if HasKey(tags, v2) then
			table.insert(result, v.id)
		end
	end

	if #result == 0 then
		return nil
	else
		return result
	end
end

local function OnEventListen(inst, tags)
	local id = HasKeyInEvent(inst, tags)
	if id ~= nil then
		for i, v in ipairs(id) do
			local EventDoer = GLOBAL.SIT_EVENTS[v].doer
			if EventDoer == "AllPlayers" or inst.prefab == EventDoer then
				GLOBAL.SIT_EVENTS[v].fn(inst)
			end
		end
	end
end

local function CheckWorldState(id)
	local TheWorld = GLOBAL.TheWorld
	if TheWorld == nil then return false end

	local worldtags = GLOBAL.SIT_EVENTS[id].worldtags
	if worldtags == nil then return true end
	
	local shouldtrigger = true
	local raw = table.concat(GLOBAL.SIT_EVENTS[id].tags)
	local HasKey = function(tag) -- Optimization.
		return string.find(raw, tag) ~= nil
	end
	
	if HasKey("spring") or HasKey("summer") or HasKey("autumn") or HasKey("winter") then -- check if season tags exist. otherwise, true.
		shouldtrigger = HasKey(TheWorld.state.season)
	end

	if HasKey("day") or HasKey("dusk") or HasKey("night") then
		shouldtrigger = shouldtrigger and HasKey(TheWorld.state.phase) -- need test in cave since it does have cavephase.
	end

	if HasKey("cave") then
		shouldtrigger = shouldtrigger and TheWorld:HasTag("cave")
	end

	return shouldtrigger
end

local STATKEY = { 
	"health", "hunger", "sanity", "power", "moisture"
	-- TODO : "grogginess", "debuff"
}
local function InsertToDataTable(data, t, i)
	table.insert(data, t[i])
	table.insert(data, t[i+1]) -- amount
end
local function Dataize(data)
	local stats = {}
	local recipes = {}
	local prefabs = {}

	for i, v in ipairs(data) do
		if HasKey(STATKEY, v) then
			InsertToDataTable(stats, data, i)
		end

		if v:find("*") ~= nil then
			InsertToDataTable(recipes, data, i)
		else
			InsertToDataTable(prefabs, data, i)
		end
	end

	return stats, recipes, prefabs
end

local function Excute(inst, data)
	local stats, recipes, prefabs = Dataize(data)
	
	for i = 1, #stats, 2 do
		if inst.components[stats[i]] ~= nil then
			inst.components[stats[i]]:DoDelta(stats[i+1])
		end
	end

	if inst.components.builder ~= nil then
		for i = 1, #recipes, 2 do
			inst.components.builder:UnlockRecipe(recipes[i])
		end
	end

	if inst.components.inventory ~= nil then
		inst.components.inventory.ignoresound = true
		for i = 1, #prefabs, 2 do
			local prefab_val = SpawnPrefab(prefabs[i])
			if prefab_val == nil then
				print("unkown prefab "..prefabs[i])
			else
				prefab_val:Remove()

				for numtogive = 1, prefabs[i+1] do
					local prefab = SpawnPrefab(prefabs[i])
					if prefab.components.equippable ~= nil then
						local eslot = prefab.components.equippable.equipslot
						if inst.components.inventory.equipslots[eslot] == nil then
							inst.components.inventory:Equip(prefab)
						else
							inst.components.inventory:GiveItem(prefab)
						end
					end
				end
			end
		end
		inst.components.inventory.ignoresound = false
	end
end