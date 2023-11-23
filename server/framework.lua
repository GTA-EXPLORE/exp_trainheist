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

---@param source any Server id
---@param item string Item name
---@param amount number Amount of item to have
function DoesPlayerHaveItem(source, item, amount)
    return ESX.GetPlayerFromId(source).getInventoryItem(item).count >= amount
end

---@param source any Server id
---@param item string Item name
---@param amount number Amount to add
function AddPlayerItem(source, item, amount)
    ESX.GetPlayerFromId(source).addInventoryItem(item, amount)
    return true
end

---@param source any Server id
---@param item string Item name
---@return number count Item count
function GetPlayerItemCount(source, item)
    return ESX.GetPlayerFromId(source).getInventoryItem(item).count
end

---@param source any Server id
---@param item string Item name
---@param amount number Amount to remove
function RemovePlayerItem(source, item, amount)
    ESX.GetPlayerFromId(source).removeInventoryItem(item, amount)
    return true
end

---@param source any Server id
---@param amount any Blackmoney amount
function AddPlayerBlackMoney(source, amount)
    ESX.GetPlayerFromId(source).addAccountMoney("black_money", amount)
    return true
end