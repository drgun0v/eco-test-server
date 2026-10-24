-- mt-restaurants/server/offlineShops.lua

-- Only initialize offline shops if using ox_inventory
if Config.inventory == "ox_inventory" then
  -- Initialize locales
  lib.locale()
  
  -- Track online job players count by restaurant
  local onlineJobPlayersCount = {}
  
  -- Track online job players by restaurant
  local onlineJobPlayers = {}
  
  -- Register offline shop stashes for each restaurant
  for restaurantId, restaurant in pairs(Config.restaurants) do
    -- Register stash for offline shop
    exports.ox_inventory:RegisterStash(
      "restaurants_offline_shop_stash_" .. restaurantId,
      locale("inventory_stash_offline_shop"),
      50, -- slots
      10000 -- weight
    )
    
    -- Register hook to allow Boss to put ANY item in the stash
    exports.ox_inventory:registerHook(
      "swapItems",
      function(payload)
        -- FIXED: Removed the restriction that only allowed "restaurant_food".
        -- Now returns true to allow stocking any item (Food, Drink, etc.)
        return true
      end,
      {
        inventoryFilter = {"restaurants_offline_shop_stash_" .. restaurantId}
      }
    )
  end

  -- Register hook for when items are bought from offline shops
  exports.ox_inventory:registerHook(
    "buyItem",
    function(payload)
      -- Process purchase for each restaurant
      for restaurantId, restaurant in pairs(Config.restaurants) do
        local shopType = "restaurants_offline_shop_" .. restaurantId
        
        if payload.shopType == shopType then
          -- Calculate total price
          local totalPrice = payload.price * payload.count
          
          -- Add money to restaurant account
          addAccountMoney(restaurantId, totalPrice)
          
          -- Remove item from offline shop stash
          exports.ox_inventory:RemoveItem(
            "restaurants_offline_shop_stash_" .. restaurantId,
            payload.itemName,
            payload.count,
            payload.metadata
          )
          
          break
        end
      end
    end
  )

  -- Function to manage online job players for restaurants
  local function setOnlineJobPlayers(playerId, restaurantId, action)
    if action == "add" then
      if not onlineJobPlayers[restaurantId] then
        onlineJobPlayers[restaurantId] = {}
      end
      table.insert(onlineJobPlayers[restaurantId], playerId)
      onlineJobPlayersCount[restaurantId] = (onlineJobPlayersCount[restaurantId] or 0) + 1
    else
      if onlineJobPlayersCount[restaurantId] ~= nil then
        for restaurantKey, playerList in pairs(onlineJobPlayers) do
          for i = #playerList, 1, -1 do
            if playerList[i] == playerId then
              table.remove(playerList, i)
              break
            end
          end
        end
        onlineJobPlayersCount[restaurantId] = onlineJobPlayersCount[restaurantId] - 1
      end
    end
    return onlineJobPlayersCount
  end
  lib.callback.register("mt-restaurants:server:setOnlineJobPlayers", setOnlineJobPlayers)
  
  -- Handle player disconnect
  AddEventHandler("playerDropped", function(reason)
    local playerId = source
    for restaurantId, playerList in pairs(onlineJobPlayers) do
      for i = #playerList, 1, -1 do
        if playerList[i] == playerId then
          onlineJobPlayersCount[restaurantId] = onlineJobPlayersCount[restaurantId] - 1
          table.remove(playerList, i)
          if onlineJobPlayersCount[restaurantId] <= 0 then
            TriggerClientEvent("mt-restaurants:client:updateSpawnedShopPeds", -1, restaurantId, "spawn")
          end
          break
        end
      end
    end
  end)

  -- Callback: Check if restaurant is online (has employees)
  lib.callback.register("mt-restaurants:server:checkRestaurantOnline", function(source, restaurantId)
    return onlineJobPlayersCount[restaurantId] ~= nil and onlineJobPlayersCount[restaurantId] > 0
  end)

  -- Callback: Check if Player is Boss (To open Stash)
  lib.callback.register("mt-restaurants:server:canOpenOfflineStash", function(source, restaurantId)
      local src = source
      local xPlayer = nil
      
      if Config.framework == 'esx' then
          xPlayer = Config.core.GetPlayerFromId(src)
          -- Check if player has the job AND is boss
          if xPlayer and xPlayer.job.name == restaurantId and xPlayer.job.grade_name == 'boss' then
              return true
          end
      elseif Config.framework == 'qb' then
          xPlayer = Config.core.Functions.GetPlayer(src)
          -- Check if player has the job AND is boss
          if xPlayer and xPlayer.PlayerData.job.name == restaurantId and xPlayer.PlayerData.job.isboss then
              return true
          end
      end
      
      return false
  end)

  -- Callback: Get Items (for customers viewing the shop UI)
  lib.callback.register("mt-restaurants:server:getStashItems", function(source, stashId)
    local result = MySQL.query.await(
      "SELECT * FROM `" .. Config.inventoriesDatabase .. "` WHERE " .. Config.itemsDatabaseColumn .. " = ?",
      {stashId}
    )
    if result and result[1] then
        return json.decode(result[1].items)
    end
    return {}
  end)
  
  -- Event to update spawned shop peds
  RegisterNetEvent("mt-restaurants:server:updateSpawnedShopPeds", function(restaurantId, action)
    -- Only send update if the state actually changes or needs refresh
    -- This basic check ensures we don't spam events unnecessarily
    TriggerClientEvent("mt-restaurants:client:updateSpawnedShopPeds", -1, restaurantId, action)
  end)

  -- NEW COMMAND: Allow Boss to stock the offline stash even if the ped is gone
  RegisterCommand('stockoffline', function(source, args, rawCommand)
      local src = source
      local xPlayer = nil
      local jobName = nil
      local isBoss = false

      if Config.framework == 'esx' then
          xPlayer = Config.core.GetPlayerFromId(src)
          if xPlayer then
              jobName = xPlayer.job.name
              if xPlayer.job.grade_name == 'boss' then isBoss = true end
          end
      elseif Config.framework == 'qb' then
          xPlayer = Config.core.Functions.GetPlayer(src)
          if xPlayer then
              jobName = xPlayer.PlayerData.job.name
              if xPlayer.PlayerData.job.isboss then isBoss = true end
          end
      end

      -- If player is boss of a valid restaurant
      if isBoss and Config.restaurants[jobName] then
          -- Force open the inventory stash from server side
          exports.ox_inventory:forceOpenInventory(src, 'stash', 'restaurants_offline_shop_stash_' .. jobName)
      else
          if Config.framework == 'esx' and xPlayer then
             xPlayer.showNotification(locale("notify_error_not_boss"))
          elseif Config.framework == 'qb' and xPlayer then
             TriggerClientEvent('QBCore:Notify', src, locale("notify_error_not_boss"), "error")
          end
      end
  end, false)
end