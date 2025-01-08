fx_version 'cerulean'
game 'gta5' 
lua54 'yes'

dependencies {
    'lockpick'
}


shared_scripts {
    '@es_extended/imports.lua',
    'config.lua'
}

client_scripts {
    '@ox_lib/init.lua',
    'client/cl_main.lua'  -- Ensure the main client script is explicitly included
}

server_scripts {
	"@oxmysql/lib/MySQL.lua",
    'server/*.lua'
}