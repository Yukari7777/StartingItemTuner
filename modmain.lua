PrefabFiles = { }

local assert = GLOBAL.assert
local require = GLOBAL.require
local tonumber = GLOBAL.tonumber
local Prefabs = GLOBAL.Prefabs
local KnownModIndex = GLOBAL.KnownModIndex
local SpawnPrefab = GLOBAL.SpawnPrefab
local ShouldOverrideVanilla = GetModConfigData("ShouldOverrideVanila")
local ShouldOverrideMod = GetModConfigData("ShouldOverrideMod")

modimport "datatest.lua"
GLOBAL.SIT_DATA = {}
GLOBAL.SIT_EVENTS = {}
-- Validate execution keys
for k, v in pairs(GLOBAL.SIT_DATA_RAW) do
	local _data = {}
	for k2, v2 in pairs(v) do
		local data = {}
		local dindex, rindex = 1, 1
		repeat
			local c1 = tonumber(GLOBAL.SIT_DATA_RAW[k][k2][rindex]) == nil
			local c2 = tonumber(GLOBAL.SIT_DATA_RAW[k][k2][rindex+1]) == nil
			if rindex == 1 and not c1 then
				print("[Starting Item Tuner] wrong data at "..k.."."..k2.." #"..rindex..", first key should not be numeric.")
				rindex = rindex + 1
			elseif c1 and c2 then
				data[dindex] = GLOBAL.SIT_DATA_RAW[k][k2][rindex]
				data[dindex+1] = 1
				rindex = rindex + 1
				dindex = dindex + 2
			elseif c1 and not c2 then
				data[dindex] = GLOBAL.SIT_DATA_RAW[k][k2][rindex]
				data[dindex+1] = GLOBAL.SIT_DATA_RAW[k][k2][rindex+1]
				rindex = rindex + 2
				dindex = dindex + 2
			else
				print("[Starting Item Tuner] wrong data at #"..rindex..", numeric data was given two times in a row.")
				rindex = rindex + 1
			end
		until rindex > #GLOBAL.SIT_DATA_RAW[k][k2]

		_data[k2] = data
	end
	GLOBAL.SIT_DATA[k] = _data
end

local _KEYWORDS = {
	time = { "anytime", "day", "dusk", "night" },
	season = { "always", "spring", "summer", "autumn", "winter" },

	respawn = { "respawn", "portal", "touchstone", "effigy", "newspawn" }, 
	revived = { "revived", "heart", "amulet", "debug", "other" },

	other = { "change", "cave" }, -- do not check whether overlaps
}

local WORDTAGS = { "cave" } -- TODO : nightmare phase
for k, t in pairs(_KEYWORDS) do
	if k == "time" or k == "season" then
		for i, v in ipairs(t) do
			table.insert(WORDTAGS, v)
		end
	end
end

local function FindFirstKeyIndex(list, tag)
	for i, v in ipairs(list) do
		if v:find(tag) then return i end
	end
end

local function HasKey(list, tag)
	if list == nil then return end
	if type(list) == "table" then
		return table.contains(list, tag) -- There's an env in don't starve api.
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

local function CheckWorldState(wtags)
	if wtags == nil then return true end
		
	local TheWorld = GLOBAL.TheWorld
	if TheWorld == nil then return false end
	
	local raw = table.concat(wtags)
	local HasKey = function(k) -- Optimization.
		return string.find(raw, k) ~= nil
	end

	local shouldtrigger = true
	
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

	for i = 1, #data, 2 do
		if HasKey(STATKEY, data[i]) then
			InsertToDataTable(stats, data, i)
		else
			if data[i]:find("*") ~= nil then
				InsertToDataTable(recipes, data, i)
			else
				InsertToDataTable(prefabs, data, i)
			end
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
	
	local builder = inst.components.builder
	if builder ~= nil then
		for i = 1, #recipes, 2 do
			local unlock = recipes[i]:sub(2)
			if unlock == "ALL" then 
				for i, v in ipairs(require("techtree").AVAILABLE_TECH) do 
					builder:UnlockRecipesForTech(v)
				end
			elseif unlock == "CREATIVE" then
				if not builder.freebuildmode then
					builder:GiveAllRecipes()
				end
			elseif unlock == unlock:match("%u*") then
				-- consider as a techtree name if it's all uppercase. https://repl.it/@HimekaidouHatat/Is-Uppercase
				builder:UnlockRecipesForTech({[unlock] = recipes[i+1]})
			else
				inst.components.builder:UnlockRecipe(unlock)
			end
		end
	end

	if inst.components.inventory ~= nil then
		inst.components.inventory.ignoresound = true
		for i = 1, #prefabs, 2 do
			local prefab_val = SpawnPrefab(prefabs[i])
			if prefab_val == nil then
				print("[Starting Item Tuner] unkown prefab "..prefabs[i])
			else
				prefab_val:Remove()

				for numtogive = 1, prefabs[i+1] do
					local prefab = SpawnPrefab(prefabs[i])
					if prefab.components.equippable ~= nil and inst.components.inventory.equipslots[prefab.components.equippable.equipslot] == nil then
						inst.components.inventory:Equip(prefab)
					else
						inst.components.inventory:GiveItem(prefab)
					end
				end
			end
		end
		inst.components.inventory.ignoresound = false
	end
end

local function RegisterEvent(name, data, tags)
	local Event = {}
	Event.id = #GLOBAL.SIT_EVENTS + 1
	Event.doer = name
	Event.tags = tags
	Event.wtags = GetWorldTags(tags)
	Event.data = data
	Event.fn = function(inst)
		if CheckWorldState(Event.wtags) then
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
		local ShouldAddNewspawnTag = true
		local tags = {}

		for sort, keys in pairs(_KEYWORDS) do
			for index, key in ipairs(keys) do -- find keys in raw condition keys written in modinfo.
				local i, j = string.find(leftover, key)

				if i ~= nil and j ~= nil then
					local tag = string.sub(leftover, i, j)
					table.insert(tags, tag)
					print(tag)

					leftover = leftover:gsub(tag, "")
				end
				
				if ShouldAddNewspawnTag and ((sort == "respawn" or sort == "revived") and HasKey(tags, key) or HasKey(tags, "newspawn")) then
					ShouldAddNewspawnTag = false
				end
			end

			if sort ~= "other" and HasKey(tags, keys[1]) then -- "anytime", "always", ...
				RemoveKey(tags, keys[1])
				for i = 2, #keys do
					AddKey(tags, keys[i])
				end
			end

			DeleteOverlaps(tags)
		end

		if ShouldAddNewspawnTag then
			print("ShouldAddNewspawnTag")
			AddKey(tags, "newspawn")
		end

		if leftover ~= "" then
			print("[Starting Item Tuner] unkown condition keyword \""..leftover.."\" in key \""..keyraw.."\" in "..(name == "AllPlayers" and "AllPlayers" or "character "..name))
		end

		RegisterEvent(name, data, tags)
	end
end

local function GetIdsInEvent(inst, tags)
	-- it's quite brute-forcy right now. I have no idea how to handle events with tag.
	local result = {}
	for i, v in ipairs(GLOBAL.SIT_EVENTS) do
		local raw = table.concat(v.tags)
		for k, v2 in pairs(tags) do
			if HasKey(raw, v2) then
				table.insert(result, v.id)
			end
		end
	end
		
	if #result == 0 then
		return nil
	else
		return result
	end
end

local function IsValidDoer(inst, key)
	return key == "AllPlayers" or (key == "admin" and inst.Network:IsServerAdmin()) or inst.prefab == key
end

local function PushEvent(inst, ...)
	local tags = {...}
	local ids = GetIdsInEvent(inst, tags)
	if ids ~= nil then
		for i, id in ipairs(ids) do
			local doer = GLOBAL.SIT_EVENTS[id].doer
			if IsValidDoer(inst, doer) then
				GLOBAL.SIT_EVENTS[id].fn(inst)
			end
		end
	end
end

GLOBAL.SITPushEvent = PushEvent

local exnewspawn = {
	"reviver", "heart", "amulet", "amulet", "resurrectionstone", "touchstone", "resurrectionstatue", "effigy"
}

local function PushRespawnEvent(inst, data)
	if data == nil or data.source == nil then
		PushEvent(inst, "debug")
	elseif inst.sg.currentstate.name == "remoteresurrect" then
		PushEvent(inst, "remote")
	elseif data.source:HasTag("multiplayer_portal") then
		PushEvent(inst, "portal")
	else
		local index = FindFirstKeyIndex(exnewspawn, data.source.prefab)
		if index ~= nil then
			PushEvent(inst, exnewspawn[i+1])
		else
			PushEvent(inst, "other")
		end
	end
end

local function IsModCharacter(inst)
	return not table.contains(GLOBAL.DST_CHARACTERLIST, inst.prefab)
end

AddPlayerPostInit(function(inst)
	local _OnNewSpawn = inst.OnNewSpawn
	inst.OnNewSpawn = function(inst)
		if IsModCharacter(inst) then
			inst.starting_inventory = ShouldOverrideMod and {} or inst.starting_inventory
		else
			inst.starting_inventory = ShouldOverrideVanilla and {} or inst.starting_inventory
		end

		PushEvent(inst, "newspawn")
		inst.starting_inventory = nil
		_OnNewSpawn(inst)
	end

	local _LoadForReroll = inst.LoadForReroll 
	inst.LoadForReroll = function(inst)
		_LoadForReroll(inst)
		PushEvent(inst, "change")
	end

	inst:ListenForEvent("respawnfromghost", PushRespawnEvent)
end)