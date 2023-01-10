ESX = nil
local HasAlreadyEnteredMarker = false
local LastZone = nil
local CurrentAction = nil
local CurrentActionMsg = ''
local CurrentActionData = {}
local ShopOpen = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	ESX.TriggerServerCallback('esx_weaponshop:getShop', function(shopItems)
		for k,v in pairs(shopItems) do
			Config.Zones[k].Items = v
		end
	end)
	
	ESX.TriggerServerCallback('esx_weaponshop:getMiscItems', function(miscItems)
		for k,v in pairs(miscItems) do
			Config.Zones[k].MiscItems = v
		end
	end)
end)

RegisterNetEvent('esx_weaponshop:sendShop')
AddEventHandler('esx_weaponshop:sendShop', function(shopItems)
	for k,v in pairs(shopItems) do
		Config.Zones[k].Items = v
	end
end)

RegisterNetEvent('esx_weaponshop:sendMiscItems')
AddEventHandler('esx_weaponshop:sendMiscItems', function(miscItems)
	for k,v in pairs(miscItems) do
		Config.Zones[k].MiscItems = v
	end
end)

function OpenShopMenu(zone)
	menu_open = true
	local elements = {}
	ShopOpen = true

	for i=1, #Config.Zones[zone].Items, 1 do
		local item = Config.Zones[zone].Items[i]

		table.insert(elements, {
			label = ('%s - <span style="color: green;">%s</span>'):format(item.label, _U('shop_menu_item', ESX.Math.GroupDigits(item.price))),
			price = item.price,
			weaponName = item.item
		})
	end

	ESX.UI.Menu.CloseAll()
	PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop', {
		title = "Weapons",
		align = 'top-left',
		elements = elements
	}, function(data, menu)
		ESX.TriggerServerCallback('esx_weaponshop:buyWeapon', function(bought)
			if bought then
				DisplayBoughtScaleform(data.current.weaponName, data.current.price)
			else
				PlaySoundFrontend(-1, 'ERROR', 'HUD_AMMO_SHOP_SOUNDSET', false)
			end
		end, data.current.weaponName, zone)
	end, function(data, menu)
		PlaySoundFrontend(-1, 'BACK', 'HUD_AMMO_SHOP_SOUNDSET', false)
		ShopOpen = false
		menu.close()
		OpenMenu("main")
		CurrentAction     = 'shop_menu'
		CurrentActionMsg  = _U('shop_menu_prompt')
		CurrentActionData = { zone = zone }
	end, function(data, menu)
		PlaySoundFrontend(-1, 'NAV', 'HUD_AMMO_SHOP_SOUNDSET', false)
	end)
end

function DisplayBoughtScaleform(weaponName, price)
	local scaleform = ESX.Scaleform.Utils.RequestScaleformMovie('MP_BIG_MESSAGE_FREEMODE')
	local sec = 4

	BeginScaleformMovieMethod(scaleform, 'SHOW_WEAPON_PURCHASED')

	PushScaleformMovieMethodParameterString(_U('weapon_bought', ESX.Math.GroupDigits(price)))
	PushScaleformMovieMethodParameterString(ESX.GetWeaponLabel(weaponName))
	PushScaleformMovieMethodParameterInt(GetHashKey(weaponName))
	PushScaleformMovieMethodParameterString('')
	PushScaleformMovieMethodParameterInt(100)

	EndScaleformMovieMethod()

	PlaySoundFrontend(-1, 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET', false)

	Citizen.CreateThread(function()
		while sec > 0 do
			Citizen.Wait(0)
			sec = sec - 0.01
	
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		end
	end)
end

AddEventHandler('esx_weaponshop:hasEnteredMarker', function(zone)
	if zone == 'GunShop' or zone == 'BlackWeashop' then
		CurrentAction     = 'shop_menu'
		CurrentActionMsg  = _U('shop_menu_prompt')
		CurrentActionData = { zone = zone }
	end
end)

AddEventHandler('esx_weaponshop:hasExitedMarker', function(zone)
	CurrentAction = nil
	ESX.UI.Menu.CloseAll()
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if ShopOpen then
			ESX.UI.Menu.CloseAll()
		end
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	for i = 1, #Config.Zones.GunShop.Locations, 1 do
		local blip = AddBlipForCoord(Config.Zones.GunShop.Locations[i])

		SetBlipSprite (blip, 110)
		SetBlipDisplay(blip, 4)
		SetBlipScale  (blip, 1.0)
		SetBlipColour (blip, 81)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName("STRING")
		AddTextComponentSubstringPlayerName(_U('map_blip'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Find closest Marker
Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(250)
		local closest
		local closestDist
		local coords = GetEntityCoords(PlayerPedId())
		for i = 1, #Config.Zones.GunShop.Locations, 1 do
			local dist = GetDistanceBetweenCoords(coords, Config.Zones.GunShop.Locations[i], true)
			if (dist < Config.DrawDistance and dist < (closestDist ~= nil and closestDist or dist + 1)) then
				closest = i
				closestDist = dist
				break
			end
		end
		ClosestMarker = closest
	end
end) 

function OpenMenu(type)
	if (type == "main") then 
		menu_open = true
		-- {label = "Armor - <span style='color: green;'>$" .. 6000 .."</span>", value = "weapons"},
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'main_shop', {
			title = "Ammu-nation",
			align = 'top-left',
			elements = {
				{label = "Weapons", value = "weapons"},
				{label = "Items", value = "items"}
			}
		}, function(data, menu)
			menu.close()
			OpenMenu(data.current.value)
		end, function(data, menu)
			menu_open = false
			menu.close()
		end)

	elseif (type == "weapons") then
		OpenShopMenu("GunShop")
	elseif (type == "items") then
		menu_open = true
		-- {label = "Armor - <span style='color: green;'>$" .. 6000 .."</span>", value = "weapons"},
		local elements = {}
		for i=1, #Config.Zones["GunShop"].MiscItems, 1 do
			local item = Config.Zones["GunShop"].MiscItems[i]
			table.insert(elements, {
				label = ('%s - <span style="color: green;">%s</span>'):format(item.label, _U('shop_menu_item', ESX.Math.GroupDigits(item.price))),
				price = item.price,
				item = item.item,
				value = 1,
				type       = 'slider',
				min        = 1,
				max        = 100
			})
		end
		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'items', {
			title = "Items",
			align = 'top-left',
			elements = elements
		}, function(data, menu)
			ESX.TriggerServerCallback("esx_weaponshop:buyItem", function(bought) 
				if bought then
					PlaySoundFrontend(-1, 'WEAPON_PURCHASE', 'HUD_AMMO_SHOP_SOUNDSET', false)
				else
					PlaySoundFrontend(-1, 'ERROR', 'HUD_AMMO_SHOP_SOUNDSET', false)
				end
			end, data.current.item, data.current.value)

		end, function(data, menu)
			menu.close()
			OpenMenu("main")
		end)
	end
end

-- Marker interaction & Drawing
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local coords = GetEntityCoords(PlayerPedId())
		if (ClosestMarker ~= nil) then 
			DrawMarker(Config.Type, Config.Zones.GunShop.Locations[ClosestMarker], 0.0, 0.0, 0.0, 0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.Color.r, Config.Color.g, Config.Color.b, 100, false, true, 2, false, false, false, false)
			if GetDistanceBetweenCoords(coords, Config.Zones.GunShop.Locations[ClosestMarker], true) < Config.Size.x then			
				ESX.ShowHelpNotification(_U("shop_menu_prompt"))

				if IsControlJustReleased(0, 38) then
					OpenMenu("main")
				end
			elseif (menu_open) then 
				ESX.UI.Menu.CloseAll()
				menu_open = false
			end
		end
	end
end)

RegisterNetEvent('esx_weaponshop:useItem')
AddEventHandler('esx_weaponshop:useItem', function(itemName)
	local ped = PlayerPedId()
	if (itemName == "ammoclip") then
		if IsPedArmed(ped, 4) then
			local hash = GetSelectedPedWeapon(ped)
			if hash ~= nil then
				TriggerServerEvent('esx_weaponshop:removeItem', "ammoclip", 1)
				AddAmmoToPed(ped, hash, 1000)
				MakePedReload(ped)
				ESX.ShowNotification("You have used an ammo clip.")
			else
				ESX.ShowNotification("You can't use this without having a valid weapon out.")
			end
		else
			ESX.ShowNotification("You can't use this without having a weapon out.")
		end
	elseif (itemName == "bulletproof") then
		AddArmourToPed(ped, 100)
		SetPedArmour(ped, 100)
		TriggerServerEvent('esx_weaponshop:removeItem', "bulletproof", 1)
	elseif (itemName == "medikit") then
		SetEntityHealth(ped, GetEntityMaxHealth(ped))
		TriggerServerEvent('esx_weaponshop:removeItem', "medikit", 1)
	end
end)