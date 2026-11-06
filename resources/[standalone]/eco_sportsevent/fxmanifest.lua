fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'eco_sportsevent'
author 'Eco Development Suite'
description 'San Andreas Sports & Expedition Suite (Four Summit, Running Fest, Triathlon)'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/foursummit.lua',
    -- Modul mendatang:
    -- 'client/marathon/*.lua',
    -- 'client/triathlon/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/foursummit.lua',
    -- Modul mendatang:
    -- 'server/marathon/*.lua',
    -- 'server/triathlon/*.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js'
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'oxmysql'
}
