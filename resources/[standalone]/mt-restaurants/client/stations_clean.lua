-- mt-restaurants/client/stations_clean.lua

function haveStation(stationId, stationsList)
  for _, station in pairs(stationsList) do
    if station == stationId then return true end
  end
  return false
end

function openStation(restaurantId, stationIndex)
  local stationId = "station_" .. restaurantId .. "_" .. stationIndex
  
  if Config.inventory == "ox_inventory" and Config.useOxInventoryCraft then
      exports.ox_inventory:openInventory("crafting", { id = stationId })
      return
  end
  
  local menu = {
    id = stationId,
    title = Config.restaurants[restaurantId].stations[stationIndex].label,
    options = {}
  }
  
  local recipes = lib.callback.await("mt-restaurants:server:getRecipes", false, restaurantId)
  
  -- NEW: Check if station draws from a stash (Prepped/Fridge)
  local stationInfo = Config.restaurants[restaurantId].stations[stationIndex]
  local stashCounts = {}
  
  if stationInfo and stationInfo.drawsFrom then
      -- Get counts from the stash (e.g., "Prepped Ingredients")
      stashCounts = lib.callback.await('mt-restaurants:server:getStationIngredientCounts', false, restaurantId, stationInfo.drawsFrom)
  end

  if recipes and #recipes >= 1 then
    for recipeId, recipe in pairs(recipes) do
      if tonumber(recipe.active) == 1 then
        if haveStation(stationId, json.decode(recipe.stations)) then
          local ingredientDescription = ""
          local isDisabled = true
          local availableCount = 0
          local neededItems = {}
          local ingredientData = {}
          local totalCalories = 0
          local customBuffs = {}
          
          for ingredientName, ingredientAmount in pairs(json.decode(recipe.ingredients)) do
            if ingredientName ~= "no_ingredient" then
              local ingredientItemData = itemData(tostring(ingredientName))
              if not ingredientItemData then
                lib.print.error("Item " .. tostring(ingredientName) .. " missing in items.lua!")
              else
                neededItems[#neededItems + 1] = {
                  item = tostring(ingredientName),
                  count = tonumber(ingredientAmount)
                }
                
                for _, restaurantIngredient in pairs(Config.restaurants[restaurantId].ingredients) do
                  if restaurantIngredient.item == ingredientName then
                    totalCalories = totalCalories + (restaurantIngredient.calories * ingredientAmount)
                    if restaurantIngredient.customBuffs then
                        for buffName, buffValue in pairs(restaurantIngredient.customBuffs) do
                            customBuffs[buffName] = (customBuffs[buffName] or 0) + (buffValue * ingredientAmount)
                        end
                    end
                  end
                end
                
                ingredientData[ingredientName] = ingredientAmount
              end
            end
          end
          
          for _, neededItem in pairs(neededItems) do
            local neededItemData = itemData(tostring(neededItem.item))
            if neededItemData then
              -- NEW: Calculate Total (Pocket + Stash)
              local playerHas = getItemCount(tostring(neededItem.item))
              local stashHas = stashCounts[neededItem.item] or 0
              local totalHas = playerHas + stashHas
              
              local requiredCount = tonumber(neededItem.count)
              
              if totalHas >= requiredCount then
                ingredientDescription = ingredientDescription .. locale("menu_prepare_needed_item_format_check", neededItemData.label, requiredCount)
                availableCount = availableCount + 1
              else
                ingredientDescription = ingredientDescription .. locale("menu_prepare_needed_item_format_error", neededItemData.label, requiredCount)
              end
            end
          end
          
          if availableCount == #neededItems then isDisabled = false end
          
          menu.options[#menu.options + 1] = {
            disabled = isDisabled,
            title = locale("menu_prepare_title", recipe.label),
            description = ingredientDescription,
            icon = recipe.image_url,
            onSelect = function()
              prepareItemStation(
                restaurantId, stationIndex, Config.restaurants[restaurantId].stations[stationIndex].label,
                Config.restaurants[restaurantId].stations[stationIndex].anim,
                "restaurant_food",
                {
                  imageurl = recipe.image_url, label = recipe.label, description = recipe.description,
                  calories = totalCalories, restaurant = Config.restaurants[restaurantId].label,
                  animation = recipe.animation, type = recipe.type, price = recipe.price, customBuffs = customBuffs
                },
                ingredientData
              )
            end
          }
        end
      end
    end
  end
  
  if menu.options and #menu.options >= 1 then
    lib.registerContext(menu)
    lib.showContext(menu.id)
  else
    notify(locale("notify_error_no_recipes_station"), "error")
  end
end

function prepareItemStation(restaurantId, stationIndex, stationLabel, animation, itemName, itemData, ingredientData)
  local input = lib.inputDialog(stationLabel, {
    { type = "slider", label = locale("input_prepare_quantity"), required = true, min = 1, max = Config.maxPreparesPerTime }
  })
  
  if input then
    local quantity = input[1]
    local stationInfo = Config.restaurants[restaurantId].stations[stationIndex]

    for i = 1, quantity do
      local canCraft = lib.callback.await("mt-restaurants:server:canCraftItem", false, ingredientData, stationInfo)
      if not canCraft then notify(locale("notify_error_no_needed_items"), "error") break end
      
      local success = progressBar(locale("progress_preparing_ingredient", itemData.label), Config.times.makeFood, { car = true, move = true }, animation, {})
      if success then
        lib.callback.await("mt-restaurants:server:craftItem", false, itemName, 1, ingredientData, itemData, stationInfo)
      else
        return openStation(restaurantId, stationIndex)
      end
    end
  end
  return openStation(restaurantId, stationIndex)
end