fx_version 'cerulean'

shared_script "@SecureServe/src/module/module.lua"
shared_script "@SecureServe/src/module/module.js"
file "@SecureServe/secureserve.key"

game 'gta5'
lua54 'yes'
author 'Peleg'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'bridge/shared.lua',
}

client_scripts {
    'bridge/client.lua',
    'client/main.lua',
    'client/oxygen.lua',
    'client/containers.lua',
    'client/rental.lua',
    'client/zones.lua',
}

server_scripts {
    'bridge/server.lua',
    'server/main.lua',
    'server/divegear.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

escrow_ignore {
    'config.lua',
}