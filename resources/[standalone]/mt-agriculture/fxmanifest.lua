fx_version 'cerulean'
game 'gta5'

name 'mt-agriculture'
author 'dragun0v'
description 'Hardcore farming backbone – Phase 1 Wheat → Flour'
version '0.2.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config/*.lua'
}

client_scripts {
    'client/main.lua',
    'client/fields.lua',
    'client/processing.lua',
    'client/shops.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua',
    'server/crops.lua',
    'server/processing.lua',
    'server/market.lua',
    'server/shops.lua',
}
