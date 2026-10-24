-- Initialize locale
lib.locale()

-- Register notification event
RegisterNetEvent("mt-restaurants:client:notify", notify)

-- Main function to create restaurants
local function createRestaurants()
  -- Setup inventory metadata display for ox_inventory
  if Config.inventory == "ox_inventory" then
    exports.ox_inventory:displayMetadata({
      calories = locale("inventory_metadata_calories"),
      restaurant = locale("inventory_metadata_restaurant")
    })
  end
  -- Iterate through all restaurants
  for restaurantId, restaurant in pairs(Config.restaurants) do
    if restaurant.enabled then
      -- Create blip if enabled
      if restaurant.blip and restaurant.blip.enabled then
        createBlip(
          restaurant.blip.coords,
          restaurant.blip.sprite,
          restaurant.blip.display,
          restaurant.blip.scale,
          restaurant.blip.color,
          restaurant.label
        )
      end
      -- Create restaurant zone
      lib.zones.poly({
        points = restaurant.zone.points,
        thickness = restaurant.zone.thickness,
        debug = Config.debug,
        onEnter = function()
          onZoneEnter(restaurant.job, restaurantId)
        end,
        onExit = function()
          onZoneExit(restaurant.job, restaurantId)
        end
      })
      -- Create management targets
      if restaurant.management then
        for managementId, management in pairs(restaurant.management) do
          local options = {{
            distance = 2.5,
            label = locale("target_management"),
            icon = locale("target_management_icon"),
            onSelect = function()
              openManagement(restaurant.job)
            end,
            action = function()
              openManagement(restaurant.job)
            end,
            canInteract = function()
              return getPlayerJob() == restaurant.job
            end
          }}
          createSphereZoneTarget(
            management.coords,
            management.radius,
            options,
            2.5,
            "management_target_" .. restaurantId .. "_" .. managementId
          )
        end
      end
      -- Create stash targets
      if restaurant.stashes then
        for stashId, stash in pairs(restaurant.stashes) do
          local options = {{
            distance = 2.5,
            label = locale("target_stashes", stash.label),
            icon = locale("target_stashes_icon"),
            onSelect = function()
              openStash(
                "restaurants_stash_" .. restaurantId .. "_" .. stashId,
                stash.label,
                stash.slots,
                stash.weight
              )
            end,
            action = function()
              openStash(
                "restaurants_stash_" .. restaurantId .. "_" .. stashId,
                stash.label,
                stash.slots,
                stash.weight
              )
            end,
            canInteract = function()
              return getPlayerJob() == restaurant.job
            end
          }}
          createSphereZoneTarget(
            stash.coords,
            stash.radius,
            options,
            2.5,
            "stash_target_" .. restaurantId .. "_" .. stashId
          )
        end
      end
      -- Create tray targets
      if restaurant.trays then
        for trayId, tray in pairs(restaurant.trays) do
          local options = {{
            distance = 2.5,
            label = locale("target_trays", tray.label),
            icon = locale("target_trays_icon"),
            onSelect = function()
              openStash(
                "restaurants_trays_" .. restaurantId .. "_" .. trayId,
                tray.label,
                tray.slots,
                tray.weight
              )
            end,
            action = function()
              openStash(
                "restaurants_trays_" .. restaurantId .. "_" .. trayId,
                tray.label,
                tray.slots,
                tray.weight
              )
            end
          }}
          createSphereZoneTarget(
            tray.coords,
            tray.radius,
            options,
            2.5,
            "tray_target_" .. restaurantId .. "_" .. trayId
          )
          -- Create prop if specified
          if tray.prop then
            createProp(
              tray.prop,
              tray.coords,
              tray.propHeading or 0.0
            )
          end
        end
      end
      -- Create prepare targets
      if restaurant.prepare then
        for prepareId, prepare in pairs(restaurant.prepare) do
          -- Find this section in client/main.lua (inside the restaurant.prepare loop)
          local options = {{
            distance = 2.5,
            label = locale("target_prepare", prepare.label),
            icon = locale("target_prepare_icon"),
            
            -- FIXED: Added missing arguments (ingredients, label, anim)
            onSelect = function()
              openPrepare(
                  "restaurants_prepare_" .. restaurant.job .. "_" .. prepareId, 
                  prepare.ingredients, 
                  prepare.label, 
                  prepare.anim
              )
            end,
            action = function()
              openPrepare(
                  "restaurants_prepare_" .. restaurant.job .. "_" .. prepareId, 
                  prepare.ingredients, 
                  prepare.label, 
                  prepare.anim
              )
            end,
            
            canInteract = function()
              return getPlayerJob() == restaurant.job
            end
          }}
          createSphereZoneTarget(
            prepare.coords,
            prepare.radius,
            options,
            2.5,
            "prepare_target_" .. restaurantId .. "_" .. prepareId
          )
          -- Create prop if specified
          if prepare.prop then
            createProp(
              prepare.prop,
              prepare.coords,
              prepare.propHeading or 0.0
            )
          end
        end
      end
      -- Create station targets
      if restaurant.stations then
        for stationId, station in pairs(restaurant.stations) do
          local options = {{
            distance = 2.5,
            label = locale("target_station", station.label),
            icon = locale("target_station_icon"),
            onSelect = function()
              openStation(restaurant.job, stationId)
            end,
            action = function()
              openStation(restaurant.job, stationId)
            end,
            canInteract = function()
              return getPlayerJob() == restaurant.job
            end
          }}
          createSphereZoneTarget(
            station.coords,
            station.radius,
            options,
            2.5,
            "station_target_" .. restaurantId .. "_" .. stationId
          )
        end
      end
      -- Create register targets
      if restaurant.registers then
        for registerId, register in pairs(restaurant.registers) do
          local options = {{
            distance = 2.5,
            label = locale("target_register", register.label),
            icon = locale("target_register_icon"),
            onSelect = function()
              openRegisterMenu(restaurant.job, registerId)
            end,
            action = function()
              openRegisterMenu(restaurant.job, registerId)
            end,
            canInteract = function()
              return getPlayerJob() == restaurant.job
            end
          }}
          createSphereZoneTarget(
            register.coords,
            register.radius,
            options,
            2.5,
            "register_target_" .. restaurantId .. "_" .. registerId
          )
          -- Create prop if specified
          if register.prop then
            createProp(
              register.prop,
              register.coords,
              register.propHeading or 0.0
            )
          end
        end
      end
      -- Create menu targets
      if restaurant.menus then
        for menuId, menu in pairs(restaurant.menus) do
          local options = {{
            distance = 2.5,
            label = locale("target_menu", menu.label),
            icon = locale("target_menu_icon"),
            onSelect = function()
              takeMenu(restaurant.job)
            end,
            action = function()
              takeMenu(restaurant.job)
            end
          }}
          createSphereZoneTarget(
            menu.coords,
            menu.radius,
            options,
            2.5,
            "menu_target_" .. restaurantId .. "_" .. menuId
          )
        end
      end
      -- Create music targets
      if restaurant.music then
        for musicId, music in pairs(restaurant.music) do
          local musicName = "restaurant_music_" .. restaurant.job .. "_" .. musicId
          local options = {}
          
          -- Play song option
          local playOption = {
            distance = 2.5,
            label = locale("target_music_play_song"),
            icon = locale("target_music_play_song_icon"),
            onSelect = function()
              playSong(musicName, restaurant.job, musicId, music.coords)
            end,
            action = function()
              playSong(musicName, restaurant.job, musicId, music.coords)
            end,
            canInteract = function()
              return getPlayerJob() == restaurant.job
            end
          }
          
          -- Stop song option
          local stopOption = {
            distance = 2.5,
            label = locale("target_music_stop_song"),
            icon = locale("target_music_stop_song_icon"),
            onSelect = function()
              stopSong(musicName)
            end,
            action = function()
              stopSong(musicName)
            end,
            canInteract = function()
              return getPlayerJob() == restaurant.job and exports.xsound:soundExists(musicName)
            end
          }
          
          -- Change song status option
          local changeStatusOption = {
            distance = 2.5,
            label = locale("target_music_change_song_status"),
            icon = locale("target_music_change_song_status_icon"),
            onSelect = function()
              changeSongStatus(musicName, restaurant.job, musicId)
            end,
            action = function()
              changeSongStatus(musicName, restaurant.job, musicId)
            end,
            canInteract = function()
              return getPlayerJob() == restaurant.job and exports.xsound:soundExists(musicName)
            end
          }
          
          options[1] = playOption
          options[2] = stopOption
          options[3] = changeStatusOption
          
          createSphereZoneTarget(
            music.coords,
            music.radius,
            options,
            2.5,
            "music_target_" .. restaurantId .. "_" .. musicId
          )
          
          -- Create prop if specified
          if music.prop then
            createProp(
              music.prop,
              music.coords,
              music.propHeading or 0.0
            )
          end
        end
      end
      -- Create garage targets
      if restaurant.garage then
        for garageId, garage in pairs(restaurant.garage) do
          local options = {{
            distance = 2.5,
            label = locale("target_garage"),
            icon = locale("target_garage_icon"),
            onSelect = function()
              openGarage(restaurant.job, garageId)
            end,
            action = function()
              openGarage(restaurant.job, garageId)
            end,
            canInteract = function()
              return getPlayerJob() == restaurant.job
            end
          }}
          
          -- Create garage prop
          loadModel("prop_park_ticket_01")
          local garageObject = CreateObject(
            GetHashKey("prop_park_ticket_01"),
            garage.coords.x,
            garage.coords.y,
            garage.coords.z,
            false,
            false,
            false
          )
          SetEntityHeading(garageObject, garage.coords.w)
          FreezeEntityPosition(garageObject, true)
          
          createEntityTarget(
            garageObject,
            options,
            2.5,
            "garage_shop_" .. restaurant.job .. "_" .. garageId
          )
        end
      end
      -- Create box targets
      if restaurant.boxes then
        for boxId, box in pairs(restaurant.boxes) do
          local options = {{
            distance = 2.5,
            label = locale("target_take_box"),
            icon = locale("target_take_box_icon"),
            onSelect = function()
              takeBox(restaurant.job)
            end,
            action = function()
              takeBox(restaurant.job)
            end,
            canInteract = function()
              return getPlayerJob() == restaurant.job
            end
          }}
          createSphereZoneTarget(
            box.coords,
            box.radius,
            options,
            2.5,
            "box_target_" .. restaurantId .. "_" .. boxId
          )
        end
      end
      -- Create peds
      if restaurant.peds then
        for pedId, ped in pairs(restaurant.peds) do
          createPed(ped.coords, ped.model, ped.anim)
        end
      end
      -- Create delivery targets
      if restaurant.delivery then
        for deliveryId, delivery in pairs(restaurant.delivery) do
          local options = {{
            distance = 2.5,
            label = locale("target_ask_delivery"),
            icon = locale("target_ask_delivery_icon"),
            onSelect = function()
              takeOrder(restaurant.job, deliveryId)
            end,
            action = function()
              takeOrder(restaurant.job, deliveryId)
            end,
            canInteract = function()
              return getPlayerJob() == restaurant.job
            end
          }}
          createSphereZoneTarget(
            delivery.coords,
            delivery.radius,
            options,
            2.5,
            "delivery_target_" .. restaurantId .. "_" .. deliveryId
          )
          -- Create prop if specified
          if delivery.prop then
            createProp(
              delivery.prop,
              delivery.coords,
              delivery.propHeading or 0.0
            )
          end
        end
      end
      -- Create drive-thru points
      if restaurant.drivethru then
        for driveThruId, driveThru in pairs(restaurant.drivethru) do
          -- Drive-thru entrance point
          lib.points.new({
            coords = driveThru.inCoords,
            distance = driveThru.inRadius,
            onEnter = function()
              enteredInDriveThru(restaurant.job, driveThruId, restaurant.driveThruId)
            end,
            onExit = function()
              exitInDriveThru(restaurant.job, driveThruId, restaurant.driveThruId)
            end
          })
          
          -- Drive-thru exit point
          lib.points.new({
            coords = driveThru.outCoords,
            distance = driveThru.outRadius,
            onEnter = function()
              enteredOutDriveThru(restaurant.job, driveThruId, restaurant.driveThruId)
            end,
            onExit = function()
              exitOutDriveThru(restaurant.job, driveThruId, restaurant.driveThruId)
            end
          })
        end
      end
      -- Create chair targets
      if restaurant.chairs then
        for chairId, chair in pairs(restaurant.chairs) do
          local options = {{
            distance = 2.5,
            label = locale("target_sit"),
            icon = locale("target_sit_icon"),
            onSelect = function()
              sitChair(chair, "chair_target_" .. restaurantId .. "_" .. chairId)
            end,
            action = function()
              sitChair(chair, "chair_target_" .. restaurantId .. "_" .. chairId)
            end
          }}
          createSphereZoneTarget(
            chair,
            0.4,
            options,
            2.5,
            "chair_target_" .. restaurantId .. "_" .. chairId
          )
        end
      end
    end
  end
  
  -- Create ingredient shops
  for shopId, shop in pairs(Config.shops) do
    if shop.enabled then
      -- Create shop blip
      createBlip(
        vec3(shop.ped.coords.x, shop.ped.coords.y, shop.ped.coords.z),
        shop.blip.sprite,
        shop.blip.display,
        shop.blip.scale,
        shop.blip.color,
        shop.label
      )
      
      -- Create shop ped
      local shopPed = createPed(
        shop.ped.coords,
        shop.ped.model,
        { scenario = shop.ped.scenario }
      )
      
      -- Create shop target
      local options = {{
        distance = 2.5,
        label = locale("target_shop", shop.label),
        icon = locale("target_shop_icon"),
        onSelect = function()
          openShop("ingredients_shop_" .. shopId, shop.label, shop.items)
        end,
        action = function()
          openShop("ingredients_shop_" .. shopId, shop.label, shop.items)
        end
      }}
      
      createEntityTarget(
        shopPed,
        options,
        2.5,
        "ingredients_shop_" .. shopId
      )
    end
  end
end

-- Initialize restaurants on thread
CreateThread(createRestaurants)

-- =====================================================
-- KITCHEN DISPLAY SYSTEM (KDS) - NUI UPDATER
-- =====================================================

RegisterNetEvent('mt-restaurants:client:syncOrders')
AddEventHandler('mt-restaurants:client:syncOrders', function(jobName, newOrders)
    local myJob = getPlayerJob()
    
    -- Only show if it's my job
    if myJob == jobName then
        
        -- Send data to NUI
        SendNUIMessage({
            action = "updateKDS",
            orders = newOrders
        })
    else
        -- If I switched jobs or it's not for me, clear KDS
        SendNUIMessage({
            action = "updateKDS",
            orders = {}
        })
    end
end)

-- Ensure KDS clears on restart
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    Wait(1000) -- Small wait to ensure NUI is loaded
    SendNUIMessage({ action = "updateKDS", orders = {} })
end)

-- Specific event for "Order Ready" to prevent global broadcast
RegisterNetEvent('mt-restaurants:client:orderReadyAlert', function(restaurantJob, orderId)
    local myJob = getPlayerJob()
    
    -- Only notify if I work at this specific restaurant
    if myJob == restaurantJob then
        -- Play "Ding" Sound
        PlaySoundFrontend(-1, "Hack_Success", "DLC_HEIST_BIOLAB_PREP_HACKING_SOUNDS", 1)
        
        -- Show Notification
        lib.notify({
            title = 'ORDER #'..orderId..' READY!',
            description = 'Please package the order.',
            type = 'success',
            icon = 'bell'
        })
    end
end)