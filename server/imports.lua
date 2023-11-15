local ServerCallbacks = {}

function RegisterServerCallback(name, cb)
	ServerCallbacks[name] = cb
end

function TriggerServerCallback(name, requestId, source, cb, ...)
	if ServerCallbacks[name] then
		ServerCallbacks[name](source, cb, ...)
	else
		print(('[^3WARNING^7] Server callback ^5"%s"^0 does not exist. ^1Please Check The Server File for Errors!'):format(name))
	end
end

RegisterServerEvent('exp_trainheist:triggerServerCallback')
AddEventHandler('exp_trainheist:triggerServerCallback', function(name, requestId, ...)
	local playerId = source

	TriggerServerCallback(name, requestId, playerId, function(...)
		TriggerClientEvent('exp_trainheist:serverCallback', playerId, requestId, ...)
	end, ...)
end)