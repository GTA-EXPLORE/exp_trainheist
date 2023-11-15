local lastrob, start = os.time() - ROBBERY_INTERVAL, false

RegisterServerCallback('exp_trainheist:checkPoliceCount', function(source, cb)
    cb(GetPoliceCount() >= POLICE_REQUIRED)
end)

RegisterServerCallback('exp_trainheist:checkTime', function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if (os.time() - lastrob) < ROBBERY_INTERVAL then
        local remaining = math.floor(ROBBERY_INTERVAL - (os.time() - lastrob) / 60)
        TriggerClientEvent("exp_trainheist:ShowNotification", _source, {
            message = _("wait_nextrob", remaining),
            title = _("notif_title"),
            type = "error"
        })
        return
    end

    lastrob = os.time()
    start = true
    DiscordLog(_source, {
        name = "start"
    })
    cb()
end)

RegisterServerCallback('exp_trainheist:hasItem', function(source, cb, item)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    cb(xPlayer.getInventoryItem(item).count > 0)
end)

RegisterNetEvent('exp_trainheist:rewardItems', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    xPlayer.addInventoryItem(LOOT.item, LOOT.stack)
end)

RegisterNetEvent('exp_trainheist:sellRewardItems', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    local count = xPlayer.getInventoryItem(LOOT.item).count
    if count > 0 then
        xPlayer.removeInventoryItem(LOOT.item, count)
        xPlayer.addAccountMoney("black_money", LOOT.price * count)
        TriggerClientEvent("exp_trainheist:ShowNotification", _source, {
            message = _("money_earned", LOOT.price * count),
            title = _("notif_title"),
            type = "default"
        })
        DiscordLog(_source, {
            name = "End",
            earnings = LOOT.price * count
        })
    end
end)

RegisterNetEvent('exp_trainheist:containerSync', function(coords, rotation)
    TriggerClientEvent('exp_trainheist:containerSync', -1, coords, rotation)
end)

RegisterNetEvent('exp_trainheist:objectSync', function(e)
    TriggerClientEvent('exp_trainheist:objectSync', -1, e)
end)

RegisterNetEvent('exp_trainheist:trainLoop', function()
    TriggerClientEvent('exp_trainheist:trainLoop', -1)
end)

RegisterNetEvent('exp_trainheist:lockSync', function(index)
    TriggerClientEvent('exp_trainheist:lockSync', -1, index)
end)

RegisterNetEvent('exp_trainheist:grabSync', function(index, index2)
    TriggerClientEvent('exp_trainheist:grabSync', -1, index, index2)
end)

RegisterNetEvent('exp_trainheist:resetHeist', function()
    if not start then return end
    start = false
    TriggerClientEvent('exp_trainheist:resetHeist', -1)
end)

RegisterNetEvent("exp_trainheist:SpawnHitboxes", function()
    TriggerClientEvent("exp_trainheist:SpawnHitboxes", -1)
end)

RegisterNetEvent("exp_trainheist:RemoveHitbox", function(id)
    TriggerClientEvent("exp_trainheist:RemoveHitbox", -1, id)
end)

RegisterServerCallback("exp_trainheist:CanCarryGold", function(source, callback)
    local xPlayer = ESX.GetPlayerFromId(source)
    callback(xPlayer.canCarryItem(LOOT.item, LOOT.stack))
end)