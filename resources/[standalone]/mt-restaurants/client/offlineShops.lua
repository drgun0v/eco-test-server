-- mt-restaurants/client/offlineShops.lua

-- Only run if using ox_inventory
if Config.inventory ~= "ox_inventory" then
  return
end

local offlineShopPeds = {}

-- Function to open offline shop interaction
function openOfflineShop(shopId, label, restaurantId)
  -- Check if the player is the Boss and can stock the stash
  local canStock = lib.callback.await("mt-restaurants:server:canOpenOfflineStash", false, restaurantId)

  if canStock then
      -- BOSS: Open the Stash to put items in
      -- We open the stash registered on the server as 'restaurants_offline_shop_stash_' .. restaurantId
      exports.ox_inventory:openInventory('stash', 'restaurants_offline_shop_stash_' .. restaurantId)
  else
      -- CUSTOMER: Open the Shop Menu to buy items
      -- This calls the standard shop opening function (ensure openShop is defined in your main/functions)
      openShop(shopId, label, restaurantId)
  end
end

-- Function to update offline shop peds (spawn/delete)
function updateOfflineShop(restaurantId, action)
  local restaurant = Config.restaurants[restaurantId]
  if not restaurant or not restaurant.offlineShop then
    return
  end
  
  if action == "spawn" then
    -- Only spawn if player is inside restaurant
    if not playerInsideRestaurant then
      return
    end
    
    -- Check if restaurant is online
    local isOnline = lib.callback.await("mt-restaurants:server:checkRestaurantOnline", false, restaurantId)
    
    -- If no employees are online, spawn the shop ped
    if not isOnline then
        for shopIndex, shopData in pairs(restaurant.offlineShop) do
          if not offlineShopPeds[shopIndex] then
            -- Create the shop ped
            offlineShopPeds[shopIndex] = createPed(
              shopData.coords,
              shopData.model,
              { scenario = shopData.scenario }
            )
            
            -- Create target options
            local targetOptions = {
              {
                distance = 2.5,
                label = locale("target_shop", shopData.label),
                icon = locale("target_shop_icon"),
                onSelect = function()
                  openOfflineShop(
                    "restaurants_offline_shop_" .. restaurantId,
                    shopData.label,
                    restaurantId
                  )
                end
              }
            }
            
            -- Add entity target
            createEntityTarget(
              offlineShopPeds[shopIndex],
              targetOptions,
              2.5,
              "restaurants_offline_shop_" .. shopIndex
            )
          end
        end
    end
  else
    -- Delete all offline shop peds
    for shopIndex, shopData in pairs(restaurant.offlineShop) do
      if offlineShopPeds[shopIndex] then
        DeletePed(offlineShopPeds[shopIndex])
        DeleteEntity(offlineShopPeds[shopIndex])
        offlineShopPeds[shopIndex] = nil
      end
    end
  end
end

-- Register event to update spawned shop peds
RegisterNetEvent("mt-restaurants:client:updateSpawnedShopPeds", function(restaurantId, action)
  updateOfflineShop(restaurantId, action)
end)