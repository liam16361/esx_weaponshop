fx_version 'adamant'

game 'gta5'

description 'Custom ESX Weapon Shop'
author 'liam16361' 
version '1.1.0'

server_scripts {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/es.lua',
	'locales/pl.lua',
	'locales/sv.lua',
	'locales/cs.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'locales/de.lua',
	'locales/br.lua',
	'locales/en.lua',
	'locales/fi.lua',
	'locales/fr.lua',
	'locales/es.lua',
	'locales/pl.lua',
	'locales/sv.lua',
	'locales/cs.lua',
	'client/main.lua'
}

dependency 'es_extended'
