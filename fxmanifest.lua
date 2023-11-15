fx_version "adamant"
game "gta5"
lua54 'yes'

author 'EXPLORE, MilyonJames'
description 'https://www.gta-explore.com'

client_scripts {
	"locales/*",
	'config.lua',
	'client/*',
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
	"locales/*",
	'config.lua',
    'server/*'
}
