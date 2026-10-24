-- Event handler to play a song using xsound
local function playSong(songId, songData, coords)
  -- Play song at position with URL and volume
  exports.xsound:PlayUrlPos(
    -1, -- All players
    songId,
    songData[1], -- URL
    songData[2] / 100, -- Volume (convert percentage to decimal)
    vector3(coords.x, coords.y, coords.z)
  )
  
  -- Set distance for the sound
  exports.xsound:Distance(-1, songId, songData[3])
  
  -- Set volume for the sound
  exports.xsound:setVolume(-1, songId, songData[2] / 100)
end

-- Register event for playing song
RegisterNetEvent("mt-restaurants:server:playSong", playSong)
-- Event handler to change song status (volume and distance)
local function changeSongStatus(songId, statusData)
  -- Update distance for the sound
  exports.xsound:Distance(-1, songId, statusData[2])
  
  -- Update volume for the sound
  exports.xsound:setVolume(-1, songId, statusData[1] / 100)
end

-- Register event for changing song status
RegisterNetEvent("mt-restaurants:server:changeSongStatus", changeSongStatus)
-- Event handler to stop a song
local function stopSong(songId)
  -- Destroy the sound for all players
  exports.xsound:Destroy(-1, songId)
end

-- Register event for stopping song
RegisterNetEvent("mt-restaurants:server:stopSong", stopSong)
