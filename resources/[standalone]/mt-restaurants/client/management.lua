-- mt-restaurants/client/management.lua

-- Function to open restaurant management menu
function openManagement(restaurantId)
  -- 1. Security Check
  if not isPlayerJobBoss() then 
    notify(locale("notify_error_not_boss"), "error")
    return 
  end

  -- 2. Fetch Data from Server for the Boss Menu
  local bossData = lib.callback.await('mt-restaurants:server:getBossData', false, restaurantId)
  
  if bossData then
    -- 3. Open NUI Tablet
    SendNUIMessage({
        action = "showBossMenu",
        restaurantId = restaurantId,
        societyMoney = bossData.money,
        employees = bossData.employees,
        grades = bossData.grades
    })
    SetNuiFocus(true, true)
  else
    notify(locale("notify_error_boss_data"), "error")
  end
end

-- Function to show recipes management menu (Called from NUI or Context)
function recipesMenu(restaurantId)
  local recipes = lib.callback.await("mt-restaurants:server:getRecipes", false, restaurantId)
  
  local menu = {
    title = locale("menu_management_recipes_title"),
    id = "restaurant_recipes_menu_" .. restaurantId,
    options = {}
  }
  
  -- Check if max recipes limit is reached
  local isMaxReached = false
  if Config.restaurants[restaurantId].maxRecipes then
    isMaxReached = Config.restaurants[restaurantId].maxRecipes <= #recipes
  end
  
  -- Add create new recipe option
  menu.options[#menu.options + 1] = {
    disabled = isMaxReached,
    title = locale("menu_recipes_create_title"),
    icon = locale("menu_recipes_create_icon"),
    onSelect = function()
      createOrEditRecipe(restaurantId, "create", nil)
    end
  }
  
  -- Add existing recipes to menu
  if recipes and #recipes >= 1 then
    for index, recipe in pairs(recipes) do
      -- Determine recipe type
      local recipeType = recipe.type == "food" and 
        locale("input_recipe_type_food") or 
        locale("input_recipe_type_drink")
      
      -- Build stations list
      local stationsList = ""
      local stations = json.decode(recipe.stations)
      
      for stationIndex, stationId in pairs(stations) do
        local separator = (stationIndex == #stations) and "" or ", "
        
        -- Find station name from config
        for stationConfigIndex, stationConfig in pairs(Config.restaurants[restaurantId].stations) do
          local stationKey = "station_" .. restaurantId .. "_" .. stationConfigIndex
          if stationKey == stationId then
            stationsList = stationsList .. stationConfig.label .. separator
            break
          end
        end
      end
      
      -- Determine if recipe is active
      local activeStatus = ""
      if tonumber(recipe.active) == 1 then
        activeStatus = locale("menu_recipe_active_true")
      else
        activeStatus = locale("menu_recipe_active_false")
      end
      
      -- Add recipe option to menu
      menu.options[#menu.options + 1] = {
        title = recipe.label,
        arrow = true,
        description = locale("menu_recipes_recipe_description"),
        icon = recipe.image_url,
        metadata = {
          { label = locale("menu_recipe_label"), value = recipe.label or "" },
          { label = locale("menu_recipe_description"), value = recipe.description or "" },
          { label = locale("menu_recipe_type"), value = recipeType },
          { label = locale("menu_recipe_stations"), value = stationsList },
          { label = locale("menu_recipe_price"), value = recipe.price or 0 },
          { label = locale("menu_recipe_active"), value = activeStatus }
        },
        onSelect = function()
          editRecipeMenu(restaurantId, recipe.id)
        end
      }
    end
  end
  
  -- Register and show the menu
  lib.registerContext(menu)
  lib.showContext(menu.id)
end

-- Function to show edit recipe menu for a specific recipe
function editRecipeMenu(restaurantId, recipeId)
  local recipes = lib.callback.await("mt-restaurants:server:getRecipes", false, restaurantId)
  
  if recipes and #recipes >= 1 then
    for _, recipe in pairs(recipes) do
      if recipe.id == recipeId then
        local recipeData = {
          label = recipe.label,
          description = recipe.description,
          image_url = recipe.image_url,
          animation = recipe.animation,
          type = recipe.type,
          station = json.decode(recipe.stations),
          ingredients = json.decode(recipe.ingredients),
          active = recipe.active,
          job = recipe.job,
          price = recipe.price,
          recipeId = recipeId
        }
        
        local editMenu = {
          id = "restaurant_edit_recipe_menu_" .. restaurantId .. recipeId,
          menu = "restaurant_recipes_menu_" .. restaurantId,
          title = recipe.label,
          options = {
            {
              title = locale("menu_edit_recipe_title"),
              description = locale("menu_edit_recipe_description"),
              icon = locale("menu_edit_recipe_icon"),
              onSelect = function()
                createOrEditRecipe(restaurantId, "edit", recipeData)
              end
            },
            {
              title = locale("menu_delete_recipe_title"),
              description = locale("menu_delete_recipe_description"),
              icon = locale("menu_delete_recipe_icon"),
              onSelect = function()
                deleteRecipe(restaurantId, recipeId)
              end
            }
          }
        }
        
        lib.registerContext(editMenu)
        lib.showContext("restaurant_edit_recipe_menu_" .. restaurantId .. recipeId)
        return
      end
    end
  end
end

-- ===========================
-- NUI CALLBACKS (Boss Actions)
-- ===========================

-- 1. Switch to Recipe Menu
RegisterNUICallback('openRecipeMenu', function(data, cb)
    SetNuiFocus(false, false)
    if data.restaurantId then
        recipesMenu(data.restaurantId)
    end
    cb('ok')
end)

-- 2. Handle Actions (Hire/Fire/Money)
RegisterNUICallback('bossAction', function(data, cb)
    -- Don't close focus here to allow multiple actions, except for Hire which requires target selection
    if data.action == 'hire' then
        SetNuiFocus(false, false)
        
        local nearbyPlayers = lib.getNearbyPlayers(GetEntityCoords(cache.ped), 3.0, true)
        local options = {}
        
        -- Need to fetch names separately because lib.getNearbyPlayers typically only returns IDs/coords
        local idsToFetch = {}
        for _, player in pairs(nearbyPlayers) do
            table.insert(idsToFetch, GetPlayerServerId(player.id))
        end

        local rpNames = {}
        if #idsToFetch > 0 then
            rpNames = lib.callback.await('mt-restaurants:server:getNearbyNames', false, idsToFetch)
        end

        for _, player in pairs(nearbyPlayers) do
            local sId = GetPlayerServerId(player.id)
            -- Skip self
            if sId ~= GetPlayerServerId(PlayerId()) then
                local name = rpNames[sId] or ("Player " .. sId)
                table.insert(options, {
                    label = 'Hire ' .. name .. ' (ID: '..sId..')',
                    value = sId
                })
            end
        end

        if #options > 0 then
            local input = lib.inputDialog('Hire Employee', {
                {type = 'select', label = 'Select Player', options = options}
            })
            if input and input[1] then
                TriggerServerEvent('mt-restaurants:server:performBossAction', 'hire', {
                    targetId = input[1],
                    restaurantId = data.restaurantId
                })
            end
        else
            notify("No players nearby", "error")
        end

    elseif data.action == 'bonus' then
        SetNuiFocus(false, false)
        
        local input = lib.inputDialog('Send Bonus', {
            {type = 'number', label = 'Amount', description = "Amount to send from Society to Player", required = true, min = 1}
        })
        
        if input and input[1] then
            TriggerServerEvent('mt-restaurants:server:performBossAction', 'bonus', {
                target = data.target,
                restaurantId = data.restaurantId,
                amount = input[1]
            })
            
            -- Re-open tablet
            Wait(500)
            openManagement(data.restaurantId)
        end

    elseif data.action == 'grade' then
        -- NEW: Handle Grade Change with Dialog
        SetNuiFocus(false, false)
        
        -- Get available grades for this job from server
        local jobGrades = lib.callback.await('mt-restaurants:server:getJobGrades', false, data.restaurantId)
        
        if jobGrades and #jobGrades > 0 then
            local options = {}
            for _, grade in pairs(jobGrades) do
                table.insert(options, {
                    label = grade.label .. " (Grade " .. grade.grade .. ")",
                    value = grade.grade
                })
            end
            
            -- Sort options by grade level
            table.sort(options, function(a, b) return a.value < b.value end)
            
            local input = lib.inputDialog('Promote / Demote', {
                {
                    type = 'select',
                    label = 'Select New Grade',
                    options = options,
                    required = true
                }
            })
            
            if input and input[1] then
                -- Send the selected grade to the server
                data.newGrade = input[1]
                TriggerServerEvent('mt-restaurants:server:performBossAction', 'grade', data)
                
                -- Re-open tablet after update
                Wait(500)
                openManagement(data.restaurantId)
            end
        else
            notify("Could not fetch job grades.", "error")
        end
        
    else
        -- Withdraw/Deposit/Fire/Promote
        TriggerServerEvent('mt-restaurants:server:performBossAction', data.action, data)
        
        -- Refresh UI Data
        Wait(500)
        local bossData = lib.callback.await('mt-restaurants:server:getBossData', false, data.restaurantId)
        if bossData then
            SendNUIMessage({
                action = "showBossMenu",
                restaurantId = data.restaurantId,
                societyMoney = bossData.money,
                employees = bossData.employees,
                grades = bossData.grades
            })
        end
    end
    cb('ok')
end)

-- ===========================
-- HELPER FUNCTIONS (Recipes)
-- ===========================

function validateRecipeStations(restaurantId, stations, requiredType)
  for _, stationId in pairs(stations) do
    for stationIndex, stationConfig in pairs(Config.restaurants[restaurantId].stations) do
      local stationKey = "station_" .. restaurantId .. "_" .. stationIndex
      if stationKey == stationId then
        if stationConfig.type ~= requiredType then return false end
        break
      end
    end
  end
  return true
end

function isValidStation(restaurantId, ingredients, stationType)
  for ingredientName, _ in pairs(ingredients) do
    for _, ingredient in pairs(Config.restaurants[restaurantId].ingredients) do
      if ingredient.item == ingredientName and "no_ingredient" ~= ingredientName then
        local isValid = false
        for _, ingredientType in pairs(ingredient.type) do
          if ingredientType == stationType then isValid = true break end
        end
        return isValid
      elseif "no_ingredient" == ingredientName then return true end
    end
  end
  return false
end

-- Get available stations for recipe creation
local function getAvailableStations(restaurantId, recipeType, stationType)
  local stations = {}
  for stationIndex, station in pairs(Config.restaurants[restaurantId].stations) do
    local stationTypeLabel = (station.type == "food") and locale("input_recipe_type_food") or locale("input_recipe_type_drink")
    stations[#stations + 1] = {
      value = "station_" .. restaurantId .. "_" .. stationIndex,
      label = station.label .. " (" .. stationTypeLabel .. ")"
    }
  end
  return stations
end

-- Get available ingredients
local function getAvailableIngredients(restaurantId, recipeType, stationType)
  local ingredients = {}
  ingredients[#ingredients + 1] = { value = "no_ingredient", label = locale("input_recipe_no_ingredient") }
  
  for _, ingredient in pairs(Config.restaurants[restaurantId].ingredients) do
    local ingredientItemData = itemData(tostring(ingredient.item))
    if ingredientItemData then
      ingredients[#ingredients + 1] = {
        value = ingredient.item,
        label = ingredientItemData.label
      }
    end
  end
  return ingredients
end

local function getAvailableAnimations()
  local animations = {}
  for animationKey, animation in pairs(Config.foodAnimations) do
    animations[#animations + 1] = { value = animationKey, label = animation.label }
  end
  return animations
end

local function getAvailableRecipeTypes()
  return {
      { value = "food", label = locale("input_recipe_type_food") },
      { value = "drink", label = locale("input_recipe_type_drink") }
  }
end

function createOrEditRecipe(restaurantId, recipeType, existingRecipe)
  local availableStations = getAvailableStations(restaurantId, nil, nil)
  local availableIngredients = getAvailableIngredients(restaurantId, nil, nil)
  local availableAnimations = getAvailableAnimations()
  local availableRecipeTypes = getAvailableRecipeTypes()
  
  local defaultValues = {
    label = existingRecipe and existingRecipe.label or "",
    description = existingRecipe and existingRecipe.description or "",
    image_url = existingRecipe and existingRecipe.image_url or "",
    price = existingRecipe and existingRecipe.price or 0,
    animation = existingRecipe and existingRecipe.animation or availableAnimations[1].value,
    type = existingRecipe and existingRecipe.type or availableRecipeTypes[1].value,
    station = existingRecipe and existingRecipe.station or nil,
    ingredients = existingRecipe and existingRecipe.ingredients or {},
    active = existingRecipe and existingRecipe.active or true
  }

  -- If editing, convert ingredients object to array for multi-select (simplified for this context)
  local ingredientArray = {}
  if defaultValues.ingredients then
      for k, v in pairs(defaultValues.ingredients) do
          for i=1, v do table.insert(ingredientArray, k) end
      end
  end

  local formInputs = {
    { type = "input", label = locale("input_recipe_label"), default = defaultValues.label, required = true },
    { type = "input", label = locale("input_recipe_description"), default = defaultValues.description },
    { type = "input", label = locale("input_recipe_url"), default = defaultValues.image_url, required = true },
    { type = "select", label = locale("input_recipe_animation"), default = defaultValues.animation, options = availableAnimations, required = true },
    { type = "select", label = locale("input_recipe_type"), default = defaultValues.type, options = availableRecipeTypes, required = true },
    { type = "multi-select", label = locale("input_recipe_station"), default = defaultValues.station, options = availableStations, required = true },
    { type = "checkbox", label = locale("input_recipe_active"), checked = defaultValues.active },
    { type = "number", label = locale("input_recipe_price"), default = defaultValues.price, required = true, max = Config.restaurants[restaurantId].maxRecipePrice }
  }

  -- Dynamic Ingredients
  for i = 1, Config.restaurants[restaurantId].maxIngredients do
      table.insert(formInputs, {
          type = "select", 
          label = locale("input_recipe_ingredients"), 
          default = ingredientArray[i] or "no_ingredient", 
          options = availableIngredients,
          searchable = true
      })
  end
  
  local input = lib.inputDialog(locale("menu_recipes_create_title"), formInputs)
  
  if input then
    local ingredients = {}
    for i = 9, #input do
      local ing = input[i]
      if ing ~= "no_ingredient" then
          ingredients[ing] = (ingredients[ing] or 0) + 1
      end
    end
    
    local recipeData = {
      label = input[1], description = input[2], image_url = input[3], animation = input[4],
      type = input[5], station = input[6], ingredients = ingredients, active = input[7],
      price = input[8], job = restaurantId, recipeId = existingRecipe and existingRecipe.recipeId or nil
    }
    
    if validateRecipeStations(restaurantId, recipeData.station, recipeData.type) and isValidStation(restaurantId, recipeData.ingredients, recipeData.type) then
        local success = false
        if recipeType == "create" then
            success = lib.callback.await("mt-restaurants:server:createNewRecipe", false, recipeData)
        else
            success = lib.callback.await("mt-restaurants:server:editRecipe", false, recipeData)
        end
        if success then notify("Success", "success") else notify("Error", "error") end
        recipesMenu(restaurantId)
    else
        notify("Invalid Station or Ingredients", "error")
    end
  end
end

function deleteRecipe(restaurantId, recipeId)
  local result = lib.alertDialog({ header = locale("alert_delete_recipe_title"), content = locale("alert_delete_recipe_description"), centered = true, cancel = true })
  if result == "confirm" then
    lib.callback.await("mt-restaurants:server:deleteRecipe", false, recipeId, restaurantId)
  end
  recipesMenu(restaurantId)
end