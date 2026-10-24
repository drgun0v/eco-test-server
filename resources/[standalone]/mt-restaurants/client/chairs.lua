-- Chair sitting state variables
local isSitting = false
local originalPosition = nil

-- Function to sit on a chair
function sitChair(chairCoords, targetId)
  -- Check if already sitting
  if isSitting then
    return
  end
  
  -- Check if chair is occupied
  local isOccupied = lib.callback.await("mt-restaurants:server:isChairOccupied", false, targetId)
  if isOccupied then
    return
  end
  
  -- Notify server that chair is occupied
  TriggerServerEvent("mt-restaurants:server:sitChair", targetId, true)
  
  -- Store original position
  originalPosition = GetEntityCoords(cache.ped)
  
  -- Start sitting scenario
  local scenario = "PROP_HUMAN_SEAT_CHAIR_MP_PLAYER"
  TaskStartScenarioAtPosition(
    cache.ped,
    scenario,
    chairCoords.x,
    chairCoords.y,
    chairCoords.z,
    chairCoords.w,
    0,
    true,
    true
  )
  
  isSitting = true
  
  -- Create thread to handle getting up from chair
  CreateThread(function()
    while isSitting do
      Wait(0)
      
      -- Show text UI for getting up
      showTextUI(locale("textui_sit_get_up"), Config.textuiPos)
      
      -- Check if player wants to get up or if they stopped using the scenario
      if IsControlJustPressed(0, Config.sitsGetUpKey) or not IsPedUsingScenario(cache.ped, scenario) then
        -- Stop sitting
        isSitting = false
        hideTextUI()
        
        -- Clear ped tasks
        ClearPedTasks(cache.ped)
        
        -- Move player back to original position
        SetEntityCoords(
          cache.ped,
          originalPosition.x,
          originalPosition.y,
          originalPosition.z - 0.3,
          true,
          false,
          false,
          false
        )
        
        -- Notify server that chair is no longer occupied
        TriggerServerEvent("mt-restaurants:server:sitChair", targetId, false)
        break
      end
    end
  end)
end
