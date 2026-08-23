fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Rico Scripts'
description 'Server-authoritative ESX winkels voor ox_inventory'
version '1.1.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client/main.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependencies {
    'es_extended',
    'ox_lib',
    'ox_target',
    'ox_inventory',
    'oxmysql'
}
