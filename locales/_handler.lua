Locales = {}
function _(str, ...)
	if Locales[LANGUAGE] ~= nil then
		if Locales[LANGUAGE][str] ~= nil then
			return string.format(Locales[LANGUAGE][str], ...)
		else
			return 'Missing [' .. LANGUAGE .. '][' .. str .. '] translation.'
		end

	else
		return 'Missing [' .. LANGUAGE .. '] locale.'
	end
end