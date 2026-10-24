fx_version 'cerulean'
game 'gta5'
author 'Marttins | MT Scripts'
description 'Advanced FiveM restaurants script'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    --'@qbx_core/modules/lib.lua',
    'config/*.lua',
    'restaurants/*.lua'
}

-- CORRECTED CLIENT SCRIPTS: Removed the extra nested block
client_scripts {
    -- This specific order fixes all load errors
    'client/offlineShops.lua',
    'client/functions.lua',
    'client/main.lua',
    
    -- Load the rest of the files
    'client/admin.lua',
    'client/boxes.lua',
    'client/chairs.lua',
    'client/consumeables.lua',
    'client/delivery.lua',
    'client/drivethru.lua',
    'client/garage.lua',
    'client/management.lua',
    'client/menus.lua',
    'client/music.lua',
    'client/prepare.lua',
    'client/registers.lua',
    'client/stations.lua',
    'client/stations_clean.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
}

ui_page 'web/index.html'

-- CORRECTED FILES: Added the new style.css
files {
    'locales/*.json',
    'web/*.html',
    'web/*.js',
    'web/style.css' -- ADDED THIS LINE
}

escrow_ignore {
    'client/functions.lua',
    'server/functions.lua',
    'server/callbacks.lua',
    'server/delivery.lua',
    'config/*.lua',
    'restaurants/*.lua'
}
dependency '/assetpacks'