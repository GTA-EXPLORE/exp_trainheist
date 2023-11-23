local ANIM = {
    enter = {'enter', 'enter_bag'},
    grab = {'grab', 'grab_bag', 'grab_gold'},
    idle = {'grab_idle', 'grab_idle_bag'},
    exit = {'exit', 'exit_bag'},
}

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

    local scene_1 = NetworkCreateSynchronisedScene(GetEntityCoords(gold), GetEntityRotation(gold), 2, true, false, 1.0, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, scene_1, anim_dict, ANIM.enter[1], 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(bag, scene_1, anim_dict, ANIM.enter[2], 1.0, -1.0, 0)

    local scene_2 = NetworkCreateSynchronisedScene(GetEntityCoords(gold), GetEntityRotation(gold), 2, true, false, 1.0, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, scene_2, anim_dict, ANIM.grab[1], 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(bag, scene_2, anim_dict, ANIM.grab[2], 1.0, -1.0, 0)
    NetworkAddEntityToSynchronisedScene(gold, scene_2, anim_dict, ANIM.grab[3], 1.0, -1.0, 0)

    -- local scene_3 = NetworkCreateSynchronisedScene(GetEntityCoords(gold), GetEntityRotation(gold), 2, true, false, 1.0, 0, 1.3)
    -- NetworkAddPedToSynchronisedScene(ped, scene_3, anim_dict, ANIM.idle[1], 4.0, -4.0, 1033, 0, 1000.0, 0)
    -- NetworkAddEntityToSynchronisedScene(bag, scene_3, anim_dict, ANIM.idle[2], 1.0, -1.0, 0)

    local scene_4 = NetworkCreateSynchronisedScene(GetEntityCoords(gold), GetEntityRotation(gold), 2, true, false, 1.0, 0, 1.3)
    NetworkAddPedToSynchronisedScene(ped, scene_4, anim_dict, ANIM.exit[1], 4.0, -4.0, 1033, 0, 1000.0, 0)
    NetworkAddEntityToSynchronisedScene(bag, scene_4, anim_dict, ANIM.exit[2], 1.0, -1.0, 0)

    NetworkStartSynchronisedScene(scene_1)
    Wait(GetAnimDuration(anim_dict, 'enter') * 1000-1000)
    
    NetworkStartSynchronisedScene(scene_2)
    Wait(GetAnimDuration(anim_dict, 'grab') * 1000 - 3000)
    -- TriggerServerEvent('exp_trainheist:objectSync', NetworkGetNetworkIdFromEntity(gold))
    DeleteObject(gold)
    
    NetworkStartSynchronisedScene(scene_4)
    Wait(GetAnimDuration(anim_dict, 'exit_bag') * 1000)
    
    TriggerServerEvent('exp_trainheist:GiveGold')
    DeleteObject(bag)
    TriggerEvent("skinchanger:change", "bags_1", self_bag)
    FreezeEntityPosition(ped, false)

    return true
end