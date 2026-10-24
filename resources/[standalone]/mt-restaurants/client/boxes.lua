-- Function to take a restaurant box
function takeBox(restaurantJob)
  lib.callback.await("mt-restaurants:server:addRestaurantBox", false, restaurantJob)
end
-- Function to use a restaurant box
function useBox(name, item)
  local metadata = item.metadata or item.info
  
  -- Check if box is ready
  local isReady = lib.callback.await("mt-restaurants:server:checkBox", false, metadata.id)
  
  if isReady then
    openStash(
      metadata.id,
      locale("inventory_stash_restaurant_box", metadata.label),
      50,
      50000
    )
  else
    notify(locale("notify_box_not_ready"), "error")
  end
end
-- Export and register the useBox function
exports("useBoxItem", useBox)
RegisterNetEvent("mt-restaurants:client:useBoxItem", useBox)
