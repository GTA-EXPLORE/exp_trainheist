IsHeistActive = false

RegisterServerCallback('exp_trainheist:CanPlayerStartHeist', function(source, cb)
    if IsHeistActive then
        cb({
            time = false,
            cops = GetPoliceCount() >= POLICE_REQUIRED
        })
        return
    end
    
    cb({
        time = true,
        cops = GetPoliceCount() >= POLICE_REQUIRED
    })
    DiscordLog(_source, {
        name = "start"
    })
    IsHeistActive = true

    Wait(ROBBERY_INTERVAL)

    IsHeistActive = false
    DiscordLog(_source, {
        name = "reset"
    })
    TriggerClientEvent("exp_trainheist:ResetAndWipe", -1)
end)

RegisterServerCallback('exp_trainheist:HasItem', function(source, cb, item)
    cb(DoesPlayerHaveItem(source, item, 1))
end)

RegisterNetEvent('exp_trainheist:GiveGold', function()
    local _source = source
    AddPlayerItem(_source, LOOT.item, LOOT.stack)
end)

RegisterNetEvent('exp_trainheist:DeliverGold', function()
    local _source = source

    local count = GetPlayerItemCount(_source, LOOT.item)
    if count > 0 then
        RemovePlayerItem(source, LOOT.item, count)
        AddPlayerBlackMoney(source, LOOT.price * count)

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

RegisterNetEvent('exp_trainheist:SynchronizeContainer', function(data)
    TriggerClientEvent('exp_trainheist:SynchronizeContainer', -1, data)
end)

RegisterNetEvent('exp_trainheist:SynchronizeEntity', function(entity)
    TriggerClientEvent('exp_trainheist:SynchronizeEntity', -1, entity)
end)

RegisterServerCallback("exp_trainheist:CanCarryGold", function(source, callback)
    callback(CanPlayerCarryItem(source, LOOT.item, LOOT.stack))
end)

RegisterNetEvent("exp_trainheist:CreateHitbox", function (data)
    TriggerClientEvent("exp_trainheist:CreateHitbox", -1, data)
end)

RegisterNetEvent("exp_trainheist:RemoveHitbox", function (data)
    TriggerClientEvent("exp_trainheist:RemoveHitbox", -1, data)
end)