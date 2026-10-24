-- Menu clipboard object
local menuClipboard = nil

-- NUI callback to set UI focus and show menu animation
RegisterNUICallback("setUIFocus", function()
  -- Enable NUI focus
  SetNuiFocus(true, true)
  
  -- Load and play menu reading animation
  loadAnimDict("missfam4")
  TaskPlayAnim(
    cache.ped,
    "missfam4",
    "base",
    8.0,
    8.0,
    -1,
    1,
    0,
    false,
    false,
    false
  )
  
  -- Create and attach clipboard prop
  loadModel("p_amb_clipboard_01")
  menuClipboard = CreateObject(
    GetHashKey("p_amb_clipboard_01"),
    0.0,
    0.0,
    0.0,
    true,
    false,
    false
  )
  
  AttachEntityToEntity(
    menuClipboard,
    cache.ped,
    GetPedBoneIndex(cache.ped, 36029),
    0.16,
    0.08,
    0.1,
    -130.0,
    -50.0,
    0.0,
    false,
    true,
    false,
    false,
    true,
    true
  )
end)
-- NUI callback to unset UI focus and clean up menu
RegisterNUICallback("unsetUIFocus", function()
  -- Disable NUI focus
  SetNuiFocus(false, false)
  
  -- Clear player tasks and animations
  ClearPedTasks(cache.ped)
  StopAnimTask(cache.ped, "missfam4", "base", 0.0)
  RemoveAnimDict("missfam4")
  
  -- Delete clipboard prop
  DeleteEntity(menuClipboard)
end)
-- Function to take a restaurant menu
function takeMenu(restaurantId)
  lib.callback.await("mt-restaurants:server:addRestaurantMenu", false, restaurantId)
end
-- Function to open and display a restaurant menu
function openMenu(name, item)
  local metadata = item.metadata or item.info
  
  SendNUIMessage({
    action = "show",
    image_url = metadata.image_url
  })
end
-- Export and register the openMenu function
exports("openMenu", openMenu)
RegisterNetEvent("mt-restaurants:client:openMenu", openMenu)
