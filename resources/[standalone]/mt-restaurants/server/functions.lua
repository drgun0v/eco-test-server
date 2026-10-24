-- Discord logs webhooks config
LogsConfig = {
    createRecipe = '',
    editRecipe = '',
    deleteRecipe = '',
    menuImageEdited = '',
    registers = '',
    offlineShopItemBuy = '', -- With ox_inventory this will use the default inv logs
    craftItem = '', -- With ox_inventory this will use the default inv logs
    delivery = 'https://discord.com/api/webhooks/1405143712346017832/Iu3oeYamGRMTwHZVgB_B-j7N_rBBzI3VEqeWNbHhobGA81imk06Wo3dYrLs5uw-sYDrn',
}

addAccountMoney = function(account, amount)
    if Config.banking == 'Renewed-Banking' then
        exports['Renewed-Banking']:addAccountMoney(account, amount)
    elseif Config.banking == 'esx_addonaccount' then
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_' .. account, function(account)
            account.addMoney(amount)
        end)
    else
        exports[Config.banking]:AddMoney(account, amount)
    end
end

if Config.inventory ~= 'ox_inventory' and Config.framework == 'qb' then
    Config.core.Functions.CreateUseableItem('restaurant_food', function(source, item)
        local src = source
        local Player = Config.core.Functions.GetPlayer(src)
        if not Player then return end
        if Player.Functions.GetItemBySlot(item.slot) ~= nil then
            TriggerClientEvent('mt-restaurants:client:useFoodItem', src, {}, item)
        end
    end)

    Config.core.Functions.CreateUseableItem('restaurant_box', function(source, item)
        local src = source
        local Player = Config.core.Functions.GetPlayer(src)
        if not Player then return end
        if Player.Functions.GetItemBySlot(item.slot) ~= nil then
            TriggerClientEvent('mt-restaurants:client:useBoxItem', src, {}, item)
        end
    end)

    Config.core.Functions.CreateUseableItem('restaurant_menu', function(source, item)
        local src = source
        local Player = Config.core.Functions.GetPlayer(src)
        if not Player then return end
        if Player.Functions.GetItemBySlot(item.slot) ~= nil then
            TriggerClientEvent('mt-restaurants:client:openMenu', src, {}, item)
        end
    end)
end

if Config.inventory ~= 'ox_inventory' and Config.framework == 'esx' then
    Config.core.RegisterUsableItem('restaurant_food', function(source, item)
        local src = source
        TriggerClientEvent('mt-restaurants:client:useFoodItem', src, {}, item)
    end)

    Config.core.RegisterUsableItem('restaurant_box', function(source, item)
        local src = source
        TriggerClientEvent('mt-restaurants:client:useBoxItem', src, {}, item)
    end)

    Config.core.RegisterUsableItem('restaurant_menu', function(source, item)
        local src = source
        TriggerClientEvent('mt-restaurants:client:openMenu', src, {}, item)
    end)
end

addNeeds = function(thirst, hunger)
    local src = source
    if Config.framework == 'qb' then
        local Player = Config.core.Functions.GetPlayer(src)
        if not Player then return end
        thirst = Player.PlayerData.metadata.thirst + thirst
        hunger = Player.PlayerData.metadata.hunger + hunger
        local newThirst = thirst <= 100 and thirst or 100
        local newHunger = hunger <= 100 and hunger or 100
        Player.Functions.SetMetaData('thirst', newThirst)
        Player.Functions.SetMetaData('hunger', newHunger)
        TriggerClientEvent('hud:client:UpdateNeeds', src, newHunger, newThirst)
    elseif Config.framework == 'qbx' then
        local Player = exports.qbx_core:GetPlayer(src)
        if not Player then return end
        thirst = Player.PlayerData.metadata.thirst + thirst
        hunger = Player.PlayerData.metadata.hunger + hunger
        local newThirst = thirst <= 100 and thirst or 100
        local newHunger = hunger <= 100 and hunger or 100
        Player.Functions.SetMetaData('thirst', newThirst)
        Player.Functions.SetMetaData('hunger', newHunger)
        TriggerClientEvent('hud:client:UpdateNeeds', src, newHunger, newThirst)
    elseif Config.framework == 'esx' then
        TriggerClientEvent('esx_status:add', src, 'hunger', (hunger * 10000))
        TriggerClientEvent('esx_status:add', src, 'thirst',  (thirst * 10000))
    end
end

createLog = function(webhook, title, message, image)
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        embeds = {
            {
                title = title,
                author = {
                    name = "MT Scripts - Restaurants",
                    icon_url = 'https://cdn.discordapp.com/attachments/1014907105733517442/1141400655450361916/Logo_PNG_8K.png?ex=66292c32&is=6616b732&hm=7f280578a3f1186b3778c2e828032df28d8f0b21debf468f126e0f5cb099e3d8&',
                    url = 'https://mt-scripts.tebex.io/',
                },
                color = '000000255',
                description = message,
                image = { url = image or '' },
                footer = { text = 'mt-scripts.tebex.io' },
            }
        }
    }), { ['Content-Type'] = 'application/json' })
end

-- Register shops

registerShop = function(id, label, passedItems)
    if Config.inventory == 'ox_inventory' then
        exports.ox_inventory:RegisterShop(id, { name = label, slots = #passedItems, inventory = passedItems })
    elseif Config.inventory == 'qb-inventory' then
        local items = {}
        for k, v in pairs(passedItems) do
            items[#items+1] = { name = v.name, price = tonumber(v.price), amount = tonumber(v.count), info = {}, slot = k }
        end
        exports[Config.inventory]:CreateShop({ name = id, label = label, slots = #items, items = items })
    end
end

haveStation = function(station, stations)
    for k, v in pairs(stations) do
        if v == station then return true end
    end

    return false
end

registerStation = function(job)
    for a, b in pairs(Config.restaurants[job].stations) do
        local items = {}
        local recipes = MySQL.query.await('SELECT * FROM `restaurants_recipes` WHERE job = ? AND active = 1', { job })
        if recipes and #recipes >= 1 then
            for _, rv in pairs(recipes) do
                if haveStation('station_'..job..'_'..a, json.decode(rv.stations)) then
                    local ingredients = {}
                    local calories = 0
                    local customBuffs = {}

                    for ik, iv in pairs(json.decode(rv.ingredients)) do
                        if ik ~= 'no_ingredient' then
                            ingredients[ik] = iv
                            for _, y in pairs(Config.restaurants[job].ingredients) do
                                if y.item == ik then
                                    calories += (y.calories * iv)
                                    if y.customBuffs then
                                        for o, p in pairs(y.customBuffs) do
                                            if customBuffs[o] ~= nil then customBuffs[o] += (p * iv) else customBuffs[o] = (p * iv) end
                                        end
                                    end
                                end
                            end
                        end
                    end

                    items[#items+1] = {
                        anim = b.anim,
                        prop = b.prop,
                        name = 'restaurant_food',
                        count = 1,
                        ingredients = ingredients,
                        duration = Config.times.makeFood,
                        metadata = {
                            imageurl = rv.image_url,
                            label = rv.label,
                            description = rv.description,
                            calories = calories,
                            restaurant = Config.restaurants[job].label,
                            animation = rv.animation,
                            type = rv.type,
                            price = rv.price,
                            customBuffs = customBuffs
                        }
                    }
                end
            end
        end

        exports.ox_inventory:RegisterCraftStation('station_'..job..'_'..a, { items = items, label = b.label or "Restaurant Station" })
    end
end

if Config.inventory == 'ox_inventory' or Config.inventory == 'qb-inventory' then
    for k, v in pairs (Config.shops) do
        if v.enabled then
            registerShop('ingredients_shop_'..k, v.label, v.items)
        end
    end

    for k, v in pairs(Config.restaurants) do
        if v.stashes then
            for a, b in pairs(v.stashes) do
                exports.ox_inventory:RegisterStash('restaurants_stash_'..k..'_'..a, b.label, b.slots, b.weight)
            end
        end

        if v.trays then
            for a, b in pairs(v.trays) do
                exports.ox_inventory:RegisterStash('restaurants_trays_'..k..'_'..a, b.label, b.slots, b.weight)
            end
        end

        if Config.inventory == 'ox_inventory' and Config.useOxInventoryCraft then
            if v.prepare then
                local items = {}
                if v.ingredients then
                    for _, b in pairs(v.ingredients) do
                        if b.needCut then
                            items[#items+1] = { name = b.item, count = b.count, ingredients = b.neededItems, duration = Config.times.prepare, anim = b.anim }
                        end
                    end
                end

                for a, b in pairs(v.prepare) do
                    exports.ox_inventory:RegisterCraftStation('restaurants_prepare_'..v.job..'_'..a, { items = items, label = b.label })
                end
            end

            if v.stations then
                registerStation(v.job)
            end
        end
    end
end