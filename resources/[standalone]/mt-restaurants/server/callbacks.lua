-- mt-restaurants/server/callbacks.lua

if Config.inventory == 'ox_inventory' then
    lib.callback.register('mt-restaurants:server:registerCraft', function(source, id, items, label)
        return exports.ox_inventory:RegisterCraftStation(id, { items = items, label = label })
    end)
end

-- Helpers for non-OX and other functions
if Config.inventory ~= 'ox_inventory' and Config.framework == 'qb' then
    lib.callback.register('mt-restaurants:server:GetItemCount', function(source, item)
        local src = source
        local Player = Config.core.Functions.GetPlayer(src)
        if not Player then return end
        if Player.Functions.GetItemByName(item) then return Player.Functions.GetItemByName(item).amount end
        return 0
    end)
    lib.callback.register('mt-restaurants:server:openShop', function(source, id, label) exports[Config.inventory]:OpenShop(source, id) return true end)
    lib.callback.register('mt-restaurants:server:openStash', function(source, id, data) exports[Config.inventory]:OpenInventory(source, id, data) return true end)
end

lib.callback.register('mt-restaurants:server:addNeeds', function(source, thirst, hunger) return addNeeds(thirst, hunger) end)
lib.callback.register('mt-restaurants:server:removeFoodItem', function(source, metadata, slot)
    local src = source
    if Config.inventory == 'ox_inventory' then exports.ox_inventory:RemoveItem(src, 'restaurant_food', 1, metadata, slot)
    else local Player = Config.core.Functions.GetPlayer(src) if Player then Player.Functions.RemoveItem('restaurant_food', 1, slot) end end
    return true
end)

if Config.inventory == 'ox_inventory' then
    lib.callback.register('mt-restaurants:server:getInventoryItems', function(source, invId) return exports.ox_inventory:GetInventoryItems(invId) end)
    lib.callback.register('mt-restaurants:server:openOfflineStash', function(_, invId, shopId, label)
        local shopStashItems = exports.ox_inventory:GetInventoryItems(invId)
        if not shopStashItems then return end
        local filteredItems = {}
        for _, v in pairs(shopStashItems) do filteredItems[#filteredItems + 1] = { name = v.name, count = v.count, price = v.metadata.price, slot = v.slot, metadata = v.metadata } end
        registerShop(shopId, label, filteredItems)
        return true
    end)
end

lib.callback.register('mt-restaurants:server:addRestaurantBox', function(source, job)
    local src = source
    local info = { id = 'restaurants_food_box_'..job..'_'..math.random(1, 999999) }
    if Config.inventory == 'ox_inventory' then
        exports.ox_inventory:AddItem(src, 'restaurant_box', 1, info)
    else
        local Player = Config.core.Functions.GetPlayer(src)
        if not Player then return end
        Player.Functions.AddItem('restaurant_box', 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', src, Config.core.Shared.Items['restaurant_box'], "add", 1)
    end
    return true
end)

lib.callback.register('mt-restaurants:server:addRestaurantMenu', function(source, job)
    local src = source
    local menus = MySQL.query.await('SELECT * FROM `restaurants_menus` WHERE job = ?', { job })
    if not menus[1] or not menus[1].image_url then return end
    local info = { job = job, imageurl = menus[1].image_url, images = menus[1].image_url, image_url = menus[1].image_url, label = Config.restaurants[job].menus[1].label }
    if Config.inventory == 'ox_inventory' then
        exports.ox_inventory:AddItem(src, 'restaurant_menu', 1, info)
    else
        local Player = Config.core.Functions.GetPlayer(src)
        if not Player then return end
        Player.Functions.AddItem('restaurant_menu', 1, nil, info)
        TriggerClientEvent('inventory:client:ItemBox', src, Config.core.Shared.Items['restaurant_menu'], "add", 1)
    end
    return true
end)

if Config.framework == 'esx' then
    lib.callback.register('mt-restaurants:server:getPlayerJobESX', function(source)
        local Player = Config.core.GetPlayerFromId(source)
        return Player and Player.getJob().name
    end)
    lib.callback.register('mt-restaurants:server:getPlayerJobIsBossESX', function(source)
        local Player = Config.core.GetPlayerFromId(source)
        return Player and (Player.getJob().grade_name == 'boss')
    end)
end

-- --- HELPER: CHECK INGREDIENTS ---
local canCraftItem = function(src, nItems, stationInfo)
    local items = 0
    local neededItems = {}
    local job = nil

    -- Get Job
    if Config.framework == 'esx' then
        local Player = Config.core.GetPlayerFromId(src)
        if Player then job = Player.getJob().name end
    elseif Config.framework == 'qb' then
        local Player = Config.core.Functions.GetPlayer(src)
        if Player then job = Player.PlayerData.job.name end
    end
    if not job then return false end

    -- Determine Source Inventory (Player vs Stash)
    local sourceInventory = src
    if stationInfo and stationInfo.drawsFrom and Config.restaurants[job].stashes then
        for i, stash in pairs(Config.restaurants[job].stashes) do
            if stash.label == stationInfo.drawsFrom then
                sourceInventory = 'restaurants_stash_' .. job .. '_' .. i
                break
            end
        end
    end

    for k, v in pairs(nItems) do
        neededItems[#neededItems+1] = { item = tostring(k), count = tonumber(v) }
    end

    if Config.inventory == 'ox_inventory' then
        for k, v in pairs(neededItems) do
            -- Check Stash/Player
            if exports.ox_inventory:GetItemCount(sourceInventory, v.item) >= v.count then 
                items = items + 1
            -- Fallback: Check Player if Stash didn't have it (and we aren't already checking player)
            elseif sourceInventory ~= src and exports.ox_inventory:GetItemCount(src, v.item) >= v.count then
                items = items + 1
            else 
                break 
            end
        end
    else
        -- Legacy inventory check
        local Player = Config.core.Functions.GetPlayer(src)
        if not Player then return end
        for k, v in pairs(neededItems) do
            if Player.Functions.GetItemByName(v.item) and Player.Functions.GetItemByName(v.item).amount >= v.count then items = items + 1 else break end
        end
    end

    if items == #neededItems then return true end
    return false
end
lib.callback.register('mt-restaurants:server:canCraftItem', canCraftItem)


-- --- SMART CRAFTING LOGIC (THE ROUTER) ---
lib.callback.register('mt-restaurants:server:craftItem', function(source, item, count, neededItems, metadata, stationInfo)
    local src = source
    local job = nil

    if Config.framework == 'esx' then
        local Player = Config.core.GetPlayerFromId(src)
        if Player then job = Player.getJob().name end
    elseif Config.framework == 'qb' then
        local Player = Config.core.Functions.GetPlayer(src)
        if Player then job = Player.PlayerData.job.name end
    end
    if not job then return false end

    -- 1. Determine SOURCE (Where ingredients come from)
    local sourceInventory = src
    if stationInfo and stationInfo.drawsFrom and Config.restaurants[job].stashes then
        for i, stash in pairs(Config.restaurants[job].stashes) do
            if stash.label == stationInfo.drawsFrom then
                sourceInventory = 'restaurants_stash_' .. job .. '_' .. i
                break
            end
        end
    end

    -- 2. Remove Ingredients
    if Config.inventory == 'ox_inventory' then
        for k, v in pairs(neededItems) do
            local success = exports.ox_inventory:RemoveItem(sourceInventory, tostring(k), tonumber(v))
            if not success then
                -- Fallback to player pocket
                if sourceInventory ~= src then
                    success = exports.ox_inventory:RemoveItem(src, tostring(k), tonumber(v))
                end
                if not success then return false end
            end
        end

        -- 3. Determine OUTPUT (Where finished item goes)
        local itemRouted = false
        local itemLabel = (metadata and metadata.label) or item -- Fixed: Checks if metadata exists first

        -- A. Check Specific Stash Output (e.g., Prepped Ingredients)
        if stationInfo and stationInfo.outputsTo and stationInfo.outputsTo ~= 'SmartBox' then
             for i, stash in pairs(Config.restaurants[job].stashes) do
                if stash.label == stationInfo.outputsTo then
                    local stashId = 'restaurants_stash_' .. job .. '_' .. i
                    exports.ox_inventory:AddItem(stashId, item, count, metadata or {})
                    itemRouted = true
                    TriggerClientEvent('esx:showNotification', src, 'Sent '..itemLabel..' to '..stash.label, 'success')
                    break
                end
            end
        end

        -- B. Smart Routing (Orders)
        if not itemRouted and (not stationInfo or stationInfo.outputsTo == 'SmartBox') then
            if ActiveOrders and ActiveOrders[job] then
                for i, order in ipairs(ActiveOrders[job]) do
                    if order.needs[itemLabel] and order.needs[itemLabel] > 0 then
                        
                        -- [FIX] Delivery Handling: If no boxId exists, give to player
                        if order.boxId then
                            exports.ox_inventory:AddItem(order.boxId, item, count, metadata or {})
                        else
                            -- Delivery Order: No box, so put it in the chef's pocket
                            exports.ox_inventory:AddItem(src, item, count, metadata or {})
                        end

                        order.needs[itemLabel] = order.needs[itemLabel] - count
                        itemRouted = true
                        
                        -- Notify cook
                        TriggerClientEvent('ox_lib:notify', src, {
                            title = 'Order #'..order.id, 
                            description = 'Added '..count..'x '..itemLabel, 
                            type = 'success'
                        })

                        -- [NEW] CHECK FOR COMPLETION
                        local isComplete = true
                        for _, qty in pairs(order.needs) do
                            if qty > 0 then isComplete = false break end
                        end

                        if isComplete then
                            order.status = 'done'
                            
                            -- [CHANGE] Use specific alert instead of generic notify
                            TriggerClientEvent('mt-restaurants:client:orderReadyAlert', -1, job, order.id)
                            
                            -- 2. Sync "Done" status (Turn Text Green)
                            TriggerClientEvent('mt-restaurants:client:syncOrders', -1, job, ActiveOrders[job])

                            -- 3. Auto-Delete after 5 Seconds
                            SetTimeout(5000, function()
                                if ActiveOrders[job] then
                                    for k, v in ipairs(ActiveOrders[job]) do
                                        if v.id == order.id then
                                            table.remove(ActiveOrders[job], k)
                                            break
                                        end
                                    end
                                    TriggerClientEvent('mt-restaurants:client:syncOrders', -1, job, ActiveOrders[job])
                                end
                            end)
                        else
                             -- Just Sync Progress (Item count updates)
                             TriggerClientEvent('mt-restaurants:client:syncOrders', -1, job, ActiveOrders[job])
                        end
                        break
                    end
                end
            end
        end

        -- C. Fallback: Player Pocket
        if not itemRouted then
            exports.ox_inventory:AddItem(src, item, count, metadata or {})
            TriggerClientEvent('esx:showNotification', src, 'Added to inventory', 'info')
        end

    else
        -- Legacy Fallback
        local Player = Config.core.Functions.GetPlayer(src)
        if not Player then return end
        for k, v in pairs(neededItems) do
            Player.Functions.RemoveItem(tostring(k), tonumber(v))
        end
        Player.Functions.AddItem(item, count, nil, metadata or {})
    end

    createLog(LogsConfig.craftItem, locale('logs_item_crafted'), locale('logs_item_crafted_desc', GetPlayerName(src), src, item, count))
    return true
end)

if Config.inventory == 'ox_inventory' then
    exports.ox_inventory:registerHook('swapItems', function(payload)
        if (type(payload.fromInventory) == 'string' and payload.fromInventory:match('^restaurants_food_box')) or (type(payload.toInventory) == 'string' and payload.toInventory:match('^restaurants_food_box')) then
            return (payload.fromSlot.name == 'restaurant_food')
        end
    end)
end

-- NEW: Helper to let client menus "see" inside stashes
lib.callback.register('mt-restaurants:server:getStationIngredientCounts', function(source, job, drawsFromLabel)
    if not job or not drawsFromLabel then return {} end
    
    local stashId = nil
    -- Find the stash ID based on the label (e.g., "Fridge")
    if Config.restaurants[job] and Config.restaurants[job].stashes then
        for i, stash in pairs(Config.restaurants[job].stashes) do
            if stash.label == drawsFromLabel then
                stashId = 'restaurants_stash_' .. job .. '_' .. i
                break
            end
        end
    end

    if not stashId then return {} end

    -- Get all items from that stash
    local items = exports.ox_inventory:GetInventoryItems(stashId)
    local counts = {}
    
    -- Convert to a simple list: { onion = 5, meat = 10 }
    if items then
        for _, item in pairs(items) do
            if item and item.name then
                counts[item.name] = (counts[item.name] or 0) + (item.count or 0)
            end
        end
    end
    
    return counts
end)