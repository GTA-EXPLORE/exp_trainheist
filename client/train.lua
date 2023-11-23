local hid = 0
function BuildTrain()
    Wagons, Containers, Hitboxes = {}, {}, {}
    local train = {}
    local loot_pos = math.random(TRAIN.length)
    for i = 1, TRAIN.length do
        if i == loot_pos then
            table.insert(train, "freightcar")
        else
            table.insert(train, TRAIN_PARTS[math.random(#TRAIN_PARTS)])
        end
    end

    -- BUILD

    Wagons[1] = SpawnWagon(GetHashKey("freight"), TRAIN.position, TRAIN.heading)
    Entities[#Entities+1] = Wagons[1]

    local fwd = GetForwardVectorFromHeading(TRAIN.heading)
    local prev_position = TRAIN.position
    for index, value in ipairs(train) do
        local model = GetHashKey(value)
        _RequestModel(model)
        local dim_max, dim_min = GetModelDimensions(model)
        local length = (dim_min - dim_max).y/2
        dim_max, dim_min = GetModelDimensions(GetEntityModel(Wagons[#Wagons]))
        local prev_length = (dim_min - dim_max).y/2
        
        local position = vector3(
            prev_position.x+fwd.x*(length+prev_length),
            prev_position.y+fwd.y*-1*(length+prev_length),
            prev_position.z
        )
        local retval, groundZ = GetGroundZFor_3dCoord_2(position.x, position.y, position.z, true)
        position = vector3(position.xy, groundZ+0.1)
        
        local wagon = SpawnWagon(model, position, TRAIN.heading)
        Wagons[index+1] = wagon
        Entities[#Entities+1] = wagon
        prev_position = position

        if value == "freightcar" then
            SetupContainers(wagon)
        end
    end

    -- LOOTS
    local cp_containers = DeepCopy(Containers)
    for i = 1, 2 do
        local rand = math.random(#cp_containers)
        SetupLoot(cp_containers[rand])
        table.remove(cp_containers, rand)
    end
    
    return {
        center = vector3(
            (prev_position.x + TRAIN.position.x)/2,
            (prev_position.y + TRAIN.position.y)/2,
            (prev_position.z + TRAIN.position.z)/2
        )
    }
end

---@param model number Model hash
---@param position vector3 World position
---@param heading number Heading
---@return number Wagon Entity spawned
function SpawnWagon(model, position, heading)
    _RequestModel(model)
    local vehicle = CreateVehicle(model, position, heading, true, true)
    
    FreezeEntityPosition(vehicle, true)
    SetEntityRotation(vehicle, TRAIN.angle, 0.0, heading)

    RequestCollisionAtCoord(position)
	while not HasCollisionLoadedAroundEntity(vehicle) do Wait(1) end
    return vehicle
end

---@param entity number Entity handle
function SetupContainers(entity)
    local rotation = GetEntityRotation(entity)
    
    -- Front Container
    _RequestModel(GetHashKey('tr_prop_tr_container_01a'))
    local container_1 = CreateObject(GetHashKey('tr_prop_tr_container_01a'), GetOffsetFromEntityInWorldCoords(entity, vector3(0.0, 4.2, -0.3)), true, true, false)
    while not NetworkDoesNetworkIdExist(NetworkGetNetworkIdFromEntity(container_1)) do Wait(10)
        NetworkRegisterEntityAsNetworked(container_1)
    end
    SetEntityRotation(container_1, rotation)
    FreezeEntityPosition(container_1, true)
    Entities[#Entities+1] = container_1
    Containers[#Containers+1] = container_1

    _RequestModel(GetHashKey('tr_prop_tr_lock_01a'))
    local lock_1 = CreateObject(GetHashKey('tr_prop_tr_lock_01a'), GetOffsetFromEntityInWorldCoords(container_1, vector3(0.0, -1.8, 1.15)), true, true, false)
    while not NetworkDoesNetworkIdExist(NetworkGetNetworkIdFromEntity(lock_1)) do Wait(10)
        NetworkRegisterEntityAsNetworked(lock_1)
    end
    SetEntityRotation(lock_1, rotation)
    FreezeEntityPosition(lock_1, true)
    SetEntityCollision(lock_1, false)
    Entities[#Entities+1] = lock_1

    hid = hid + 1
    TriggerServerEvent("exp_trainheist:CreateHitbox", {
        model = "apa_mp_h_acc_artwalll_01",
        position = GetOffsetFromEntityInWorldCoords(entity, vector3(0.0, 2.35, -0.3)),
        rotation = rotation,
        event = "exp_trainheist:CutDoor",
        description = _("cut_door"),
        name = _("door_name"),
        id = hid,
        data = {
            container = NetworkGetNetworkIdFromEntity(container_1),
            lock = NetworkGetNetworkIdFromEntity(lock_1)
        }
    })

    -- Rear Container
    local container_2 = CreateObject(GetHashKey('tr_prop_tr_container_01a'), GetOffsetFromEntityInWorldCoords(entity, vector3(0.0, -4.2, -0.3)), true, true, false)
    while not NetworkDoesNetworkIdExist(NetworkGetNetworkIdFromEntity(container_2)) do Wait(10)
        NetworkRegisterEntityAsNetworked(container_2)
    end
    SetEntityRotation(container_2, rotation.x-2*TRAIN.angle, rotation.y, rotation.z+180)
    FreezeEntityPosition(container_2, true)
    Entities[#Entities+1] = container_2
    Containers[#Containers+1] = container_2
    
    local lock_2 = CreateObject(GetHashKey('tr_prop_tr_lock_01a'), GetOffsetFromEntityInWorldCoords(container_2, vector3(0.0, -1.8, 1.15)), true, true, false)
    while not NetworkDoesNetworkIdExist(NetworkGetNetworkIdFromEntity(lock_2)) do Wait(10)
        NetworkRegisterEntityAsNetworked(lock_2)
    end
    SetEntityRotation(lock_2, rotation.x-2*TRAIN.angle, rotation.y, rotation.z+180)
    FreezeEntityPosition(lock_2, true)
    SetEntityCollision(lock_2, false)
    Entities[#Entities+1] = lock_2
    
    hid = hid + 1
    TriggerServerEvent("exp_trainheist:CreateHitbox", {
        model = "apa_mp_h_acc_artwalll_01",
        position = GetOffsetFromEntityInWorldCoords(entity, vector3(0.0, -2.4, -0.3)),
        rotation = vector3(rotation.x-2*TRAIN.angle, rotation.y, rotation.z+180),
        event = "exp_trainheist:CutDoor",
        description = _("cut_door"),
        name = _("door_name"),
        id = hid,
        data = {
            container = NetworkGetNetworkIdFromEntity(container_2),
            lock = NetworkGetNetworkIdFromEntity(lock_2)
        }
    })
end

---@param entity number Entity Handle
function SetupLoot(entity)
    local rotation = GetEntityRotation(entity)
    
    -- TABLE
    _RequestModel(GetHashKey('xm_prop_lab_desk_02'))
    local table = CreateObject(GetHashKey('xm_prop_lab_desk_02'), GetOffsetFromEntityInWorldCoords(entity, vector3(0.0, 1.0, 0.2)), true, true, false)
    SetEntityRotation(table, rotation)
    FreezeEntityPosition(table, true)
    Entities[#Entities+1] = table
    

    -- GOLD
    _RequestModel(GetHashKey('h4_prop_h4_gold_stack_01a'))
    local gold = CreateObject(GetHashKey('h4_prop_h4_gold_stack_01a'), GetOffsetFromEntityInWorldCoords(table, vector3(0.0, 0.0, 0.9)), true, true, false)
    while not NetworkDoesNetworkIdExist(NetworkGetNetworkIdFromEntity(gold)) do Wait(10)
        NetworkRegisterEntityAsNetworked(gold)
    end
    SetEntityRotation(gold, rotation)
    FreezeEntityPosition(gold, true)
    Entities[#Entities+1] = gold

    hid = hid + 1
    TriggerServerEvent("exp_trainheist:CreateHitbox", {
        model = "apa_mp_h_acc_box_trinket_01",
        position = GetEntityCoords(gold),
        rotation = rotation,
        event = "exp_trainheist:GrabGold",
        description = _("grab_gold"),
        name = _("gold_name"),
        id = hid,
        data = {
            gold = NetworkGetNetworkIdFromEntity(gold)
        }
    })
end