fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'
lua54 'yes'

name 'Zombie Spawners'
author 'MrAnthac'
description 'Spawner de zombies pour RedM'
version '0.0.1'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/commands.lua',
    'server/server.lua'
}