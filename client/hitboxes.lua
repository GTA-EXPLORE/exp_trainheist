RegisterNetEvent("exp_trainheist:CreateHitbox", function (data)
    _RequestModel(GetHashKey(data.model))
    local hitbox = CreateObject(GetHashKey(data.model), data.position)
    FreezeEntityPosition(hitbox, true)
    SetEntityRotation(hitbox, data.rotation.x, data.rotation.y, data.rotation.z)
    SetEntityInvincible(hitbox, true)
    SetEntityVisible(hitbox, false)
    AddEntityMenuItem({
        entity = hitbox,
        event = data.event,
        name = data.name,
        desc = data.description
    })
    Entities[#Entities+1] = hitbox

    Hitboxes[hitbox] = data.data

    HitboxRegister[hitbox] = data.id
end)

RegisterNetEvent("exp_trainheist:RemoveHitbox", function (data)
    for key, value in pairs(HitboxRegister) do
        if value == data.id then
            DeleteEntity(key)
            return
        end
    end
end)