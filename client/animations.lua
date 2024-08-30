-- MARK:AnimateContainerOpening
function AnimateContainerOpening(data)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local anim_dict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
    _RequestAnimDict(anim_dict)
    _RequestNamedPtfxAsset('scr_tn_tr')
    
    local grinderModel = `tr_prop_tr_grinder_01a`
    _RequestModel(grinderModel)
    local grinder = CreateObject(grinderModel, coords, true, true, false)
    SetEntityCollision(grinder, false)
    Entities[#Entities+1] = grinder
    
    local bagModel = `ch_p_m_bag_var02_arm_s`
    _RequestModel(bagModel)
    local bag = CreateObject(bagModel, coords, true, true, false)
    SetEntityCollision(bag, false)
    Entities[#Entities+1] = bag
    
    local self_bag
    TriggerEvent("skinchanger:getSkin", function(skin)
        self_bag = skin.bags_1
        TriggerEvent("skinchanger:change", "bags_1", -1)
    end)

    local container = NetworkGetEntityFromNetworkId(data.container)
    local lock = NetworkGetEntityFromNetworkId(data.lock)

    local animPos = GetEntityCoords(container)
    local scene = NetworkCreateSynchronisedScene(animPos, GetEntityRotation(container), 2, true, false, 1.0, 0.0, 1.0)

    NetworkAddPedToSynchronisedScene(ped, scene, anim_dict, "action", 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(container, scene, anim_dict, "action_container", 1.0, -1.0, 0)
    NetworkAddEntityToSynchronisedScene(lock, scene, anim_dict, "action_lock", 1.0, -1.0, 0)
    NetworkAddEntityToSynchronisedScene(grinder, scene, anim_dict, "action_angle_grinder", 1.0, -1.0, 0)
    NetworkAddEntityToSynchronisedScene(bag, scene, anim_dict, "action_bag", 1.0, -1.0, 0)

    local fwd = GetEntityForwardVector(container)
    local vec90 = vec(fwd.y*-1, fwd.x)
    fwd = vec(fwd.x*-1, fwd.y*-1)

    local camPos = vec(animPos.x + fwd.x*3.5 + vec90.x*1.5, animPos.y + fwd.y*3.5 + vec90.y*1.5, animPos.z+2.0)
    local camHeading = GetHeadingFromVector_2d(animPos.x - camPos.x, animPos.y - camPos.y) - 20

    local sceneCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camPos, -20.0, 0.0, camHeading,  60.0, false, 0)
    SetCamActive(sceneCam, true)
    RenderScriptCams(true, true, 1000, true, true)

    SetEntityCoords(ped, animPos)
    NetworkStartSynchronisedScene(scene)
    
    Wait(3000)
    
    if GetResourceState("xsound") == "started" then
        exports.xsound:PlayUrlPos("exp_trainheist:grinder", "https://cfx-nui-exp_trainheist/client/sounds/grinder.mp3", 0.1, GetEntityCoords(grinder), false)
    end

    Wait(1000)

    if GetResourceState("xsound") == "started" then
        exports.xsound:setVolume("exp_trainheist:grinder", 1.0)
    end
    
    UseParticleFxAssetNextCall('scr_tn_tr')
    local sparks = StartParticleFxLoopedOnEntity("scr_tn_tr_angle_grinder_sparks", grinder, 0.0, 0.25, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false, 1065353216, 1065353216, 1065353216, 1)
    
    Wait(1000)

    StopParticleFxLooped(sparks, true)
    
    if GetResourceState("xsound") == "started" then
        exports.xsound:fadeOut("exp_trainheist:grinder", 500)
    end

    Wait(GetAnimDuration(anim_dict, 'action') * 1000 - 7000)

    SetCamActive(sceneCam, false)
    RenderScriptCams(false, true, 1000, true, true)

    Wait(2000)
    
    TriggerServerEvent('exp_trainheist:SynchronizeContainer', {
        position = GetEntityCoords(container),
        rotation = GetEntityRotation(container)
    })

    DeleteObject(grinder)
    DeleteObject(bag)
    
    TriggerEvent("skinchanger:change", "bags_1", self_bag)
    DeleteObject(container)
    DeleteObject(lock)
end

RegisterNetEvent('exp_trainheist:SynchronizeContainer', function(data)
    local anim_dict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
    _RequestAnimDict(anim_dict)

    local container = CreateObject(GetHashKey('tr_prop_tr_container_01a'), data.position, 0, 0, 0)
    SetEntityRotation(container, data.rotation)
    Entities[#Entities+1] = container

    local lock = CreateObject(GetHashKey('tr_prop_tr_lock_01a'), data.position, 0, 0, 0)
    SetEntityRotation(lock, data.rotation)
    Entities[#Entities+1] = lock
    
    local scene = CreateSynchronizedScene(data.position, data.rotation, 2, true, false, 1.0, 0, 1.0)
    PlaySynchronizedEntityAnim(container, scene, "action_container", anim_dict, 1.0, -1.0, 0, 0)
    ForceEntityAiAndAnimationUpdate(container)
    PlaySynchronizedEntityAnim(lock, scene, "action_lock", anim_dict, 1.0, -1.0, 0, 0)
    ForceEntityAiAndAnimationUpdate(lock)

    SetSynchronizedScenePhase(scene, 0.99)
    SetEntityCollision(container, false, true)
    FreezeEntityPosition(container, true)
end)

-- MARK:AnimateGoldGrabbing
function AnimateGoldGrabbing(data)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    SetEntityCoords(ped, GetOffsetFromEntityInWorldCoords(data.gold, vector3(1.0, 0.0, 0.0)))
    FreezeEntityPosition(ped, true)
    
    local anim_dict = 'anim@scripted@heist@ig1_table_grab@gold@male@'
    _RequestAnimDict(anim_dict)
    
    local self_bag
    TriggerEvent("skinchanger:getSkin", function(skin)
        self_bag = skin.bags_1
        TriggerEvent("skinchanger:change", "bags_1", -1)
    end)
    
    local gold = NetworkGetEntityFromNetworkId(data.gold)

    _RequestModel(GetHashKey('hei_p_m_bag_var22_arm_s'))
    local bag = CreateObject(GetHashKey('hei_p_m_bag_var22_arm_s'), coords, true, true, false)
    NetworkRegisterEntityAsNetworked(gold)
    SetEntityCollision(bag, false)
    Entities[#Entities+1] = bag

    local animPos, animRot = GetEntityCoords(gold), GetEntityRotation(gold)

    local scene_1 = NetworkCreateSynchronisedScene(animPos, animRot, 2, true, false, 1.0, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, scene_1, anim_dict, "enter", 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(bag, scene_1, anim_dict, "enter_bag", 1.0, -1.0, 0)

    local scene_2 = NetworkCreateSynchronisedScene(animPos, animRot, 2, true, false, 1.0, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, scene_2, anim_dict, "grab", 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(bag, scene_2, anim_dict, "grab_bag", 1.0, -1.0, 0)
    NetworkAddEntityToSynchronisedScene(gold, scene_2, anim_dict, "grab_gold", 1.0, -1.0, 0)

    -- local scene_3 = NetworkCreateSynchronisedScene(animPos, animRot, 2, true, false, 1.0, 0, 1.3)
    -- NetworkAddPedToSynchronisedScene(ped, scene_3, anim_dict, "grab_idle", 4.0, -4.0, 1033, 0, 1000.0, 0)
    -- NetworkAddEntityToSynchronisedScene(bag, scene_3, anim_dict, "grab_idle_bag", 1.0, -1.0, 0)

    local scene_4 = NetworkCreateSynchronisedScene(animPos, animRot, 2, true, false, 1.0, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, scene_4, anim_dict, "exit", 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(bag, scene_4, anim_dict, "exit_bag", 1.0, -1.0, 0)

    local fwd = GetEntityForwardVector(gold)
    local vec90 = vec(fwd.y*-1, fwd.x)
    fwd = vec(fwd.x*-1, fwd.y*-1)

    local camPos = vec(animPos.x + fwd.x*1.0 + vec90.x*1.0, animPos.y + fwd.y*1.0 + vec90.y*1.0, animPos.z+0.5)
    local camHeading = GetHeadingFromVector_2d(animPos.x - camPos.x, animPos.y - camPos.y) - 20

    local sceneCam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", camPos, -20.0, 0.0, camHeading,  60.0, false, 0)
    SetCamActive(sceneCam, true)
    RenderScriptCams(true, true, 1000, true, true)

    NetworkStartSynchronisedScene(scene_1)
    Wait(GetAnimDuration(anim_dict, 'enter') * 1000-1000)
    
    NetworkStartSynchronisedScene(scene_2)
    Wait(GetAnimDuration(anim_dict, 'grab') * 1000 - 3000)
    -- TriggerServerEvent('exp_trainheist:objectSync', NetworkGetNetworkIdFromEntity(gold))
    
    SetCamActive(sceneCam, false)
    RenderScriptCams(false, true, 1000, true, true)

    DeleteObject(gold)
    
    NetworkStartSynchronisedScene(scene_4)
    Wait(GetAnimDuration(anim_dict, 'exit_bag') * 1000)
    
    TriggerServerEvent('exp_trainheist:GiveGold')
    DeleteObject(bag)
    TriggerEvent("skinchanger:change", "bags_1", self_bag)
    FreezeEntityPosition(ped, false)

    return true
end