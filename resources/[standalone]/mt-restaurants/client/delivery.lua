-- Delivery system variables
local currentOrder = nil
local deliveryLocation = nil
local hasActiveOrder = false
local deliveryBlip = nil
local deliveryPed = nil
local isDelivering = false

-- Function to take a delivery order
function takeOrder(restaurantId, deliveryId)
  -- [NEW] Vehicle Check
  if Config.DeliverySettings.requireVehicle then
    if not IsPedInAnyVehicle(cache.ped, false) then
        notify("You need a vehicle to start deliveries!", "error")
        return
    end
  end

  -- Check if can start delivery
  local canStart = lib.callback.await("mt-restaurants:server:canStartDelivery", false, restaurantId)
  
  if hasActiveOrder and not canStart then
    notify(locale("notify_cant_start_delivery"), "error")
    return
  end
  
  -- Get available recipes
  local recipes = lib.callback.await("mt-restaurants:server:getRecipes", false, restaurantId)
  
  if not recipes or #recipes < 1 then
    notify(locale("notify_no_recipes_created"), "error")
    return
  end
  
  -- Filter only active recipes
  for recipeId, recipe in pairs(recipes) do
    if recipe.active ~= 1 and recipe.active ~= true then
      recipes[recipeId] = nil
    end
  end
  
  if not recipes or #recipes < 1 then
    notify(locale("notify_no_recipes_created"), "error")
    return
  end
  
  -- Show progress bar for taking order with phone animation
  local success = progressBar(
    locale("progress_taking_order"),
    Config.times.takeOrder,
    {
      car = true,
      move = true
    },
    {
      dict = "cellphone@",
      clip = "cellphone_call_listen_base"
    },
    {
      model = "vw_prop_casino_phone_01b_handle",
      pos = vec3(-0.007, -0.01, -0.03),
      rot = vec3(-92.7, 28.22, -49.0),
      bone = 28422
    }
  )
  
  if success then
    hasActiveOrder = true
    
    -- Set cooldown state on server
    lib.callback.await("mt-restaurants:server:setCooldownState", false, restaurantId, deliveryId)
    
    -- Select random recipe
    local randomRecipe = recipes[math.random(1, #recipes)]
    currentOrder = randomRecipe
    
    -- Set random amount (1-3)
    currentOrder.amount = math.random(1, 3)
    
    -- [NEW] Register on KDS and get ID
    local orderId = lib.callback.await('mt-restaurants:server:startDeliveryOrder', false, restaurantId, currentOrder)
    currentOrder.orderId = orderId -- Save this so we can remove it later

    -- Select random delivery location
    deliveryLocation = Config.deliveryLocations[math.random(1, #Config.deliveryLocations)]
    
    -- Calculate delivery price with loss percentage
    local totalPrice = currentOrder.price * currentOrder.amount
    local priceLoss = totalPrice * (Config.restaurants[restaurantId].delivery[deliveryId].priceLost / 100)
    currentOrder.price = tonumber(math.floor(totalPrice - priceLoss))
    
    -- Show order details dialog
    local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z))
    
    lib.alertDialog({
      header = locale("alert_order_details"),
      content = locale(
        "alert_order_details_desc",
        currentOrder.amount,
        currentOrder.label,
        currentOrder.price,
        streetName
      ),
      centered = true,
      cancel = false
    })
    
    -- Create delivery blip with route
    deliveryBlip = createBlip(
      vec3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z),
      409,
      4,
      0.6,
      5,
      locale("blip_delivery_customer")
    )
    
    SetBlipRoute(deliveryBlip, true)
    SetBlipRouteColour(deliveryBlip, 5)
    
    -- Create customer ped at delivery location
    deliveryPed = createPed(
      deliveryLocation,
      Config.peds[math.random(1, #Config.peds)],
      {
        dict = "random@shop_tattoo",
        clip = "_idle_a"
      }
    )
    
    -- Create target for delivery ped
    local targetOptions = {{
      label = locale("target_delivery_order"),
      icon = locale("target_delivery_order_icon"),
      onSelect = function()
        deliveryOrder(restaurantId, deliveryId)
      end,
      action = function()
        deliveryOrder(restaurantId, deliveryId)
      end,
      canInteract = function()
        return getPlayerJob() == restaurantId and hasActiveOrder and not isDelivering
      end
    }}
    
    createEntityTarget(
      deliveryPed,
      targetOptions,
      2.5,
      "delivery_ped_" .. restaurantId
    )
  end
end

-- Function to deliver the order to customer
function deliveryOrder(restaurantId, deliveryId)
  if isDelivering then return end
  isDelivering = true
  
  -- Check if can deliver order (Has items)
  local canDeliver = lib.callback.await("mt-restaurants:server:canDeliveryOrder", false, restaurantId, currentOrder)
  
  if canDeliver then
    
    -- Skill Check for Tip
    local earnedTip = false
    if Config.DeliverySettings.tips.enabled then
        earnedTip = lib.skillCheck(Config.DeliverySettings.skillCheck, {'e'})
    end

    -- Remove delivery blip
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
        deliveryBlip = nil
    end
    
    -- Clear ped tasks and start delivery animation
    ClearPedTasks(deliveryPed)
    loadAnimDict("mp_common")
    
    -- Customer receives animation
    TaskPlayAnim(deliveryPed, "mp_common", "givetake1_b", 8.0, 8.0, -1, 1, 0.0, false, false, false)
    
    -- Player gives animation
    TaskPlayAnim(cache.ped, "mp_common", "givetake1_a", 8.0, 8.0, -1, 1, 0.0, false, false, false)
    
    -- Wait based on order amount
    Wait(currentOrder.amount * 1000) 
    
    -- [UPDATED] Attempt to complete delivery on server
    local success = lib.callback.await("mt-restaurants:server:makeDelivery", false, restaurantId, deliveryId, currentOrder, earnedTip, currentOrder.orderId)
    
    -- Clear animations
    ClearPedTasks(cache.ped)
    ClearPedTasks(deliveryPed)
    
    StopAnimTask(deliveryPed, "mp_common", "givetake1_b", 0.0)
    StopAnimTask(cache.ped, "mp_common", "givetake1_a", 0.0)
    RemoveAnimDict("mp_common")
    
    if success then
        -- Visual Feedback
        if earnedTip then
            notify("Great service! You got a tip!", "success")
        else
            notify("Delivery completed.", "success")
        end

        -- Clean up after delay
        Wait(5000)
        if deliveryPed then DeleteEntity(deliveryPed) end
        
        -- Reset delivery state
        deliveryPed = nil
        deliveryLocation = nil
        currentOrder = nil
    else
        -- Server failed to remove items (Cheating? Or dropped items during anim?)
        notify("Could not hand over items. Do you still have them?", "error")
        
        -- Restore Blip so they can try again
        if not deliveryBlip and deliveryLocation then
             deliveryBlip = createBlip(
              vec3(deliveryLocation.x, deliveryLocation.y, deliveryLocation.z),
              409, 4, 0.6, 5, locale("blip_delivery_customer")
            )
            SetBlipRoute(deliveryBlip, true)
        end
    end
  else
    notify(locale("notify_cant_deliver"), "error")
  end
  
  isDelivering = false
end