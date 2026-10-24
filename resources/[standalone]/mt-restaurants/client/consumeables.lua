-- Function to use/consume food items
function useFoodItem(name, item)
  local metadata = item.metadata or item.info
  
  -- Calculate progress time based on calories
  local progressTime = tonumber(metadata.calories / 10)
  
  -- Determine progress message based on item type
  local progressMessage = metadata.type == "food" and 
    locale("progress_eating_food", metadata.label) or 
    locale("progress_drinking_drink", metadata.label)
  
  -- Get animation data
  local animData = Config.foodAnimations[metadata.animation]
  
  -- Show progress bar with animation
  local success = progressBar(
    progressMessage,
    Config.times.eatFood,
    {
      car = false,
      move = false
    },
    animData.anim,
    animData.prop
  )
  
  if success then
    -- Add needs (hunger/thirst)
    addNeeds(metadata.type, progressTime)
    
    -- Remove item from inventory
    lib.callback.await("mt-restaurants:server:removeFoodItem", false, metadata, item.slot)
    
    -- Apply custom buffs if any
    giveCustomBuffs(metadata.type, metadata.customBuffs)
  end
end
-- Export and register the useFoodItem function
exports("useFoodItem", useFoodItem)
RegisterNetEvent("mt-restaurants:client:useFoodItem", useFoodItem)
