local ANIM = {
    objects = {
        'tr_prop_tr_grinder_01a',
        'ch_p_m_bag_var02_arm_s'
    },
    animations = { 'action', 'action_container', 'action_lock', 'action_angle_grinder', 'action_bag'}
}

function AnimateContainerOpening(data)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local anim_dict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
    _RequestAnimDict(anim_dict)
    _RequestNamedPtfxAsset('scr_tn_tr')
    
    local objects = {}
    for index, value in ipairs(ANIM.objects) do
        local model = GetHashKey(value)
        _RequestModel(model)
        objects[index] = CreateObject(model, coords, true, true, false)
        SetEntityCollision(objects[index], false)
    end
    
    local self_bag
    TriggerEvent("skinchanger:getSkin", function(skin)
        self_bag = skin.bags_1
        TriggerEvent("skinchanger:change", "bags_1", -1)
    end)

    local container = NetworkGetEntityFromNetworkId(data.container)
    local lock = NetworkGetEntityFromNetworkId(data.lock)

    local scene = NetworkCreateSynchronisedScene(GetEntityCoords(container), GetEntityRotation(container), 2, true, false, 1.0, 0.0, 1.0)

    NetworkAddPedToSynchronisedScene(ped, scene, anim_dict, ANIM.animations[1], 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(container, scene, anim_dict, ANIM.animations[2], 1.0, -1.0, 0)
    NetworkAddEntityToSynchronisedScene(lock, scene, anim_dict, ANIM.animations[3], 1.0, -1.0, 0)
    NetworkAddEntityToSynchronisedScene(objects[1], scene, anim_dict, ANIM.animations[4], 1.0, -1.0, 0)
    NetworkAddEntityToSynchronisedScene(objects[2], scene, anim_dict, ANIM.animations[5], 1.0, -1.0, 0)

    SetEntityCoords(ped, GetEntityCoords(container))
    NetworkStartSynchronisedScene(scene)
    
    Wait(4000)

    UseParticleFxAssetNextCall('scr_tn_tr')
    local sparks = StartParticleFxLoopedOnEntity("scr_tn_tr_angle_grinder_sparks", objects[1], 0.0, 0.25, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false, 1065353216, 1065353216, 1065353216, 1)
    
    Wait(1000)

    StopParticleFxLooped(sparks, true)
    
    Wait(GetAnimDuration(anim_dict, 'action') * 1000 - 5000)
    
    
    TriggerServerEvent('exp_trainheist:SynchronizeContainer', {
        position = GetEntityCoords(container),
        rotation = GetEntityRotation(container)
    })
    for index, value in ipairs(objects) do
        DeleteObject(value)
    end
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
    PlaySynchronizedEntityAnim(container, scene, ANIM.animations[2], anim_dict, 1.0, -1.0, 0, 0)
    ForceEntityAiAndAnimationUpdate(container)
    PlaySynchronizedEntityAnim(lock, scene, ANIM.animations[3], anim_dict, 1.0, -1.0, 0, 0)
    ForceEntityAiAndAnimationUpdate(lock)

    SetSynchronizedScenePhase(scene, 0.99)
    SetEntityCollision(container, false, true)
    FreezeEntityPosition(container, true)
end)