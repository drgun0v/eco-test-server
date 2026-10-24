-- Current spawned vehicle
local currentVehicle = nil

-- Function to open garage menu
function openGarage(restaurantId, garageId)
  local menu = {
    id = "garage_restaurants_" .. restaurantId .. "_" .. garageId,
    title = locale("menu_garage_title"),
    options = {}
  }
  
  if not currentVehicle then
    -- Show vehicle spawn options
    for vehicleIndex, vehicle in pairs(Config.restaurants[restaurantId].garage[garageId].vehicles) do
      menu.options[#menu.options + 1] = {
        title = vehicle.label,
        icon = vehicle.icon,
        arrow = true,
        onSelect = function()
          currentVehicle = spawnVehicle(
            vehicle.id,
            Config.restaurants[restaurantId].garage[garageId].spawnCoords
          )
        end
      }
    end
  else
    -- Show vehicle store option
    menu.options[#menu.options + 1] = {
      title = locale("menu_garage_store_vehicle"),
      icon = "ban",
      arrow = true,
      onSelect = function()
        -- Remove vehicle keys and make everyone exit
        removeVehicleKeys(currentVehicle)
        TaskEveryoneLeaveVehicle(currentVehicle)
        
        -- Request control and delete vehicle
        NetworkRequestControlOfEntity(currentVehicle)
        DeleteVehicle(currentVehicle)
        DeleteEntity(currentVehicle)
        
        -- Reset current vehicle
        currentVehicle = nil
      end
    }
  end
  
  -- Register and show the menu
  lib.registerContext(menu)
  lib.showContext(menu.id)
end
