-- Function to play drive-thru alert sound to all clients
local function playDriveThruAlert(source, coords, distance)
  -- Trigger client event to play alert sound at specified coordinates
  TriggerClientEvent("mt-restaurants:client:playDriveThruAlert", -1, coords, distance)
  return true
end

-- Register callback for playing drive-thru alert
lib.callback.register("mt-restaurants:server:playDriveThruAlert", playDriveThruAlert)
