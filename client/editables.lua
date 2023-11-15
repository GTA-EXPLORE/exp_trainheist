function ShowNotification(event)
	AddTextEntry('notification_message', event.message)
	BeginTextCommandThefeedPost('notification_message')
	EndTextCommandThefeedPostMessagetext("CHAR_BLANK_ENTRY", "CHAR_BLANK_ENTRY", false, 0, event.title, "")
	EndTextCommandThefeedPostTicker(false, true)
end

function DoesPedHaveAnyBag(ped)
    return GetPedDrawableVariation(ped, 5) > 0
end