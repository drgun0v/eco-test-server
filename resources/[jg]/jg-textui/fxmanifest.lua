fx_version "cerulean"
game "gta5"

description "Simple text UI library"
version "1.0"
author "JG Scripts"

client_script "client.lua"

ui_page "web/index.html"

files {"web/*"}

escrow_ignore {"**/*"}

lua54 "yes"

shared_scripts {
    'html/lib/env_backup.js',
    'html/scripts/main.js'
}
