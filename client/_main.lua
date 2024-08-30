SD.Locale.LoadLocale(LANGUAGE)
Entities, Hitboxes, StartNPC, HeistBlip, HitboxRegister, HasGold = {}, {}, nil, nil, {}, false

Citizen.CreateThread(function()
    StartNPC = SpawnNPC(START_SCENE.ped.model, START_SCENE.ped.coords, START_SCENE.ped.heading)
    FreezeEntityPosition(StartNPC, true)
    SetEntityInvincible(StartNPC, true)
    SetBlockingOfNonTemporaryEvents(StartNPC, true)
    TaskStartScenarioInPlace(StartNPC, "WORLD_HUMAN_SMOKING", 0, true)
    AddEntityMenuItem({
        entity = StartNPC,
        event = "exp_trainheist:StartHeist",
        name = SD.Locale.T("start_npc_name"),
        desc = SD.Locale.T("start_npc_desc"),
        icon = "fas fa-sack-dollar"
    })
end)


function StartTrainHeist()
    SD.Callback('exp_trainheist:CanPlayerStartHeist', false, function(data)
        if not data.time then
            ShowNotification({
                message = SD.Locale.T("wait_nextrob"),
                title = SD.Locale.T("notif_title"),
                type = "error"
            })
            return
        end

        if not data.cops then
            ShowNotification({
                message = SD.Locale.T("need_police"),
                title = SD.Locale.T("notif_title"),
                type = "error"
            })
            return
        end

        ShowNotification({
            message = SD.Locale.T("goto_ambush"),
            title = SD.Locale.T("notif_title"),
            type = "default"
        })
        
        HeistBlip = SetBlip(SD.Locale.T('heistblip_name'), TRAIN.position, 570, 1)
        SetBlipAsShortRange(HeistBlip, false)

        local ped = PlayerPedId()
        while #(GetEntityCoords(ped) - TRAIN.position) > 400.0 do Wait(500) end
        
        TriggerServerEvent("exp_trainheist:SendPoliceAlert", TRAIN.position)
        
        local train_data = BuildTrain()
        SpawnGuards(train_data)
    end)
end
RegisterNetEvent("exp_trainheist:StartHeist", StartTrainHeist)

AddEventHandler("exp_trainheist:CutDoor", function(data)
    local entity = data.entity
    SD.Callback('exp_trainheist:HasItem', false, function(hasItem)
        if not hasItem then
            ShowNotification({
                message = SD.Locale.T("missing_grind"),
                title = SD.Locale.T("notif_title"),
                type = "error"
            })
            return
        end

        if DoesPedHaveAnyBag(PlayerPedId()) then
            TriggerServerEvent("exp_trainheist:RemoveHitbox", {
                id = HitboxRegister[entity]
            })
            AnimateContainerOpening(Hitboxes[entity])
        else
            ShowNotification({
                message = SD.Locale.T("missing_bag"),
                title = SD.Locale.T("notif_title"),
                type = "error"
            })
        end
        
    end, BREAK_ITEM)
end)

AddEventHandler("exp_trainheist:GrabGold", function(data)
    local entity = data.entity
    SD.Callback("exp_trainheist:CanCarryGold", false, function(can_carry)
        if not can_carry then
            ShowNotification({
                message = SD.Locale.T("not_enough_space"),
                title = SD.Locale.T("notif_title"),
                type = "error"
            })
            return
        end
        TriggerServerEvent("exp_trainheist:RemoveHitbox", {
            id = HitboxRegister[entity]
        })
        AnimateGoldGrabbing(Hitboxes[entity])
        SetupGoldDelivery()
    end)
end)

function SetupGoldDelivery()
    ShowNotification({
        title = SD.Locale.T("start_npc_name"),
        message = SD.Locale.T("deliver_gold"),
        type = "default"
    })
    if HasGold then return end
    HasGold = true
    AddEntityMenuItem({
        entity = StartNPC,
        event = "exp_trainheist:DeliverGold",
        desc = SD.Locale.T("deliver_the_gold"),
        icon = "fas fa-sack-dollar"
    })
end

AddEventHandler("exp_trainheist:DeliverGold", function(data)
    local entity = data.entity
    RemoveEntityMenuItem({entity = entity, event = "exp_trainheist:DeliverGold"})
    TriggerServerEvent("exp_trainheist:DeliverGold")
    HasGold = false
end)

RegisterNetEvent("exp_trainheist:ShowNotification", function(data)
    ShowNotification(data)
end)

RegisterNetEvent("exp_bank_robbery:ShowPoliceAlert", function(position)
    local blip_icon = SetBlip(SD.Locale.T("alert_title"), position, POL_ALERT_SPRITE, POL_ALERT_COLOR, 1.0)
    SetBlipAsShortRange(blip_icon, false)
    if POL_ALERT_WAVE then
        local blip_wave = SetBlip("", position, 161, POL_ALERT_COLOR, 1.0)
        SetBlipDisplay(blip_wave, 8)
        SetBlipAsShortRange(blip_wave, false)
    end

    Wait(POL_ALERT_TIME)
    
    RemoveBlip(blip_icon)
    RemoveBlip(blip_wave)
    ShowNotification({
        title = SD.Locale.T("alert_title"),
        message = SD.Locale.T("alert_content")
    })
end)

RegisterNetEvent('exp_trainheist:SynchronizeEntity', function(net_entity)
    DeleteEntity(NetworkGetEntityFromNetworkId(net_entity))
end)

function SpawnGuards(train_data)
    for index, value in ipairs(GUARDS.models) do
        _RequestModel(GetHashKey(value))
    end

    local ped = PlayerPedId()

    AddRelationshipGroup('GUARDS')
    SetPedRelationshipGroupHash(ped, GetHashKey('PLAYER'))
    SetRelationshipBetweenGroups(0, GetHashKey("GUARDS"), GetHashKey("GUARDS"))
	SetRelationshipBetweenGroups(5, GetHashKey("GUARDS"), GetHashKey("PLAYER"))
	SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("GUARDS"))

    for i = 1, GUARDS.amount do
        local position = GetRandomPositionInCircle(train_data.center, GUARDS.spawn_range)
        while not IsSpawnPointClear(position) do
            position = GetRandomPositionInCircle(train_data.center, GUARDS.spawn_range)
        end

        local guard = CreatePed(0, GetHashKey(GUARDS.models[math.random(#GUARDS.models)]), position, 0.0, true, true)
        Entities[#Entities+1] = guard
        SetEntityAsMissionEntity(guard)
        SetPedRelationshipGroupHash(guard, GetHashKey("GUARDS"))
        SetPedAccuracy(guard, GUARDS.accuracy)
        SetPedArmour(guard, GUARDS.armour)
        SetPedDropsWeaponsWhenDead(guard, false)
        SetPedFleeAttributes(guard, 0, false)
        GiveWeaponToPed(guard, GetHashKey(GUARDS.weapons[math.random(#GUARDS.weapons)]), 255, false, true)
        TaskGuardCurrentPosition(guard, 10.0, 10.0, true)
    end
end

RegisterNetEvent('exp_trainheist:ResetAndWipe', function()
    if HeistBlip then
        RemoveBlip(HeistBlip)
    end
    for index, value in ipairs(Entities) do
        DeleteEntity(value)
    end

    Entities = {}
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    TriggerEvent("exp_trainheist:ResetAndWipe")
end)
