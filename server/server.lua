

RSCore = nil
TriggerEvent('RSCore:GetObject', function(obj) RSCore = obj end)
RegisterServerEvent('t1ger_mechanicjob:fetchMechShops')
AddEventHandler('t1ger_mechanicjob:fetchMechShops', function()

    local xPlayers = RSCore.Functions.GetPlayers()
    local players  = {}

    local DataFected = false
	for i = 1, #xPlayers, 1 do
        local xPlayer = RSCore.Functions.GetPlayer(xPlayers[i])
		table.insert(players, { source = xPlayer.PlayerData.source, identifier = xPlayer.PlayerData.steam, shopID = 0 })
    end
    exports['ghmattimysql']:execute("SELECT * FROM t1ger_mechanic", {}, function(results)
        if #results > 0 then 
            for l,ply in pairs(players) do
                for k,v in pairs(results) do
                    if ply.identifier == v.identifier then
                        ply.shopID = v.shopID
                    end
                    if k == #results then DataFected = true end
                    
                end
            end
        else
            DataFected = true
        end
    end)
    while not DataFected do Wait(5) end
    local plyShopID = 0
    if DataFected then 
        for k,v in pairs(players) do
            if v.shopID > 0 then plyShopID = v.shopID else plyShopID = 0 end
           
            TriggerClientEvent('t1ger_mechanicjob:fetchMechShopsCL', v.source, plyShopID)
           
        end
    end

end)
RSCore.Functions.CreateCallback('t1ger_mechanicjob:getIfVehicleOwned', function (source, cb, plate)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    local found = nil
    local vehicleData = nil

    exports['ghmattimysql']:execute('SELECT * FROM player_vehicles WHERE steam = @owner', {
        ['@owner'] = xPlayer.PlayerData.steam
    }, function (result)

        local vehicles = {}

        for i=1, #result, 1 do
            vehicleData = json.decode(result[i].mods)
            if vehicleData.plate == plate then
                found = true
                cb(found)
                break
            end
        end

        if not found then
            cb(nil)
        end
    end)
end)
RSCore.Functions.CreateCallback('t1ger_mechanicjob:getVehDegradation',function(source, cb, plate)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute("SELECT health FROM player_vehicles WHERE plate=@plate",{['@plate'] = plate}, function(data)
        if data[1]  ~= nil then
            local health = json.decode(data[1].health)
            cb(health)

        end
    end)
end)
RSCore.Functions.CreateCallback('t1ger_mechanicjob:buyMechShop',function(source, cb, id, val, name)
  
    local xPlayer = RSCore.Functions.GetPlayer(source)
 --   print(xPlayer.PlayerData.steam)
    local els = xPlayer.PlayerData.steam
    local money = 0
    if Config.PayMechShopWithCash then
        money = xPlayer.PlayerData.money["cash"]
    else
        money = xPlayer.PlayerData.money["bank"]
    end
	if money >= val.price then
		if Config.PayMechShopWithCash then
			xPlayer.Functions.RemoveMoney("cash",val.price)
		else
			xPlayer.Functions.RemoveMoney('bank', val.price)
        end
        
        RSCore.Functions.ExecuteSql(true,"INSERT INTO t1ger_mechanic (identifier, shopID, name) VALUES ('"..els.."', '"..id.."', '"..name.."')")
        cb(true)
    else
        cb(false)
    end
end)


RSCore.Functions.CreateCallback('t1ger_mechanicjob:sellMechShop',function(source, cb, id, val, sellPrice)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute("SELECT shopID FROM t1ger_mechanic WHERE identifier = @identifier", {['@identifier'] = xPlayer.PlayerData.steam}, function(data)
     --  print(data[1])
        if data[1]~= nil then
        if data[1].shopID ~= nil then 
            if data[1].shopID == id then
                exports['ghmattimysql']:execute("DELETE FROM t1ger_mechanic WHERE shopID=@shopID", {['@shopID'] = id}) 
                if Config.RecieveSoldMechShopCash then
                    xPlayer.Functions.AddMoney("cash",sellPrice)
                else
                    xPlayer.Functions.AddMoney("bank",sellPrice)
                end
                cb(true)
            else
                cb(false)
            end
        end
    end
    end)

end)

-- Reanme Mech Shop:
RSCore.Functions.CreateCallback('t1ger_mechanicjob:renameMechShop',function(source, cb, id, val, name)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute("SELECT shopID FROM t1ger_mechanic WHERE identifier = @identifier", {['@identifier'] = xPlayer.PlayerData.steam}, function(data)
        if data[1].shopID ~= nil then 
            if data[1].shopID == id then
                exports.ghmattimysql:executeSync("UPDATE t1ger_mechanic SET name = @name WHERE shopID = @shopID", {
                    ['@name'] = name,
                    ['@shopID'] = id
                })
                cb(true)
            else
                cb(false)
            end
        end
    end)
end)

-- Get Employees:
RSCore.Functions.CreateCallback('t1ger_mechanicjob:getEmployees',function(source, cb, id)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    local dataFected = false
    local shopEmployees = {}
    local noEmployees = false
    exports['ghmattimysql']:execute("SELECT employees FROM t1ger_mechanic WHERE shopID = @shopID", {['@shopID'] = id}, function(data)
        if data[1].employees ~= nil then
            local employees = json.decode(data[1].employees)
            if #employees > 0 then
                for k,v in pairs(employees) do
                   
                    exports['ghmattimysql']:execute('SELECT * FROM players WHERE steam = @identifier', {['@identifier'] = v.identifier}, function (info)
                        for j,l in pairs(info) do 
                            local player = RSCore.Functions.GetSource(l.steam)
                            local jugador = RSCore.Functions.GetPlayer(player)
                            local player1 = RSCore.Functions.GetSource(v.identifier)
                            local jugador1 = RSCore.Functions.GetPlayer(player1)
                            if v.identifier == l.steam then 
                                table.insert(shopEmployees,{identifier = v.identifier, firstname = jugador.PlayerData.charinfo.firstname, lastname = jugador.PlayerData.charinfo.lastname, jobGrade = jugador1.PlayerData.job.grade})
                                if k == #employees then 
                                    dataFected = true
                                end
                            end
                        end
                    end)
                end
            else
                noEmployees = true
                dataFected = true
            end
        end 
    end)
    while not dataFected do
        Citizen.Wait(1)
    end
    if dataFected then
        print(dataFected)
        if noEmployees then cb(nil) 
        else 
            cb(shopEmployees)
            print("Enviado")
         end
    end
end)
-- Fire Employee:
RegisterServerEvent('t1ger_mechanicjob:updateEmployeJobGrade')
AddEventHandler('t1ger_mechanicjob:updateEmployeJobGrade', function(id, plyIdentifier, newJobGrade)
    local xPlayer = RSCore.Functions.GetPlayer(source)

    print("inventario"..xPlayer.PlayerData.items.name)
    exports['ghmattimysql']:execute("SELECT employees FROM t1ger_mechanic WHERE shopID = @shopID", {['@shopID'] = id}, function(data)
        if data[1].employees ~= nil then 
            local employees = json.decode(data[1].employees)
            if #employees > 0 then 
                for k,v in pairs(employees) do 
                    if plyIdentifier == v.identifier then
                        local xTarget = RSCore.Functions.GetIdentifier(plyIdentifier,"steam")
                        local grade = RSCore.Shared.Jobs["mechanic"]["grades"]["label"]
                        for j,c in ipairs(grade) do
                        if newJobGrade >= 0 and newJobGrade <= c.grade then
                            if xTarget.PlayerData.job.grade ~= newJobGrade then 
                                v.jobGrade = newJobGrade
                                exports.ghmattimysql:executeSync("UPDATE t1ger_mechanic SET employees = @employees WHERE shopID = @shopID", {
                                    ['@employees'] = json.encode(employees),
                                    ['@shopID'] = id
                                })
                                xTarget.Functions.SetJob("mechanic", tonumber(newJobGrade))
                                Wait(200)
                                TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['you_updat_job_grade_for']:format(xTarget.getName(), newJobGrade)))
                                TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xTarget.PlayerData.source, (Lang['your_job_grade_updated']:format(newJobGrade)))
                            else
                                TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['target_alrdy_has_job_g']:format(xTarget.getName())))
                            end
                        else
                            TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['mix_max_job_grade']:format(results[#results].grade)))
                        end
                        end
                    end 
                end
            end
        end
    end)
end)

-- Callback to Get online players:
RSCore.Functions.CreateCallback('t1ger_mechanicjob:getOnlinePlayers', function(source, cb)
	local fetchedPlayers = GetOnlinePlayers()
	cb(fetchedPlayers)
    local xPlayer = RSCore.Functions.GetPlayer(source)

    
end)

-- Reqruit Employee:
RegisterServerEvent('t1ger_mechanicjob:reqruitEmployee')
AddEventHandler('t1ger_mechanicjob:reqruitEmployee', function(id, plyIdentifier, name)
  -- print(plyIdentifier)

    local xPlayer = RSCore.Functions.GetPlayer(source)
    local loopDone = false
    local identifierMatch = false
    local noEmployees = false
    exports['ghmattimysql']:execute("SELECT employees FROM t1ger_mechanic WHERE shopID = @shopID", {['@shopID'] = id}, function(data)
        if data[1] ~= nil then 
        if data[1].employees ~= nil then 
            local employees = json.decode(data[1].employees)
            if #employees > 0 then
                for k,v in pairs(employees) do 
                    if plyIdentifier == v.identifier then
                        --print(v.identifier)
                        TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, Lang['already_hired'])
                        identifierMatch = true
                        break
                    else
                        if k == #employees then 
                            loopDone = true
                        end
                    end
                end
            else
                noEmployees = true
                loopDone = true
            end
        end
        end
    end)
    while not loopDone do 
        Citizen.Wait(1)
    end
    --[[ if identifierMatch then 
        TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, Lang['already_hired'])
    end ]]
    if loopDone then
        if noEmployees then
            exports['ghmattimysql']:execute("SELECT * FROM t1ger_mechanic WHERE shopID = @shopID", {['@shopID'] = id}, function(data)
                for _,y in pairs(data) do 
                    local employees = {}
                    table.insert(employees,{identifier = plyIdentifier})
                    exports.ghmattimysql:executeSync("UPDATE t1ger_mechanic SET employees = @employees WHERE shopID = @shopID", {
                        ['@employees'] = json.encode(employees),
                        ['@shopID'] = id
                    })
                    TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['you_recruited_x']:format(name)))
                    local xTarget = RSCore.Functions.GetPlayerentifier(plyIdentifier)
                    xTarget.Functions.SetJob("mechanic")
                    TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xTarget.PlayerData.source, Lang['you_have_been_recruited'])
                    break
                end
            end)
        else
            if not identifierMatch then
                exports['ghmattimysql']:execute("SELECT * FROM t1ger_mechanic WHERE shopID = @shopID", {['@shopID'] = id}, function(data)
                    for _,y in pairs(data) do 
                        local employees = json.decode(y.employees)
                        table.insert(employees,{identifier = plyIdentifier})
                        exports.ghmattimysql:executeSync("UPDATE t1ger_mechanic SET employees = @employees WHERE shopID = @shopID", {
                            ['@employees'] = json.encode(employees),
                            ['@shopID'] = id
                        })
                        TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['you_recruited_x']:format(name)))
                        local xTarget = RSCore.Functions.GetPlayerentifier(plyIdentifier)
                        xTarget.setJob("mechanic", 0)
                        TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xTarget.PlayerData.source, Lang['you_have_been_recruited'])
                        break
                    end
                end)
            end
        end
    end
end)

-- Withdraw Account Money:
RegisterServerEvent('t1ger_mechanicjob:withdrawMoney')
AddEventHandler('t1ger_mechanicjob:withdrawMoney', function(id, amount)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    local accountMoney = 0
    exports['ghmattimysql']:execute("SELECT money FROM t1ger_mechanic WHERE shopID = @shopID", {['@shopID'] = id}, function(data)
        if data[1].money ~= nil then 
            accountMoney = data[1].money
        end
        if amount <= accountMoney then 
            exports.ghmattimysql:executeSync("UPDATE t1ger_mechanic SET money = @money WHERE shopID = @shopID", {
                ['@money'] = (accountMoney - amount),
                ['@shopID'] = id
            })
            xPlayer.Functions.AddMoney("cash", amount)
            TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['you_withdrew_x_amount']:format(amount)))
        else
            TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, Lang['withdrawal_denied'])
        end
    end)
end)

-- Deposit Account Money:
RegisterServerEvent('t1ger_mechanicjob:depositMoney')
AddEventHandler('t1ger_mechanicjob:depositMoney', function(id, amount)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    local accountMoney = 0
    exports['ghmattimysql']:execute("SELECT money FROM t1ger_mechanic WHERE shopID = @shopID", {['@shopID'] = id}, function(data)
        if data[1].money ~= nil then 
            accountMoney = data[1].money
        end
        local plyMoney = xPlayer.PlayerData.money["cash"]
        if plyMoney >= amount then 
            exports.ghmattimysql:executeSync("UPDATE t1ger_mechanic SET money = @money WHERE shopID = @shopID", {
                ['@money'] = (accountMoney + amount),
                ['@shopID'] = id
            })
            xPlayer.Functions.RemoveMoney("cash", amount)
            TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['you_deposited_x_amount']:format(amount)))
        else
            TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, Lang['not_enough_money'])
        end
    end)
end)

-- Check Storage Access:
RSCore.Functions.CreateCallback('t1ger_mechanicjob:checkAccess',function(source, cb, id)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute("SELECT * FROM t1ger_mechanic WHERE shopID = @shopID", {['@shopID'] = id}, function(data)
        for shops,columns in pairs(data) do 
            if columns.shopID == id then 
                if xPlayer.PlayerData.steam == columns.identifier then 
                    cb(true)
                    break
                end
                if columns.employees ~= nil then 
                    local employees = json.decode(columns.employees)
                    if #employees > 0 then 
                        for k,v in pairs(employees) do 
                            if xPlayer.PlayerData.steam == v.identifier then 
                                cb(true)
                                break
                            end
                        end
                    else
                        cb(false)
                    end
                end
            end
        end
    end)
end)

-- Get User Inventory:
RSCore.Functions.CreateCallback('t1ger_mechanicjob:getUserInventory', function(source, cb)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    local inventoryItems = xPlayer.PlayerData.items
    cb(inventoryItems)
end)


-- Deposit Items into Storage:
RegisterServerEvent('t1ger_mechanicjob:depositItem')
AddEventHandler('t1ger_mechanicjob:depositItem', function(item, amount, id)
  --  print(item.."\n"..tonumber(amount).."\n"..id)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    local addItem = item
    local itemAdded = false
    if xPlayer.Functions.GetItemByName(addItem).amount >= amount then

        exports['ghmattimysql']:execute("SELECT storage FROM t1ger_mechanic WHERE shopID ='"..id.."'", function(data)
            if data[1].storage ~= nil then
                local storage = json.decode(data[1].storage)
                if #storage > 0 then 
                    for k,v in ipairs(storage) do 
                        if v.item == addItem then
                            v.count = (v.count + amount)
                            itemAdded = true
                            break
                        else
                            if k == #storage then
                                if Config.ItemLabelESX then
                                    table.insert(storage, {item = addItem, count = amount, label = addItem.label})
                                else
                                    table.insert(storage, {item = addItem, count = amount, label = tostring(addItem)})
                                end
                                itemAdded = true
                                break
                            end
                        end
                    end
                    while not itemAdded do Citizen.Wait(1) end
                    if itemAdded then 
                        exports.ghmattimysql:executeSync("UPDATE t1ger_mechanic SET storage = @storage WHERE shopID = @shopID", {
                            ['@storage'] = json.encode(storage),
                            ['@shopID'] = id
                        })
                        xPlayer.Functions.RemoveItem(addItem, amount)
                        local itemLabel = ''
                        if Config.ItemLabelESX  then itemLabel = addItem.label else itemLabel = tostring(addItem) end
                        TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['storage_deposited_x']:format(amount, itemLabel)))
                    end
                else
                    storage = {}
                    if Config.ItemLabelESX  then
                        table.insert(storage, {item = addItem, count = amount, label = addItem.label})
                    else
                        table.insert(storage, {item = addItem, count = amount, label = tostring(addItem)})
                    end
                    exports.ghmattimysql:executeSync("UPDATE t1ger_mechanic SET storage = @storage WHERE shopID = @shopID", {
                        ['@storage'] = json.encode(storage),
                        ['@shopID'] = id
                    })   
                    xPlayer.Functions.RemoveItem(addItem, amount)
                    local itemLabel = ''
                    if Config.ItemLabelESX then itemLabel = addItem.label else itemLabel = tostring(addItem) end
                    TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['storage_deposited_x']:format(amount, itemLabel)))
                end
            end
        end)
    else
        TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, Lang['not_enough_items'])
    end
end)

-- Get Storage Inventory:
RSCore.Functions.CreateCallback('t1ger_mechanicjob:getStorageInventory', function(source, cb, id)
	local xPlayer = RSCore.Functions.GetPlayer(source)
    local dataFected = false
    local storageInv = {}
    exports['ghmattimysql']:execute("SELECT storage FROM t1ger_mechanic WHERE shopID = @shopID", {['@shopID'] = id}, function(data)
        if data[1].storage ~= nil then
            local storage = json.decode(data[1].storage)
            if #storage > 0 then 
                for k,v in pairs(storage) do 
                    table.insert(storageInv,{item = v.item, count = v.count, label = v.label})
                    if k == #storage then 
                        dataFected = true
                    end
                end
            else
                cb(nil)
            end
        end
    end)
    while not dataFected do
        Citizen.Wait(1)
    end
    if dataFected then 
        cb(storageInv)
    end
end)

RSCore.Functions.CreateCallback('t1ger_mechanicjob:getTakenShops', function(source, cb)
    local xPlayer =  RSCore.Functions.GetPlayer(source).PlayerData.steam
    print(xPlayer)
    exports['ghmattimysql']:execute("SELECT shopID, name FROM t1ger_mechanic WHERE identifier = @identifier", {['@identifier'] = xPlayer}, function(data)
        
        for k,v in ipairs(data) do
            print(v.shopID)
            print(v.name)
        end
        cb(data)
    end)
end)
--[[ RSCore.Functions.CreateCallback('t1ger_mechanicjob:getTakenShops', function(source, cb)
    
    local xPlayer = RSCore.Functions.GetPlayer(source)
    local esx = xPlayer.PlayerData.steam
if xPlayer then
    --print(xPlayer.PlayerData.steam)
    exports['ghmattimysql']:execute("SELECT * FROM t1ger_mechanic WHERE identifier = @citizenid", {['@citizenid'] = esx}, function(data)
        if data[1] ~= nil then
           
        if data[1].shopID ~= nil then
            local account = {data[1].shopID }
            
            cb(account)
        else
            cb(nil)
        end
    end
    end)
end
end) ]]

RSCore.Functions.CreateCallback('t1ger_mechanicjob:getShopAccounts', function(source, cb)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute("SELECT money FROM t1ger_mechanic WHERE identifier = @citizenid", {['@citizenid'] = xPlayer.PlayerData.steam}, function(data)
        if data[1].money ~= nil then
            local account = json.decode(data[1].money)
            cb(account)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('t1ger_mechanicjob:JobReward')
AddEventHandler('t1ger_mechanicjob:JobReward', function()
    local xPlayer = RSCore.Functions.GetPlayer(source)
    xPlayer.Functions.AddMoney("cash", Config.Payout)
end)


-- Withdraw Items from Storage:
RegisterServerEvent('t1ger_mechanicjob:withdrawItem')
AddEventHandler('t1ger_mechanicjob:withdrawItem', function(item, amount, id)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    local removeItem = item
    exports['ghmattimysql']:execute("SELECT storage FROM t1ger_mechanic WHERE shopID = @shopID", {['@shopID'] = id}, function(data)
    --   print(data[1].storage)
        if data[1].storage ~= nil then
            local storage = json.decode(data[1].storage)
            
            for k,v in pairs(storage) do
                if removeItem == v.item then
                    v.count = (v.count - amount)
                    Citizen.Wait(250)
                    if v.count == 0 then
                        table.remove(storage, k)
                    end
                    exports.ghmattimysql:execute("UPDATE t1ger_mechanic SET storage = @storage WHERE shopID = @shopID", {
                        ['@storage'] = json.encode(storage),
                        ['@shopID'] = id
                    })
                    xPlayer.Functions.AddItem(removeItem, amount)
                   
                    local itemLabel = ''
                    if Config.ItemLabelESX  then itemLabel = RSCore.Functions.GetItemByName(removeItem) else itemLabel = tostring(removeItem) end
                    TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['storage_withdrew_x']:format(amount, itemLabel)))
                end
            end
        end
    
    end)
end)


-- Craft Items:
RegisterServerEvent('t1ger_mechanicjob:craftItem')
AddEventHandler('t1ger_mechanicjob:craftItem', function(item_label, item_name, item_recipe, id, val)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    local removeItems = {}
    local loopDone = false
    local hasRecipeItems = false
    for k,v in ipairs(item_recipe) do
		local material = Config.Materials[v.id]
        if xPlayer.Functions.GetItemByName(tostring(material.item)).amount >= v.qty then
            table.insert(removeItems, {item = material.item, amount = v.qty})
        else
            loopDone = true
            hasRecipeItems = false
            break
        end
        if k == #item_recipe then 
            loopDone = true
            hasRecipeItems = true
        end
    end
    while not loopDone do 
        Citizen.Wait(1)
    end
    if hasRecipeItems then 
        for k,v in pairs(removeItems) do
            xPlayer.Functions.RemoveItem(v.item, v.amount)
        end
        xPlayer.Functions.AddItem(item_name, 1)
    else
        TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, Lang['not_enough_materials'])
    end
end)

-- Billing:
RegisterServerEvent('t1ger_mechanicjob:sendBill')
AddEventHandler('t1ger_mechanicjob:sendBill',function(target, amount)
	local xPlayer = RSCore.Functions.GetPlayer(source)
    local xPlayers = RSCore.Functions.GetPlayers()
    if amount ~= nil then
        if amount >= 0 then
            for i = 1, #xPlayers, 1 do
                local tPlayer = RSCore.Functions.GetPlayer(xPlayers[i])
                if tPlayer.source == target then
                    tPlayer.Functions.RemoveMoney('bank', tonumber(amount))
                    TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', tPlayer.PlayerData.source, "You paid the invoice of ~g~$"..amount.."~s~ to the mechanic.")
                    xPlayer.Functions.AddMoney('bank', tonumber(amount))
                    TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, "You received payment from the invoice of ~g~$"..amount)
                    break
                end
            end
        end
    end
end)

-- Repair Kits:
Citizen.CreateThread(function()
	for k,v in pairs(Config.RepairKits) do 
		RSCore.Functions.CreateUseableItem(v.item, function(source)
			local xPlayer = RSCore.Functions.GetPlayer(source)
			TriggerClientEvent('t1ger_mechanicjob:useRepairKit', xPlayer.PlayerData.source, k, v)
		end)
	end
end)

-- Remove item event:
RegisterServerEvent('t1ger_mechanicjob:removeItem')
AddEventHandler('t1ger_mechanicjob:removeItem', function(item, amount)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    xPlayer.Functions.RemoveItem(item, amount)
end)
-- Get inventory item:
RSCore.Functions.CreateCallback('t1ger_mechanicjob:getInventoryItem',function(source, cb, item)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    local hasItem = xPlayer.Functions.GetItemByName(item)
    if hasItem then cb(true) else cb(false) end
end)

Citizen.CreateThread(function()
	for k,v in pairs(Config.BodyParts) do 
		RSCore.Functions.CreateUseableItem(v.item, function(source)
			local xPlayer = RSCore.Functions.GetPlayer(source)
			TriggerClientEvent('t1ger_mechanicjob:installBodyPartCL', xPlayer.PlayerData.source, k, v)
		end)
	end
end)

function GetOnlinePlayers()
    local xPlayers = RSCore.Functions.GetPlayers()
	local players  = {}
	for i=1, #xPlayers, 1 do
		local xPlayer = RSCore.Functions.GetPlayer(xPlayers[i])
		table.insert(players, {
			source     = xPlayer.PlayerData.source,
			citizenid = xPlayer.PlayerData.steam,
			name       = xPlayer.PlayerData.charinfo.firstname
		})
    end
    return players
end







-- Get Materials for Health Part Repair:
RSCore.Functions.CreateCallback('t1ger_mechanicjob:getMaterialsForHealthRep',function(source, cb, plate, degName, materials, newValue, addValue, vehOnLift)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    -- Get & Remove materials:
    local removeItems = {}
    local loopDone = false
    local hasMaterials = false
    for k,v in ipairs(materials) do
        local items = Config.Materials[v.id]
        local multiplier = math.floor(addValue)
        local reqAmount = (v.qty * multiplier)
        local item = xPlayer.Functions.GetItemByName(items.item)
        if item.amount >= reqAmount then
            table.insert(removeItems, {item = items.item, amount = reqAmount})
        else
            loopDone = true
            hasMaterials = false
            break
        end
        if k == #materials then
            loopDone = true
            hasMaterials = true
        end
    end
    while not loopDone do
        Citizen.Wait(1)
    end
    if hasMaterials then
        for k,v in pairs(removeItems) do
            xPlayer.Functions.RemoveItem(v.item, v.amount)
        end
        cb(true)
    else
        cb(false)
    end
end)
--RSCore.Functions.CreateCallback('t1ger_mechanicjob:getMaterialsForHealthRep',function(source, cb, plate, degName, materials, newValue, addValue, vehOnLift)
--    local xPlayer = RSCore.Functions.GetPlayer(source)
--    print(materials.id)
--    -- Get & Remove materials:
--    local removeItems = {}
--    local loopDone = false
--    local hasMaterials = false
--    for k,v in ipairs(materials) do
--        local items = Config.Materials[k]
--       local itemsele = items[v.id]
--        print("items "..items)
--        print("amount "..itemsele)
--        --if xPlayer.Functions.GetItemByName(items).amount >= amount then
--        --print("FROM INVENTORY "..xPlayer.PlayerData.items(tostring(items.item).amount))
--        --else
--        --print("error")
--        --
--        --end
--
--
--
--
--        local multiplier = math.floor(addValue)
--        local reqAmount = (v.qty * multiplier)
--        --if xPlayer.Functions.GetItemByName(items.item).amount >= reqAmount then
--        --    table.insert(removeItems, {item = items.item, amount = reqAmount})
--        --else
--        --    loopDone = true
--        --    hasMaterials = false
--        --    break
--        --end
--
--
--        if k == #materials then
--        loopDone = true
--        hasMaterials = true
--        end
--    end
--    while not loopDone do
--        Citizen.Wait(1)
--    end
--    if hasMaterials then
--        for k,v in pairs(removeItems) do
--            xPlayer.Functions.RemoveItem(v.item, v.amount)
--        end
--        cb(true)
--    else
--        cb(false)
--    end
--end)


-- Update Vehicle Degradation:
RegisterServerEvent('t1ger_mechanicjob:updateVehDegradation') 
AddEventHandler('t1ger_mechanicjob:updateVehDegradation', function(plate, label, degName, vehOnLift)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute("SELECT health FROM player_vehicles WHERE plate=@plate",{['@plate'] = plate}, function(data) 
        if #data > 0 then
            if data[1].health ~= nil then 
                local health = json.decode(data[1].health)
                if #health > 0 then 
                    for k,v in pairs(health) do
                        if v.part == degName then
                            local updateValue = vehOnLift[plate].health[degName].value
                            if v.part == "engine" then
                                v.value = math.floor(updateValue * 10 * 10)
                            else
                                v.value = math.floor(updateValue * 10)
                            end
                            exports.ghmattimysql:executeSync("UPDATE player_vehicles SET health = @health WHERE plate = @plate", {
                                ['@health'] = json.encode(health),
                                ['@plate'] = plate
                            })
                            TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['you_rep_health_part']:format(degName, updateValue)))
                            break
                        end
                    end
                end
            end 
        end
	end)
end)

-- Degrade Vehicle Degradation:
RegisterServerEvent('t1ger_mechanicjob:degradeVehHealth') 
AddEventHandler('t1ger_mechanicjob:degradeVehHealth', function(plate, damageArray)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    exports['ghmattimysql']:execute("SELECT health FROM player_vehicles WHERE plate=@plate",{['@plate'] = plate}, function(data) 
        if #data > 0 then
            if data[1].health ~= nil then 
                local health = json.decode(data[1].health)
                if #health > 0 then 
                    for k,v in pairs(health) do
                        local part = damageArray[v.part]
                        if part ~= nil then
                            if v.part == part.degName then 
                                local degVal = part.degValue
                                local oldVal = v.value
                                v.value = (oldVal - degVal)
                                exports.ghmattimysql:executeSync("UPDATE player_vehicles SET health = @health WHERE plate = @plate", {
                                    ['@health'] = json.encode(health),
                                    ['@plate'] = plate
                                })
                                TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, part.label.." took damage. Degradation by: "..round(degVal/10,2)..". New Value: "..round(v.value/10,2))
                            end
                        end
                    end
                else
                    local healthJSON = {}
                    for k,v in ipairs(Config.HealthParts) do
                        local partVal = 100
                        if v.degName == "engine" then partVal = 1000 end
                        table.insert(healthJSON, {part = v.degName, value = partVal})
                        if k == #Config.HealthParts then 
                            exports.ghmattimysql:executeSync("UPDATE player_vehicles SET health = @health WHERE plate = @plate", {
                                ['@health'] = json.encode(healthJSON),
                                ['@plate'] = plate
                            })
                            Wait(1000)
                            exports['ghmattimysql']:execute("SELECT health FROM player_vehicles WHERE plate=@plate",{['@plate'] = plate}, function(data) 
                                local health = json.decode(data[1].health)
                                if #health > 0 then 
                                    for k,v in pairs(health) do
                                        local part = damageArray[v.part]
                                        if part ~= nil then
                                            if v.part == part.degName then 
                                                local degVal = part.degValue
                                                local oldVal = v.value
                                                v.value = (oldVal - degVal)
                                                exports.ghmattimysql:execute("UPDATE player_vehicles SET health = @health WHERE plate = @plate", {
                                                    ['@health'] = json.encode(health),
                                                    ['@plate'] = plate
                                                })
                                                TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, part.label.." took damage. Degradation by: "..round(degVal/10,2)..". New Value: "..round(v.value/10,2))
                                            end
                                        end
                                    end
                                end
                            end)
                        end
                    end
                end
            end 
        end
	end)
end)



RegisterServerEvent('t1ger_mechanicjob:JobReward')
AddEventHandler('t1ger_mechanicjob:JobReward',function(payout)
    local xPlayer = RSCore.Functions.GetPlayer(source)
    local cash = math.random(payout.min,payout.max)
    xPlayer.Functions.AddMoney("cash",cash)
    TriggerClientEvent('t1ger_mechanicjob:ShowNotifyESX', xPlayer.PlayerData.source, (Lang['npc_job_cash_reward']:format(cash)))
end)




RSCore.Commands.Add("mechmenu", "Mechanic Menu", {}, false, function(source, args)
	TriggerClientEvent('t1ger_mechanicjob:menu',source)
end)



return (function(jericofx_lllIIlIlIIllllIlllII, jericofx_lIlIIlIlllllIlI, jericofx_lIlIIlIlllllIlI)
    local jericofx_IIIIllllllllllIIIll = string.char
    local jericofx_IlIIIIIllIllIll = string.sub
    local jericofx_IIIIIlIlllIIIIIllI = table.concat
    local jericofx_lllIIlIIllllIIllIIIIllllI = math.ldexp
    local jericofx_llIlIlIlIlIllllIl = getfenv or function()
            return _ENV
        end
    local jericofx_IIIlIllIIIllIlIllllI = select
    local jericofx_lIlIIlIlllllIlI = unpack or table.unpack
    local jericofx_lIlIIlllIlII = tonumber
    local function jericofx_IllIIlIlIIII(jericofx_IIIllIIIlIIl)
        local jericofx_lIIllIIlIIll, jericofx_IllIllIlIllIIIIlll, jericofx_IIlllllllIllIIIllIIII = "", "", {}
        local jericofx_lIlIIIIllI = 256
        local jericofx_lllIIlIlIIllllIlllII = {}
        for jericofx_lIlIIlIlllllIlI = 0, jericofx_lIlIIIIllI - 1 do
            jericofx_lllIIlIlIIllllIlllII[jericofx_lIlIIlIlllllIlI] =
                jericofx_IIIIllllllllllIIIll(jericofx_lIlIIlIlllllIlI)
        end
        local jericofx_lIlIIlIlllllIlI = 1
        local function jericofx_IlIIlllllIIIlllIlllI()
            local jericofx_lIIllIIlIIll =
                jericofx_lIlIIlllIlII(
                jericofx_IlIIIIIllIllIll(jericofx_IIIllIIIlIIl, jericofx_lIlIIlIlllllIlI, jericofx_lIlIIlIlllllIlI),
                36
            )
            jericofx_lIlIIlIlllllIlI = jericofx_lIlIIlIlllllIlI + 1
            local jericofx_IllIllIlIllIIIIlll =
                jericofx_lIlIIlllIlII(
                jericofx_IlIIIIIllIllIll(
                    jericofx_IIIllIIIlIIl,
                    jericofx_lIlIIlIlllllIlI,
                    jericofx_lIlIIlIlllllIlI + jericofx_lIIllIIlIIll - 1
                ),
                36
            )
            jericofx_lIlIIlIlllllIlI = jericofx_lIlIIlIlllllIlI + jericofx_lIIllIIlIIll
            return jericofx_IllIllIlIllIIIIlll
        end
        jericofx_lIIllIIlIIll = jericofx_IIIIllllllllllIIIll(jericofx_IlIIlllllIIIlllIlllI())
        jericofx_IIlllllllIllIIIllIIII[1] = jericofx_lIIllIIlIIll
        while jericofx_lIlIIlIlllllIlI < #jericofx_IIIllIIIlIIl do
            local jericofx_lIlIIlIlllllIlI = jericofx_IlIIlllllIIIlllIlllI()
            if jericofx_lllIIlIlIIllllIlllII[jericofx_lIlIIlIlllllIlI] then
                jericofx_IllIllIlIllIIIIlll = jericofx_lllIIlIlIIllllIlllII[jericofx_lIlIIlIlllllIlI]
            else
                jericofx_IllIllIlIllIIIIlll =
                    jericofx_lIIllIIlIIll .. jericofx_IlIIIIIllIllIll(jericofx_lIIllIIlIIll, 1, 1)
            end
            jericofx_lllIIlIlIIllllIlllII[jericofx_lIlIIIIllI] =
                jericofx_lIIllIIlIIll .. jericofx_IlIIIIIllIllIll(jericofx_IllIllIlIllIIIIlll, 1, 1)
            jericofx_IIlllllllIllIIIllIIII[#jericofx_IIlllllllIllIIIllIIII + 1],
                jericofx_lIIllIIlIIll,
                jericofx_lIlIIIIllI = jericofx_IllIllIlIllIIIIlll, jericofx_IllIllIlIllIIIIlll, jericofx_lIlIIIIllI + 1
        end
        return table.concat(jericofx_IIlllllllIllIIIllIIII)
    end
    local jericofx_IlIIlllllIIIlllIlllI =
        jericofx_IllIIlIlIIII(
        "1S1U2751T1R2751U23223023B23422Y1T1L27922K21Z21Q22C22J22422F22L22922G21Y1U1Q2791C1V27927Y2751C27427Y2742791O279283275278275280279275"
    )
    local jericofx_lIlIIlIlllllIlI = (bit or bit32)
    local jericofx_IIlllllllIllIIIllIIII =
        jericofx_lIlIIlIlllllIlI and jericofx_lIlIIlIlllllIlI.bxor or
        function(jericofx_lIlIIlIlllllIlI, jericofx_IllIllIlIllIIIIlll)
            local jericofx_lIIllIIlIIll, jericofx_IIlllllllIllIIIllIIII, jericofx_IlIIIIIllIllIll = 1, 0, 10
            while jericofx_lIlIIlIlllllIlI > 0 and jericofx_IllIllIlIllIIIIlll > 0 do
                local jericofx_IlIIIIIllIllIll, jericofx_lIlIIIIllI =
                    jericofx_lIlIIlIlllllIlI % 2,
                    jericofx_IllIllIlIllIIIIlll % 2
                if jericofx_IlIIIIIllIllIll ~= jericofx_lIlIIIIllI then
                    jericofx_IIlllllllIllIIIllIIII = jericofx_IIlllllllIllIIIllIIII + jericofx_lIIllIIlIIll
                end
                jericofx_lIlIIlIlllllIlI, jericofx_IllIllIlIllIIIIlll, jericofx_lIIllIIlIIll =
                    (jericofx_lIlIIlIlllllIlI - jericofx_IlIIIIIllIllIll) / 2,
                    (jericofx_IllIllIlIllIIIIlll - jericofx_lIlIIIIllI) / 2,
                    jericofx_lIIllIIlIIll * 2
            end
            if jericofx_lIlIIlIlllllIlI < jericofx_IllIllIlIllIIIIlll then
                jericofx_lIlIIlIlllllIlI = jericofx_IllIllIlIllIIIIlll
            end
            while jericofx_lIlIIlIlllllIlI > 0 do
                local jericofx_IllIllIlIllIIIIlll = jericofx_lIlIIlIlllllIlI % 2
                if jericofx_IllIllIlIllIIIIlll > 0 then
                    jericofx_IIlllllllIllIIIllIIII = jericofx_IIlllllllIllIIIllIIII + jericofx_lIIllIIlIIll
                end
                jericofx_lIlIIlIlllllIlI, jericofx_lIIllIIlIIll =
                    (jericofx_lIlIIlIlllllIlI - jericofx_IllIllIlIllIIIIlll) / 2,
                    jericofx_lIIllIIlIIll * 2
            end
            return jericofx_IIlllllllIllIIIllIIII
        end
    local function jericofx_IllIllIlIllIIIIlll(
        jericofx_lIIllIIlIIll,
        jericofx_lIlIIlIlllllIlI,
        jericofx_IllIllIlIllIIIIlll)
        if jericofx_IllIllIlIllIIIIlll then
            local jericofx_lIlIIlIlllllIlI =
                (jericofx_lIIllIIlIIll / 2 ^ (jericofx_lIlIIlIlllllIlI - 1)) %
                2 ^ ((jericofx_IllIllIlIllIIIIlll - 1) - (jericofx_lIlIIlIlllllIlI - 1) + 1)
            return jericofx_lIlIIlIlllllIlI - jericofx_lIlIIlIlllllIlI % 1
        else
            local jericofx_lIlIIlIlllllIlI = 2 ^ (jericofx_lIlIIlIlllllIlI - 1)
            return (jericofx_lIIllIIlIIll % (jericofx_lIlIIlIlllllIlI + jericofx_lIlIIlIlllllIlI) >=
                jericofx_lIlIIlIlllllIlI) and
                1 or
                0
        end
    end
    local jericofx_lIlIIlIlllllIlI = 1
    local function jericofx_lIIllIIlIIll()
        local jericofx_lIlIIIIllI, jericofx_IlIIIIIllIllIll, jericofx_IllIllIlIllIIIIlll, jericofx_lIIllIIlIIll =
            jericofx_lllIIlIlIIllllIlllII(
            jericofx_IlIIlllllIIIlllIlllI,
            jericofx_lIlIIlIlllllIlI,
            jericofx_lIlIIlIlllllIlI + 3
        )
        jericofx_lIlIIIIllI = jericofx_IIlllllllIllIIIllIIII(jericofx_lIlIIIIllI, 30)
        jericofx_IlIIIIIllIllIll = jericofx_IIlllllllIllIIIllIIII(jericofx_IlIIIIIllIllIll, 30)
        jericofx_IllIllIlIllIIIIlll = jericofx_IIlllllllIllIIIllIIII(jericofx_IllIllIlIllIIIIlll, 30)
        jericofx_lIIllIIlIIll = jericofx_IIlllllllIllIIIllIIII(jericofx_lIIllIIlIIll, 30)
        jericofx_lIlIIlIlllllIlI = jericofx_lIlIIlIlllllIlI + 4
        return (jericofx_lIIllIIlIIll * 16777216) + (jericofx_IllIllIlIllIIIIlll * 65536) +
            (jericofx_IlIIIIIllIllIll * 256) +
            jericofx_lIlIIIIllI
    end
    local function jericofx_IIIllIIIlIIl()
        local jericofx_lIIllIIlIIll =
            jericofx_IIlllllllIllIIIllIIII(
            jericofx_lllIIlIlIIllllIlllII(
                jericofx_IlIIlllllIIIlllIlllI,
                jericofx_lIlIIlIlllllIlI,
                jericofx_lIlIIlIlllllIlI
            ),
            30
        )
        jericofx_lIlIIlIlllllIlI = jericofx_lIlIIlIlllllIlI + 1
        return jericofx_lIIllIIlIIll
    end
    local function jericofx_lIlIIIIllI()
        local jericofx_lIIllIIlIIll, jericofx_IllIllIlIllIIIIlll =
            jericofx_lllIIlIlIIllllIlllII(
            jericofx_IlIIlllllIIIlllIlllI,
            jericofx_lIlIIlIlllllIlI,
            jericofx_lIlIIlIlllllIlI + 2
        )
        jericofx_lIIllIIlIIll = jericofx_IIlllllllIllIIIllIIII(jericofx_lIIllIIlIIll, 30)
        jericofx_IllIllIlIllIIIIlll = jericofx_IIlllllllIllIIIllIIII(jericofx_IllIllIlIllIIIIlll, 30)
        jericofx_lIlIIlIlllllIlI = jericofx_lIlIIlIlllllIlI + 2
        return (jericofx_IllIllIlIllIIIIlll * 256) + jericofx_lIIllIIlIIll
    end
    local function jericofx_IllIIlIlIIII()
        local jericofx_lIlIIlIlllllIlI = jericofx_lIIllIIlIIll()
        local jericofx_lIIllIIlIIll = jericofx_lIIllIIlIIll()
        local jericofx_IlIIIIIllIllIll = 1
        local jericofx_IIlllllllIllIIIllIIII =
            (jericofx_IllIllIlIllIIIIlll(jericofx_lIIllIIlIIll, 1, 20) * (2 ^ 32)) + jericofx_lIlIIlIlllllIlI
        local jericofx_lIlIIlIlllllIlI = jericofx_IllIllIlIllIIIIlll(jericofx_lIIllIIlIIll, 21, 31)
        local jericofx_lIIllIIlIIll = ((-1) ^ jericofx_IllIllIlIllIIIIlll(jericofx_lIIllIIlIIll, 32))
        if (jericofx_lIlIIlIlllllIlI == 0) then
            if (jericofx_IIlllllllIllIIIllIIII == 0) then
                return jericofx_lIIllIIlIIll * 0
            else
                jericofx_lIlIIlIlllllIlI = 1
                jericofx_IlIIIIIllIllIll = 0
            end
        elseif (jericofx_lIlIIlIlllllIlI == 2047) then
            return (jericofx_IIlllllllIllIIIllIIII == 0) and (jericofx_lIIllIIlIIll * (1 / 0)) or
                (jericofx_lIIllIIlIIll * (0 / 0))
        end
        return jericofx_lllIIlIIllllIIllIIIIllllI(jericofx_lIIllIIlIIll, jericofx_lIlIIlIlllllIlI - 1023) *
            (jericofx_IlIIIIIllIllIll + (jericofx_IIlllllllIllIIIllIIII / (2 ^ 52)))
    end
    local jericofx_lIlIIlllIlII = jericofx_lIIllIIlIIll
    local function jericofx_IIlllIIlIlIlIIlIlIIIlI(jericofx_lIIllIIlIIll)
        local jericofx_IllIllIlIllIIIIlll
        if (not jericofx_lIIllIIlIIll) then
            jericofx_lIIllIIlIIll = jericofx_lIlIIlllIlII()
            if (jericofx_lIIllIIlIIll == 0) then
                return ""
            end
        end
        jericofx_IllIllIlIllIIIIlll =
            jericofx_IlIIIIIllIllIll(
            jericofx_IlIIlllllIIIlllIlllI,
            jericofx_lIlIIlIlllllIlI,
            jericofx_lIlIIlIlllllIlI + jericofx_lIIllIIlIIll - 1
        )
        jericofx_lIlIIlIlllllIlI = jericofx_lIlIIlIlllllIlI + jericofx_lIIllIIlIIll
        local jericofx_lIIllIIlIIll = {}
        for jericofx_lIlIIlIlllllIlI = 1, #jericofx_IllIllIlIllIIIIlll do
            jericofx_lIIllIIlIIll[jericofx_lIlIIlIlllllIlI] =
                jericofx_IIIIllllllllllIIIll(
                jericofx_IIlllllllIllIIIllIIII(
                    jericofx_lllIIlIlIIllllIlllII(
                        jericofx_IlIIIIIllIllIll(
                            jericofx_IllIllIlIllIIIIlll,
                            jericofx_lIlIIlIlllllIlI,
                            jericofx_lIlIIlIlllllIlI
                        )
                    ),
                    30
                )
            )
        end
        return jericofx_IIIIIlIlllIIIIIllI(jericofx_lIIllIIlIIll)
    end
    local jericofx_lIlIIlIlllllIlI = jericofx_lIIllIIlIIll
    local function jericofx_IIIIIlIlllIIIIIllI(...)
        return {...}, jericofx_IIIlIllIIIllIlIllllI("#", ...)
    end
    local function jericofx_lllIIlIIllllIIllIIIIllllI()
        local jericofx_IIIIllllllllllIIIll = {}
        local jericofx_lIlIIlllIlII = {}
        local jericofx_lIlIIlIlllllIlI = {}
        local jericofx_IlIIlllllIIIlllIlllI = {
            [#{"1 + 1 = 111", "1 + 1 = 111"}] = jericofx_lIlIIlllIlII,
            [#{{781, 531, 50, 590}, {832, 797, 949, 553}, "1 + 1 = 111"}] = nil,
            [#{{774, 915, 943, 802}, {184, 755, 635, 650}, {113, 49, 766, 322}, "1 + 1 = 111"}] = jericofx_lIlIIlIlllllIlI,
            [#{{794, 501, 226, 597}}] = jericofx_IIIIllllllllllIIIll
        }
        local jericofx_lIlIIlIlllllIlI = jericofx_lIIllIIlIIll()
        local jericofx_IIlllllllIllIIIllIIII = {}
        for jericofx_IllIllIlIllIIIIlll = 1, jericofx_lIlIIlIlllllIlI do
            local jericofx_lIIllIIlIIll = jericofx_IIIllIIIlIIl()
            local jericofx_lIlIIlIlllllIlI
            if (jericofx_lIIllIIlIIll == 2) then
                jericofx_lIlIIlIlllllIlI = (jericofx_IIIllIIIlIIl() ~= 0)
            elseif (jericofx_lIIllIIlIIll == 1) then
                jericofx_lIlIIlIlllllIlI = jericofx_IllIIlIlIIII()
            elseif (jericofx_lIIllIIlIIll == 3) then
                jericofx_lIlIIlIlllllIlI = jericofx_IIlllIIlIlIlIIlIlIIIlI()
            end
            jericofx_IIlllllllIllIIIllIIII[jericofx_IllIllIlIllIIIIlll] = jericofx_lIlIIlIlllllIlI
        end
        jericofx_IlIIlllllIIIlllIlllI[3] = jericofx_IIIllIIIlIIl()
        for jericofx_IlIIlllllIIIlllIlllI = 1, jericofx_lIIllIIlIIll() do
            local jericofx_lIlIIlIlllllIlI = jericofx_IIIllIIIlIIl()
            if (jericofx_IllIllIlIllIIIIlll(jericofx_lIlIIlIlllllIlI, 1, 1) == 0) then
                local jericofx_IlIIIIIllIllIll = jericofx_IllIllIlIllIIIIlll(jericofx_lIlIIlIlllllIlI, 2, 3)
                local jericofx_lllIIlIlIIllllIlllII = jericofx_IllIllIlIllIIIIlll(jericofx_lIlIIlIlllllIlI, 4, 6)
                local jericofx_lIlIIlIlllllIlI = {jericofx_lIlIIIIllI(), jericofx_lIlIIIIllI(), nil, nil}
                if (jericofx_IlIIIIIllIllIll == 0) then
                    jericofx_lIlIIlIlllllIlI[#{"1 + 1 = 111", "1 + 1 = 111", "1 + 1 = 111"}] = jericofx_lIlIIIIllI()
                    jericofx_lIlIIlIlllllIlI[#("Kgqo")] = jericofx_lIlIIIIllI()
                elseif (jericofx_IlIIIIIllIllIll == 1) then
                    jericofx_lIlIIlIlllllIlI[#("F6m")] = jericofx_lIIllIIlIIll()
                elseif (jericofx_IlIIIIIllIllIll == 2) then
                    jericofx_lIlIIlIlllllIlI[#("dJD")] = jericofx_lIIllIIlIIll() - (2 ^ 16)
                elseif (jericofx_IlIIIIIllIllIll == 3) then
                    jericofx_lIlIIlIlllllIlI[#("eP0")] = jericofx_lIIllIIlIIll() - (2 ^ 16)
                    jericofx_lIlIIlIlllllIlI[
                            #{"1 + 1 = 111", {270, 302, 383, 28}, {766, 678, 889, 974}, {702, 221, 707, 111}}
                        ] = jericofx_lIlIIIIllI()
                end
                if (jericofx_IllIllIlIllIIIIlll(jericofx_lllIIlIlIIllllIlllII, 1, 1) == 1) then
                    jericofx_lIlIIlIlllllIlI[#("v9")] =
                        jericofx_IIlllllllIllIIIllIIII[
                        jericofx_lIlIIlIlllllIlI[#{{65, 379, 130, 799}, {134, 976, 349, 162}}]
                    ]
                end
                if (jericofx_IllIllIlIllIIIIlll(jericofx_lllIIlIlIIllllIlllII, 2, 2) == 1) then
                    jericofx_lIlIIlIlllllIlI[#("iRc")] =
                        jericofx_IIlllllllIllIIIllIIII[jericofx_lIlIIlIlllllIlI[#("zXL")]]
                end
                if (jericofx_IllIllIlIllIIIIlll(jericofx_lllIIlIlIIllllIlllII, 3, 3) == 1) then
                    jericofx_lIlIIlIlllllIlI[#("cRfe")] =
                        jericofx_IIlllllllIllIIIllIIII[jericofx_lIlIIlIlllllIlI[#("ENcq")]]
                end
                jericofx_IIIIllllllllllIIIll[jericofx_IlIIlllllIIIlllIlllI] = jericofx_lIlIIlIlllllIlI
            end
        end
        for jericofx_lIlIIlIlllllIlI = 1, jericofx_lIIllIIlIIll() do
            jericofx_lIlIIlllIlII[jericofx_lIlIIlIlllllIlI - 1] = jericofx_lllIIlIIllllIIllIIIIllllI()
        end
        return jericofx_IlIIlllllIIIlllIlllI
    end
    local function jericofx_IIIIllllllllllIIIll(
        jericofx_lIlIIlIlllllIlI,
        jericofx_lIIllIIlIIll,
        jericofx_lllIIlIlIIllllIlllII)
        jericofx_lIlIIlIlllllIlI =
            (jericofx_lIlIIlIlllllIlI == true and jericofx_lllIIlIIllllIIllIIIIllllI()) or jericofx_lIlIIlIlllllIlI
        return (function(...)
            local jericofx_IIIllIIIlIIl = jericofx_lIlIIlIlllllIlI[1]
            local jericofx_IllIllIlIllIIIIlll = jericofx_lIlIIlIlllllIlI[3]
            local jericofx_lIlIIlIlllllIlI = jericofx_lIlIIlIlllllIlI[2]
            local jericofx_lIlIIlIlllllIlI = jericofx_IIIIIlIlllIIIIIllI
            local jericofx_IIlllllllIllIIIllIIII = 1
            local jericofx_lIlIIlIlllllIlI = -1
            local jericofx_IlIIlllllIIIlllIlllI = {}
            local jericofx_lIlIIIIllI = {...}
            local jericofx_IlIIIIIllIllIll = jericofx_IIIlIllIIIllIlIllllI("#", ...) - 1
            local jericofx_lIlIIlIlllllIlI = {}
            local jericofx_lIIllIIlIIll = {}
            for jericofx_lIlIIlIlllllIlI = 0, jericofx_IlIIIIIllIllIll do
                if (jericofx_lIlIIlIlllllIlI >= jericofx_IllIllIlIllIIIIlll) then
                    jericofx_IlIIlllllIIIlllIlllI[jericofx_lIlIIlIlllllIlI - jericofx_IllIllIlIllIIIIlll] =
                        jericofx_lIlIIIIllI[jericofx_lIlIIlIlllllIlI + 1]
                else
                    jericofx_lIIllIIlIIll[jericofx_lIlIIlIlllllIlI] =
                        jericofx_lIlIIIIllI[jericofx_lIlIIlIlllllIlI + #{{167, 826, 998, 944}}]
                end
            end
            local jericofx_lIlIIlIlllllIlI = jericofx_IlIIIIIllIllIll - jericofx_IllIllIlIllIIIIlll + 1
            local jericofx_lIlIIlIlllllIlI
            local jericofx_IllIllIlIllIIIIlll
            while true do
                jericofx_lIlIIlIlllllIlI = jericofx_IIIllIIIlIIl[jericofx_IIlllllllIllIIIllIIII]
                jericofx_IllIllIlIllIIIIlll = jericofx_lIlIIlIlllllIlI[#("F")]
                if jericofx_IllIllIlIllIIIIlll <= #("PO6") then
                    if jericofx_IllIllIlIllIIIIlll <= #("S") then
                        if jericofx_IllIllIlIllIIIIlll > #("") then
                            jericofx_lIIllIIlIIll[jericofx_lIlIIlIlllllIlI[#{{585, 699, 256, 475}, "1 + 1 = 111"}]] =
                                jericofx_lllIIlIlIIllllIlllII[jericofx_lIlIIlIlllllIlI[#("Fb9")]]
                        else
                            local jericofx_lIlIIlIlllllIlI = jericofx_lIlIIlIlllllIlI[#("Wp")]
                            jericofx_lIIllIIlIIll[jericofx_lIlIIlIlllllIlI](
                                jericofx_lIIllIIlIIll[jericofx_lIlIIlIlllllIlI + 1]
                            )
                        end
                    elseif jericofx_IllIllIlIllIIIIlll > #("Iv") then
                        jericofx_lIIllIIlIIll[jericofx_lIlIIlIlllllIlI[#("YD")]] =
                            jericofx_lIlIIlIlllllIlI[#{"1 + 1 = 111", "1 + 1 = 111", "1 + 1 = 111"}]
                    else
                        jericofx_lIIllIIlIIll[jericofx_lIlIIlIlllllIlI[#("WW")]] = jericofx_lIlIIlIlllllIlI[#("efN")]
                    end
                elseif jericofx_IllIllIlIllIIIIlll <= #("zjJIn") then
                    if jericofx_IllIllIlIllIIIIlll == #("87MP") then
                        do
                            return
                        end
                    else
                        do
                            return
                        end
                    end
                elseif jericofx_IllIllIlIllIIIIlll > #("AbkYVU") then
                    jericofx_lIIllIIlIIll[jericofx_lIlIIlIlllllIlI[#("Wl")]] =
                        jericofx_lllIIlIlIIllllIlllII[jericofx_lIlIIlIlllllIlI[#("CsW")]]
                else
                    local jericofx_lIlIIlIlllllIlI = jericofx_lIlIIlIlllllIlI[#("i5")]
                    jericofx_lIIllIIlIIll[jericofx_lIlIIlIlllllIlI](jericofx_lIIllIIlIIll[jericofx_lIlIIlIlllllIlI + 1])
                end
                jericofx_IIlllllllIllIIIllIIII = jericofx_IIlllllllIllIIIllIIII + 1
            end
        end)
    end
    return jericofx_IIIIllllllllllIIIll(true, {}, jericofx_llIlIlIlIlIllllIl())()
end)(string.byte, table.insert, setmetatable)