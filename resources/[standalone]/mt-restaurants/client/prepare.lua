-- mt-restaurants/client/prepare.lua

function openPrepare(stationId, recipes, title, animation)
  if Config.inventory == "ox_inventory" and Config.useOxInventoryCraft then
      exports.ox_inventory:openInventory("crafting", { id = stationId })
      return
  end
  
  local menu = { id = stationId, title = title, options = {} }

  -- NEW: Parse Station ID to get Info (restaurants_prepare_JOB_INDEX)
  local parts = {}
  for part in string.gmatch(stationId, "[^_]+") do table.insert(parts, part) end
  local job = parts[3]
  local index = tonumber(parts[4])
  
  -- NEW: Get Stash Counts (Fridge)
  local stashCounts = {}
  local stationInfo = nil
  if job and index and Config.restaurants[job] and Config.restaurants[job].prepare then
      stationInfo = Config.restaurants[job].prepare[index]
      if stationInfo and stationInfo.drawsFrom then
          stashCounts = lib.callback.await('mt-restaurants:server:getStationIngredientCounts', false, job, stationInfo.drawsFrom)
      end
  end

  for recipeIndex, recipe in pairs(recipes) do
    if recipe.needCut then
      local ingredientDescription = ""
      local isDisabled = true
      local availableCount = 0
      local neededItems = {}
      
      local recipeItemData = itemData(tostring(recipe.item))
      if recipeItemData then
        for itemName, itemCount in pairs(recipe.neededItems) do
          neededItems[#neededItems + 1] = { item = tostring(itemName), count = tonumber(itemCount) }
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
          title = locale("menu_prepare_title", recipeItemData.label),
          description = ingredientDescription,
          icon = string.format(Config.imagesDirectory, recipe.item),
          onSelect = function()
            prepareItem(stationId, recipes, title, animation, recipe.item, recipe.count, recipe.neededItems)
          end
        }
      end
    end
  end
  lib.registerContext(menu)
  lib.showContext(menu.id)
end

function prepareItem(stationId, recipes, title, animation, itemName, itemCount, neededItems)
  local input = lib.inputDialog(title, {
    { type = "number", label = locale("input_prepare_quantity"), required = true, min = 1, max = Config.maxPreparesPerTime }
  })
  
  if input then
    local quantity = input[1]
    
    local parts = {}
    for part in string.gmatch(stationId, "[^_]+") do table.insert(parts, part) end
    local job = parts[3]
    local index = tonumber(parts[4])

    local stationInfo = nil
    if job and index and Config.restaurants[job] and Config.restaurants[job].prepare then
        stationInfo = Config.restaurants[job].prepare[index]
    end
    
    for i = 1, quantity do
      local canCraft = lib.callback.await("mt-restaurants:server:canCraftItem", false, neededItems, stationInfo)
      if not canCraft then notify(locale("notify_error_no_needed_items"), "error") break end
      
      local success = progressBar(locale("progress_preparing_ingredient", itemData(itemName).label), Config.times.preparing, { car = true, move = true }, animation, {})
      if success then
        lib.callback.await("mt-restaurants:server:craftItem", false, itemName, itemCount, neededItems, nil, stationInfo)
      else
        return openPrepare(stationId, recipes, title, animation)
      end
    end
  end
  
  openPrepare(stationId, recipes, title, animation)
end