local ServerCallbacks, CurrentRequestId = {}, 0

function TriggerServerCallback(name, cb, ...)
	ServerCallbacks[CurrentRequestId] = cb

	TriggerServerEvent('exp_trainheist:triggerServerCallback', name, CurrentRequestId, ...)

	if CurrentRequestId < 65535 then
		CurrentRequestId = CurrentRequestId + 1
	else
		CurrentRequestId = 0
	end
end

RegisterNetEvent('exp_trainheist:serverCallback')
AddEventHandler('exp_trainheist:serverCallback', function(requestId, ...)
	ServerCallbacks[requestId](...)
	ServerCallbacks[requestId] = nil
end)

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