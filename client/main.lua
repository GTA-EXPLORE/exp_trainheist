TrainHeist = {
    startPeds = {},
    guardPeds = {},
    containers = {},
    collisions = {},
    locks = {},
    desks = {},
    golds = {}
}

local gold_to_indexes = {}
local hitboxes = {}
local ambushBlip

Citizen.CreateThread(function()
    local start_npc = SpawnNPC(START_SCENE.ped.model, START_SCENE.ped.coords, START_SCENE.ped.heading)
    FreezeEntityPosition(start_npc, true)
    SetEntityInvincible(start_npc, true)
    SetBlockingOfNonTemporaryEvents(start_npc, true)
    TaskStartScenarioInPlace(start_npc, "WORLD_HUMAN_SMOKING", 0, true)
    TriggerEvent("exp_target_menu:AddEntityMenuItem", start_npc, "exp_trainheist:StartHeist", _("start_npc_desc"), false)
    TriggerEvent("exp_target_menu:SetEntityName", start_npc, _("start_npc_name"))
end)

RegisterNetEvent("exp_trainheist:StartHeist")
AddEventHandler("exp_trainheist:StartHeist", function()
    StartTrainHeist()
end)

function StartTrainHeist()
    TriggerServerCallback('exp_trainheist:checkPoliceCount', function(enough_police)
        if not enough_police then
            ShowNotification({
                message = _("need_police"),
                title = _("notif_title"),
                type = "error"
            })
            return
        end

        TriggerServerCallback('exp_trainheist:checkTime', function()
            ShowNotification({
                message = _("goto_ambush"),
                title = _("notif_title"),
                type = "default"
            })
            
            ambushBlip = SetBlip(_('ambush_blip'), TRAIN_SETUP.pos, 570, 1)
            SetBlipAsShortRange(ambushBlip, false)
            repeat
                local ped = PlayerPedId()
                local pedCo = GetEntityCoords(ped)
                local dist = #(pedCo - TRAIN_SETUP.pos)
                Wait(1)
            until dist <= 150.0
            SpawnGuards()
            SetupTrain()
            TriggerServerEvent('exp_trainheist:trainLoop')
            TriggerServerEvent("exp_trainheist:SendPoliceAlert", TRAIN_SETUP.pos)
        end)
    end)
end

RegisterNetEvent('exp_trainheist:trainLoop')
AddEventHandler('exp_trainheist:trainLoop', function()
    trainLoop = true

    while trainLoop do
        local ped = PlayerPedId()
        local pedCo = GetEntityCoords(ped)

        if robber then
            local trainDist = #(pedCo - TRAIN_SETUP.pos)
            if trainDist >= 50.0 then
                FinishHeist()
                break
            end
        end

        if IsEntityDead(ped) then
            break
        end
        Wait(1)
    end
end)

AddEventHandler("exp_trainheist:CutDoor1", function(entity)
    OpenContainer(1)
end)
AddEventHandler("exp_trainheist:CutDoor2", function(entity)
    OpenContainer(2)
end)

AddEventHandler("exp_trainheist:GrabGold", function(entity)
    TriggerServerCallback("exp_trainheist:CanCarryGold", function(can_carry)
        if not can_carry then
            ShowNotification({
                message = _("not_enough_space"),
                title = _("notif_title"),
                type = "error"
            })
            return
        end
        Grab(gold_to_indexes[entity].k, gold_to_indexes[entity].x)
    end)
end)

function FinishHeist()
    ShowNotification({
        message = _("deliver_to_buyer"),
        title = _("notif_title"),
        type = "default"
    })
    loadModel('baller')
    local buyerBlip = SetBlip(_('buyer_blip'), END_SCENE.position, 500, 0)
    SetBlipAsShortRange(buyerBlip, false)
    buyerVehicle = CreateVehicle(GetHashKey('baller'), END_SCENE.position.xy + 3.0, END_SCENE.position.z, 269.4, 0, 0)
    while true do
        local ped = PlayerPedId()
        local pedCo = GetEntityCoords(ped)
        local dist = #(pedCo - END_SCENE.position)

        if dist <= 15.0 then
            PlayCutscene('hs3f_all_drp3', END_SCENE.position)
            DeleteVehicle(buyerVehicle)
            RemoveBlip(buyerBlip)
            TriggerServerEvent('exp_trainheist:sellRewardItems')

            RemoveBlip(ambushBlip)
            DeleteVehicle(mainTrain)
            DeleteVehicle(trainPart)
            DeleteObject(TrainHeist.desks[1])
            DeleteObject(TrainHeist.desks[2])
            DeleteObject(TrainHeist.containers[1])
            DeleteObject(TrainHeist.containers[2])
            DeleteObject(TrainHeist.locks[1])
            DeleteObject(TrainHeist.locks[2])
            TriggerServerEvent('exp_trainheist:resetHeist')
            break
        end
        Wait(1)
    end
end

RegisterNetEvent('exp_trainheist:resetHeist')
AddEventHandler('exp_trainheist:resetHeist', function()
    DeleteObject(clientContainer)
    DeleteObject(clientLock)
    DeleteObject(clientContainer2)
    DeleteObject(clientLock2)
    clientContainer, clientContainer2, clientLock, clientLock2 = nil, nil, nil, nil
    ClearArea(2885.97, 4560.83, 48.0551, 50.0)
    trainLoop = false
    for k, v in pairs(TRAIN_SETUP.containers) do
        v.lock.taken = false
        for x, y in pairs(v.golds) do
            y.taken = false
        end
    end
end)

function SpawnGuards()
    local ped = PlayerPedId()

    SetPedRelationshipGroupHash(ped, GetHashKey('PLAYER'))
    AddRelationshipGroup('GuardPeds')

    for k, v in pairs(GUARDS) do
        loadModel(v.model)
        TrainHeist.guardPeds[k] = CreatePed(26, GetHashKey(v.model), v.coords, v.heading, true, true)
        NetworkRegisterEntityAsNetworked(TrainHeist.guardPeds[k])
        networkID = NetworkGetNetworkIdFromEntity(TrainHeist.guardPeds[k])
        SetNetworkIdCanMigrate(networkID, true)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetPedRandomComponentVariation(TrainHeist.guardPeds[k], 0)
        SetPedRandomProps(TrainHeist.guardPeds[k])
        SetEntityAsMissionEntity(TrainHeist.guardPeds[k])
        SetEntityVisible(TrainHeist.guardPeds[k], true)
        SetPedRelationshipGroupHash(TrainHeist.guardPeds[k], GetHashKey("GuardPeds"))
        SetPedAccuracy(TrainHeist.guardPeds[k], 50)
        SetPedArmour(TrainHeist.guardPeds[k], 100)
        SetPedCanSwitchWeapon(TrainHeist.guardPeds[k], true)
        SetPedDropsWeaponsWhenDead(TrainHeist.guardPeds[k], false)
		SetPedFleeAttributes(TrainHeist.guardPeds[k], 0, false)
        GiveWeaponToPed(TrainHeist.guardPeds[k], GetHashKey('WEAPON_PISTOL'), 255, false, false)
        local random = math.random(1, 2)
        if random == 2 then
            TaskGuardCurrentPosition(TrainHeist.guardPeds[k], 10.0, 10.0, 1)
        end
    end

    SetRelationshipBetweenGroups(0, GetHashKey("GuardPeds"), GetHashKey("GuardPeds"))
	SetRelationshipBetweenGroups(5, GetHashKey("GuardPeds"), GetHashKey("PLAYER"))
	SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("GuardPeds"))
end

function SetupTrain()
    loadModel('freight')
    loadModel('freightcar')
    loadModel('tr_prop_tr_container_01a')
    loadModel('prop_ld_container')
    loadModel('tr_prop_tr_lock_01a')
    loadModel('xm_prop_lab_desk_02')
    loadModel('h4_prop_h4_gold_stack_01a')
    loadModel('apa_mp_h_acc_box_trinket_01')
    loadModel('apa_mp_h_acc_artwalll_01')

    mainTrain = CreateVehicle(GetHashKey('freight'), TRAIN_SETUP.pos, TRAIN_SETUP.heading, 1, 0)
    trainPart = CreateVehicle(GetHashKey('freightcar'), TRAIN_SETUP.part, TRAIN_SETUP.heading, 1, 0)
    FreezeEntityPosition(mainTrain, true)
    FreezeEntityPosition(trainPart, true)

    for k, v in pairs(TRAIN_SETUP.containers) do
        TrainHeist.containers[k] = CreateObject(GetHashKey('tr_prop_tr_container_01a'), v.pos, 1, 1, 0)
        SetEntityHeading(TrainHeist.containers[k], v.heading)
        FreezeEntityPosition(TrainHeist.containers[k], true)

        TrainHeist.collisions[k] = CreateObject(GetHashKey('prop_ld_container'), v.pos, 1, 1, 0)
        SetEntityHeading(TrainHeist.collisions[k], v.heading)
        SetEntityVisible(TrainHeist.collisions[k], false)
        FreezeEntityPosition(TrainHeist.collisions[k], true)

        TrainHeist.locks[k] = CreateObject(GetHashKey('tr_prop_tr_lock_01a'), v.lock.pos, 1, 1, 0)
        SetEntityHeading(TrainHeist.locks[k], v.heading)
        TrainHeist.desks[k] = CreateObject(GetHashKey('xm_prop_lab_desk_02'), v.table, 1, 1, 0)
        SetEntityHeading(TrainHeist.desks[k], v.heading)
        
        for x, y in pairs(v.golds) do
            TrainHeist.golds[k..x] = CreateObject(GetHashKey('h4_prop_h4_gold_stack_01a'), y.pos, 1, 1, 0)
            SetEntityHeading(TrainHeist.golds[k..x], v.heading)            
        end
    end

    TriggerServerEvent("exp_trainheist:SpawnHitboxes")
end

RegisterNetEvent("exp_trainheist:SpawnHitboxes")
AddEventHandler("exp_trainheist:SpawnHitboxes", function()
    hitboxes.cutting_1 = CreateObject(GetHashKey("apa_mp_h_acc_artwalll_01"), vector3(2882.215, 4556.313, 48.29))
    FreezeEntityPosition(hitboxes.cutting_1, true)
    SetEntityRotation(hitboxes.cutting_1, 0.0, 0.0, 140.0)
    SetEntityInvincible(hitboxes.cutting_1, true)
    SetEntityVisible(hitboxes.cutting_1, false)
    TriggerEvent("exp_target_menu:AddEntityMenuItem", hitboxes.cutting_1, "exp_trainheist:CutDoor1", _("cut_door"))
    TriggerEvent("exp_target_menu:SetEntityName", hitboxes.cutting_1, _("door_name"))

    hitboxes.cutting_2 = CreateObject(GetHashKey("apa_mp_h_acc_artwalll_01"), vector3(2884.701, 4559.342, 48.27))
    FreezeEntityPosition(hitboxes.cutting_2, true)
    SetEntityRotation(hitboxes.cutting_2, 0.0, 0.0, 320.0)
    SetEntityInvincible(hitboxes.cutting_2, true)
    SetEntityVisible(hitboxes.cutting_2, false)
    TriggerEvent("exp_target_menu:AddEntityMenuItem", hitboxes.cutting_2, "exp_trainheist:CutDoor2", _("cut_door"))
    TriggerEvent("exp_target_menu:SetEntityName", hitboxes.cutting_2, _("door_name"))

    for k, v in pairs(TRAIN_SETUP.containers) do
        for x, y in pairs(v.golds) do
            local gold_hitbox = CreateObject(GetHashKey("apa_mp_h_acc_box_trinket_01"), y.pos, true, true, false)
            FreezeEntityPosition(gold_hitbox, true)
            SetEntityInvincible(gold_hitbox, true)
            SetEntityVisible(gold_hitbox, false)
            gold_to_indexes[gold_hitbox] = {
                k = k,
                x = x
            }
            hitboxes["gold_"..k..x] = gold_hitbox
            TriggerEvent("exp_target_menu:AddEntityMenuItem", gold_hitbox, "exp_trainheist:GrabGold", _("grab_gold"))
            TriggerEvent("exp_target_menu:SetEntityName", gold_hitbox, _("gold_name"))
     
        end
    end
end)

RegisterNetEvent("exp_trainheist:RemoveHitbox")
AddEventHandler("exp_trainheist:RemoveHitbox", function(id)
    if not hitboxes[id] then return end
    DeleteObject(hitboxes[id])
end)

function OpenContainer(index)
    TriggerServerCallback('exp_trainheist:hasItem', function(hasItem)
        if not hasItem then
            ShowNotification({
                message = _("missing_grind"),
                title = _("notif_title"),
                type = "error"
            })
            return
        end
        
        TriggerServerEvent("exp_trainheist:RemoveHitbox", "cutting_"..index)
        local ped = PlayerPedId()
        local pedCo = GetEntityCoords(ped)
        local pedRotation = GetEntityRotation(ped)
        local animDict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
        loadAnimDict(animDict)
        loadPtfxAsset('scr_tn_tr')
        TriggerServerEvent('exp_trainheist:lockSync', index)
        
        for i = 1, #TrainAnimation.objects do
            loadModel(TrainAnimation.objects[i])
            TrainAnimation.sceneObjects[i] = CreateObject(GetHashKey(TrainAnimation.objects[i]), pedCo, 1, 1, 0)
        end

        
        local self_bag
        TriggerEvent("skinchanger:getSkin", function(skin)
            self_bag = skin.bags_1
            TriggerEvent("skinchanger:change", "bags_1", -1)
        end)

        sceneObject = GetClosestObjectOfType(pedCo, 2.5, GetHashKey('tr_prop_tr_container_01a'), 0, 0, 0)
        lockObject = GetClosestObjectOfType(pedCo, 2.5, GetHashKey('tr_prop_tr_lock_01a'), 0, 0, 0)
        NetworkRegisterEntityAsNetworked(sceneObject)
        NetworkRegisterEntityAsNetworked(lockObject)

        scene = NetworkCreateSynchronisedScene(GetEntityCoords(sceneObject), GetEntityRotation(sceneObject), 2, true, false, 1065353216, 0, 1065353216)

        NetworkAddPedToSynchronisedScene(ped, scene, animDict, TrainAnimation.animations[1][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
        NetworkAddEntityToSynchronisedScene(sceneObject, scene, animDict, TrainAnimation.animations[1][2], 1.0, -1.0, 1148846080)
        NetworkAddEntityToSynchronisedScene(lockObject, scene, animDict, TrainAnimation.animations[1][3], 1.0, -1.0, 1148846080)
        NetworkAddEntityToSynchronisedScene(TrainAnimation.sceneObjects[1], scene, animDict, TrainAnimation.animations[1][4], 1.0, -1.0, 1148846080)
        NetworkAddEntityToSynchronisedScene(TrainAnimation.sceneObjects[2], scene, animDict, TrainAnimation.animations[1][5], 1.0, -1.0, 1148846080)

        SetEntityCoords(ped, GetEntityCoords(sceneObject))
        NetworkStartSynchronisedScene(scene)
        
        Wait(4000)

        UseParticleFxAssetNextCall('scr_tn_tr')
        sparks = StartParticleFxLoopedOnEntity("scr_tn_tr_angle_grinder_sparks", TrainAnimation.sceneObjects[1], 0.0, 0.25, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false, 1065353216, 1065353216, 1065353216, 1)
        
        Wait(1000)

        StopParticleFxLooped(sparks, 1)
        Wait(GetAnimDuration(animDict, 'action') * 1000 - 5000)
        TriggerServerEvent('exp_trainheist:containerSync', GetEntityCoords(sceneObject), GetEntityRotation(sceneObject))
        TriggerServerEvent('exp_trainheist:objectSync', NetworkGetNetworkIdFromEntity(sceneObject))
        TriggerServerEvent('exp_trainheist:objectSync', NetworkGetNetworkIdFromEntity(lockObject))
        DeleteObject(TrainAnimation.sceneObjects[1])
        DeleteObject(TrainAnimation.sceneObjects[2])
        ClearPedTasks(ped)
        TriggerEvent("skinchanger:change", "bags_1", self_bag)

    end, BREAK_ITEM)
end

RegisterNetEvent('exp_trainheist:lockSync')
AddEventHandler('exp_trainheist:lockSync', function(index)
    TRAIN_SETUP.containers[index].lock.taken = not TRAIN_SETUP.containers[index].lock.taken
end)

RegisterNetEvent('exp_trainheist:grabSync')
AddEventHandler('exp_trainheist:grabSync', function(index, index2)
    TRAIN_SETUP.containers[index].golds[index2].taken = not TRAIN_SETUP.containers[index].golds[index2].taken
end)

RegisterNetEvent('exp_trainheist:objectSync')
AddEventHandler('exp_trainheist:objectSync', function(e)
    local entity = NetworkGetEntityFromNetworkId(e)
    DeleteEntity(entity)
    DeleteObject(entity)
end)

RegisterNetEvent('exp_trainheist:containerSync')
AddEventHandler('exp_trainheist:containerSync', function(coords, rotation)
    animDict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
    loadAnimDict(animDict)

    if clientContainer and clientLock then
        clientContainer2 = CreateObject(GetHashKey('tr_prop_tr_container_01a'), coords, 0, 0, 0)
        clientLock2 = CreateObject(GetHashKey('tr_prop_tr_lock_01a'), coords, 0, 0, 0)
        
        clientScene = CreateSynchronizedScene(coords, rotation, 2, true, false, 1065353216, 0, 1065353216)
        PlaySynchronizedEntityAnim(clientContainer2, clientScene, TrainAnimation.animations[1][2], animDict, 1.0, -1.0, 0, 1148846080)
        ForceEntityAiAndAnimationUpdate(clientContainer2)
        PlaySynchronizedEntityAnim(clientLock2, clientScene, TrainAnimation.animations[1][3], animDict, 1.0, -1.0, 0, 1148846080)
        ForceEntityAiAndAnimationUpdate(clientLock2)

        SetSynchronizedScenePhase(clientScene, 0.99)
        SetEntityCollision(clientContainer2, false, true)
        FreezeEntityPosition(clientContainer2, true)
    else
        clientContainer = CreateObject(GetHashKey('tr_prop_tr_container_01a'), coords, 0, 0, 0)
        clientLock = CreateObject(GetHashKey('tr_prop_tr_lock_01a'), coords, 0, 0, 0)
        
        clientScene = CreateSynchronizedScene(coords, rotation, 2, true, false, 1065353216, 0, 1065353216)
        PlaySynchronizedEntityAnim(clientContainer, clientScene, TrainAnimation.animations[1][2], animDict, 1.0, -1.0, 0, 1148846080)
        ForceEntityAiAndAnimationUpdate(clientContainer)
        PlaySynchronizedEntityAnim(clientLock, clientScene, TrainAnimation.animations[1][3], animDict, 1.0, -1.0, 0, 1148846080)
        ForceEntityAiAndAnimationUpdate(clientLock)

        SetSynchronizedScenePhase(clientScene, 0.99)
        SetEntityCollision(clientContainer, false, true)
        FreezeEntityPosition(clientContainer, true)
    end
end)

function Grab(index, index2)
    if DoesPedHaveAnyBag(PlayerPedId()) then
        grabNow = true
        robber = true
        TriggerServerEvent("exp_trainheist:RemoveHitbox", "gold_"..index..index2)
        TriggerServerEvent('exp_trainheist:grabSync', index, index2)
        local ped = PlayerPedId()
        local pedCo, pedRotation = GetEntityCoords(ped), GetEntityRotation(ped)
        animDict = 'anim@scripted@heist@ig1_table_grab@gold@male@'
        loadAnimDict(animDict)
        
        loadModel('hei_p_m_bag_var22_arm_s')
        local self_bag
        TriggerEvent("skinchanger:getSkin", function(skin)
            self_bag = skin.bags_1
            TriggerEvent("skinchanger:change", "bags_1", -1)
        end)
        bag = CreateObject(GetHashKey('hei_p_m_bag_var22_arm_s'), pedCo, 1, 1, 0)
        sceneObject = GetClosestObjectOfType(pedCo, 2.0, GetHashKey('h4_prop_h4_gold_stack_01a'), false, false, false)
        NetworkRegisterEntityAsNetworked(sceneObject)
    
        for i = 1, #GrabGold.animations do
            GrabGold.scenes[i] = NetworkCreateSynchronisedScene(GetEntityCoords(sceneObject), GetEntityRotation(sceneObject), 2, true, false, 1065353216, 0, 1.3)
            NetworkAddPedToSynchronisedScene(ped, GrabGold.scenes[i], animDict, GrabGold.animations[i][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
            NetworkAddEntityToSynchronisedScene(bag, GrabGold.scenes[i], animDict, GrabGold.animations[i][2], 1.0, -1.0, 1148846080)
            if i == 2 then
                NetworkAddEntityToSynchronisedScene(sceneObject, GrabGold.scenes[i], animDict, 'grab_gold', 1.0, -1.0, 1148846080)
            end
        end
    
        NetworkStartSynchronisedScene(GrabGold.scenes[1])
        Wait(GetAnimDuration(animDict, 'enter') * 1000)
        NetworkStartSynchronisedScene(GrabGold.scenes[2])
        Wait(GetAnimDuration(animDict, 'grab') * 1000 - 2250)
        TriggerServerEvent('exp_trainheist:objectSync', NetworkGetNetworkIdFromEntity(sceneObject))
        TriggerServerEvent('exp_trainheist:rewardItems')
        NetworkStartSynchronisedScene(GrabGold.scenes[4])
        Wait(GetAnimDuration(animDict, 'exit_bag') * 1000)
        
        ClearPedTasks(ped)
        DeleteObject(bag)
        TriggerEvent("skinchanger:change", "bags_1", self_bag)
        grabNow = false
    else
        ShowNotification({
            message = _("missing_bag"),
            title = _("notif_title"),
            type = "error"
        })
    end
end


function Finish(coords)
    if coords then
        local tripped = false
        repeat
            Wait(0)
            if (timer and (GetCutsceneTime() > timer))then
                DoScreenFadeOut(250)
                tripped = true
            end
            if (GetCutsceneTotalDuration() - GetCutsceneTime() <= 250) then
            DoScreenFadeOut(250)
            tripped = true
            end
        until not IsCutscenePlaying()
        if (not tripped) then
            DoScreenFadeOut(100)
            Wait(150)
        end
        return
    else
        Wait(18500)
        StopCutsceneImmediately()
    end
end

AddEventHandler('onResourceStop', function (resource)
    if resource == GetCurrentResourceName() then
        DeleteVehicle(mainTrain)
        DeleteVehicle(trainPart)
        ClearArea(2885.97, 4560.83, 48.0551, 50.0)
    end
end)

RegisterNetEvent("exp_trainheist:ShowNotification", function(data)
    ShowNotification(data)
end)

RegisterNetEvent("exp_bank_robbery:ShowPoliceAlert")
AddEventHandler("exp_bank_robbery:ShowPoliceAlert", function(position)
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