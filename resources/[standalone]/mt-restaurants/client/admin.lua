-- Admin food menu event handler
local function adminFoodMenu(restaurantId, quantity)
  print(quantity)
  
  -- Get recipes from server
  local recipes = lib.callback.await("mt-restaurants:server:getRecipes", false, restaurantId)
  
  -- Create menu context
  local menu = {
    title = locale("menu_admin_givefood"),
    id = "restaurant_admin_givefood",
    options = {}
  }
  
  if not recipes then
    return
  end
  -- Process each recipe
  for recipeId, recipe in pairs(recipes) do
    local totalCalories = 0
    local customBuffs = {}
    
    -- Calculate calories and buffs from ingredients
    local ingredients = json.decode(recipe.ingredients)
    for ingredientName, ingredientAmount in pairs(ingredients) do
      if ingredientName ~= "no_ingredient" then
        -- Find ingredient in restaurant config
        for _, ingredient in pairs(Config.restaurants[restaurantId].ingredients) do
          if ingredient.item == ingredientName then
            -- Add calories
            totalCalories = totalCalories + (ingredient.calories * ingredientAmount)
            
            -- Add custom buffs if they exist
            if ingredient.customBuffs then
              for buffName, buffValue in pairs(ingredient.customBuffs) do
                if customBuffs[buffName] then
                  customBuffs[buffName] = customBuffs[buffName] + (buffValue * ingredientAmount)
                else
                  customBuffs[buffName] = buffValue * ingredientAmount
                end
              end
            end
          end
        end
      end
    end
    -- Add recipe option to menu
    menu.options[#menu.options + 1] = {
      title = recipe.label,
      description = recipe.description,
      icon = recipe.image_url,
      onSelect = function()
        TriggerServerEvent("mt-restaurants:server:admin", {
          imageurl = recipe.image_url,
          label = recipe.label,
          description = recipe.description,
          calories = totalCalories,
          restaurant = Config.restaurants[restaurantId].label,
          animation = recipe.animation,
          type = recipe.type,
          price = recipe.price,
          customBuffs = customBuffs
        }, quantity)
      end
    }
  end
  -- Register and show menu
  lib.registerContext(menu)
  lib.showContext(menu.id)
end

-- Register the event
RegisterNetEvent("mt-restaurants:client:adminFoodMenu", adminFoodMenu)
