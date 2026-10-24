-- mt-restaurants/server/delivery.lua

local cooldownActive = {}
local DeliveryCounter = {}

-- [NEW] Register Delivery on KDS
lib.callback.register('mt-restaurants:server:startDeliveryOrder', function(source, job, recipe)
    if not ActiveOrders[job] then ActiveOrders[job] = {} end
    if not DeliveryCounter[job] then DeliveryCounter[job] = 1 end

    local id = DeliveryCounter[job]
    DeliveryCounter[job] = DeliveryCounter[job] + 1
    if DeliveryCounter[job] > 999 then DeliveryCounter[job] = 1 end

    local needs = {}
    needs[recipe.label] = recipe.amount

    table.insert(ActiveOrders[job], {
        id = id,
        needs = needs,
        isDelivery = true, 
        status = 'prep' 
    })

    TriggerClientEvent('mt-restaurants:client:syncOrders', -1, job, ActiveOrders[job])
    
    return id 
end)

-- [UPDATED] Handles Payment + Tips + Split Stacks
lib.callback.register('mt-restaurants:server:makeDelivery', function(source, job, id, recipe, earnedTip, orderId)
    local src = source
    
    -- 1. Calculate Tip
    local tipAmount = 0
    if earnedTip and Config.DeliverySettings.tips.enabled then
        if math.random(1, 100) <= Config.DeliverySettings.tips.chance then
            local maxTip = math.floor(recipe.price * (Config.DeliverySettings.tips.percentage / 100))
            if maxTip < 1 then maxTip = 1 end
            tipAmount = math.random(1, maxTip)
        end
    end

    -- 2. REMOVE ITEMS LOGIC (Handles Split Stacks)
    local itemsRemoved = false
    
    if Config.inventory == 'ox_inventory' then
        local playerItems = exports.ox_inventory:GetInventoryItems(src)
        local totalAvail = 0
        local itemsNeeded = recipe.amount

        -- Pass 1: Verify Counts
        for _, v in pairs(playerItems) do
            if v.name == 'restaurant_food' and v.metadata.label == recipe.label then
                totalAvail = totalAvail + v.count
            end
        end

        if totalAvail >= itemsNeeded then
            -- Pass 2: Remove Items
            for _, v in pairs(playerItems) do
                if v.name == 'restaurant_food' and v.metadata.label == recipe.label then
                    local toRemove = math.min(v.count, itemsNeeded)
                    if toRemove > 0 then
                        exports.ox_inventory:RemoveItem(src, v.name, toRemove, nil, v.slot)
                        itemsNeeded = itemsNeeded - toRemove
                        if itemsNeeded <= 0 then break end
                    end
                end
            end
            itemsRemoved = true
        end
    else
        -- Legacy Inventory
        local Player = Config.core.Functions.GetPlayer(src)
        if Player then
            local playerItems = Player.PlayerData.items
            local totalAvail = 0
            
            for _, v in pairs(playerItems) do
                if v.name == 'restaurant_food' and v.info.label == recipe.label then
                    totalAvail = totalAvail + v.amount
                end
            end

            if totalAvail >= recipe.amount then
                Player.Functions.RemoveItem('restaurant_food', recipe.amount) -- QB handles finding the item usually
                itemsRemoved = true
            end
        end
    end

    -- 3. PAYOUT (Only if items were removed)
    if itemsRemoved then
        local commission = tonumber(math.floor(recipe.price * Config.restaurants[job].delivery[id].comission / 100))
        local totalPayout = commission + tipAmount

        if Config.framework == 'qb' then
            local Player = Config.core.Functions.GetPlayer(src)
            if Player then Player.Functions.AddMoney('cash', totalPayout, 'restaurants-delivery-payment') end
        elseif Config.framework == 'qbx' then
            local Player = exports.qbx_core:GetPlayer(src)
            if Player then Player.Functions.AddMoney('cash', totalPayout, 'restaurants-delivery-payment') end
        elseif Config.framework == 'esx' then
            local Player = Config.core.GetPlayerFromId(src)
            if Player then Player.addAccountMoney('money', totalPayout) end
        end

        addAccountMoney(job, tonumber(recipe.price - commission))
        createLog(LogsConfig.delivery, locale('logs_delivery_payment'), locale('logs_delivery_payment_desc', GetPlayerName(src), src, job, recipe.label, recipe.amount, totalPayout))
        
        -- Remove from KDS
        if ActiveOrders[job] and orderId then
            for i, o in ipairs(ActiveOrders[job]) do
                if o.id == orderId and o.isDelivery then
                    table.remove(ActiveOrders[job], i)
                    break
                end
            end
            TriggerClientEvent('mt-restaurants:client:syncOrders', -1, job, ActiveOrders[job])
        end

        return true
    end

    return false
end)

-- (Keep helpers: canDeliveryOrder, canStartDelivery, setCooldownState)
lib.callback.register('mt-restaurants:server:canDeliveryOrder', function(source, job, recipe)
    local src = source
    local itemAmount = 0
    if Config.inventory == 'ox_inventory' then
        local playerItems = exports.ox_inventory:GetInventoryItems(src)
        for k, v in pairs(playerItems) do
            if v.name == 'restaurant_food' then
                if v.metadata.label == recipe.label then itemAmount = itemAmount + v.count end
            end
        end
    else
        local Player = Config.core.Functions.GetPlayer(src)
        if not Player then return end
        local playerItems = Player.PlayerData.items
        for k, v in pairs(playerItems) do
            if v.name == 'restaurant_food' then
                if v.info.label == recipe.label then itemAmount = itemAmount + v.amount end
            end
        end
    end
    return (itemAmount >= recipe.amount)
end)

lib.callback.register('mt-restaurants:server:canStartDelivery', function(source, job)
    return cooldownActive[job]
end)

lib.callback.register('mt-restaurants:server:setCooldownState', function(source, job, id)
    cooldownActive[job] = false
    Citizen.CreateThread(function()
        Wait(Config.restaurants[job].delivery[id].cooldown*60000)
        cooldownActive[job] = true
    end)
    return true
end)