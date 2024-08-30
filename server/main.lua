SD.Locale.LoadLocale(LANGUAGE)
IsHeistActive = false

SD.Callback.Register('exp_trainheist:CanPlayerStartHeist', function(source)
    if IsHeistActive then
        return({
            time = false,
            cops = GetPoliceCount() >= POLICE_REQUIRED
        })
    end
    
    Citizen.CreateThread(function()
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
    return({
        time = true,
        cops = GetPoliceCount() >= POLICE_REQUIRED
    })
end)

SD.Callback.Register('exp_trainheist:HasItem', function(source, item)
    return(SD.Inventory.HasItem(source, item, 1))
end)

RegisterNetEvent('exp_trainheist:GiveGold', function()
    local _source = source
    SD.Inventory.AddItem(_source, LOOT.item, LOOT.stack)
end)

RegisterNetEvent('exp_trainheist:DeliverGold', function()
    local _source = source

    local count = SD.Inventory.HasItem(_source, LOOT.item)
    if count > 0 then
        SD.Inventory.RemoveItem(source, LOOT.item, count)
        SD.Money.AddMoney(source, MONEY_TYPE, LOOT.price * count)

        TriggerClientEvent("exp_trainheist:ShowNotification", _source, {
            message = SD.Locale.T("money_earned", LOOT.price * count),
            title = SD.Locale.T("notif_title"),
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

SD.Callback.Register("exp_trainheist:CanCarryGold", function(source)
    return true
end)

RegisterNetEvent("exp_trainheist:CreateHitbox", function (data)
    TriggerClientEvent("exp_trainheist:CreateHitbox", -1, data)
end)

RegisterNetEvent("exp_trainheist:RemoveHitbox", function (data)
    TriggerClientEvent("exp_trainheist:RemoveHitbox", -1, data)
end)