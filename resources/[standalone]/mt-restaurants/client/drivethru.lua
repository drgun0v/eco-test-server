-- Function called when entering drive-thru area
function enteredInDriveThru(restaurantId, driveThruId, voiceChannel)
  exports["pma-voice"]:setCallChannel(driveThruId)
end
-- Function called when exiting drive-thru area
function exitInDriveThru(restaurantId, driveThruId, voiceChannel)
  exports["pma-voice"]:setCallChannel(0)
end
-- Function called when entering drive-thru order area
function enteredOutDriveThru(restaurantId, driveThruId, voiceChannel)
  -- Notify server to play alert sound
  lib.callback.await("mt-restaurants:server:playDriveThruAlert", false, restaurantId, driveThruId)
  
  -- Set voice channel
  exports["pma-voice"]:setCallChannel(driveThruId)
end
-- Function called when exiting drive-thru order area
function exitOutDriveThru(restaurantId, driveThruId, voiceChannel)
  exports["pma-voice"]:setCallChannel(0)
end
-- Event handler for playing drive-thru alert sound
local function playDriveThruAlert(restaurantId, driveThruId)
  local driveThruCoords = Config.restaurants[restaurantId].drivethru[driveThruId].inCoords
  local playerCoords = GetEntityCoords(cache.ped)
  
  local distance = GetDistanceBetweenCoords(
    playerCoords.x,
    playerCoords.y,
    playerCoords.z,
    driveThruCoords.x,
    driveThruCoords.y,
    driveThruCoords.z,
    false
  )
  
  -- Play sound if player is within range
  if distance <= 10.0 then
    PlaySoundFromCoord(
      GetSoundId(),
      "Menu_Accept",
      driveThruCoords.x,
      driveThruCoords.y,
      driveThruCoords.z,
      "Phone_SoundSet_Default",
      false,
      10.0,
      false
    )
    
    -- Notify restaurant employees
    if getPlayerJob() == restaurantId and playerInsideRestaurant then
      notify(locale("notify_player_at_drive_thru"), "info")
    end
  end
end

RegisterNetEvent("mt-restaurants:client:playDriveThruAlert", playDriveThruAlert)
