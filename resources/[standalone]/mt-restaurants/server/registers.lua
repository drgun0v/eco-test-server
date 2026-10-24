-- mt-restaurants/server/registers.lua
lib.locale()
-- [CHANGE] Use a table instead of a single number
local RestaurantOrderNumbers = {} 
ActiveOrders = {} 

-- [NEW] Shared Tip Pools Storage
local RestaurantTipPools = {}

-- Helper to find the "Pass" stash index
local function GetPassStashId(job)
    if Config.restaurants[job] and Config.restaurants[job].stashes then
        for i, stash in pairs(Config.restaurants[job].stashes) do
            if stash.label == 'Pass' or stash.label == 'Tray' then 
                return 'restaurants_stash_' .. job .. '_' .. i
            end
        end
        return 'restaurants_stash_' .. job .. '_1'
    end
    return nil
end

RegisterNetEvent('mt-restaurants:server:processNuiPayment', function(targetPlayerId, cart, restaurantId, paymentMethod)
    local source = source
    local cashierPlayer = Config.core.GetPlayerFromId(source)
    local targetPlayer = Config.core.GetPlayerFromId(targetPlayerId)
    local inventoryId = tonumber(targetPlayerId)
    
    if not targetPlayer or not cashierPlayer then return end
    if not paymentMethod then paymentMethod = 'bank' end

    local job = cashierPlayer.getJob().name
    if job ~= restaurantId then 
        TriggerClientEvent('esx:showNotification', source, "You don't have permission.", "error")
        return 
    end

    local recipes = MySQL.query.await('SELECT id, price, label FROM restaurants_recipes WHERE job = ?', {restaurantId})
    local priceLookup = {}
    for _, recipe in pairs(recipes) do
        priceLookup[tonumber(recipe.id)] = { price = recipe.price, label = recipe.label }
    end

    local subtotal = 0
    -- [UPDATE] Handle both numeric and string keys in cart if necessary
    for _, item in pairs(cart) do
        if priceLookup[item.id] and priceLookup[item.id].price then
            subtotal = subtotal + (tonumber(priceLookup[item.id].price) * tonumber(item.amount))
        end
    end

    local tax = subtotal * 0.05
    local totalPrice = math.floor(subtotal + tax)
    if totalPrice == 0 then return end

    local paymentSuccessful = false
    local notifyMessage = ''

    -- [UPDATE] Robust payment checks
    if paymentMethod == 'bank' then
        if Config.framework == 'esx' then
            local bankMoney = 0
            if targetPlayer.getAccount then 
                bankMoney = targetPlayer.getAccount('bank').money 
            else
                local acc = targetPlayer.getAccount('bank')
                if acc then bankMoney = acc.money end
            end
            if bankMoney >= totalPrice then
                targetPlayer.removeAccountMoney('bank', totalPrice)
                paymentSuccessful = true
                notifyMessage = locale('notify_success_charged_by_player_bank', totalPrice, cashierPlayer.getName())
            else
                notifyMessage = locale('notify_error_cannot_pay_bank')
            end
        elseif Config.framework == 'qb' or Config.framework == 'qbx' then
            if targetPlayer.Functions.RemoveMoney('bank', totalPrice) then
                paymentSuccessful = true
                notifyMessage = locale('notify_success_charged_by_player_bank', totalPrice, cashierPlayer.PlayerData.charinfo.firstname)
            else
                notifyMessage = locale('notify_error_cannot_pay_bank')
            end
        end
    else 
        if Config.framework == 'esx' then
            if targetPlayer.getMoney() >= totalPrice then
                targetPlayer.removeMoney(totalPrice)
                paymentSuccessful = true
                notifyMessage = locale('notify_success_charged_by_player_cash', totalPrice, cashierPlayer.getName())
            else
                notifyMessage = locale('notify_error_cannot_pay_cash')
            end
        elseif Config.framework == 'qb' or Config.framework == 'qbx' then
            if targetPlayer.Functions.RemoveMoney('cash', totalPrice) then
                paymentSuccessful = true
                notifyMessage = locale('notify_success_charged_by_player_cash', totalPrice, cashierPlayer.PlayerData.charinfo.firstname)
            else
                notifyMessage = locale('notify_error_cannot_pay_cash')
            end
        end
    end

    if paymentSuccessful then
        -- [NEW] Calculate Shared Tip Pool Split
        local societyAmount = totalPrice
        if Config.SharedTips and Config.SharedTips.enabled then
            local tipAmount = math.floor(totalPrice * Config.SharedTips.percentage)
            
            -- Prevent taking more than the total if config is weird, though percentage usually < 1
            if tipAmount > totalPrice then tipAmount = totalPrice end
            
            societyAmount = totalPrice - tipAmount
            
            -- Add to pool
            if not RestaurantTipPools[restaurantId] then RestaurantTipPools[restaurantId] = 0 end
            RestaurantTipPools[restaurantId] = RestaurantTipPools[restaurantId] + tipAmount
        end

        -- Add money to society (Modified to use societyAmount)
        if Config.framework == 'esx' then
            TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. restaurantId, function(account)
                if account then account.addMoney(societyAmount) end
            end)
        elseif Config.framework == 'qb' or Config.framework == 'qbx' then
            exports['qb-management']:AddMoney(restaurantId, societyAmount)
        end
        -- addAccountMoney(restaurantId, societyAmount) -- Commented out to prefer the direct event above, uncomment if using custom wrapper

        TriggerClientEvent('esx:showNotification', targetPlayerId, notifyMessage, 'success')
        TriggerClientEvent('esx:showNotification', source, "Payment Successful", 'success')

        -- [NEW] Update Employee Stats Directly (Fixes 0 Sales in Management Menu)
        local employeeId = nil
        if Config.framework == 'esx' then
             employeeId = cashierPlayer.identifier
        elseif Config.framework == 'qb' or Config.framework == 'qbx' then
             employeeId = cashierPlayer.PlayerData.citizenid
        end

        if employeeId then
             pcall(function()
                MySQL.insert('INSERT INTO restaurants_employee_stats (identifier, job, sales_count, total_earnings) VALUES (?, ?, 1, ?) ON DUPLICATE KEY UPDATE sales_count = sales_count + 1, total_earnings = total_earnings + ?', {employeeId, restaurantId, totalPrice, totalPrice})
             end)
        end

        -- [CHANGE] Get or Initialize the counter for THIS SPECIFIC restaurant
        if not RestaurantOrderNumbers[restaurantId] then
            RestaurantOrderNumbers[restaurantId] = 1
        end

        local orderId = RestaurantOrderNumbers[restaurantId]
        
        -- Increment for next time
        RestaurantOrderNumbers[restaurantId] = RestaurantOrderNumbers[restaurantId] + 1
        if RestaurantOrderNumbers[restaurantId] > 999 then 
            RestaurantOrderNumbers[restaurantId] = 1 
        end

        -- 1. Build the Needs List
        local orderNeeds = {}
        local itemListString = ""
        
        for _, item in pairs(cart) do
            if priceLookup[item.id] then
                local label = priceLookup[item.id].label
                itemListString = itemListString .. string.format("• %sx %s\n", item.amount, label)
                
                if orderNeeds[label] then
                    orderNeeds[label] = orderNeeds[label] + item.amount
                else
                    orderNeeds[label] = item.amount
                end
            end
        end

        -- 2. Register the Box Stash
        local boxId = "box_order_" .. orderId .. "_" .. os.time()
        local boxLabel = "Order #" .. orderId
        exports.ox_inventory:RegisterStash(boxId, boxLabel, 50, 50000)

        -- 3. Create the Physical Box Item
        local boxMetadata = {
            id = boxId,
            label = boxLabel,
            description = "Contains:\n" .. itemListString
        }

        -- 4. Put the Box in the "Pass" Stash
        local passStashId = GetPassStashId(restaurantId)
        if passStashId then
            exports.ox_inventory:AddItem(passStashId, 'restaurant_box', 1, boxMetadata)
        else
            print("^1[MT-Restaurants] Error: Could not find 'Pass' stash for " .. restaurantId)
        end

        -- 5. Save to Active Orders Table
        if not ActiveOrders[restaurantId] then ActiveOrders[restaurantId] = {} end
        
        table.insert(ActiveOrders[restaurantId], {
            id = orderId,
            boxId = boxId,
            needs = orderNeeds
        })

        -- [NEW] Trigger Sales/Receipt Events for Management Menu
        TriggerEvent("mt-restaurants:server:registerSale", restaurantId, totalPrice, orderNeeds)
        
        -- Build Receipt Entry for Management Analytics (Fixes empty Analytics/Receipts tab)
        local customerName = "Customer"
        local cashierName = "Cashier"
        
        if Config.framework == 'esx' then
            if targetPlayer.getName then customerName = targetPlayer.getName() else customerName = GetPlayerName(targetPlayerId) end
            if cashierPlayer.getName then cashierName = cashierPlayer.getName() else cashierName = GetPlayerName(source) end
        elseif Config.framework == 'qb' then
            customerName = targetPlayer.PlayerData.charinfo.firstname .. " " .. targetPlayer.PlayerData.charinfo.lastname
            cashierName = cashierPlayer.PlayerData.charinfo.firstname .. " " .. cashierPlayer.PlayerData.charinfo.lastname
        end

        local receiptEntry = {
            orderId = orderId,
            customer = customerName,
            cashier = cashierName,
            total = totalPrice,
            time = os.date("%H:%M")
        }
        TriggerEvent("mt-restaurants:server:registerReceipt", restaurantId, receiptEntry)

        TriggerClientEvent('mt-restaurants:client:syncOrders', -1, restaurantId, ActiveOrders[restaurantId])

        -- 6. Give Receipt Item to Customer
        local restaurantLabel = "Unknown Restaurant"
        if Config.restaurants[restaurantId] and Config.restaurants[restaurantId].label then
            restaurantLabel = Config.restaurants[restaurantId].label
        end

        local descriptionString = string.format(
            "%s\nOrder #%s  \nCashier: %s  \n____________________  \n%s  \nTotal: $%s",
            restaurantLabel,
            orderId,
            cashierPlayer.name,
            itemListString,
            totalPrice
        )

        local receiptMetadata = {
            description = descriptionString,
            orderId = "#" .. orderId,
            store = restaurantLabel,
            cashier = cashierPlayer.name,
            total = "$" .. totalPrice,
            itemData = itemListString
        }

        exports.ox_inventory:AddItem(inventoryId, 'restaurant_receipt', 1, receiptMetadata)

    else
        TriggerClientEvent('esx:showNotification', targetPlayerId, notifyMessage, 'error')
    end
end)

-- [NEW] Callback to fetch RP Names for the Register
lib.callback.register('mt-restaurants:server:getNearbyNames', function(source, playerIds)
    local names = {}
    
    for _, targetId in ipairs(playerIds) do
        local name = "Unknown (" .. targetId .. ")"
        local targetId = tonumber(targetId) -- Ensure it's a number

        if Config.framework == 'esx' then
            local xPlayer = Config.core.GetPlayerFromId(targetId)
            if xPlayer then
                name = xPlayer.getName()
            end
        elseif Config.framework == 'qb' then
            local Player = Config.core.Functions.GetPlayer(targetId)
            if Player then
                name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
            end
        elseif Config.framework == 'qbx' then
            local Player = exports.qbx_core:GetPlayer(targetId)
            if Player then
                name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
            end
        else
            -- Fallback for standalone or if framework data is missing
            name = GetPlayerName(targetId)
        end
        
        names[targetId] = name
    end
    
    return names
end)

-- [NEW] Command for transparency: Check current pool balance
if Config.SharedTips and Config.SharedTips.enabled and Config.SharedTips.command then
    RegisterCommand(Config.SharedTips.command, function(source, args, raw)
        local src = source
        local jobName = nil
        
        if Config.framework == 'esx' then
            local xPlayer = Config.core.GetPlayerFromId(src)
            if xPlayer then jobName = xPlayer.job.name end
        elseif Config.framework == 'qb' or Config.framework == 'qbx' then
            local Player = Config.core.Functions.GetPlayer(src)
            if Player then jobName = Player.PlayerData.job.name end
        end

        if jobName and RestaurantTipPools[jobName] then
            local currentPool = RestaurantTipPools[jobName]
            local msg = string.format("Current Shared Tip Pool for %s: $%s", jobName, currentPool)
            
            if Config.framework == 'esx' then
                TriggerClientEvent('esx:showNotification', src, msg)
            elseif Config.framework == 'qb' or Config.framework == 'qbx' then
                TriggerClientEvent('QBCore:Notify', src, msg, "primary")
            end
        else
            if Config.framework == 'esx' then
                TriggerClientEvent('esx:showNotification', src, "No active tip pool for your job.", "error")
            elseif Config.framework == 'qb' or Config.framework == 'qbx' then
                TriggerClientEvent('QBCore:Notify', src, "No active tip pool for your job.", "error")
            end
        end
    end, false)
end

-- [NEW] Shared Tip Pool Distribution Loop (Updated with Weighted Logic)
CreateThread(function()
    if not Config.SharedTips or not Config.SharedTips.enabled then return end
    
    while true do
        Wait(Config.SharedTips.interval * 60 * 1000) -- Convert minutes to ms

        for jobName, poolAmount in pairs(RestaurantTipPools) do
            if poolAmount > 0 then
                local onlineEmployees = {}

                -- Fetch Online Employees based on Framework
                if Config.framework == 'esx' then
                    if Config.core.GetExtendedPlayers then
                        local xPlayers = Config.core.GetExtendedPlayers('job', jobName)
                        for _, xPlayer in pairs(xPlayers) do
                            table.insert(onlineEmployees, xPlayer)
                        end
                    else
                        local xPlayers = Config.core.GetPlayers()
                        for _, src in ipairs(xPlayers) do
                            local xPlayer = Config.core.GetPlayerFromId(src)
                            if xPlayer and xPlayer.job.name == jobName then
                                table.insert(onlineEmployees, xPlayer)
                            end
                        end
                    end
                elseif Config.framework == 'qb' or Config.framework == 'qbx' then
                    local players = Config.core.Functions.GetPlayers()
                    for _, src in pairs(players) do
                        local player = Config.core.Functions.GetPlayer(src)
                        -- Check for job and duty status (if applicable)
                        if player and player.PlayerData.job.name == jobName and player.PlayerData.job.onduty then
                            table.insert(onlineEmployees, player)
                        end
                    end
                end

                local count = #onlineEmployees
                if count > 0 then
                    local totalDistributed = 0

                    if Config.SharedTips.weighted then
                        -- WEIGHTED DISTRIBUTION LOGIC
                        local totalWeight = 0
                        local employeeWeights = {}

                        -- Calculate total weight points
                        for _, employee in ipairs(onlineEmployees) do
                            local gradeName = ""
                            if Config.framework == 'esx' then
                                gradeName = employee.job.grade_name
                            elseif Config.framework == 'qb' or Config.framework == 'qbx' then
                                gradeName = employee.PlayerData.job.grade.name
                            end

                            -- Fetch weight from config (default 1.0)
                            -- We force lowercase for safer matching
                            local weight = Config.SharedTips.weights[string.lower(gradeName or "")] or 1.0
                            employeeWeights[employee] = weight
                            totalWeight = totalWeight + weight
                        end

                        if totalWeight > 0 then
                            local valuePerPoint = poolAmount / totalWeight

                            for employee, weight in pairs(employeeWeights) do
                                local share = math.floor(valuePerPoint * weight)
                                if share > 0 then
                                    if Config.framework == 'esx' then
                                        employee.addAccountMoney('bank', share)
                                        TriggerClientEvent('esx:showNotification', employee.source, "Tip Pool Payout: $" .. share .. " (Weighted)", "success")
                                    elseif Config.framework == 'qb' or Config.framework == 'qbx' then
                                        employee.Functions.AddMoney('bank', share, "tip-pool-share")
                                        TriggerClientEvent('QBCore:Notify', employee.PlayerData.source, "Tip Pool Payout: $" .. share .. " (Weighted)", "success")
                                    end
                                    totalDistributed = totalDistributed + share
                                end
                            end
                        end

                    else
                        -- EQUAL DISTRIBUTION LOGIC
                        local share = math.floor(poolAmount / count)
                        if share > 0 then
                            for _, employee in ipairs(onlineEmployees) do
                                if Config.framework == 'esx' then
                                    employee.addAccountMoney('bank', share)
                                    TriggerClientEvent('esx:showNotification', employee.source, "Tip Pool Payout: $" .. share, "success")
                                elseif Config.framework == 'qb' or Config.framework == 'qbx' then
                                    employee.Functions.AddMoney('bank', share, "tip-pool-share")
                                    TriggerClientEvent('QBCore:Notify', employee.PlayerData.source, "Tip Pool Payout: $" .. share, "success")
                                end
                                totalDistributed = totalDistributed + share
                            end
                        end
                    end
                    
                    -- Remove distributed amount from pool (keep remainder/rounding errors in pool)
                    RestaurantTipPools[jobName] = poolAmount - totalDistributed
                else
                    -- No one online? Keep money in pool for next cycle.
                end
            end
        end
    end
end)