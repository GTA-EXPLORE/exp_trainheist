
---@param model any Model Hash
function _RequestModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(50) end
end

---@param heading number
function GetForwardVectorFromHeading(heading)
    local radians = math.rad(heading)
    local x = math.sin(radians)
    local y = math.cos(radians)
    return vector2(x, y)
end

---@param fxName string
function _RequestNamedPtfxAsset(fxName)
    RequestNamedPtfxAsset(fxName)
    while not HasNamedPtfxAssetLoaded(fxName) do Wait(50) end
end

---@param dict string
function _RequestAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(50) end
end

---@param orig table
---@return table
function DeepCopy(orig)
    local copy
    if type(orig) == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

---@param center vector3
---@param radius number
---@return vector3
function GetRandomPositionInCircle(center, radius)
    local angle = math.rad(math.random(0, 360))
    local offsetX = (math.max(0.25, math.random()) * radius) * math.cos(angle)
    local offsetY = (math.max(0.25, math.random()) * radius) * math.sin(angle)

    local randomPosition = vector3(center.x + offsetX, center.y + offsetY, center.z)
    return randomPosition
end

---@param data table
function AddEntityMenuItem(data)
    if GetResourceState("ox_target") == "started" then
        exports.ox_target:addLocalEntity(data.entity, {
            label = data.desc,
            event = data.event,
            icon = data.icon,
            distance = 1.5
        })
    end

    if GetResourceState("qb-target") == "started" then
        exports["qb-target"]:AddTargetEntity(data.entity, {
            options = {
                {
                    label = data.desc,
                    event = data.event,
                    icon = data.icon,
                }
            },
            distance = 1.5
        })
    end
end

---@param data table
function RemoveEntityMenuItem(data)
    if GetResourceState("exp_target_menu") == "started" then
        exports.exp_target_menu:RemoveEntityMenuItem({
            entity = data.entity,
            event = data.event
        })
    end

    if GetResourceState("ox_target") == "started" then
        exports.ox_target:removeLocalEntity(data.entity, data.event)
    end
end


function SpawnNPC(model, position, heading)
	model = GetHashKey(model)
	RequestModel(model)
    while not HasModelLoaded(model) do Wait(50) end
	local npc = CreatePed(4, model, position, heading, false, true)
	SetEntityHeading(npc, heading)
	return npc
end

---@param name string
---@param coords vector3
---@param sprite integer
---@param color integer
---@param scale number 
---@return number Blip Blip Handle
function SetBlip(name, coords, sprite, color, scale)
	local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

	SetBlipSprite(blip, sprite)
	SetBlipDisplay(blip, 4)
	SetBlipColour(blip, color)
	SetBlipScale(blip, scale or 1.0)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(name)
	EndTextCommandSetBlipName(blip)
    return blip
end

function IsSpawnPointClear(coords)
	return #EnumerateEntitiesWithinDistance(GetVehicles(), false, coords, 1.0) == 0
end

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for k,entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if distance <= maxDistance then
			table.insert(nearbyEntities, isPlayerEntities and k or entity)
		end
	end

	return nearbyEntities
end

function GetVehicles()
	return GetGamePool('CVehicle')
end