-- Initialize locale
lib.locale()

-- Add givefood command
lib.addCommand("givefood", {
  help = locale("command_give_food"),
  params = {
    {
      name = "target",
      type = "playerId",
      help = locale("command_target")
    },
    {
      name = "restaurantId",
      type = "string",
      help = locale("command_restaurant_id")
    },
    {
      name = "quantity",
      type = "number",
      help = locale("command_quantity")
    }
  },
  restricted = "group.admin"
}, function(source, args, raw)
  local playerId = source
  local targetId = args.target
  local restaurantId = args.restaurantId
  local quantity = args.quantity
  
  if not targetId or not restaurantId then
    return
  end
  
  TriggerClientEvent("mt-restaurants:client:adminFoodMenu", playerId, restaurantId, quantity)
end)
-- Admin event handler for giving food
local function adminGiveFood(foodData, quantity)
  local src = source
  
  -- Check if player has admin permissions
  if not IsPlayerAceAllowed(src, "admin") then
    return
  end
  
  if not foodData then
    return
  end
  
  -- Add item based on inventory system
  if Config.inventory == "ox_inventory" then
    exports.ox_inventory:AddItem(src, "restaurant_food", quantity, foodData or {})
  else
    local Player = Config.core.Functions.GetPlayer(src)
    Player.Functions.AddItem("restaurant_food", quantity, nil, foodData or {})
  end
end

-- Register the admin event
RegisterNetEvent("mt-restaurants:server:admin", adminGiveFood)
