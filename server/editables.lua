ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)

function GetPoliceCount()
    local players = ESX.GetPlayers()
    local count = 0

    for i = 1, #players do
        local player = ESX.GetPlayerFromId(players[i])
        if player.job.name == 'lspd' then
            count = count + 1
        end
    end

    return count
end

function DiscordLog(player_src, event)
    -- Complete
end

RegisterNetEvent("exp_trainheist:SendPoliceAlert", function(coords)
    for _, server_id in ipairs(ESX.GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(server_id)
        if xPlayer.getJob().name == "lspd" then
            xPlayer.triggerEvent("exp_bank_robbery:ShowPoliceAlert", coords)
        end
    end
end)