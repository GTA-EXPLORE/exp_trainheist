fx_version 'cerulean'
game 'gta5'
lua54 'yes'
version '2.0.0'
author 'EXPLORE - MilyonJames'

author 'EXPLORE, MilyonJames'
description 'https://www.gta-explore.com'

shared_scripts {
    "@ox_lib/init.lua", -- This can be commented if you're not using ox_lib's notifications
    "@sd_lib/init.lua",
	'config.lua',
}

client_scripts {
	'client/*',
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
    'server/*'
}

files {
    "locales/*",
    "client/sounds/*"
}