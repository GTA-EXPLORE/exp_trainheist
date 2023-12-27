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
        name = _("start_npc_name"),
        desc = _("start_npc_desc")
    })
end)


function StartTrainHeist()
    TriggerServerCallback('exp_trainheist:CanPlayerStartHeist', function(data)
        if not data.time then
            ShowNotification({
                message = _("wait_nextrob"),
                title = _("notif_title"),
                type = "error"
            })
            return
        end

        if not data.cops then
            ShowNotification({
                message = _("need_police"),
                title = _("notif_title"),
                type = "error"
            })
            return
        end

        ShowNotification({
            message = _("goto_ambush"),
            title = _("notif_title"),
            type = "default"
        })
        
        HeistBlip = SetBlip(_('heistblip_name'), TRAIN.position, 570, 1)
        SetBlipAsShortRange(HeistBlip, false)

        local ped = PlayerPedId()
        while #(GetEntityCoords(ped) - TRAIN.position) > 400.0 do Wait(500) end
        
        TriggerServerEvent("exp_trainheist:SendPoliceAlert", TRAIN.position)
        
        local train_data = BuildTrain()
        SpawnGuards(train_data)
    end)
end
RegisterNetEvent("exp_trainheist:StartHeist", StartTrainHeist)

AddEventHandler("exp_trainheist:CutDoor", function(entity)
    entity = type(entity) == "number" and entity or entity.entity
    TriggerServerCallback('exp_trainheist:HasItem', function(hasItem)
        if not hasItem then
            ShowNotification({
                message = _("missing_grind"),
                title = _("notif_title"),
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
                message = _("missing_bag"),
                title = _("notif_title"),
                type = "error"
            })
        end
        
    end, BREAK_ITEM)
end)

AddEventHandler("exp_trainheist:GrabGold", function(entity)
    entity = type(entity) == "number" and entity or entity.entity
    TriggerServerCallback("exp_trainheist:CanCarryGold", function(can_carry)
        if not can_carry then
            ShowNotification({
                message = _("not_enough_space"),
                title = _("notif_title"),
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
        title = _("start_npc_name"),
        message = _("deliver_gold"),
        type = "default"
    })
    if HasGold then return end
    HasGold = true
    AddEntityMenuItem({
        entity = StartNPC,
        event = "exp_trainheist:DeliverGold",
        desc = _("deliver_the_gold")
    })
end

AddEventHandler("exp_trainheist:DeliverGold", function(entity)
    entity = type(entity) == "number" and entity or entity.entity
    RemoveEntityMenuItem({entity = entity, event = "exp_trainheist:DeliverGold"})
    TriggerServerEvent("exp_trainheist:DeliverGold")
    HasGold = false
end)

RegisterNetEvent("exp_trainheist:ShowNotification", function(data)
    ShowNotification(data)
end)

RegisterNetEvent("exp_bank_robbery:ShowPoliceAlert", function(position)
    local blip_icon = SetBlip(_("alert_title"), position, POL_ALERT_SPRITE, POL_ALERT_COLOR, 1.0)
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
        title = _("alert_title"),
        message = _("alert_content")
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
