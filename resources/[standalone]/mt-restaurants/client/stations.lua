-- Function to check if a station is available for a recipe
function haveStation(stationId, stationsList)
  for _, station in pairs(stationsList) do
    if station == stationId then
      return true
    end
  end
  return false
end

-- Function to open cooking station menu
function openStation(restaurantId, stationIndex)
  local stationId = "station_" .. restaurantId .. "_" .. stationIndex
  
  -- Use ox_inventory crafting if configured
  if Config.inventory == "ox_inventory" then
    if Config.useOxInventoryCraft then
      exports.ox_inventory:openInventory("crafting", { id = stationId })
      return
    end
  end
  
  -- Build custom station menu
  local menu = {
    id = stationId,
    title = Config.restaurants[restaurantId].stations[stationIndex].label,
    options = {}
  }
  
  -- Get recipes for this restaurant
  local recipes = lib.callback.await("mt-restaurants:server:getRecipes", false, restaurantId)
  
  if recipes and #recipes >= 1 then
    -- Process each recipe
    for recipeId, recipe in pairs(recipes) do
      if tonumber(recipe.active) == 1 then
        -- Check if this recipe can be made at this station
        if haveStation(stationId, json.decode(recipe.stations)) then
          local ingredientDescription = ""
          local isDisabled = true
          local availableCount = 0
          local neededItems = {}
          local ingredientData = {}
          local totalCalories = 0
          local customBuffs = {}
          
          -- Process recipe ingredients
          for ingredientName, ingredientAmount in pairs(json.decode(recipe.ingredients)) do
            if ingredientName ~= "no_ingredient" then
              local ingredientItemData = itemData(tostring(ingredientName))
              if not ingredientItemData then
                lib.print.error("The item " .. tostring(ingredientName) .. " is missing on your inventory items.lua!!")
                lib.print.error("The recipe " .. recipe.label .. " recipe have some items that are not added to the inventory items.lua!!")
              else
                neededItems[#neededItems + 1] = {
                  item = tostring(ingredientName),
                  count = tonumber(ingredientAmount)
                }
                
                -- Calculate calories and buffs from restaurant ingredients config
                for _, restaurantIngredient in pairs(Config.restaurants[restaurantId].ingredients) do
                  if restaurantIngredient.item == ingredientName then
                    totalCalories = totalCalories + (restaurantIngredient.calories * ingredientAmount)
                    if restaurantIngredient.customBuffs then
                      for buffName, buffValue in pairs(restaurantIngredient.customBuffs) do
                        if customBuffs[buffName] ~= nil then
                          customBuffs[buffName] = customBuffs[buffName] + (buffValue * ingredientAmount)
                        else
                          customBuffs[buffName] = buffValue * ingredientAmount
                        end
                      end
                    end
                  end
                end
                
                ingredientData[ingredientName] = ingredientAmount
              end
            end
          end
          
          -- Check availability of needed items
          for _, neededItem in pairs(neededItems) do
            local neededItemData = itemData(tostring(neededItem.item))
            if neededItemData then
              local playerItemCount = getItemCount(tostring(neededItem.item))
              local requiredCount = tonumber(neededItem.count)
              
              if playerItemCount >= requiredCount then
                ingredientDescription = ingredientDescription .. locale("menu_prepare_needed_item_format_check", 
                  neededItemData.label, requiredCount)
                availableCount = availableCount + 1
              else
                ingredientDescription = ingredientDescription .. locale("menu_prepare_needed_item_format_error", 
                  neededItemData.label, requiredCount)
              end
            else
              if Config.debug then
                print("^1Needed item: " .. tostring(neededItem.item) .. " is not created!")
              end
            end
          end
          
          -- Enable recipe if all ingredients are available
          if availableCount == #neededItems then
            isDisabled = false
          end
          
          -- Add recipe option to menu
          menu.options[#menu.options + 1] = {
            disabled = isDisabled,
            title = locale("menu_prepare_title", recipe.label),
            description = ingredientDescription,
            icon = recipe.image_url,
            onSelect = function()
              prepareItemStation(
                restaurantId, 
                stationIndex, 
                Config.restaurants[restaurantId].stations[stationIndex].label,
                Config.restaurants[restaurantId].stations[stationIndex].anim,
                "restaurant_food",
                {
                  imageurl = recipe.image_url,
                  label = recipe.label,
                  description = recipe.description,
                  calories = totalCalories,
                  restaurant = Config.restaurants[restaurantId].label,
                  animation = recipe.animation,
                  type = recipe.type,
                  price = recipe.price,
                  customBuffs = customBuffs
                },
                ingredientData
              )
            end
          }
        end
      end
    end
  end
  
  -- Show menu if there are options available
  if menu.options and #menu.options >= 1 then
    lib.registerContext(menu)
    lib.showContext(menu.id)
  else
    notify(locale("notify_error_no_recipes_station"), "error")
  end
end

-- Prepare item at station with quantity selection
local function prepareItemStation(restaurantId, stationIndex, stationLabel, stationAnim, itemName, itemData, ingredientData)
  local input = lib.inputDialog(stationLabel, {
    {
      type = "slider",
      label = locale("input_prepare_quantity"),
      required = true,
      min = 1,
      max = Config.maxPreparesPerTime,
      default = 1
    }
  })
  
  if input then
    local quantity = input[1]
    
    -- Craft items one by one
    for i = 1, quantity do
      -- Check if player can still craft this item
      local canCraft = lib.callback.await("mt-restaurants:server:canCraftItem", false, ingredientData)
      if not canCraft then
        break
      end
      
      -- Show progress bar for crafting
      local success = progressBar(
        locale("progress_preparing_ingredient", itemData.label),
        Config.times.makeFood,
        {
          canCancel = true,
          disable = {
            car = true,
            move = true
          }
        },
        stationAnim,
        {}
      )
      
      if success then
        -- Craft the item on server
        lib.callback.await("mt-restaurants:server:craftItem", false, itemName, 1, ingredientData, itemData)
      else
        -- Player cancelled, return to station menu
        return openStation(restaurantId, stationIndex)
      end
    end
  end
end
