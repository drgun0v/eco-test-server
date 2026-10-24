-- Track occupied chairs by chair ID
local occupiedChairs = {}

-- Function to check if a chair is occupied
local function isChairOccupied(source, chairId)
  -- Return the occupancy status of the chair
  return occupiedChairs[chairId] or false
end

-- Register callback for checking chair occupancy
lib.callback.register("mt-restaurants:server:isChairOccupied", isChairOccupied)

-- Event handler for sitting in a chair
local function sitChair(chairId, playerId)
  -- Set chair as occupied by the player
  occupiedChairs[chairId] = playerId
end

-- Register event for sitting in chair
RegisterNetEvent("mt-restaurants:server:sitChair", sitChair)
