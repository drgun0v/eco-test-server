-- Track registered box stashes to avoid duplicate registrations
local registeredBoxes = {}

-- Function to check and register restaurant box stash
local function checkBox(source, boxId)
  -- If not using ox_inventory, return true (no registration needed)
  if Config.inventory ~= "ox_inventory" then
    return true
  end
  
  -- Check if box is already registered
  if registeredBoxes[boxId] then
    return true
  end
  
  -- Register the box stash with ox_inventory
  exports.ox_inventory:RegisterStash(
    boxId,
    locale("inventory_stash_restaurant_box"),
    Config.boxes.slots,
    Config.boxes.weigth
  )
  
  -- Mark as registered
  registeredBoxes[boxId] = true
  
  return true
end

-- Register callback for checking box
lib.callback.register("mt-restaurants:server:checkBox", checkBox)
