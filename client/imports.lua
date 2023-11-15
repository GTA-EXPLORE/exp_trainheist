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

function SetBlip(pName, pCoords, pSprite, pColor, pScale)
	local blip = AddBlipForCoord(pCoords.x, pCoords.y, pCoords.z)

	SetBlipSprite(blip, pSprite)
	SetBlipDisplay(blip, 4)
	SetBlipColour(blip, pColor)
	SetBlipScale(blip, pScale or 1.0)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName(pName)
	EndTextCommandSetBlipName(blip)
    return blip
end