function openRegisterMenu(restaurantId)
    -- 1. Get all recipes for this restaurant
    local recipes = lib.callback.await("mt-restaurants:server:getRecipes", false, restaurantId)

    -- 2. Get nearby players
    local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 10.0, true)
    
    -- 3. Prepare list of IDs to fetch names for (Include Self)
    local idsToFetch = {}
    local myServerId = GetPlayerServerId(PlayerId())
    table.insert(idsToFetch, myServerId)

    for _, player in pairs(nearbyPlayers) do
        if player.id ~= PlayerId() then
            table.insert(idsToFetch, GetPlayerServerId(player.id))
        end
    end

    -- 4. [NEW] Fetch RP Names from Server
    local rpNames = lib.callback.await('mt-restaurants:server:getNearbyNames', false, idsToFetch)

    -- 5. Format for NUI
    local playerOptions = {}

    -- Add Self (Yourself)
    table.insert(playerOptions, {
        id = myServerId,
        name = (rpNames[myServerId] or "Unknown") .. " (Yourself)"
    })

    -- Add other nearby players
    for _, player in pairs(nearbyPlayers) do
        if player.id ~= PlayerId() then
            local sId = GetPlayerServerId(player.id)
            table.insert(playerOptions, {
                id = sId,
                name = rpNames[sId] or ("Player " .. sId)
            })
        end
    end
    
    -- 6. Send data to NUI
    SendNUIMessage({
        action = 'showRegister',
        recipes = recipes,
        players = playerOptions, 
        currency = Config.core.Currency or '$',
        restaurantId = restaurantId 
    })
    
    -- 7. Set Focus
    SetNuiFocus(true, true)
end

-- 5. Create NUI callbacks to handle "Pay" or "Cancel"
RegisterNUICallback('cancel', function(data, cb)
    SetNuiFocus(false, false)
    notify(locale("notify_error_payment_cancelled"), "error")
    cb('ok')
end)

-- 6. "PAY" CALLBACK (Now much simpler)
-- The NUI will now send us all the data we need
RegisterNUICallback('pay', function(data, cb)
    SetNuiFocus(false, false)
    
    if not data or not data.targetId or not data.paymentMethod or not data.cart then
        notify(locale("notify_error_payment_cancelled"), "error")
        cb('error')
        return
    end

    -- Trigger the server event with all the data from the NUI
    TriggerServerEvent('mt-restaurants:server:processNuiPayment', data.targetId, data.cart, data.restaurantId, data.paymentMethod)
    
    cb('ok')
end)

-- NUI → analytics request
RegisterNUICallback('getAnalytics', function(data, cb)
    local restaurantId = data and data.restaurantId
    if not restaurantId then
        cb('{}')
        return
    end

    local stats = lib.callback.await('mt-restaurants:server:getAnalytics', false, restaurantId)
    cb(stats or {})
end)

-- NUI → Get last receipts for current restaurant
RegisterNUICallback('getReceipts', function(data, cb)
    local restaurantId = data and data.restaurantId
    if not restaurantId then
        cb({})
        return
    end

    local receipts = lib.callback.await('mt-restaurants:server:getReceipts', false, restaurantId)
    cb(receipts or {})
end)
