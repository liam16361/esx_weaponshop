ESX = nil
local shopItems = {}
local miscItems = {}

TriggerEvent('esx:getSharedObject', function(obj) 
	ESX = obj 	
	if shopItems["GunShop"] == nil then
		shopItems["GunShop"] = {}
	end

	local items = Config.Zones.GunShop.Items
	for i=1, #items do 
		items[i].label = items[i].label ~= nil and items[i].label or ESX.GetWeaponLabel(items[i].item)
	end
	Config.Zones.GunShop.Items = items

	if miscItems["GunShop"] == nil then
		miscItems["GunShop"] = {}
	end

	local items = Config.Zones.GunShop.MiscItems
	for i=1, #items do 
		items[i].label = items[i].label ~= nil and items[i].label or ESX.GetItemLabel(items[i].item)
	end
	Config.Zones.GunShop.MiscItems = items

	shopItems["GunShop"] = Config.Zones.GunShop.Items
	miscItems["GunShop"] = Config.Zones.GunShop.MiscItems
	TriggerClientEvent('esx_weaponshop:sendShop', -1, shopItems)
	TriggerClientEvent('esx_weaponshop:sendMiscItems', -1, miscItems)
end)

ESX.RegisterServerCallback('esx_weaponshop:getShop', function(source, cb)
	cb(shopItems)
end)

ESX.RegisterServerCallback('esx_weaponshop:getMiscItems', function(source, cb)
	if miscItems["GunShop"] == nil then
		miscItems["GunShop"] = {}
	end

	local items = Config.Zones.GunShop.MiscItems
	for i=1, #items do 
		items[i].label = items[i].label ~= nil and items[i].label or ESX.GetItemLabel(items[i].item)
	end
	Config.Zones.GunShop.MiscItems = items

	shopItems["GunShop"] = Config.Zones.GunShop.Items
	miscItems["GunShop"] = Config.Zones.GunShop.MiscItems
	cb(miscItems)
end)

ESX.RegisterServerCallback('esx_weaponshop:buyWeapon', function(source, cb, weaponName)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = GetPrice(weaponName)

	if price == 0 then
		print(('esx_weaponshop: %s attempted to buy a unknown weapon!'):format(xPlayer.identifier))
		cb(false)
	else
		if xPlayer.hasWeapon(weaponName) then
			xPlayer.showNotification(_U('already_owned'))
			cb(false)
		else
			if xPlayer.getMoney() >= price then
				xPlayer.removeMoney(price)
				xPlayer.addWeapon(weaponName, 1000)

				cb(true)
			else
				xPlayer.showNotification(_U('not_enough'))
				cb(false)
			end
		end
	end
end)

ESX.RegisterServerCallback('esx_weaponshop:buyItem', function(source, cb, itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local price = IsItemBuyable(source, itemName, count) 
	if (price ~= nil and count > 0) then 
		xPlayer.addInventoryItem(itemName, count)
		xPlayer.removeMoney(price)
		cb(true)
	else
		cb(false)
	end
end)

function GetPrice(weaponName)
	local items = Config.Zones.GunShop.Items
	for i=1, #items do 
		if (items[i].item == weaponName) then 
			return items[i].price
		end
	end
end

function IsItemBuyable(source, itemName, count) 
	local xPlayer = ESX.GetPlayerFromId(source)
	local item = xPlayer.getInventoryItem(itemName)
	local price = nil
	local items = Config.Zones.GunShop.MiscItems
	for i=1, #items do 
		if (items[i].item == itemName) then 
			price = items[i].price
		end
	end
	return (itemName ~= nil and item ~= nil and item.count + count <= item.limit and price ~= nil and xPlayer.getMoney() - (price * count) >= 0) and price * count or nil
end

-- ITEMS

ESX.RegisterUsableItem('ammoclip', function(source)
	TriggerClientEvent('esx_weaponshop:useItem', source, "ammoclip")
end)

ESX.RegisterUsableItem('bulletproof', function(source)
	TriggerClientEvent('esx_weaponshop:useItem', source, "bulletproof")
end)

ESX.RegisterUsableItem('medikit', function(source)
	TriggerClientEvent('esx_weaponshop:useItem', source, "medikit")
end)

RegisterServerEvent("esx_weaponshop:removeItem")
AddEventHandler("esx_weaponshop:removeItem", function(itemName, count)
	local xPlayer = ESX.GetPlayerFromId(source)
	local item = xPlayer.getInventoryItem(itemName)
	if (item.count - count >= 0) then 
		xPlayer.removeInventoryItem(itemName, count)
	end
end)