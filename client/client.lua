--[[


     ██╗███████╗██████╗ ██╗ ██████╗ ██████╗ ███████╗██╗  ██╗ ██╗ ██╗ ██████╗ ███████╗ ██╗██████╗ 
     ██║██╔════╝██╔══██╗██║██╔════╝██╔═══██╗██╔════╝╚██╗██╔╝████████╗╚════██╗██╔════╝███║╚════██╗
     ██║█████╗  ██████╔╝██║██║     ██║   ██║█████╗   ╚███╔╝ ╚██╔═██╔╝ █████╔╝███████╗╚██║ █████╔╝
██   ██║██╔══╝  ██╔══██╗██║██║     ██║   ██║██╔══╝   ██╔██╗ ████████╗ ╚═══██╗╚════██║ ██║██╔═══╝ 
╚█████╔╝███████╗██║  ██║██║╚██████╗╚██████╔╝██║     ██╔╝ ██╗╚██╔═██╔╝██████╔╝███████║ ██║███████╗
 ╚════╝ ╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝ ╚═╝ ╚═╝ ╚═════╝ ╚══════╝ ╚═╝╚══════╝
                                                                                                 

 ]]

 
 RSCore = nil
 player = nil
 coords = {}
 curVehicle = nil
 driver = nil
 jerico = 0
 
 Citizen.CreateThread(
	 function()
		 while RSCore == nil do
			 TriggerEvent("RSCore:GetObject",function(obj)RSCore = obj
				 end)
			 Citizen.Wait(400)
		 end
		 while true do
			 player = PlayerPedId()
			 coords = GetEntityCoords(player)
			 curVehicle = GetVehiclePedIsIn(player, false)
			 driver = GetPedInVehicleSeat(curVehicle, -1)
			 Citizen.Wait(100)
		 end

	 end
 )
 plyShopID = 0
 emptyShops = {}


RegisterNetEvent('RSCore:Client:OnPlayerLoaded')
AddEventHandler('RSCore:Client:OnPlayerLoaded', function()
	PlayerJob = RSCore.Functions.GetPlayerData().job
	TriggerServerEvent("t1ger_mechanicjob:fetchMechShops")
end)

RegisterNetEvent('RSCore:Client:OnJobUpdate')
AddEventHandler('RSCore:Client:OnJobUpdate', function(JobInfo)
	PlayerJob = JobInfo
end)


Citizen.CreateThread(function()
	Wait(500)
	if RSCore.Functions.GetPlayerData() ~= nil then
		PlayerJob = RSCore.Functions.GetPlayerData().job
		onDuty = true
	end
end)

local bossMenu, storageMenu, workbenchMenu = nil, nil, nil
local distance                             = 0
Citizen.CreateThread(function()
	while true do

		local pos = GetEntityCoords(PlayerPedId(), true)

		for k, v in pairs(Config.MechanicShops) do
			distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.menuPos[1], v.menuPos[2], v.menuPos[3], true)
			if distance <= 6.0 then
				bossMenuFunction(k, v, distance)

			end
			-- Storage Menu:
			distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.storage[1], v.storage[2], v.storage[3], true)
			if distance <= 6.0 then
				storageMenuFunction(k, v, distance)
			end
			-- Workbench Menu:
			distance = GetDistanceBetweenCoords(coords.x, coords.y, coords.z, v.workbench[1], v.workbench[2], v.workbench[3], true)
			if distance <= 6.0 then
				workbenchMenuFunction(k, v, distance)
			end
		end

		Citizen.Wait(1)
	end
end)

RegisterNetEvent('RSCore:Client:SetDuty')
AddEventHandler('RSCore:Client:SetDuty', function(duty)
	onDuty = duty
end)

 RegisterNetEvent("t1ger_mechanicjob:fetchMechShopsCL")
 AddEventHandler("t1ger_mechanicjob:fetchMechShopsCL",function(shopID1)
		 plyShopID = shopID1
		 for k, v in pairs(shopBlips) do
			 RemoveBlip(v)
		 end
		 RSCore.Functions.TriggerCallback("t1ger_mechanicjob:getTakenShops",function(ownedShops)
			 for k, v in pairs(ownedShops) do
					 if v.shopID ~= plyShopID then
						print(v.shopID)
						 emptyShops[v.shopID] = v.shopID
					 end
				 end
				 for k, v in ipairs(Config.MechanicShops) do
					 if plyShopID == k then
						 for _, y in pairs(ownedShops) do
							 if y.shopID == plyShopID then
								 CreateShopBlips(k, v, y.name)
								 break
							 end
						 end
					 else
						 if emptyShops[k] == k then
							 for _, y in pairs(ownedShops) do
								 if y.shopID == k then
									 CreateShopBlips(k, v, y.name)
								 end
							 end
						 else
							 if Config.PurchasableMechBlip then
								 CreateShopBlips(k, v, Lang["vacant_shops"])
							 end
						 end
					 end
				 end
			 end
		 )
	 end
 )

 
 -- Boss Menu:
 function bossMenuFunction(k, v, distToBoss)
	 --if bossMenu ~= nil then
		
		 distToBoss =
			 GetDistanceBetweenCoords(
			 coords.x,
			 coords.y,
			 coords.z,
			 v.menuPos[1],
			 v.menuPos[2],
			 v.menuPos[3],
			 false
		 )
	
		 local mk = Config.MarkerSettings
		 if distToBoss <= 10.0 and distToBoss >= 2.0 then
			 if mk.enable then
				 DrawMarker(mk.type,v.menuPos[1],v.menuPos[2],v.menuPos[3], 0.0,
					 0.0,
					 0.0,
					 0.0,
					 0.0,
					 0.0,
					 mk.scale.x,
					 mk.scale.y,
					 mk.scale.z,
					 mk.color.r,
					 mk.color.g,
					 mk.color.b,
					 mk.color.a,
					 false,
					 true,
					 2,
					 false,
					 false,
					 false,
					 false
				 )
			 end


		 elseif distToBoss <= 2.0 then
			 if plyShopID == k then
				 RSCore.Functions.DrawText3D(v.menuPos[1], v.menuPos[2], v.menuPos[3], Lang["mech_shop_manage"])
				 if IsControlJustPressed(0, Config.KeyToManageShop) then
					 bossMenu = v
					 MechShopManageMenu(k, v)
				 end
			 else
				 if emptyShops[k] == k then
					 RSCore.Functions.DrawText3D(v.menuPos[1], v.menuPos[2], v.menuPos[3], Lang["no_access_to_shop"])
				 else
					 if plyShopID == 0 then
						 RSCore.Functions.DrawText3D(
							 v.menuPos[1],
							 v.menuPos[2],
							 v.menuPos[3],
							 (Lang["press_to_buy_shop"]:format(math.floor(v.price)))
						 )
						 if IsControlJustPressed(0, Config.KeyToBuyMechShop) then
							 bossMenu = v
							 BuyMechShopMenu(k, v)
						 end
					 else
						 RSCore.Functions.DrawText3D(v.menuPos[1], v.menuPos[2], v.menuPos[3], Lang["only_one_mech_shop"])
					 end
				 end
			 end
		-- end
	 end
 end
 
 -- Manage Mech Shop Menu:
function MechShopManageMenu(id, val)
	local button
	local elements =
	{
		{ label = Lang["rename_mech_shop"], value = 1 },
		{ label = Lang["sell_mech_shop"], value = 2 },
		{ label = Lang["employees_action"], value = 3 },
		{ label = Lang["accounts_action"], value = 4 },
	--	{ label = "Close Menu", value = 5 }
	}

	local assert = assert
	local menu = assert(MenuV)



	Manage = MenuV:CreateMenu('Mech Shop', '', 'topleft', 255, 0, 0, 'size-150')
	Manage1 = MenuV:CreateMenu('Rename', '', 'topleft', 255, 0, 0, 'size-150')
	MenuV:OpenMenu(Manage, function()
	end)
	button = Manage:AddButton({ icon = "🧑‍🔧 ", label = Lang["rename_mech_shop"], value = 1 })
	button1 = Manage:AddButton({ icon = "🧑‍🔧 ", label = Lang["sell_mech_shop"], value = 2 })
	button2 = Manage:AddButton({ icon = "🧑‍🔧 ", label = Lang["employees_action"], value = 3 })
	button3 = Manage:AddButton({ icon = "🧑‍🔧 ", label = Lang["accounts_action"], value = 4 })
	button4 = Manage:AddButton({ icon = "🧑‍🔧 ", label = "Close menu", value =5 })
	local buybutton2 = Manage1:AddConfirm({ icon = '🔥', label = 'Confirm', value = 'no' })

	button:On("select", function()
		MenuV:Refresh()

		MenuV:OpenMenu(Manage1, function()
		end)
		buybutton2:On("confirm", function()

			local shopName = LocalInput("ShopName", 20, "New Name")
			if shopName == "New Name" then

				RSCore.Functions.Notify("Cannot Use that name")
			else
				RSCore.Functions.TriggerCallback("t1ger_mechanicjob:renameMechShop",
					function(renamed)
						if renamed then
							ShowNotifyESX((Lang["mech_shop_renamed"]):format(shopName))
							TriggerServerEvent("t1ger_mechanicjob:fetchMechShops")
							MenuV:CloseMenu(Manage1)
							MenuV:Refresh()
							bossMenu = nil
						else
							ShowNotifyESX(Lang["not_your_mech_shop"])

							MenuV:Refresh()
							bossMenu = nil
						end
					end,
					id,
					val,
					shopName)
			end
		end)
		buybutton2:On("deny", function()
			MenuV:CloseMenu(Manage1)
			MenuV:CloseMenu(Manage)
			MenuV:Refresh()

		end)
	end)
	button1:On("select", function()
		SellMechShopMenu(id, val)

	end)
	button2:On("select", function()

		EmployeesMainMenu(id, val)

	end)
	button3:On("select", function()

		AccountsMainMenu(id, val)

	end)
	--[[ button4:On("select",function()

		Manage1:Close()
		Manage:Close()

	end) ]]
end
 

 
 function LocalInput(text, numeros, windoes) --SHOW ON SCREEN KEYBOARD FOR THE PRICE AND NAME
	 DisplayOnscreenKeyboard(1, text or "FMMC_MPM_NA", "", windoes or "", "", "", "", numeros or 30)
	 while (UpdateOnscreenKeyboard() == 0) do
		 DisableAllControlActions(0)
		 Wait(0)
	 end
	 if (GetOnscreenKeyboardResult()) then
		 local result = GetOnscreenKeyboardResult()
		 return result
	 end
 end
function LocalInputInt(text, numeros, windoes) --SHOW ON SCREEN KEYBOARD FOR THE PRICE AND NAME BUT RETURN A NUMBER
	DisplayOnscreenKeyboard(1, text or "FMMC_MPM_NA", "", windoes or "", "", "", "", numeros or 30)
	while (UpdateOnscreenKeyboard() == 0) do
		DisableAllControlActions(0)
		Wait(0)
	end
	if (GetOnscreenKeyboardResult()) then
		local result = GetOnscreenKeyboardResult()
		return tonumber(result)
	end
end
 -- Acounts Main Menu:
 function AccountsMainMenu(id, val)

	 local assert = assert
	 local MenuV = assert(MenuV)


	 RSCore.Functions.TriggerCallback("t1ger_mechanicjob:getShopAccounts",
		 function(account)
			 jerico = account
			
			 MenuV:Refresh()

		 end,id)
		 local AccountMain = MenuV:CreateMenu("Account", '', 'topleft', 255, 0, 0, 'size-150')
	 MenuV:OpenMenu(AccountMain, function()
	 end)
	 local button = AccountMain:AddButton({ icon = "🧑‍🔧 	", label = Lang["account_withdraw"], value = 1 })
	 local button1 = AccountMain:AddButton({ icon = "🧑‍🔧 	", label = Lang["account_deposit"], value = 2 })
	 local button2 = AccountMain:AddButton({ icon = "🧑‍🔧 	", label = "Ammount Details", value = 3 })

	 button2:On("select", function()
		 RSCore.Functions.Notify("You Have in your account $" .. jerico)
	
		 MenuV:Refresh()
		 MenuV:CloseMenu(AccountMain)
	 end)
	 button:On("select", function()

		 local fx = LocalInput("withdraw", 20, 1)
		 if fx ~= nil or fx == 0 then
			 TriggerServerEvent("t1ger_mechanicjob:withdrawMoney", id, tonumber(fx))
			 MechShopManageMenu(id, val)
			 AccountMain = MenuV:CreateMenu("Account :$ ~r~"..jerico, '', 'topleft', 255, 0, 0, 'size-150')
			 MenuV:Refresh()
			 MenuV:CloseMenu(AccountMain)
			-- WarMenu.CloseMenu()
		 else
			 MenuV:CloseMenu(AccountMain)
			 MenuV:Refresh()
			-- WarMenu.CloseMenu()
			 RSCore.Functions.Notify("The Value is Invalid")
		 end
	 end)
	 button1:On("select", function()
		 local depositAmount = LocalInput("withdraw", 20, 1)
		 if depositAmount ~= nil or fx == 0 then
			 TriggerServerEvent("t1ger_mechanicjob:depositMoney", id, tonumber(depositAmount))
			 MechShopManageMenu(id, val)
			 MenuV:Refresh()
			 MenuV:CloseMenu(Manage)
			 --WarMenu.CloseMenu()
		 else
			 MenuV:CloseMenu(Manage)
			 MenuV:Refresh()
			-- WarMenu.CloseMenu()
			 RSCore.Functions.Notify("The Value is Invalid")
		 end


	 end)





--
--
 end
 -- Employees Main Menu:
 function EmployeesMainMenu(id, val)
	 local id1 = id
	 local assert = assert
	 local menu = assert(MenuV)



	 local Manage = MenuV:CreateMenu("Mech Shop [Employees]", '', 'topleft', 255, 0, 0, 'size-150')
	 local Manage1 = MenuV:CreateMenu("LIST", '', 'topleft', 255, 0, 0, 'size-150')
	 MenuV:OpenMenu(Manage, function()
	 end)
	 button = Manage:AddButton({ icon = "🧑‍🔧=> 	", label = Lang["hire_employee"], value = Manage1 })
	 button1 = Manage:AddButton({ icon = "🧑‍🔧=>	", label = Lang["employee_list"], value = 1 })
	 botonvalue = nil
	 
-- GET ONLINE PLAYERS AND DISPLAY
	 RSCore.Functions.TriggerCallback('t1ger_mechanicjob:getOnlinePlayers', function(players)
		 local elements = {}
		 for i = 1, #players, 1 do
			 table.insert(elements, {
				 label = players[i].name,
				 value = players[i].source,
				 name = players[i].name,
				 identifier = players[i].identifier
			 })
		 end
		 for k, v in ipairs(elements) do
			 button3 = Manage1:AddButton({ icon = "🧑‍🔧	", label = v.label, value = v, select = function(btn)
				local buybutton2 = Manage1:AddConfirm({ icon = '🔥', label = 'Confirm', value = 'no' })
				 botonvalue = btn
				 buybutton2:On("confirm", function()
					local jobGrade = 0
					TriggerServerEvent('t1ger_mechanicjob:reqruitEmployee', id, RSCore.Functions.GetPlayerData(botonvalue.Value.identifier).steam, botonvalue.Value.name)
					MenuV:CloseMenu(Manage1)
				end)
				buybutton2:On("deny", function()
					Manage1:Close()
				end)
			 end })
			
		
		 end
	 end)

	 button1:On("select", function()

		 OpenEmployeeListMenu(id1, val)

	 end)
 end
 -- Employe List Menu
 function OpenEmployeeListMenu(id, val)
	 print(id)

	 local elements = {}
	 local assert = assert
	 local menu = assert(MenuV)
	 local Manage = MenuV:CreateMenu("Employee List", '', 'topleft', 255, 0, 0, 'size-150')
	 local Manage1 = MenuV:CreateMenu("Fire?", '', 'topleft', 255, 0, 0, 'size-150')
	 MenuV:OpenMenu(Manage, function()
	 end)
	-- local confirm = Manage:AddConfirm({ icon = '🔥', label = 'Fire Employee?', value = false })

	 RSCore.Functions.TriggerCallback("t1ger_mechanicjob:getEmployees", function(employees)
		if employees ~= nil then
		 for k, v in ipairs(employees) do
				button3 = Manage:AddButton({ icon = "🧑‍🔧	", label = v.firstname.." "..v.lastname.." | "..v.jobGrade, value = v, select = function(btn)
					local data = btn.Value
					--print("Data current "..tostring(data.firstname).." | "..id.." | "..tostring(val))
					OpenEmployeeData(data,data,id,val)
				--	
				end })
			end
		 end
	 end, id)

	

 end
 
 -- Get Employee Menu Data
 function OpenEmployeeData(info, user, id, val)

	 local elements = {
		 {label = Lang["fire_employee"], value = "fire_employee"},
		 {label = Lang["employee_job_grade"], value = "job_grade_manage"}
	 }
	 local assert = assert
	local menu = assert(MenuV)
	 local ShellMenu = MenuV:CreateMenu("Employee: "..user.firstname,"", 'size-150')
	 local Firemenu = MenuV:CreateMenu("Fire "..user.firstname,"", 'size-150')
	 local Grade = MenuV:CreateMenu("Current Job Grade: "..user.jobGrade,"", 'size-150')
	 MenuV:OpenMenu(ShellMenu, function()
	end)
	local buybutton = ShellMenu:AddButton({icon ="🧑‍🔧 	",label = "Fire?",value = "fire_employee",description = 'Fire Employee'  })
	local firebutton = ShellMenu:AddButton({icon ="🧑‍🔧 	",label = Lang["employee_job_grade"],value = "job_grade_manage",description = 'Grade Manager'  })
	local gradebutton = Grade:AddButton({icon ="🧑‍🔧 	",label = "Grade Manager",value = "job_grade_manage",description = 'Grade Manager'  })
	
	local confirm = Firemenu:AddConfirm({ icon = '🔥', 		label = 'Fire Employee?', value = false })	
	buybutton:On("select",function()
		MenuV:OpenMenu(Firemenu)
		
		confirm:On("confirm",function()
			print("From Confirm"..user.identifier)
			TriggerServerEvent('t1ger_mechanicjob:fireEmployee',id,user.identifier)
			Firemenu:Close()
			EmployeesMainMenu(id,val)
		end)
		confirm:On("deny",function()
			Firemenu:Close()
			ShellMenu:Close()
			EmployeesMainMenu(id,val)
		end)
	
	end)
	firebutton:On("select",function()
		MenuV:OpenMenu(Grade)
	end)
	gradebutton:On("select",function()
	local newJobGrade = LocalInputInt("jobgrade",2,1)
	--if newJobGrade == "number" then
		print("id"..id.." Iden "..user.identifier.." New Grade "..newJobGrade)
		TriggerServerEvent('t1ger_mechanicjob:updateEmployeJobGrade',id,user.identifier,newJobGrade)
		Grade:Close()
	--end

	end)
	
	



 end
 
 -- Sell Mech Shop:
 function SellMechShopMenu(id, val)
	 local sellPrice = (val.price * Config.SellPercent)
	 local assert = assert
	local menu = assert(MenuV)
	 local ShellMenu = MenuV:CreateMenu("Confirm Sale | ","Price: $"..math.floor(sellPrice), 'size-150')
	 MenuV:OpenMenu(ShellMenu, function()
	end)
	local buybutton2 = ShellMenu:AddConfirm({ icon = '🔥', label = 'Confirm', value = 'no' })
	buybutton2:On("confirm",function()
	
		RSCore.Functions.TriggerCallback("t1ger_mechanicjob:sellMechShop",function(sold)
			if sold then
				TriggerServerEvent("t1ger_mechanicjob:fetchMechShops")
				ShowNotifyESX((Lang["mech_shop_sold"]):format(math.floor(sellPrice)))
				MenuV:CloseMenu(ShellMenu)
				--MenuV:CloseMenu(Manage)
				MenuV:Refresh()
			else
				ShowNotifyESX(Lang["not_your_mech_shop"])
			end
		end,id,val,math.floor(sellPrice))
	
	
	end)
	buybutton2:On("deny",function()
	
		MenuV:CloseMenu(ShellMenu)
	
	
	end)
 end
 
 -- Buy Mech Shop:
 function BuyMechShopMenu(id, val)
	local elements = {
		{label = Lang["button_yes"], value = "confirm_purchase"},
		{label = Lang["button_no"], value = "decline_purchase"}
	}
	local assert = assert
	local menu = assert(MenuV)

	 
	
	 local BuyMenu = MenuV:CreateMenu('Buy Shop', 'Wanna Buy it?')
	 MenuV:OpenMenu(BuyMenu, function()
		--print('Menu Open')
	end)
	local buybutton = BuyMenu:AddButton({icon ="🧑‍🔧 	",label = Lang["button_yes"] , value = "confirm_purchase",description = 'Yes'  })


	buybutton:On('select', function()

		local shopName = LocalInput("buy", 20, "Shop Name")
		RSCore.Functions.TriggerCallback("t1ger_mechanicjob:buyMechShop",function(purchased)
		--	print("792")
			 if purchased then
				 ShowNotifyESX((Lang["mech_shop_bought"]):format(math.floor(val.price)))
				 TriggerServerEvent("t1ger_mechanicjob:fetchMechShops")
			 MenuV:Refresh()
				 MenuV:CloseMenu(BuyMenu)
				 bossMenu = nil
			 else
				 ShowNotifyESX(Lang["not_enough_money"])
				 MenuV:Refresh()
				 MenuV:CloseMenu(BuyMenu)
				 bossMenu = nil
			 end
		 end,id,val,shopName)
		MenuV:CloseMenu(BuyMenu)
	end)
	



 end
 

 -- ## BOSS MENU END ## --
 
 -- ## STORAGE MENU START ## --
 function storageMenuFunction(k, v, distToStorage)
	--storageMenu = v
	-- if storageMenu ~= nil then
		 distToStorage =
			 GetDistanceBetweenCoords(
			 coords.x,
			 coords.y,
			 coords.z,
			 v.storage[1],
			 v.storage[2],
			 v.storage[3],
			 false
		 )
		 while storageMenu ~= nil and distToStorage > 2.0 do
			 storageMenu = nil
			 Citizen.Wait(1)
		 end
		 if storageMenu == nil then

		 end
	-- else
		 local mk = Config.MarkerSettings
		 if distToStorage <= 10.0 and distToStorage >= 2.0 then
			 if mk.enable then
				 DrawMarker(
					 mk.type,
					 v.storage[1],
					 v.storage[2],
					 v.storage[3],
					 0.0,
					 0.0,
					 0.0,
					 0.0,
					 0.0,
					 0.0,
					 mk.scale.x,
					 mk.scale.y,
					 mk.scale.z,
					 mk.color.r,
					 mk.color.g,
					 mk.color.b,
					 mk.color.a,
					 false,
					 true,
					 2,
					 false,
					 false,
					 false,
					 false
				 )
			 end
		 elseif distToStorage <= 2.0 then
			 RSCore.Functions.DrawText3D(v.storage[1], v.storage[2], v.storage[3], Lang["press_to_storage"])
			 if IsControlJustPressed(0, 38) then
				 RSCore.Functions.TriggerCallback(
					 "t1ger_mechanicjob:checkAccess",
					 function(hasAccess)
						 if hasAccess then
							 --TriggerEvent('inventory:stash', 'Mechanic Stash ' .. k,v)
							 storageMenu = v
							 MechShopStorageMenu(k, v)
						 else
							 TriggerEvent("notification", "you don't have any access for this", 2)
						 end
					 end,
					 k
				 )
			 end
		 end
	 --end
 end
 
 -- Storage Menu:
function MechShopStorageMenu(id, val)

	local keyPressed = false
	 invItems = {}
	local elements   = {
		{ label = Lang["storage_deposit"], value = "storage_deposit" },
		{ label = Lang['storage_withdraw'], value = "storage_withdraw" },
	}
	local assert     = assert
	local menu       = assert(MenuV)
	local Inventory  = MenuV:CreateMenu("Storage", "", 'size-150')
	local Inventory1 = MenuV:CreateMenu("Inventory", "", 'size-150')
	local Inventory2 = MenuV:CreateMenu(Lang['storage_withdraw'], "", 'size-150')
	MenuV:OpenMenu(Inventory, function()
	end)
	for k, v in ipairs(elements) do
		
		local mechmenubutton = Inventory:AddButton({ icon = "🧑‍🔧 	", label = v.label, value = v, description = v.label, select = function(btn)
			local value = btn.Value.value
			if value == "storage_deposit" then
				MenuV:OpenMenu(Inventory1, function()
				end)
				MenuV:Refresh()
			elseif value == "storage_withdraw" then
				MenuV:OpenMenu(Inventory2, function()
				end)
			end
		end })
		RSCore.Functions.TriggerCallback('t1ger_mechanicjob:getUserInventory', function(inventory)
			MenuV:Refresh()
			for k, v in pairs(inventory) do
				if v.amount > 0 then
					table.insert(invItems, { label = v.amount .. "x " .. v.label, value = v.name })
				end
			end
			for k, v in pairs(invItems) do
				
				local buybutton = Inventory1:AddButton({ icon = "🧑‍🔧 	", label = v.label, value = v, description = v.label, select = function(btn)
					

					local data = btn.Value.value
					local count = LocalInputInt("wachin", 10, 1)
					if count == nil then
						ShowNotifyESX(Lang['invalid_amount'])
						MenuV:Refresh()
					else
						if count > 0 then

							if not keyPressed then
								keyPressed = true
								TriggerServerEvent('t1ger_mechanicjob:depositItem', data, tonumber(count), id)
								Inventory1:Close()
								MenuV:Refresh()
							end

							Inventory1:Close()
							MenuV:Refresh()
						else
							ShowNotifyESX(Lang['invalid_amount'])
							Inventory1:Close()
							MenuV:Refresh()
						end
					end
				end})
			end
			MenuV:Refresh()
		end)




		RSCore.Functions.TriggerCallback('t1ger_mechanicjob:getStorageInventory', function(inventory)
			if inventory ~= nil then 
				local invItems1 = {}
				for k,v in pairs(inventory) do
					table.insert(invItems1, {label = v.count.."x "..v.label, value = v.item, amount = v.count})
				end
				for k, v in pairs(invItems1) do
				
					local buybutton = Inventory2:AddButton({ icon = "🧑‍🔧 	", label = v.label, value = v, description = v.label, select  = function(btn)

						local data = btn.Value
						print(data.value)
						local count = LocalInputInt("storage",3,1)

						if count == nil then
							ShowNotifyESX(Lang['invalid_amount'])
						else
							if count > 0 then
								if count <= data.amount then
									if not keyPressed then 
										keyPressed = true
										TriggerServerEvent('t1ger_mechanicjob:withdrawItem', data.value, count, id)
									end
								else
									ShowNotifyESX(Lang['too_high_count'])
								end
								Wait(500)
								MechShopStorageMenu(id, val)
							else
								ShowNotifyESX(Lang['invalid_amount'])
							end
						end
						MenuV:Refresh()
						Inventory2:Close()
					end})
					MenuV:Refresh()
				end
				Inventory1:Close()
				
				
			else
				ShowNotifyESX(Lang['storage_inv_empty'])
			end
		end, id)

	end

end
 -- ## STORAGE MENU END ## --
 
 -- ## WORKBENCH MENU START ## --
 function workbenchMenuFunction(k, v, distToWorkbench)
	
		 distToWorkbench =
			 GetDistanceBetweenCoords(
			 coords.x,
			 coords.y,
			 coords.z,
			 v.workbench[1],
			 v.workbench[2],
			 v.workbench[3],
			 false
		 )
		 while workbenchMenu ~= nil and distToWorkbench > 2.0 do
			 workbenchMenu = nil
			 Citizen.Wait(1)
		 end
		 if workbenchMenu == nil then
			-- WarMenu.CloseAll()
		 end
	
		 local mk = Config.MarkerSettings
		 if distToWorkbench < 10.0 and distToWorkbench > 2.0 then
			 if mk.enable then
				 DrawMarker(
					 mk.type,
					 v.workbench[1],
					 v.workbench[2],
					 v.workbench[3],
					 0.0,
					 0.0,
					 0.0,
					 0.0,
					 0.0,
					 0.0,
					 mk.scale.x,
					 mk.scale.y,
					 mk.scale.z,
					 mk.color.r,
					 mk.color.g,
					 mk.color.b,
					 mk.color.a,
					 false,
					 true,
					 2,
					 false,
					 false,
					 false,
					 false
				 )
			 end
		 elseif distToWorkbench < 2.0 then
			 RSCore.Functions.DrawText3D(v.workbench[1], v.workbench[2], v.workbench[3], Lang["press_to_workbench"])
			 if IsControlJustPressed(0, 38) then
				 RSCore.Functions.TriggerCallback(
					 "t1ger_mechanicjob:checkAccess",
					 function(hasAccess)
						 if hasAccess then
							 MechShopWorkbenchMenu(k, v)
							 ShowNotifyESX("acceso autorizado")
						 else
							 ShowNotifyESX(Lang["no_access"])
						 end
					 end,
					 k
				 )
			 end
		 end
	
 end
 --###############################################################--
 -- Workbench Menu:
 function MechShopWorkbenchMenu(id, val)
	  if not IsEntityPlayingAnim(player, 'mini@repair', 'fixing_a_player', 3) then
		 LoadAnim('mini@repair') 
		 TaskPlayAnim(player, 'mini@repair', 'fixing_a_player', 8.0, -8, -1, 49, 0, 0, 0, 0)
	 end
		local keyPressed = false
	
	 local assert = assert
	 local menu = assert(MenuV)
	 local MechShopmenu = MenuV:CreateMenu("Select Craftable","", 'size-150')
	 
	 MenuV:OpenMenu(MechShopmenu, function()
	 end)
local elements = {}
	 local craftOptions = {
		{ label = Lang['craft_item'], value = "craft_item" },
		{ label = Lang['view_recipe'], value = "view_recipe" },
	}
	 for k,v in ipairs(Config.Workbench) do
		table.insert(elements, {label = v.label, item = v.item, recipe = v.recipe})
		
	end
	for k,v in ipairs(elements) do
		local buybutton = MechShopmenu:AddButton({icon ="🧑‍🔧 ",label = v.label, value = v,description = 'Select item' ,select = function(btn) 
			local select = btn.Value
			local CraftMenu = MenuV:CreateMenu("Craftable: "..select.label,"", 'size-150')
			MenuV:OpenMenu(CraftMenu, function()
			end)
			for h,j in ipairs(craftOptions) do
				local firebutton = CraftMenu:AddButton({icon ="🧑‍🔧 ",label = j.label, value = j,description = 'Craft' ,select = function(btn1) 
					local select1 = btn1.Value
					print(select1)
				if select1.value == "craft_item" then
						print("true")
					if not keyPressed then 
						keyPressed = true
						RSCore.Functions.Progressbar("sell_pawn_items", (Lang['crafting_item']:format(string.upper(select.label))), (Config.CraftTime * 1000), false, true, {}, {}, {}, {}, function() -- Done

						end, function() -- Cancel

						end)
						Citizen.Wait((Config.CraftTime * 1000))
						TriggerServerEvent('t1ger_mechanicjob:craftItem', select.label, select.item, select.recipe, id, val)
						Wait(500)
	
						workbenchMenu = nil
						ClearPedSecondaryTask(player)
						MenuV:CloseMenu(CraftMenu)
					else
						MechShopWorkbenchMenu(id,val)
						ShowNotifyESX(Lang['crafting_in_progress'])
					end
				elseif select1.value == "view_recipe" then
					ViewCraftingRecipe(select.label, select.item, select.recipe, id, val)
					ClearPedSecondaryTask(player)
				end
					
				end})
			end
			
		end})
	end
 end
 
 -- View Recipe Function:
 function ViewCraftingRecipe(item_label, item, recipe, id, val)
	 local elements = {}
	 for k, v in ipairs(recipe) do
		 local material = Config.Materials[v.id]
		 table.insert(
			 elements,
			 {
				 label = material.label .. " [" .. v.qty .. " pcs]",
				 name = material.label,
				 item = material.item,
				 amount = v.qty
			 }
		 )
	 end
	 local assert = assert
	 local menu = assert(MenuV)
	 local Craftingone = MenuV:CreateMenu("Recipe: ","", 'size-150')
	 
	 MenuV:OpenMenu(Craftingone,function()
	end)

	 for k,v in ipairs(elements) do
		local button1 = Craftingone:AddButton({icon ="🧑‍🔧 ",label = v.label, value = v ,description = 'materials' ,select = function(btn1)
			local select = btn1.Value
			if select == "menu_return" then
				MechShopWorkbenchMenu(id, val)
				MenuV:CloseMenu(Craftingone)
			end
		end})
	 end
 end
 
 -- ## WORKBENCH MENU END ## --
 
 vehOnLift = {}
 -- Lift Thread Function:
 Citizen.CreateThread(function()
		 while true do
			 Citizen.Wait(1)
			 if PlayerJob and PlayerJob.name == "mechanic" then
				 for num, shop in pairs(Config.MechanicShops) do
					 local shopDist = GetDistanceBetweenCoords(coords.x,coords.y,coords.z,shop.menuPos[1],shop.menuPos[2],shop.menuPos[3],true)
					 if shopDist < 20.0 then
						local shops = shop.lifts
						 for k, v in pairs(shops) do
							-- local mk = v.marker
							 -- Attach Vehicle to Lift:
							 local liftDist = GetDistanceBetweenCoords(coords.x,coords.y,coords.z,v.entry[1],v.entry[2],v.entry[3],true)
							 if liftDist < 6 and IsPedInAnyVehicle(player, 1) then
								 if  liftDist > 2.0 then
									 DrawMarker(
										v.marker.type,
										 v.entry[1],
										 v.entry[2],
										 v.entry[3],
										 0.0,
										 0.0,
										 0.0,
										 0.0,
										 0.0,
										 0.0,
										 v.marker.scale.x,
										 v.marker.scale.y,
										 v.marker.scale.z,
										 v.marker.color.r,
										 v.marker.color.g,
										 v.marker.color.b,
										 v.marker.color.a,
										 false,
										 true,
										 2,
										 false,
										 false,
										 false,
										 false
									 )
								 end
								 if liftDist < 2.0 then
									 if not v.inUse then
										 RSCore.Functions.DrawText3D(v.entry[1], v.entry[2], v.entry[3], Lang["park_on_lift"])
										 if IsControlJustPressed(0, 38) then
											 local plate = GetVehicleNumberPlateText(curVehicle):gsub("^%s*(.-)%s*$", "%1")
											 v.currentVeh = curVehicle
											 v.inUse = true
											 TaskLeaveVehicle(player, v.currentVeh, 0)
											 Citizen.Wait(2000)
											 SetEntityCoordsNoOffset(
												 v.currentVeh,
												 v.pos[1],
												 v.pos[2],
												 v.pos[3],
												 true,
												 false,
												 false,
												 true
											 )
											 SetEntityHeading(v.currentVeh, v.pos[4])
											 SetVehicleOnGroundProperly(v.currentVeh)
											 FreezeEntityPosition(v.currentVeh, true)
											 local newVehPos = GetEntityCoords(v.currentVeh)
											
											 v.pos[3] = newVehPos.z
											 print(newVehPos.z)
											 vehOnLift[plate] = {entity = v.currentVeh,pos = v.pos,plate = plate,health = {}}
											 TriggerServerEvent( "t1ger_mechanicjob:liftStateSV", num,k,v,v.currentVeh,true)
										 break
										 end
									 else
										 RSCore.Functions.DrawText3D(v.entry[1], v.entry[2], v.entry[3], Lang["lift_occupied"])
									 end
								 end
							 end
							 -- Detach Vehicle or Move Up/Down:
							 local controlDist =
								 GetDistanceBetweenCoords(
								 coords.x,
								 coords.y,
								 coords.z,
								 v.control[1],
								 v.control[2],
								 v.control[3],
								 false
							 )
							 if controlDist < 6 and not IsPedInAnyVehicle(player, 1) then
								 if controlDist > 1.5 then
									 DrawMarker(v.marker.type,v.control[1],
										 v.control[2],
										 v.control[3],
										 0.0,
										 0.0,
										 0.0,
										 0.0,
										 0.0,
										 0.0,
										 v.marker.scale.x,
										 v.marker.scale.y,
										 v.marker.scale.z,
										 v.marker.color.r,
										 v.marker.color.g,
										 v.marker.color.b,
										 v.marker.color.a,
										 false,
										 true,
										 2,
										 false,
										 false,
										 false,
										 false
									 )
								 end
								 if controlDist < 1.5 then
									 if v.inUse then
										 RSCore.Functions.DrawText3D(v.control[1],v.control[2],v.control[3],Lang["remove_or_move_veh"])
										 if IsControlJustPressed(0, 47) then
											 Citizen.Wait(1000)
											 FreezeEntityPosition(v.currentVeh, false)
											 SetEntityCoords(v.currentVeh,v.entry[1],v.entry[2],v.entry[3],1,0,0,1)
											 local plate = GetVehicleNumberPlateText(v.currentVeh):gsub("^%s*(.-)%s*$", "%1")
											 if plate == nil then
												 RSCore.Functions.Notify("Plate number must not be null")
											 end
											 vehOnLift[plate] = nil
											 v.currentVeh = nil
											 v.inUse = false
											 TriggerServerEvent("t1ger_mechanicjob:liftStateSV", num,k,v,v.currentVeh,false)
											 break
										 elseif IsControlJustPressed(0, 172) then
											 if v.pos[3] < v.maxValue then
												 v.pos[3] = v.pos[3] + 0.1
												 SetEntityCoordsNoOffset(v.currentVeh,v.pos[1],v.pos[2],v.pos[3],1,0,0, 1)
												 Wait(100)
											 else
												 ShowNotifyESX(Lang["lift_cannot_go_higher"])
											 end
										 elseif IsControlJustPressed(0, 173) then
											 if v.pos[3] > v.minValue then
												 v.pos[3] = v.pos[3] - 0.1
												 SetEntityCoordsNoOffset(v.currentVeh,v.pos[1],v.pos[2],v.pos[3],1,0,0,1)
												 Wait(100)
											 else
												 ShowNotifyESX(Lang["lift_cannot_go_lower"])
											 end
										 end
									 else
										 RSCore.Functions.DrawText3D(v.control[1], v.control[2], v.control[3], Lang["no_veh_to_control"])
									 end
								 end
							 end
						 end
					 end
				 end
			 end
		 end
	 end
 )
 

 RegisterNetEvent("t1ger_mechanicjob:menu")
 AddEventHandler("t1ger_mechanicjob:menu",function()

 OpenMechanicActionMenu()
end)

 function GetClosestPlayer()
	 local closestPlayers = RSCore.Functions.GetPlayersFromCoords()
	 local closestDistance = -1
	 local closestPlayer = -1
	 local coords = GetEntityCoords(GetPlayerPed(-1))
 
	 for i = 1, #closestPlayers, 1 do
		 if closestPlayers[i] ~= PlayerId() then
			 local pos = GetEntityCoords(GetPlayerPed(closestPlayers[i]))
			 local distance = GetDistanceBetweenCoords(pos.x, pos.y, pos.z, coords.x, coords.y, coords.z, true)
 
			 if closestDistance == -1 or closestDistance > distance then
				 closestPlayer = closestPlayers[i]
				 closestDistance = distance
			 end
		 end
	 end
 
	 return closestPlayer, closestDistance
 end
 
 -- Mechanic Action Menu:
 function OpenMechanicActionMenu()
	 if RSCore.Functions.GetPlayerData().job.name == "mechanic" then
		 local elements = {
			 {label = "Billing", value = 1},
			 {label = "Use Car Jack", value = 2},
			 {label = "Inspect Vehicle", value = 3},
			 {label = "Repair Health Parts", value = 4},
			 {label = "Vehicle Engine Repair", value = 5},
			 {label = "Vehicle Body Repair", value = 6},
			 {label = "NPC Jobs", value = 7},
		--	 {label = "Objects", value = 8}

		 }
		 local assert = assert
		 local menu = assert(MenuV)
		  MechMenu1 = MenuV:CreateMenu("MECHANIC MENU","", 'size-150')
		 MenuV:OpenMenu(MechMenu1, function()
		 end)
		-- local buybutton = MechMenu1:AddButton({icon ="🧑‍🔧 	",label = "Close Menu" , value = 1,description = 'Close the Menu'  })
		 for k, v in ipairs(elements) do
			local mechmenubutton = MechMenu1:AddButton({ icon = "🧑‍🔧 	", label = v.label, value = v, description = v.label, select = function(btn)
				 local value = btn.Value.value
				 if value == 1 then
					 local amount = LocalInput("amount", 20, 1)
					 if amount ~= nil or not amount == 0 then
						 local closestPlayer, closestDistance = GetClosestPlayer()
						 if closestPlayer == -1 or closestDistance > 3.0 then
							 ShowNotifyESX(Lang['no_players_nearby'])
						 else
							 TriggerServerEvent('t1ger_mechanicjob:sendBill', GetPlayerServerId(closestPlayer), amount)
						 end
					 else
						 ShowNotifyESX(Lang['invalid_amount'])
					 end
					-- MenuV:CloseMenu(MechMenu)
				 elseif value == 2 then
					 CarJackFunction('interact')
					-- MenuV:CloseMenu(MechMenu1)
				 elseif value == 3 then
					 InspectVehicleFunction()
				 elseif value == 4 then
					 RepairVehicleHealthPart()
					-- MenuV:CloseMenu(MechMenu1)
				 elseif value == 5 then
					 RepairVehicleEngine()
					-- MenuV:CloseMenu(MechMenu1)
				 elseif value == 6 then

					 CarJackFunction('analyse')
					-- MenuV:CloseMenu(MechMenu1)
				 elseif value == 7 then
					 ManageNpcJobs()
					--[[ elseif value == 8 then
						CarryObjectsMainMenu() ]]
				 end


			end })



			end
		 		
	
		
	end
 end
 
 carryModel = 0
 holdingObj = false
 function CarryObjectsMainMenu()
	 local elements = {}
	 for k, v in pairs(Config.PropEmotes) do
		 table.insert(elements, {label = v.label, prop = v.model, bone = v.bone, pos = v.pos, rot = v.rot})
	 end
	 table.insert(elements, {label = "Remove Obj", value = "remove_obj"})
	 local assert = assert
	 local menu = assert(MenuV)
	 local CarrOBJ = MenuV:CreateMenu("Select Craftable","", 'size-150')
	  MenuV:OpenMenu(CarrOBJ, function()
	 end)
	 for k,v in ipairs(elements) do
		local buybutton = CarrOBJ:AddButton({icon ="🧑‍🔧 ",label = v.label, value = v,description = 'Select item' ,select = function(btn) 
			local select = btn.Value
			print(select.pos[1])
			if select == "remove_obj" then
			
				local coords = GetEntityCoords(GetPlayerPed(-1))
				ClearPedTasks(PlayerPedId())
				ClearPedSecondaryTask(PlayerPedId())
				Citizen.Wait(250)
				DetachEntity(carryModel)
				local allObjects = {"prop_roadcone02a", "prop_tool_box_04", "prop_cs_trolley_01", "prop_engine_hoist"}
				for i = 1, #allObjects, 1 do
					local object = GetClosestObjectOfType(coords, 2.5, GetHashKey(allObjects[i]), false, false, false)
					if DoesEntityExist(object) then
						DeleteObject(object)
					end
				end
				CarryObjectsMainMenu()
			else
		
				local coords = GetEntityCoords(GetPlayerPed(-1))
				local selct = select
				carryModel = 0
				holdingObj = true
				if selct.prop == "prop_cs_trolley_01" or selct.prop == "prop_engine_hoist" then PlayPushObjAnim() end
				--[[ local spawnModel = ]] CreateObject(selct.prop, coords.x, coords.y, coords.z, false, false, false)
				
				--[[ carryModel = spawnModel ]]
				local boneIndex = GetPedBoneIndex(PlayerPedId(), selct.bone)
				local pX, pY, pZ, rX, rY, rZ = round(selct.pos[1],2), round(selct.pos[2],2), round(selct.pos[3],2), round(selct.rot[1],2), round(selct.rot[2],2), round(selct.rot[3],2)
				AttachEntityToEntity(carryModel, PlayerPedId(), boneIndex, pX, pY, pZ, rX, rY, rZ, true, true, false, true, 2, 1)
			end
		end})
	end
 end
 
 Citizen.CreateThread(
	 function()
		 while true do
			 Citizen.Wait(5)
			 if IsControlJustPressed(0, Config.KeyToPushPickUpObjs) and carryModel ~= 0 then
				 if PlayerData.job and PlayerData.job.name == "mechanic" then
					 local placedObjs = {
						 "prop_roadcone02a",
						 "prop_tool_box_04",
						 "prop_cs_trolley_01",
						 "prop_engine_hoist"
					 }
					 local coords, nearDist = GetEntityCoords(GetPlayerPed(-1)), -1
					 carryModel = nil
					 local objName, zk = nil, Config.PropEmotes
					 for i = 1, #placedObjs, 1 do
						 local object =
							 GetClosestObjectOfType(coords, 1.5, GetHashKey(placedObjs[i]), false, false, false)
						 if DoesEntityExist(object) then
							 local objCoords = GetEntityCoords(object)
							 local objDist = GetDistanceBetweenCoords(coords, objCoords, true)
							 if nearDist == -1 or nearDist > objDist then
								 nearDist = objDist
								 carryModel = object
								 objName = placedObjs[i]
							 end
						 end
					 end
					 if holdingObj then
						 holdingObj = false
						 if (objName == "prop_roadcone02a") or (objName == "prop_tool_box_04") then
							 PlayPickUpAnim()
						 end
						 Citizen.Wait(250)
						 DetachEntity(carryModel)
						 ClearPedTasks(PlayerPedId())
						 ClearPedSecondaryTask(PlayerPedId())
					 else
						 local Dist =
							 GetDistanceBetweenCoords(GetEntityCoords(carryModel), GetEntityCoords(PlayerPedId()), true)
						 if Dist < 1.75 then
							 holdingObj = true
							 if (objName == "prop_roadcone02a") or (objName == "prop_tool_box_04") then
								 PlayPickUpAnim()
							 end
							 Citizen.Wait(250)
							 ClearPedTasks(PlayerPedId())
							 ClearPedSecondaryTask(PlayerPedId())
							 if (objName == "prop_cs_trolley_01") or (objName == "prop_engine_hoist") then
								 PlayPushObjAnim()
							 end
							 Citizen.Wait(250)
							 AttachEntityToEntity(
								 carryModel,
								 PlayerPedId(),
								 GetPedBoneIndex(PlayerPedId(), zk[objName].bone),
								 zk[objName].pos[1],
								 zk[objName].pos[2],
								 zk[objName].pos[3],
								 zk[objName].rot[1],
								 zk[objName].rot[2],
								 zk[objName].rot[3],
								 true,
								 true,
								 false,
								 true,
								 2,
								 1
							 )
						 end
					 end
				 end
			 end
		 end
	 end
 )
 
 function PlayPushObjAnim()
	 LoadAnim("anim@heists@box_carry@")
	 TaskPlayAnim((PlayerPedId()), "anim@heists@box_carry@", "idle", 4.0, 1.0, -1, 49, 0, 0, 0, 0)
 end
 
 function PlayPickUpAnim()
	 LoadAnim("random@domestic")
	 TaskPlayAnim(PlayerPedId(), "random@domestic", "pickup_low", 5.0, 1.0, 1.0, 48, 0.0, 0, 0, 0)
 end
 
 function RepairVehicleEngine()
	 local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
	 local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
	 local repairingEngine = false
	 if vehicle ~= 0 then
		 if vehOnLift[plate] ~= nil then
			 if GetEntityModel(GetHashKey(vehicle)) == GetEntityModel(GetHashKey(vehOnLift[plate].entity)) then
				 local d1, d2 = GetModelDimensions(GetEntityModel(vehicle))
				 local enginePos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, d2.y + 0.2, 0.0)
				 local distance =
					 (GetDistanceBetweenCoords(coords, vector3(enginePos.x, enginePos.y, enginePos.z), true))
 
				 while true do
					 Citizen.Wait(1)
					 distance = (GetDistanceBetweenCoords(coords, vector3(enginePos.x, enginePos.y, enginePos.z), true))
					 if distance < 5.0 then
						 RSCore.Functions.DrawText3D(enginePos.x, enginePos.y, enginePos.z, Lang["repair_engine"])
						 if IsControlJustPressed(0, 38) and distance < 1.0 then
							 -- inspect anim:
							 TaskTurnPedToFaceEntity(player, vehicle, 1.0)
							 Citizen.Wait(1000)
							 TaskStartScenarioInPlace(player, "WORLD_HUMAN_CLIPBOARD", 0, true)
							-- exports["progressBars"]:startUI(2000, "INSPECTING: ENGINE")
							 RSCore.Functions.Progressbar("sell_pawn_items", "INSPECTING: ENGINE", 2000, false, true, {}, {}, {}, {}, function() -- Done

							 end, function() -- Cancel

							 end)
							 Citizen.Wait(2000)
							 ClearPedTasks(player)
							 local engineValue = (round((GetVehicleEngineHealth(vehicle) / 10) / 10, 2))
							 if engineValue < 10.0 then
								 local engineMaterials = {}
								 for g, h in pairs(Config.HealthParts) do
									 if h.degName == "engine" then
										 local array = {}
										 engineMaterials = h.materials
										 for k, v in pairs(h.materials) do
											 local item = Config.Materials[v.id]
											 table.insert(array, item.label)
										 end
										 local items = table.concat(array, ", ")
										 local chatMsg =
											 "^*" ..
											 h.label ..
												 " [" ..
													 items .. "] » " .. round(engineValue, 2) .. " / 10.0"
										 TriggerEvent("chat:addMessage", {args = {chatMsg}})
									 end
								 end
								 local engineAddVal = 0
								 local newValue = 10.0
								 local difference = (newValue - engineValue)
								 if difference > 0 and difference <= 1.0 then
									 engineAddVal = 1.0
								 else
									 engineAddVal = math.floor(difference + 1.0)
								 end
								 RSCore.Functions.TriggerCallback(
									 "t1ger_mechanicjob:getMaterialsForHealthRep",
									 function(hasMaterials)
										 if hasMaterials then
											 -- repair anim:
											 SetEntityHeading(player, GetEntityHeading(vehicle))
											 Citizen.Wait(500)
											 TaskStartScenarioInPlace(player, "WORLD_HUMAN_VEHICLE_MECHANIC", 0, true)
											-- exports["progressBars"]:startUI(3500, "REPAIRING: ENGINE")
											 RSCore.Functions.Progressbar("sell_pawn_items", "REPAIRING: ENGINE", 3500, false, true, {}, {}, {}, {}, function()
												 -- Done

											 end, function()
												 -- Cancel

											 end)
											 Citizen.Wait(3500)
											 SetVehicleEngineHealth(vehicle, 1000.0)
											 ClearPedTasks(player)
										 else
											 ShowNotifyESX(Lang["need_more_materials"])
										 end
									 end,
									 plate,
									 "engine",
									 engineMaterials,
									 10.0,
									 engineAddVal,
									 vehOnLift
								 )
							 else
								 ShowNotifyESX("Engine is fully functional")
							 end
							 break
						 end
					 end
					 if distance > 5.0 then
						 repairingEngine = false
						 break
					 end
				 end
			 else
				 print("veh not matched")
			 end
		 else
			 ShowNotifyESX(Lang["veh_must_be_on_lift"])
		 end
	 else
		 ShowNotifyESX(Lang["no_vehicle_nearby"])
	 end
 end

function RepairVehicleHealthPart()
	--#######################################################################
	local vehicle  = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
	local plate    = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
	local elements = {}
	local elements1 = {}
	for k, v in pairs(Config.HealthParts) do
		table.insert(elements, { label = v.label, degName = v.degName, materials = v.materials })
	end

	local assert = assert
	local menu   = assert(MenuV)
	local Repair = MenuV:CreateMenu("MECHANIC MENU", "", 'size-150')
	MenuV:OpenMenu(Repair, function()
	end)
	if vehicle ~= 0 then
		if vehOnLift[plate] ~= nil then
		if GetEntityModel(GetHashKey(vehicle)) == GetEntityModel(GetHashKey(vehOnLift[plate].entity)) then
			if vehOnLift[plate].health ~= nil then
				for k, v in ipairs(elements) do
					local mechmenubutton = Repair:AddButton({ icon = "🧑‍🔧 	", label = v.label, value = v, description = v.label, select  = function(btn)
						local selected = btn.Value
						print(selected.materials)
						local newValue = LocalInputInt("input",20,1)
						if vehOnLift[plate].health[selected.degName] ~= nil then
							if newValue > 10.0 then
								ShowNotifyESX(Lang['health_part_exceeded'])
							elseif newValue < vehOnLift[plate].health[selected.degName].value then
								ShowNotifyESX(Lang['not_decrease_health_val'])
							else
								local difference = (newValue - vehOnLift[plate].health[selected.degName].value)
								local valueToAdd = 0
								if difference <= 0 then
									ShowNotifyESX(Lang['not_decrse_or_same_val'])
									ShowNotifyESX("Value "..vehOnLift[plate].health[selected.degName].value)
								else
									if difference > 0 and difference <= 1.0 then
										valueToAdd = 1.0
									else
										valueToAdd = math.floor(difference + 1.0)
									end

									RepairSelectedHealthPart(plate, selected.label, selected.degName, selected.materials, newValue, valueToAdd)
								end
							end
						else
							ShowNotifyESX(Lang['veh_must_be_inspected'])
						end
						MenuV:CloseMenu("Repair")
					end })
				end
			else
				ShowNotifyESX(Lang["veh_must_be_inspected"])
			end
		else
			print("veh not matched")
		end
		else
			ShowNotifyESX(Lang["veh_must_be_on_lift"])
		end
	else
		ShowNotifyESX(Lang["no_vehicle_nearby"])
	end
end
 
 function RepairSelectedHealthPart(plate, label, degName, materials, newValue, addValue)
	 print(materials)
	 local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
	 local repairingPart = false

	 if vehicle ~= 0 then
		 local d1, d2 = GetModelDimensions(GetEntityModel(vehicle))
		 local enginePos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, d2.y + 0.2, 0.0)
		 local distance = (GetDistanceBetweenCoords(coords, vector3(enginePos.x, enginePos.y, enginePos.z), true))
 
		 while true do
			 Citizen.Wait(1)
			 distance = (GetDistanceBetweenCoords(coords, vector3(enginePos.x, enginePos.y, enginePos.z), true))
			 if distance < 5.0 then
				 RSCore.Functions.DrawText3D(enginePos.x, enginePos.y, enginePos.z, Lang["health_rep_here"])
				 if IsControlJustPressed(0, 38) and distance < 1.0 then
					 SetEntityHeading(player, GetEntityHeading(vehicle))
					 Citizen.Wait(500)
					 TaskStartScenarioInPlace(player, "WORLD_HUMAN_VEHICLE_MECHANIC", 0, true)
					 --exports["progressBars"]:startUI(3500, (Lang["lift_repairing_veh"]:format(string.upper(label))))
					 RSCore.Functions.Progressbar("sell_pawn_items", Lang["lift_repairing_veh"]:format(string.upper(label)), 3500, false, true, {}, {}, {}, {}, function()
						 -- Done

					 end, function()
						 -- Cancel

					 end)
					 Citizen.Wait(3500)
					 ClearPedTasks(player)
					 RSCore.Functions.TriggerCallback("t1ger_mechanicjob:getMaterialsForHealthRep",function(hasMaterials)
							 if hasMaterials then
								 vehOnLift[plate].health[degName].value = round(newValue, 2)
								 TriggerServerEvent("t1ger_mechanicjob:updateVehDegradation",
									 plate,
									 label,
									 degName,
									 vehOnLift
								 )
								 if degName == "engine" then
									 local engineValue = round((vehOnLift[plate].health[degName].value * 10) * 10, 2)
									 SetVehicleEngineHealth(vehicle, engineValue)
								 end
							 else
								 ShowNotifyESX(Lang["need_more_materials"])
							 end
						 end,
						 plate,
						 degName,
						 materials,
						 newValue,
						 addValue,
						 vehOnLift)
					 break
				 end
			 end
			 if distance > 5.0 then
				 repairingPart = false
				 break
			 end
		 end
	 else
		 ShowNotifyESX(Lang["no_vehicle_nearby"])
	 end
 end
 
 function InspectVehicleFunction()
	 local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
	 local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
	 if vehicle ~= 0 then
		 if vehOnLift[plate] ~= nil then
			 if GetEntityModel(GetHashKey(vehicle)) == GetEntityModel(GetHashKey(vehOnLift[plate].entity)) then
				 local d1, d2 = GetModelDimensions(GetEntityModel(vehicle))
				 local spots = {
					 [1] = {
						 pos = GetOffsetFromEntityInWorldCoords(vehicle, d2.x + 0.2, 0.0, 0.0),
						 scenario = "WORLD_HUMAN_CLIPBOARD",
						 done = false
					 },
					 [2] = {
						 pos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, d2.y + 0.2, 0.0),
						 scenario = "WORLD_HUMAN_CLIPBOARD",
						 done = false
					 },
					 [3] = {
						 pos = GetOffsetFromEntityInWorldCoords(vehicle, d1.x - 0.2, 0.0, 0.0),
						 scenario = "WORLD_HUMAN_CLIPBOARD",
						 done = false
					 }
				 }
				 local inspectingVeh = false
				 while true do
					 Citizen.Wait(1)
					 local vehPos = GetEntityCoords(vehicle, 1)
					 if not inspectingVeh then
						 for k, v in pairs(spots) do
							 local distance =
								 (GetDistanceBetweenCoords(
								 GetEntityCoords(player),
								 vector3(v.pos.x, v.pos.y, v.pos.z),
								 true
							 ))
							 if distance < 4.0 then
								 if not v.done then
									 RSCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z, Lang["inspect_here"])
									 if IsControlJustPressed(0, 38) and distance < 1.0 then
										 TaskTurnPedToFaceEntity(player, vehicle, 1.0)
										 Citizen.Wait(1000)
										 TaskStartScenarioInPlace(player, v.scenario, 0, true)
										 RSCore.Functions.Progressbar("sell_pawn_items", Lang["progbar_inspecting_veh"], 1500, false, true, {}, {}, {}, {}, function()
											 -- Done

										 end, function()
											 -- Cancel

										 end)
									--	 exports["progressBars"]:startUI(1500, Lang["progbar_inspecting_veh"])

										 Citizen.Wait(1500)
										 ClearPedTasksImmediately(player)
										 v.done = true
									 end
								 end
							 end
						 end
						 if spots[1].done and spots[2].done and spots[3].done then
							 inspectingVeh = true
							 Wait(200)
							 break
						 end
					 end
				 end
				 print(plate)
				 RSCore.Functions.TriggerCallback(
					 "t1ger_mechanicjob:getVehDegradation",
					 function(degradation)
						print("called vehdegradation")
						 local vehHealth = {}
						 if degradation ~= nil then
							 -- insert values into health array:
							 for k, v in pairs(degradation) do
								 local partValue = (round(v.value / 10, 2))
								 if v.part == "engine" then
									 partValue = (round((GetVehicleEngineHealth(vehicle) / 10) / 10, 2))
								 end
								 -- Get materials:
								 for g, h in pairs(Config.HealthParts) do
									 if h.degName == v.part then
										 vehHealth[v.part] = {value = partValue, materials = h.materials}
										 local array = {}
										 for k, v in pairs(h.materials) do
											 local item = Config.Materials[v.id]
											 table.insert(array, item.label)
										 end
										 local items = table.concat(array, ", ")
										-- RSCore.Functions.Notify("*" ..h.label .." [" ..items .. "] » " .. round(partValue, 2) .. " / 10.0")
										 local chatMsg = "^*" ..h.label .." ^5[^6" ..items .. "^5] ^0» ^3" .. round(partValue, 2) .. "^0 / ^210.0^0" TriggerEvent("chat:addMessage", {args = {chatMsg}})
									 end
								 end
							 end
							 vehOnLift[plate].health = vehHealth
						 else
							 ShowNotifyESX("Works with only player owned vehicles.")
						 end
					 end,
					 plate
				 )
			 else
				 print("veh not matched")
			 end
		 else
			 ShowNotifyESX(Lang["veh_must_be_on_lift"])
		 end
	 else
		 ShowNotifyESX(Lang["no_vehicle_nearby"])
	 end
 end
 
 usingJack = false
 isJackRaised = false
 carJackObj = nil
 vehicleData = {}
 wheelProperties = {}
 vehAnalysed = false
 function CarJackFunction(type)
	 local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
 
	 if vehicle ~= 0 then
		 if usingJack then
			 return
		 end
		 usingJack = true
 
		 GetControlOfEntity(vehicle)
 
		 local d1, d2 = GetModelDimensions(GetEntityModel(vehicle))
		 local door = GetOffsetFromEntityInWorldCoords(vehicle, d2.x + 0.2, 0.0, 0.0)
		 local vehCoords = GetEntityCoords(vehicle, 1)
		 local distance = (GetDistanceBetweenCoords(coords, vector3(door.x, door.y, door.z), true))
 
		 while true do
			 Citizen.Wait(1)
			 distance = (GetDistanceBetweenCoords(coords, vector3(door.x, door.y, door.z), true))
			 if distance < 6.0 then
				 local label = ""
				 local findObj =
					 GetClosestObjectOfType(
					 vehCoords.x,
					 vehCoords.y,
					 vehCoords.z,
					 1.0,
					 GetHashKey("prop_carjack"),
					 false,
					 false,
					 false
				 )
				 if DoesEntityExist(findObj) then
					 isJackRaised = true
					 if type == "interact" then
						 label = Lang["lower_jack"]
					 end
					 if type == "analyse" then
						 if not vehAnalysed then
							 label = "Analyse Vehicle Body"
						 else
							 ShowNotifyESX(Lang["veh_already_analyzed"])
							 break
						 end
					 end
				 else
					 if type == "interact" then
						 isJackRaised = false
						 label = Lang["raise_jack"]
					 elseif type == "analyse" then
						 ShowNotifyESX(Lang["raise_veh_b4_analyze"])
						 break
					 end
				 end
				 RSCore.Functions.DrawText3D(door.x, door.y, door.z, "~r~[E]~s~ " .. label)
				 if IsControlJustPressed(0, 38) and distance < 1.0 then
					 if isJackRaised then
						 if type == "interact" then
							 UseTheJackFunction(vehicle)
							 break
						 else
							 if not vehAnalysed then
								 local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
								 vehicleData[plate] = {report = {}, entity = nil}
								 wheelProperties[plate] = {}
								 for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do
									 wheelProperties[plate][i + 1] = {
										 xOffset = GetVehicleWheelXOffset(vehicle, i),
										 yRotation = GetVehicleWheelYRotation(vehicle, i)
									 }
								 end
								 FetchVehicleBodyDamageReport(vehicle, plate)
								 break
							 end
						 end
					 else
						 local item = Config.CarJackItem
						 RSCore.Functions.TriggerCallback(
							 "t1ger_mechanicjob:getInventoryItem",
							 function(hasItem)
								 if hasItem then
									 UseTheJackFunction(vehicle)
								 else
									 ShowNotifyESX(Lang["car_jack_carry"])
								 end
							 end,
							 item
						 )
					 end
					 break
				 end
			 end
			 if distance > 6.0 then
				 usingJack = false
				 break
			 end
		 end
	 else
		 ShowNotifyESX(Lang["no_vehicle_nearby"])
	 end
	 usingJack = false
 end
 
 function UseTheJackFunction(vehicle)
	 TaskTurnPedToFaceEntity(player, vehicle, 1.0)
	 Citizen.Wait(1000)
	 FreezeEntityPosition(vehicle, true)
	 local vehPos = GetEntityCoords(vehicle)
 
	 if not isJackRaised then
		 SpawnJackProp(vehicle)
		 Citizen.Wait(250)
	 else
		 if DoesEntityExist(carJackObj) then
			 GetControlOfEntity(carJackObj)
			 SetEntityAsMissionEntity(carJackObj)
			 SetVehicleHasBeenOwnedByPlayer(carJackObj, true)
		 else
			 carJackObj =
				 GetClosestObjectOfType(
				 vehPos.x,
				 vehPos.y,
				 vehPos.z,
				 1.2,
				 GetHashKey("prop_carjack"),
				 false,
				 false,
				 false
			 )
			 GetControlOfEntity(carJackObj)
			 SetEntityAsMissionEntity(carJackObj)
			 SetVehicleHasBeenOwnedByPlayer(carJackObj, true)
		 end
	 end
 
	 local objPos = GetEntityCoords(carJackObj)
	 -- Request & Load Animation:
	 local anim_dict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@"
	 local anim_lib = "weed_crouch_checkingleaves_idle_02_inspector"
	 LoadAnim(anim_dict)
	 -- progbar:
	 local label = ""
	 if isJackRaised then
		 label = Lang["progbar_lowering_jack"]
		 vehAnalysed = false
	 else
		 label = Lang["progbar_raising_jack"]
	 end
	-- exports["progressBars"]:startUI((6500), label)
	 RSCore.Functions.Progressbar("sell_pawn_items", label, 6500, false, true, {}, {}, {}, {}, function()
		 -- Done

	 end, function()
		 -- Cancel

	 end)
	 -- Raise Jack Task:
	 TaskPlayAnim(player, anim_dict, anim_lib, 2.0, -3.5, -1, 1, false, false, false, false)
	 Citizen.Wait(1000)
	 ClearPedTasks(player)
	 local count = 5
	 while true do
		 vehPos = GetEntityCoords(vehicle)
		 objPos = GetEntityCoords(carJackObj)
		 if count > 0 then
			 TaskPlayAnim(player, anim_dict, anim_lib, 3.5, -3.5, -1, 1, false, false, false, false)
			 Citizen.Wait(1000)
			 ClearPedTasks(player)
			 if not isJackRaised then
				 SetEntityCoordsNoOffset(vehicle, vehPos.x, vehPos.y, (vehPos.z + 0.10), true, false, false, true)
				 SetEntityCoordsNoOffset(carJackObj, objPos.x, objPos.y, (objPos.z + 0.10), true, false, false, true)
			 else
				 SetEntityCoordsNoOffset(vehicle, vehPos.x, vehPos.y, (vehPos.z - 0.10), true, false, false, true)
				 SetEntityCoordsNoOffset(carJackObj, objPos.x, objPos.y, (objPos.z - 0.10), true, false, false, true)
			 end
			 FreezeEntityPosition(vehicle, true)
			 FreezeEntityPosition(carJackObj, true)
			 count = count - 1
		 end
		 if count <= 0 then
			 ClearPedTasks(player)
			 if isJackRaised then
				 FreezeEntityPosition(vehicle, false)
				 if DoesEntityExist(carJackObj) then
					 DeleteEntity(carJackObj)
					 DeleteObject(carJackObj)
				 end
				 carJackObj = nil
				 isJackRaised = false
			 else
				 isJackRaised = true
			 end
			 usingJack = false
			-- exports["progressBars"]:closeUI()
			 break
		 end
	 end
	 ClearPedTasks(player)
 end
 
 function FetchVehicleBodyDamageReport(vehicle, plate)
	 -- Interact To Veh Part:
	 local d1, d2 = GetModelDimensions(GetEntityModel(vehicle))
	 local spots = {
		 [1] = {
			 pos = GetOffsetFromEntityInWorldCoords(vehicle, d2.x + 0.2, 0.0, 0.0),
			 scenario = "WORLD_HUMAN_WELDING",
			 done = false
		 },
		 [2] = {
			 pos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, d2.y + 0.2, 0.0),
			 scenario = "WORLD_HUMAN_VEHICLE_MECHANIC",
			 done = false
		 },
		 [3] = {
			 pos = GetOffsetFromEntityInWorldCoords(vehicle, d1.x - 0.2, 0.0, 0.0),
			 scenario = "WORLD_HUMAN_MAID_CLEAN",
			 done = false
		 },
		 [4] = {
			 pos = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, d1.y - 0.2, 0.0),
			 scenario = "WORLD_HUMAN_CLIPBOARD",
			 done = false
		 }
	 }
	 while true do
		 Citizen.Wait(1)
		 local vehPos = GetEntityCoords(vehicle)
		 for k, v in pairs(spots) do
			 local distance = (GetDistanceBetweenCoords(coords, vector3(v.pos.x, v.pos.y, v.pos.z), true))
			 if distance < 4.0 then
				 if not v.done then
					 RSCore.Functions.DrawText3D(v.pos.x, v.pos.y, v.pos.z, Lang["analyze_here"])
					 if IsControlJustPressed(0, 38) and distance < 1.0 then
						 if k == 2 then
							 SetEntityHeading(player, GetEntityHeading(vehicle))
							 Citizen.Wait(500)
						 else
							 TaskTurnPedToFaceEntity(player, vehicle, 1.0)
							 Citizen.Wait(1000)
						 end
						 TaskStartScenarioInPlace(player, v.scenario, 0, true)
						-- exports["progressBars"]:startUI(2500, Lang["progbar_analyzing_veh"])
						 RSCore.Functions.Progressbar("sell_pawn_items", Lang["progbar_analyzing_veh"], 2500, false, true, {}, {}, {}, {}, function()
							 -- Done

						 end, function()
							 -- Cancel

						 end)
						 Citizen.Wait(2500)
						 ClearPedTasks(player)
						 v.done = true
					 end
				 end
			 end
		 end
		 if spots[1].done and spots[2].done and spots[3].done and spots[4].done then
			 break
		 end
	 end
 
	 local damageReport = {doors = {}, wheels = {}, engine = nil, body = nil}
	 -- Doors Report:
	 for i = 0, GetNumberOfVehicleDoors(vehicle) + 1 do
		 if IsVehicleDoorDamaged(vehicle, i) then
			 damageReport.doors[i + 1] = true
			 local label, doorLabel = "", ""
			 if i >= 0 and i <= 3 then
				 if i == 0 then
					 doorLabel = "Left Front"
				 elseif i == 1 then
					 doorLabel = "Right Front"
				 elseif i == 2 then
					 doorLabel = "Back Left"
				 elseif i == 3 then
					 doorLabel = "Back Right"
				 end
				 label = "Door [" .. doorLabel .. "] »  Damaged » Replace the Door"
			 end
			 if i == 4 then
				 label = "Door [Hood] »  Damaged » Replace the Hood"
			 elseif i == 5 then
				 label = "Door [Trunk] »  Damaged » Replace the Trunk"
			 elseif i == 6 then
				 label = "Door [Trunk2] »  Damaged » Replace the trunk"
			 end
			 TriggerEvent("chat:addMessage", {args = {label}})
		 else
			 damageReport.doors[i + 1] = false
		 end
	 end
	 -- Wheels Report:
	 for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do
		 if i == 0 or i == 1 then
			 if IsVehicleTyreBurst(vehicle, i) or GetVehicleWheelXOffset(vehicle, i) == 9999.0 then
				 damageReport.wheels[i + 1] = true
				 local label = ""
				 if i == 0 then
					 label = "^*Wheel [Left Front] »  Bursted » Replace the Wheel"
				 elseif i == 1 then
					 label = "^*Wheel [Right Front] »  Bursted » Replace the Wheel"
				 end
				 TriggerEvent("chat:addMessage", {args = {label}})
			 else
				 damageReport.wheels[i + 1] = false
			 end
		 end
		 if i == 2 then
			 if IsVehicleTyreBurst(vehicle, 4) or GetVehicleWheelXOffset(vehicle, i) == 9999.0 then
				 damageReport.wheels[i + 1] = true
				 local label = "Wheel [Back Left] »  Bursted » Replace the Wheel"
				 TriggerEvent("chat:addMessage", {args = {label}})
			 else
				 damageReport.wheels[i + 1] = false
			 end
		 end
		 if i == 3 then
			 if IsVehicleTyreBurst(vehicle, 5) or GetVehicleWheelXOffset(vehicle, i) == 9999.0 then
				 damageReport.wheels[i + 1] = true
				 local label = "Wheel [Back Right] »  Bursted » Replace the Wheel"
				 TriggerEvent("chat:addMessage", {args = {label}})
			 else
				 damageReport.wheels[i + 1] = false
			 end
		 end
	 end
	 -- Engine Report
	 damageReport.engine = GetVehicleEngineHealth(vehicle)
	 -- Body Report
	 damageReport.body = GetVehicleBodyHealth(vehicle)
	 SetVehicleCanDeformWheels(vehicle, false)
	 Wait(500)
	 vehicleData[plate] = {report = damageReport, entity = vehicle}
	 vehAnalysed = true
	 RefreshVehicleDamage(vehicleData[plate].entity, plate)
 end
 
 installingPart = false
 carryObj = nil
 RegisterNetEvent("t1ger_mechanicjob:installBodyPartCL")
 AddEventHandler(
	 "t1ger_mechanicjob:installBodyPartCL",
	 function(id, val)
		 local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
		 if vehicle ~= 0 then
			 if vehAnalysed then
			 else
				 return ShowNotifyESX(Lang["analyze_veh_first"])
			 end
			 GetControlOfEntity(vehicle)
			 local vehCoords = GetEntityCoords(vehicle, 1)
			 local distance = GetDistanceBetweenCoords(coords, vehCoords, false)
			 if not installingPart then
				 if not DoesEntityExist(carryObj) then
					 local anim_dict = "anim@heists@box_carry@"
					 LoadAnim(anim_dict)
					 TaskPlayAnim(player, anim_dict, "idle", 6.0, -2.0, -1, 50, 0, false, false, false)
					 SpawnObject(
						 val.prop,
						 {x = coords.x, y = coords.y, z = coords.z},
						 function(spawnObj)
							 carryObj = spawnObj
							 local boneIndex = GetPedBoneIndex(player, 28422)
							 AttachEntityToEntity(
								 spawnObj,
								 player,
								 boneIndex,
								 val.pos[1],
								 val.pos[2],
								 val.pos[3],
								 val.rot[1],
								 val.rot[2],
								 val.rot[3],
								 true,
								 true,
								 false,
								 true,
								 1,
								 true
							 )
						 end
					 )
				 end
				 while true do
					 Citizen.Wait(1)
					 distance = GetDistanceBetweenCoords(coords, vehCoords, false)
					 if distance < 4.0 then
						 local findObj =
							 GetClosestObjectOfType(
							 vehCoords.x,
							 vehCoords.y,
							 vehCoords.z,
							 1.0,
							 GetHashKey("prop_carjack"),
							 false,
							 false,
							 false
						 )
						 if DoesEntityExist(findObj) then
							 RSCore.Functions.DrawText3D(vehCoords.x, vehCoords.y, vehCoords.z, Lang["install_body_part"])
							 if IsControlJustPressed(0, 47) and distance < 1.5 then
								 installingPart = true
								 local plate = GetVehicleNumberPlateText(vehicle):gsub("^%s*(.-)%s*$", "%1")
								 if id == 1 then
									 for i = 0, (GetNumberOfVehicleDoors(vehicleData[plate].entity) - 2) do
										 if vehicleData[plate].report.doors[i + 1] == true then
											 vehicleData[plate].report.doors[i + 1] = false
											 TriggerServerEvent("t1ger_mechanicjob:syncVehicleBodySV", plate)
											 TriggerServerEvent("t1ger_mechanicjob:removeItem", val.item, 1)
											 break
										 else
											 if
												 tonumber(i + 1) ==
													 tonumber(GetNumberOfVehicleDoors(vehicleData[plate].entity) - 2)
											  then
												 ShowNotifyESX(Lang["all_doors_intact"])
												 break
											 end
										 end
									 end
								 end
								 if id == 2 then
									 if vehicleData[plate].report.doors[4 + 1] == true then
										 vehicleData[plate].report.doors[4 + 1] = false
										 TriggerServerEvent("t1ger_mechanicjob:syncVehicleBodySV", plate)
										 TriggerServerEvent("t1ger_mechanicjob:removeItem", val.item, 1)
									 else
										 ShowNotifyESX(Lang["hood_already_installed"])
									 end
								 end
								 if id == 3 then
									 if vehicleData[plate].report.doors[5 + 1] == true then
										 vehicleData[plate].report.doors[5 + 1] = false
										 TriggerServerEvent("t1ger_mechanicjob:syncVehicleBodySV", plate)
										 TriggerServerEvent("t1ger_mechanicjob:removeItem", val.item, 1)
									 else
										 ShowNotifyESX(Lang["trunk_already_installed"])
									 end
								 end
								 if id == 4 then
									 for i = 0, (GetVehicleNumberOfWheels(vehicleData[plate].entity) - 1) do
										 if GetVehicleWheelXOffset(vehicleData[plate].entity, i) == 9999.0 then
											 if vehicleData[plate].report.wheels[i + 1] == true then
												 vehicleData[plate].report.wheels[i + 1] = false
												 TriggerServerEvent("t1ger_mechanicjob:syncVehicleBodySV", plate)
												 TriggerServerEvent("t1ger_mechanicjob:removeItem", val.item, 1)
												 break
											 end
										 else
											 if
												 tonumber(i + 1) ==
													 tonumber(GetVehicleNumberOfWheels(vehicleData[plate].entity) - 1)
											  then
												 ShowNotifyESX(Lang["all_wheels_intact"])
												 SetVehicleCanDeformWheels(vehicle, true)
											 end
										 end
									 end
								 end
								 DetachEntity(carryObj, 1, 0)
								 DeleteObject(carryObj)
								 carryObj = nil
								 ClearPedTasks(player)
								 Citizen.Wait(100)
 
								 local progression = GetBodyRepairProgression(vehicle)
								 ShowNotifyESX("Progression: [" .. progression .. "/100]")
								 if progression >= 100 then
									 SetVehicleCanDeformWheels(vehicle, true)
									 Wait(100)
									 SetVehicleFixed(vehicle)
									 SetVehicleBodyHealth(vehicle, 1000.0)
									 vehAnalysed = false
									 ShowNotifyESX(Lang["all_body_repairs_done"])
								 end
								 break
							 end
						 else
							 ShowNotifyESX(Lang["raise_and_analyze"])
							 break
						 end
					 end
					 if distance > 4.0 then
						 break
					 end
				 end
			 else
				 ShowNotifyESX(Lang["finish_current_install"])
			 end
		 else
			 ShowNotifyESX(Lang["no_vehicle_nearby"])
		 end
		 installingPart = false
	 end
 )
 
 function RefreshVehicleDamage(vehicle, plate)
	 SetVehicleFixed(vehicle)
	 SetVehicleDirtLevel(
	vehicle --[[ Vehicle ]], 
	0.0 --[[ number ]]
)
	 for i = 0, GetNumberOfVehicleDoors(vehicle) + 1 do
		 if vehicleData[plate].report.doors[i + 1] == true then
			 SetVehicleDoorBroken(vehicle, i, true)
		 end
	 end
	 if vehicleData[plate].report.engine ~= nil then
		 SetVehicleEngineHealth(vehicle, tonumber(vehicleData[plate].report.engine))
	 else
		 SetVehicleEngineHealth(vehicle, 0)
	 end
	 if vehicleData[plate].report.body ~= nil then
		 SetVehicleBodyHealth(vehicle, tonumber(vehicleData[plate].report.body))
	 else
		 SetVehicleBodyHealth(vehicle, 800)
	 end
	 for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do
		 if vehicleData[plate].report.wheels[i + 1] == true then
			 SetVehicleWheelsCanBreak(vehicle, i)
			 SetVehicleWheelHealth(vehicle, i, 100.0)
			 SetVehicleWheelXOffset(vehicle, i, 9999.0)
			SetVehicleWheelYRotation(vehicle, i, -90.0)
		 else
			 SetVehicleWheelsCanBreak(vehicle, i, false)
			 SetVehicleWheelHealth(vehicle, i, 100.0)
			 SetVehicleWheelXOffset(vehicle, i, wheelProperties[plate][i + 1].xOffset)
			 SetVehicleWheelYRotation(vehicle, i, wheelProperties[plate][i + 1].yRotation)
		 end
	 end
	 RemoveVehicleWindow(vehicle, 0)
	 RemoveVehicleWindow(vehicle, 1)
	 RemoveVehicleWindow(vehicle, 2)
	 RemoveVehicleWindow(vehicle, 3)
 end
 
 -- On the road repairs:
 local repairing = false
 RegisterNetEvent("t1ger_mechanicjob:useRepairKit")
 AddEventHandler(
	 "t1ger_mechanicjob:useRepairKit",
	 function(type, val)
		 local vehicle = nil
 
		 vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
 
		 if vehicle ~= 0 then
			 if repairing then
				 return
			 end
			 repairing = true
 
			 -- Get Control of Vehicle:
			 local netTime = 15
			 NetworkRequestControlOfEntity(vehicle)
			 while not NetworkHasControlOfEntity(vehicle) and netTime > 0 do
				 NetworkRequestControlOfEntity(vehicle)
				 Citizen.Wait(100)
				 netTime = netTime - 1
			 end
 
			 -- Get Repair Veh Position:
			 local d1, d2 = GetModelDimensions(GetEntityModel(vehicle))
			 local hood = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, d2.y + 0.2, 0.0)
			 local distance =
				 (GetDistanceBetweenCoords(GetEntityCoords(player, 1), vector3(hood.x, hood.y, hood.z), true))
			 local vehRepaired = false
 
			 -- Repair thread:
			 while not vehRepaired do
				 Citizen.Wait(1)
				 distance = (GetDistanceBetweenCoords(GetEntityCoords(player, 1), vector3(hood.x, hood.y, hood.z), true))
				 RSCore.Functions.DrawText3D(hood.x, hood.y, hood.z, Lang["repair_here"])
				 if IsControlJustPressed(0, 38) then
					 if distance < 1.0 then
						 SetVehicleDoorOpen(vehicle, 4, 0, 0)
						 TaskTurnPedToFaceEntity(player, vehicle, 1.0)
						 Citizen.Wait(1000)
						 local animDict = "mini@repair"
						 LoadAnim(animDict)
						 if not IsEntityPlayingAnim(player, animDict, "fixing_a_player", 3) then
							 TaskPlayAnim(
								 player,
								 animDict,
								 "fixing_a_player",
								 5.0,
								 -5,
								 -1,
								 16,
								 false,
								 false,
								 false,
								 false
							 )
						 end
						 -- repair options:
						 RepairVehOptions(vehicle, type, val)
						 -- Chance to destroy item:
						 if math.random(100) > val.chanceToKeep then
							 TriggerServerEvent("t1ger_mechanicjob:removeItem", val.item, 1)
							 ShowNotifyESX(Lang["repair_kit_broke"])
						 end
						 -- end:
						 SetVehicleDoorShut(vehicle, 4, 1, 1)
						 ClearPedTasks(player)
						 ShowNotifyESX(Lang["repairkit_veh_repaired"])
						 vehRepaired = true
						 repairing = false
						 break
					 else
						 distance =
							 (GetDistanceBetweenCoords(GetEntityCoords(player, 1), vector3(hood.x, hood.y, hood.z), true))
					 end
				 end
			 end
		 end
		 repairing = false
	 end
 )
 
 -- Choose repairs with repairkit:
 function RepairVehOptions(veh, type, val)
	 local repairDuration =
		 (((3000 - GetVehicleEngineHealth(vehicle)) - (GetVehicleBodyHealth(vehicle) / 2)) * 2 + val.repairTime)
	-- exports["progressBars"]:startUI((repairDuration), val.progbar)
	 RSCore.Functions.Progressbar("sell_pawn_items", repairDuration, val.progbar, false, true, {}, {}, {}, {}, function()
		 -- Done

	 end, function()
		 -- Cancel

	 end)
	 Citizen.Wait(repairDuration)
	 if type == 1 then
		 if GetVehicleEngineHealth(veh) < 200.0 then
			 SetVehicleEngineHealth(veh, 200.0)
		 end
		 if GetVehicleBodyHealth(veh) < 910.0 then
			 SetVehicleBodyHealth(veh, 910.0)
		 end
		 for i = 0, math.random(5) do
			 SetVehicleTyreFixed(veh, i)
		 end
	 end
	 if type == 2 then
		 if GetVehicleEngineHealth(veh) < 200.0 then
			 SetVehicleEngineHealth(veh, 450.0)
		 end
		 if GetVehicleBodyHealth(veh) < 910.0 then
			 SetVehicleBodyHealth(veh, 975.0)
		 end
		 for i = 0, 5 do
			 SetVehicleTyreFixed(veh, i)
		 end
	 end
 end
 
 -- Vehicle Value Saver:
 Citizen.CreateThread(
	 function()
		 Citizen.Wait(1000)
		 local count = 0
		 while true do
			 Citizen.Wait(1000)
			 if IsPedInVehicle(player, curVehicle, false) then
				 count = count + 1
				 if count >= Config.WaitCountForHealth then
					 if player == driver then
						 local plate = GetVehicleNumberPlateText(curVehicle):gsub("^%s*(.-)%s*$", "%1")
						 local engine = math.ceil(GetVehicleEngineHealth(curVehicle))
						 local body = math.ceil(GetVehicleBodyHealth(curVehicle))
						 ApplyVehicledegradation(curVehicle, plate)
					 end
					 count = 0
				 end
			 end
		 end
	 end
 )
 
 function ApplyVehicledegradation(curVehicle, plate)
	 RSCore.Functions.TriggerCallback(
		 "t1ger_mechanicjob:getIfVehicleOwned",
		 function(vehOwned)
			 if vehOwned then
				 RSCore.Functions.TriggerCallback(
					 "t1ger_mechanicjob:getVehDegradation",
					 function(degradation)
						 if degradation ~= nil then
							 local vehHealth = {}
							 -- insert values into health array:
							 for k, v in pairs(degradation) do
								 local partValue = (round(v.value / 10, 2))
								 vehHealth[v.part] = v.value
							 end
							 -- electronics:
							 if vehHealth["electronics"] <= 40 then
								 local chance, electronics = math.random(1, 100), vehHealth["electronics"]
								 if electronics <= 40 and electronics >= 25 and chance > 85 then
									 for i = 0, 10 do
										 Citizen.Wait(50)
										 ElectronicsEffects(curVehicle)
									 end
								 end
								 if electronics <= 24 and electronics >= 10 and chance > 70 then
									 for i = 0, 10 do
										 Citizen.Wait(100)
										 ElectronicsEffects(curVehicle)
									 end
								 end
								 if electronics <= 9 and electronics >= 0 and chance > 50 then
									 for i = 0, 10 do
										 Citizen.Wait(200)
										 ElectronicsEffects(curVehicle)
									 end
								 end
							 end
							 -- Fuel Injector:
							 if vehHealth["fuelinjector"] <= 40 then
								 local chance, fuel_injector = math.random(1, 100), vehHealth["fuelinjector"]
								 if fuel_injector <= 40 and fuel_injector >= 25 and chance > 85 then
									 FuelInjectorEffects(curVehicle, 200)
								 end
								 if fuel_injector <= 24 and fuel_injector >= 10 and chance > 70 then
									 FuelInjectorEffects(curVehicle, 500)
								 end
								 if fuel_injector <= 9 and fuel_injector >= 0 and chance > 50 then
									 FuelInjectorEffects(curVehicle, 1000)
								 end
							 end
							 -- Brakes:
							 if vehHealth["brakes"] <= 40 then
								 local chance, brakes = math.random(1, 100), vehHealth["brakes"]
								 if brakes <= 40 and brakes >= 25 and chance > 85 then
									 BrakesEffects(curVehicle, 1000)
								 end
								 if brakes <= 24 and brakes >= 10 and chance > 70 then
									 BrakesEffects(curVehicle, 4000)
								 end
								 if brakes <= 9 and brakes >= 0 and chance > 50 then
									 BrakesEffects(curVehicle, 8000)
								 end
							 end
							 -- Radiator:
							 if vehHealth["radiator"] <= 40 then
								 local chance, radiator = math.random(1, 100), vehHealth["radiator"]
								 if radiator <= 40 and radiator >= 25 then
									 RadiatorEffects(curVehicle, chance, 1000)
								 end
								 if radiator <= 24 and radiator >= 10 then
									 RadiatorEffects(curVehicle, chance, 3000)
								 end
								 if radiator <= 9 and radiator >= 0 then
									 RadiatorEffects(curVehicle, chance, 5000)
								 end
							 end
							 -- Drive Shaft / Axle:
							 if vehHealth["driveshaft"] <= 40 then
								 local chance, axle = math.random(1, 100), vehHealth["driveshaft"]
								 if axle <= 40 and axle >= 25 and chance > 85 then
									 DriveShaftEffects(curVehicle, 10)
								 end
								 if axle <= 24 and axle >= 10 and chance > 70 then
									 DriveShaftEffects(curVehicle, 20)
								 end
								 if axle <= 9 and axle >= 0 and chance > 50 then
									 DriveShaftEffects(curVehicle, 30)
								 end
							 end
							 -- Transmission:
							 if vehHealth["transmission"] <= 40 then
								 local chance, transmission = math.random(1, 100), vehHealth["transmission"]
								 if transmission <= 40 and transmission >= 25 and chance > 85 then
									 TransmissionEffects(curVehicle, 5, 2)
								 end
								 if transmission <= 24 and transmission >= 10 and chance > 70 then
									 TransmissionEffects(curVehicle, 10, 4)
								 end
								 if transmission <= 9 and transmission >= 0 and chance > 50 then
									 TransmissionEffects(curVehicle, 20, 8)
								 end
							 end
							 -- Clutch:
							 if vehHealth["clutch"] <= 40 then
								 local chance, clutch = math.random(1, 100), vehHealth["clutch"]
								 if clutch <= 40 and clutch >= 25 and chance > 85 then
									 ClutchEffects(curVehicle, 1500, 75)
								 end
								 if clutch <= 24 and clutch >= 10 --[[and chance > 70]] then
									 ClutchEffects(curVehicle, 3000, 150)
								 end
								 if clutch <= 9 and clutch >= 0 and chance > 50 then
									 ClutchEffects(curVehicle, 6000, 300)
								 end
							 end
						 else
							 return
						 end
					 end,
					 plate
				 )
			 else
				 return
			 end
		 end,
		 plate
	 )
 end
 
 function ElectronicsEffects(entity)
	 local radios = {
		 "RADIO_03_HIPHOP_NEW",
		 "RADIO_04_PUNK",
		 "RADIO_05_TALK_01",
		 "RADIO_14_DANCE_02",
		 "RADIO_20_THELAB",
		 "RADIO_17_FUNK",
		 "RADIO_18_90S_ROCK"
	 }
	 SetVehicleLights(entity, 1)
	 SetVehRadioStation(entity, radios[math.random(1, #radios)])
	 Citizen.Wait(500)
	 SetVehicleLights(entity, 0)
 end
 
 function FuelInjectorEffects(entity, timer)
	 SetVehicleEngineOn(entity, 0, 0, 1)
	 SetVehicleUndriveable(entity, true)
	 Citizen.Wait(timer)
	 SetVehicleEngineOn(entity, 1, 0, 1)
	 SetVehicleUndriveable(entity, false)
 end
 
 function BrakesEffects(entity, timer)
	 SetVehicleHandbrake(entity, true)
	 Citizen.Wait(timer)
	 SetVehicleHandbrake(entity, false)
 end
 
 function RadiatorEffects(curVehicle, chance, timer)
	 local lastTemp = GetVehicleEngineTemperature(curVehicle)
	 local eh = GetVehicleEngineHealth(curVehicle)
	 SetVehicleEngineTemperature(curVehicle, 500.0)
	 Citizen.Wait(timer + 2000)
	 if eh >= 900 then
		 SetVehicleEngineHealth(curVehicle, (eh - 10))
	 end
	 if eh >= 450 then
		 SetVehicleEngineHealth(curVehicle, (eh - 15))
	 end
	 if eh >= 250 then
		 SetVehicleEngineHealth(curVehicle, (eh - 25))
	 end
	 SetVehicleEngineTemperature(curVehicle, lastTemp)
 end
 
 function DriveShaftEffects(curVehicle, timer)
	 local steerBias = {-1.0, -0.9, -0.8, 0.8, 0.9, 1.0}
	 local value = steerBias[math.random(#steerBias)]
	 local tick = 0
	 while true do
		 Citizen.Wait(timer)
		 SetVehicleSteerBias(curVehicle, value)
		 tick = tick + 1
		 if tick >= 20 then
			 tick = 0
			 break
		 end
	 end
 end
 
 function TransmissionEffects(curVehicle, timer, count)
	 for i = 0, count do
		 Citizen.Wait(timer)
		 SetVehicleHandbrake(curVehicle, true)
		 Citizen.Wait(1000)
		 SetVehicleHandbrake(curVehicle, false)
	 end
 end
 
 function ClutchEffects(curVehicle, timer, fuelTimer)
	 SetVehicleHandbrake(curVehicle, true)
	 FuelInjectorEffects(curVehicle, fuelTimer)
	 for i = 1, 360 do
		 SetVehicleSteeringScale(curVehicle, i)
		 Citizen.Wait(5)
	 end
	 Citizen.Wait(timer)
	 SetVehicleHandbrake(curVehicle, false)
 end
 
 -- Vehicle Collision / Damage --
 Citizen.CreateThread(
	 function()
		 Citizen.Wait(1000)
		 local lastVehSpeed = 0.0
		 local lastVehBodyhealth = 0.0
		 local multiplier = 2.236936
		 if Config.UseKMH then
			 multiplier = 3.6
		 end
		 while true do
			 Citizen.Wait(1)
			 if curVehicle ~= nil and curVehicle ~= 0 then
				 if driver == PlayerPedId() then
					 local curVehicleEngine = GetVehicleEngineHealth(curVehicle)
					 if curVehicleEngine < 0.0 then
						 SetVehicleEngineHealth(curVehicle, 0.0)
					 end
					 local crashed = HasEntityCollidedWithAnything(curVehicle)
					 if crashed then
						 Citizen.Wait(100)
						 local newVehBodyHealth = GetVehicleBodyHealth(curVehicle)
						 local newVehSpeed = (GetEntitySpeed(curVehicle) * multiplier)
 
						 if curVehicleEngine > 0.0 and (lastVehBodyhealth - newVehBodyHealth) > 10 then
							 if newVehSpeed < (lastVehSpeed * 0.5) and lastVehSpeed > 180.0 then
								 applyCrashDamage(curVehicle)
								 Citizen.Wait(1000)
								 lastVehSpeed = 0.0
								 lastVehBodyhealth = newVehBodyHealth
							 end
						 else
							 if curVehicleEngine > 10.0 and (curVehicleEngine < 199.0 or newVehBodyHealth < 100.0) then
								 applyCrashDamage(curVehicle)
								 Citizen.Wait(1000)
							 end
							 lastVehSpeed = newVehSpeed
							 lastVehBodyhealth = newVehBodyHealth
						 end
					 else
						 lastVehSpeed = (GetEntitySpeed(curVehicle) * multiplier)
						 lastVehBodyhealth = GetVehicleBodyHealth(curVehicle)
						 if curVehicleEngine > 10.0 and (curVehicleEngine < 199.0 or lastVehBodyhealth < 100.0) then
							 applyCrashDamage(curVehicle)
							 Citizen.Wait(1000)
						 end
					 end
				 end
			 end
		 end
	 end
 )
 
 function applyCrashDamage(vehicle)
	 if Config.SlashTires then
		 local tyres = {0, 1, 4, 5}
		 for i = 1, math.random(#tyres) do
			 local num = math.random(#tyres)
			 SetVehicleTyreBurst(vehicle, tyres[num], true, 1000)
			 table.remove(tyres, num)
		 end
	 end
	 if Config.EngineDisable then
		 SetVehicleEngineHealth(vehicle, 0)
		 SetVehicleEngineOn(vehicle, false, true, true)
	 end
	 local takenIDs = {}
	 local damageArray = {}
	 for i = 1, Config.AmountPartsDamage do
		 math.randomseed(GetGameTimer())
		 local id = math.random(#Config.HealthParts)
		 if Config.HealthParts[id].degName ~= "engine" then
			 while takenIDs[id] == id do
				 id = math.random(#Config.HealthParts)
				 if Config.HealthParts[id].degName == "engine" then
					 id = math.random(#Config.HealthParts)
				 end
			 end
		 end
		 takenIDs[id] = id
		 local vehPart = Config.HealthParts[id]
		 local degVal = math.random(Config.DegradeValue.min, Config.DegradeValue.max)
		 damageArray[vehPart.degName] = {label = vehPart.label, degName = vehPart.degName, degValue = degVal}
		 i = i + 1
	 end
	 local plate = GetVehicleNumberPlateText(curVehicle):gsub("^%s*(.-)%s*$", "%1")
	 TriggerServerEvent("t1ger_mechanicjob:degradeVehHealth", plate, damageArray)
	 takenIDs = {}
	 damageArray = {}
	 lastVehSpeed = 0.0
	 lastVehBodyhealth = 0.0
 end
 
 -- ## NPC VEHICLE REPAIR JOBS ## --
 
 local jobID = nil
 function ManageNpcJobs()
	 local elements = {
		 {label = "Find Call", value = "find_job"},
		 {label = "Cancel Job", value = "cancel_job"}
	 }
	 local assert = assert
		local menu = assert(MenuV)
	 local NpCMenu = MenuV:CreateMenu("NPC Job Menu","", 'size-150')

	 MenuV:OpenMenu(NpCMenu, function()
	end)
	


	for k,v in ipairs(elements) do
		local buybutton = NpCMenu:AddButton({icon ="🧑‍🔧 	",label = v.label,value = v,description = v.label , select = function(btn) 
		local value = btn.Value.value

		if value == "find_job" then
			local num = math.random(1,#Config.NPC_RepairJobs)
			local count = 0
			while Config.NPC_RepairJobs[num].inUse and count < 100 do
				count = count+1
				num = math.random(1,#Config.NPC_RepairJobs)
			end
			if count == 100 then
				ShowNotifyESX("Wait for a call")
			else
				Config.NPC_RepairJobs[num].inUse = true
				Wait(200)
				TriggerServerEvent('t1ger_mechanicjob:JobDataSV', Config.NPC_RepairJobs)
				TriggerEvent('t1ger_mechanicjob:startJobWithNPC', num)
			end
		elseif value == "cancel_job" then
			CancelCurrentJob()
			OpenMechanicActionMenu()
		end
		
		end })
	end
 end
 
 local CancelJob = false
 local JobVeh = nil
 local JobPed = nil
 RegisterNetEvent("t1ger_mechanicjob:startJobWithNPC")
 AddEventHandler(
	 "t1ger_mechanicjob:startJobWithNPC",
	 function(num)
		 local JobDone = false
		 local job = Config.NPC_RepairJobs[num]
		 local blip = CreateJobBlip(job.pos)
		 local jobVehSpawned = false
		 local vehicleRepaired = false
		 local pedCreated = false
		 local pedShouted = false
		 local buttonClicked = false
 
		 while not JobDone and not CancelJob do
			 Citizen.Wait(0)
 
			 if job.inUse then
				 local coords = GetEntityCoords(GetPlayerPed(-1))
				 local distance =
					 GetDistanceBetweenCoords(coords.x, coords.y, coords.z, job.pos[1], job.pos[2], job.pos[3], false)
 
				 if distance > 50.0 then
					 if DoesEntityExist(JobVeh) then
						 DeleteEntity(JobVeh)
						 DeleteVehicle(JobVeh)
						 SetEntityAsNoLongerNeeded(JobVeh)
						 JobVeh = nil
						 jobVehSpawned = false
					 end
				 end
 
				 if distance < 50.0 and not jobVehSpawned then
					 ClearAreaOfVehicles(job.pos[1], job.pos[2], job.pos[3], 5.0, false, false, false, false, false)
					 jobVehSpawned = true
					 Citizen.Wait(200)
					 math.randomseed(GetGameTimer())
					 local vehID = math.random(#Config.RepairVehicles)
					 local jobVehicle = Config.RepairVehicles[vehID]
					 RSCore.Functions.SpawnVehicle(
						 jobVehicle,
						 function(vehicle)
							 SetEntityCoordsNoOffset(vehicle, job.pos[1], job.pos[2], job.pos[3])
							 SetEntityHeading(vehicle, job.pos[4])
							 SetVehicleOnGroundProperly(vehicle)
							 SetEntityAsMissionEntity(JobVeh, true, true)
							 JobVeh = vehicle
							 SetVehicleEngineHealth(JobVeh, 100.0)
							 SetVehicleDoorOpen(JobVeh, 4, 0, 0)
							 SetPedIntoVehicle(ped, JobVeh, -1)
						 end,
						 {x = job.pos[1], y = job.pos[2], z = job.pos[3]},
						 true
					 )
				 end
 
				 if distance < 10.0 then
					 if not pedCreated then
						 RequestModel(job.ped)
						 while not HasModelLoaded(job.ped) do
							 Wait(10)
						 end
						 local NPC = CreatePedInsideVehicle(JobVeh, 1, job.ped, -1, true, true)
						 NetworkRegisterEntityAsNetworked(NPC)
						 SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(NPC), true)
						 SetNetworkIdExistsOnAllMachines(NetworkGetNetworkIdFromEntity(NPC), true)
						 SetPedKeepTask(NPC, true)
						 SetPedDropsWeaponsWhenDead(NPC, false)
						 SetEntityInvincible(NPC, false)
						 SetEntityVisible(NPC, true)
						 JobPed = NPC
						 SetEntityAsMissionEntity(JobPed)
						 pedCreated = true
					 end
					 if not pedShouted and distance < 6.0 then
						 ShowNotifyESX(Lang["npc_shout_msg"])
						 pedShouted = true
					 end
					 local d1, d2 = GetModelDimensions(GetEntityModel(JobVeh))
					 local enginePos = GetOffsetFromEntityInWorldCoords(JobVeh, 0.0, d2.y + 0.2, 0.0)
					 local pedPos = GetEntityCoords(JobPed)
					 local vehDistance =
						 (GetDistanceBetweenCoords(coords, vector3(enginePos.x, enginePos.y, enginePos.z), true))
					 local pedDistance = (GetDistanceBetweenCoords(coords, vector3(pedPos.x, pedPos.y, pedPos.z), false))
 
					 if vehDistance < 5.0 and not vehicleRepaired then
						 RSCore.Functions.DrawText3D(enginePos.x, enginePos.y, enginePos.z, Lang["npc_repair_veh"])
						 if IsControlJustPressed(0, 38) and vehDistance < 1.0 and not buttonClicked then
							 buttonClicked = true
							 RSCore.Functions.TriggerCallback(
								 "t1ger_mechanicjob:getInventoryItem",
								 function(hasItem)
									 if hasItem then
										 SetVehicleDoorOpen(JobVeh, 4, 0, 0)
										 TaskTurnPedToFaceEntity(GetPlayerPed(-1), JobVeh, 1.0)
										 Citizen.Wait(1000)
										 local animDict = "mini@repair"
										 LoadAnim(animDict)
										 if not IsEntityPlayingAnim(GetPlayerPed(-1), animDict, "fixing_a_player", 3) then
											 TaskPlayAnim(
												 GetPlayerPed(-1),
												 animDict,
												 "fixing_a_player",
												 5.0,
												 -5,
												 -1,
												 16,
												 false,
												 false,
												 false,
												 false
											 )
										 end
										-- exports["progressBars"]:startUI((4000), Lang["progbar_npc_fix"])
										 RSCore.Functions.Progressbar("sell_pawn_items", 4000, Lang["progbar_npc_fix"], false, true, {}, {}, {}, {}, function()
											 -- Done

										 end, function()
											 -- Cancel

										 end)
										 Citizen.Wait(4000)
										 SetVehicleEngineHealth(JobVeh, 1000.0)
										 SetVehicleBodyHealth(JobVeh, 1000.0)
										 SetVehicleFixed(JobVeh)
										 for i = 0, 5 do
											 SetVehicleTyreFixed(JobVeh, i)
										 end
										 if math.random(100) > 10 then
											 TriggerServerEvent("t1ger_mechanicjob:removeItem", "repairkit", 1)
											 ShowNotifyESX(Lang["npc_kit_broke"])
										 end
										 SetVehicleDoorShut(vehicle, 4, 1, 1)
										 ClearPedTasks(GetPlayerPed(-1))
										 ShowNotifyESX(Lang["npc_veh_repaired"])
										 vehicleRepaired = true
										 buttonClicked = false
									 else
										 ShowNotifyESX(Lang["npc_need_repair_kit"])
										 buttonClicked = false
									 end
								 end,
								 "repairkit"
							 )
						 end
					 end
 
					 if pedDistance < 5.0 and vehicleRepaired then
						 RSCore.Functions.DrawText3D(pedPos.x, pedPos.y, pedPos.z, Lang["npc_collect_cash"])
						 if IsControlJustPressed(0, 38) and pedDistance < 1.5 then
							 RollDownWindow(JobVeh, 0)
							 SetVehicleCanBeUsedByFleeingPeds(JobVeh, true)
							 LoadAnim("mp_common")
							 TaskTurnPedToFaceEntity(PlayerPedId(), JobVeh, 1.0)
							 Citizen.Wait(1000)
							 TaskPlayAnim(GetPlayerPed(-1), "mp_common", "givetake2_a", 4.0, 4.0, -1, 0, 1, 0, 0, 0)
							 RSCore.Functions.Progressbar("sell_pawn_items", 4000, Lang["progbar_npc_cash"], false, true, {}, {}, {}, {}, function()
								 -- Done

							 end, function()
								 -- Cancel

							 end)
							 Citizen.Wait(2000)
							 ClearPedTasks(GetPlayerPed(-1))
							 RollUpWindow(JobVeh, 0)
							 ShowNotifyESX(Lang["npc_thanking_msg"])
							 TriggerServerEvent("t1ger_mechanicjob:JobReward")
							 Wait(500)
							 if DoesBlipExist(blip) then
								 RemoveBlip(blip)
							 end
							 TaskVehicleDriveWander(JobPed, JobVeh, 80.0, 786603)
							 Wait(2500)
							 TaskSmartFleePed(JobPed, PlayerPedId(), 40.0, 20000)
							 Wait(2500)
							 CancelJob = true
						 end
					 end
				 end
 
				 if CancelJob then
					 if DoesEntityExist(JobVeh) then
						 DeleteVehicle(JobVeh)
					 end
					 if DoesEntityExist(JobPed) then
						 DeleteEntity(JobPed)
					 end
					 if DoesBlipExist(blip) then
						 RemoveBlip(blip)
					 end
					 Config.NPC_RepairJobs[num].inUse = false
					 Wait(200)
					 TriggerServerEvent("t1ger_mechanicjob:JobDataSV", Config.NPC_RepairJobs)
					 JobVeh = nil
					 JobPed = nil
					 CancelJob = false
					 break
				 end
			 end
		 end
	 end
 )
 
 -- Function for job blip in progress:
 function CreateJobBlip(pos)
	 local blip = AddBlipForCoord(pos[1], pos[2], pos[3])
	 SetBlipSprite(blip, 1)
	 SetBlipColour(blip, 5)
	 AddTextEntry("MYBLIP", Lang["npc_repair_job"])
	 BeginTextCommandSetBlipName("MYBLIP")
	 AddTextComponentSubstringPlayerName(name)
	 EndTextCommandSetBlipName(blip)
	 SetBlipScale(blip, 0.7) -- set scale
	 SetBlipAsShortRange(blip, true)
	 SetBlipRoute(blip, true)
	 SetBlipRouteColour(blip, 5)
	 return blip
 end
 
 AddEventHandler(
	 "esx:onPlayerDeath",
	 function(data)
		 CancelJob = true
		 if JobVeh ~= nil or JobPed ~= nil then
			 ShowNotifyESX(Lang["npc_cancel_job_death"])
		 end
		 Wait(300)
		 CancelJob = false
	 end
 )
 
 function CancelCurrentJob()
	 CancelJob = true
	 if JobVeh ~= nil or JobPed ~= nil then
		 ShowNotifyESX(Lang["npc_job_cancel_by_ply"])
	 end
	 Wait(300)
	 CancelJob = false
 end
 
 -- Update Lift State:
 RegisterNetEvent("t1ger_mechanicjob:liftStateCL")
 AddEventHandler(
	 "t1ger_mechanicjob:liftStateCL",
	 function(k, id, val, vehicle, state)
		 Config.MechanicShops[k].lifts[id] = val
		 Config.MechanicShops[k].lifts[id].currentVeh = vehicle
		 Config.MechanicShops[k].lifts[id].inUse = state
	 end
 )
 
 RegisterNetEvent("t1ger_mechanicjob:syncVehicleBodyCL")
 AddEventHandler(
	 "t1ger_mechanicjob:syncVehicleBodyCL",
	 function(plate)
		 RefreshVehicleDamage(vehicleData[plate].entity, plate)
	 end
 )
 
 function GetBodyRepairProgression(vehicleEntity)
	 if DoesEntityExist(vehicleEntity) then
		 local numWheels = GetVehicleNumberOfWheels(vehicleEntity)
		 local numDoors = (GetNumberOfVehicleDoors(vehicleEntity) - 2)
		 local plate = GetVehicleNumberPlateText(vehicleEntity):gsub("^%s*(.-)%s*$", "%1")
		 local numHood, numTrunk = 0, 0
		 local totalValue = numDoors + numWheels + numHood + numTrunk + 2
		 numWheels, numDoors = 0, 0
		 for i = 0, (GetNumberOfVehicleDoors(vehicleEntity) - 2) - 1 do
			 if vehicleData[plate].report.doors[i + 1] == false then
				 numDoors = numDoors + 1
			 end
		 end
		 if vehicleData[plate].report.doors[5] == false then
			 numHood = numHood + 1
		 end
		 if vehicleData[plate].report.doors[6] == false then
			 numTrunk = numTrunk + 1
		 end
		 for i = 0, GetVehicleNumberOfWheels(vehicleEntity) - 1 do
			 if vehicleData[plate].report.wheels[i + 1] == false then
				 numWheels = numWheels + 1
			 end
		 end
		 local newValue = numWheels + numDoors + numHood + numTrunk
		 return (math.floor((newValue / totalValue) * 100))
	 end
 end
 
 function SpawnJackProp(vehicle)
	 local heading = GetEntityHeading(vehicle)
	 local objPos = GetEntityCoords(vehicle)
	 carJackObj = CreateObject(GetHashKey("prop_carjack"), objPos.x, objPos.y, objPos.z - 0.95, true, true, true)
	 SetEntityHeading(carJackObj, heading)
	 FreezeEntityPosition(carJackObj, true)
 end
 
 function GetControlOfEntity(entity)
	 local netTime = 15
	 NetworkRequestControlOfEntity(entity)
	 while not NetworkHasControlOfEntity(entity) and netTime > 0 do
		 NetworkRequestControlOfEntity(entity)
		 Citizen.Wait(100)
		 netTime = netTime - 1
	 end
 end
 
 RegisterNetEvent("t1ger_mechanicjob:JobDataCL")
 AddEventHandler(
	 "t1ger_mechanicjob:JobDataCL",
	 function(data)
		 Config.NPC_RepairJobs = data
	 end
 )
 
 AddEventHandler(
	 "onClientResourceStart",
	 function(resourceName)
		 local ped = GetPlayerPed(-1)
		 local coords = GetEntityCoords(ped)
		
		 TriggerServerEvent("t1ger_mechanicjob:fetchMechShops")
		 vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71) --What this does is unfreeze the car if you restart the script
		 if vehicle then
			 FreezeEntityPosition(vehicle, false)
		 else
			 return
		 end
		 ClearPedSecondaryTask(player)
		 Wait(500)
		 local item =GetHashKey("prop_carjack") 
		 local findObj =
					 GetClosestObjectOfType(
					 coords.x,
					 coords.y,
					 coords.z,
					 1.0,
					 item,
					 false,
					 false,
					 false
				 )
				 if findObj then
					if DoesEntityExist(item) then
						print(true)
					DeleteEntity(item)
					 DeleteObject(item)
					end
					
				 end
			

	 end
 )
 

 SpawnObject = function(model, coords, cb, networked, dynamic) --#CREDITS TO ESX FOR THIS FUNCTION
	local vector = type(coords) == "vector3" and coords or vec(coords.x, coords.y, coords.z)
	networked = networked == nil and true or false
	dynamic = dynamic ~= nil and true or false
	
	CreateThread(function()
		
		
		-- The below has to be done just for CreateObject since for some reason CreateObjects model argument is set
		-- as an Object instead of a hash so it doesn't automatically hash the item
		model = type(model) == 'number' and model or GetHashKey(model)
		local obj = CreateObject(model, vector.xyz, networked, false, dynamic)
		if cb then
			cb(obj)
		end
	end)
end 
 -- JERICOFX#3512
 -- Config.Materials[k].item
 -- JERICOFX#3512
 -- JERICOFX#3512
 -- JERICOFX#3512
 -- JERICOFX#3512
 -- JERICOFX#3512
 -- JERICOFX#3512
 -- JERICOFX#3512
 -- JERICOFX#3512
 