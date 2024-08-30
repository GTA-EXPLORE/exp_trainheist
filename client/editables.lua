function ShowNotification(event)
    SD.ShowNotification(event.message, event.type)
end

function DoesPedHaveAnyBag(ped)
    return GetPedDrawableVariation(ped, 5) > 0
end