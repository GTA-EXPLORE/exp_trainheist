if GetResourceState("qb-core") == "started" then
    print("^5Starting with QB-Core^0")

    QBCore = exports['qb-core']:GetCoreObject()
    
    if BREAK_ITEM == "grinder" then
        QBCore.Functions.AddItem("grinder", {
            name = "grinder",
            label = _("grinder_label"),
            weight = 10,
            type = 'item',
            image = 'grinder.png',
            unique = false,
            useable = false,
            shouldClose = false,
            combinable = nil,
            description = _("grinder_desc")
        })
    end

    QBCore.Functions.AddItem(LOOT.item, {
        name = LOOT.item,
        label = _("loot_item_label"),
        weight = 1,
        type = 'item',
        image = LOOT.item..'.png',
        unique = false,
        useable = false,
        shouldClose = false,
        combinable = nil,
        description = _("loot_item_desc")
    })

    function GetPoliceCount()
        local count = 0
        for ServerId, Player in ipairs(QBCore.Functions.GetQBPlayers()) do
            if Player.PlayerData.job.name == "police" then
                count = count + 1
            end
        end
        return count
    end
    
    function DiscordLog(player_src, event)
        -- Complete
    end
    
    RegisterNetEvent("exp_trainheist:SendPoliceAlert", function(coords)
        for ServerId, Player in ipairs(QBCore.Functions.GetQBPlayers()) do
            if Player.PlayerData.job.name == "police" then
                TriggerClientEvent("exp_bank_robbery:ShowPoliceAlert", ServerId, coords)
            end
        end
    end)
    
    ---@param source any Server id
    ---@param item string Item name
    ---@param amount number Amount of item to have
    function DoesPlayerHaveItem(source, item, amount)
        local player_item = QBCore.Functions.GetPlayer(source).Functions.GetItemByName(item)
        return player_item and player_item.amount >= amount or false
    end
    
    ---@param source any Server id
    ---@param item string Item name
    ---@param amount number Amount to add
    function AddPlayerItem(source, item, amount)
        QBCore.Functions.GetPlayer(source).Functions.AddItem(item, amount)
        return true
    end
    
    ---@param source any Server id
    ---@param item string Item name
    ---@return number count Item count
    function GetPlayerItemCount(source, item)
        local player_item = QBCore.Functions.GetPlayer(source).Functions.GetItemByName(item)
        return player_item and player_item.amount or 0
    end
    
    ---@param source any Server id
    ---@param item string Item name
    ---@param amount number Amount to remove
    function RemovePlayerItem(source, item, amount)
        QBCore.Functions.GetPlayer(source).Functions.RemoveItem(item, amount)
        return true
    end
    
    ---@param source any Server id
    ---@param amount any Blackmoney amount
    function AddPlayerBlackMoney(source, amount)        
        QBCore.Functions.GetPlayer(source).Functions.AddMoney("cash", amount)
        return true
    end

    ---@param source any Server id
    ---@param item string Item name
    ---@param amount integer Item Amount
    ---@return boolean
    function CanPlayerCarryItem(source, item, amount)
        local Player = QBCore.Functions.GetPlayer(source)
        local totalWeight = QBCore.Player.GetTotalWeight(Player.PlayerData.items)
        local itemInfo = QBCore.Shared.Items[item]
        return (totalWeight + (itemInfo.weight * amount)) <= (QB_MAX_WEIGHT)
    end
end