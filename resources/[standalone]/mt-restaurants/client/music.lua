-- Function to play a song with input dialog
function playSong(musicId, restaurantId, musicIndex, coords)
  local input = lib.inputDialog(locale("input_music_play_song"), {
    {
      type = "input",
      icon = "fab fa-youtube",
      label = locale("input_music_song_link"),
      required = true
    },
    {
      type = "slider",
      icon = "volume-up",
      label = locale("input_music_song_vol"),
      required = true,
      min = 0,
      max = Config.restaurants[restaurantId].music[musicIndex].maxMusicVolume
    },
    {
      type = "slider",
      icon = "expand",
      label = locale("input_music_song_dist"),
      required = true,
      min = 0,
      max = Config.restaurants[restaurantId].music[musicIndex].maxMusicRadius
    }
  })
  
  if input and input[1] and input[2] and input[3] then
    TriggerServerEvent("mt-restaurants:server:playSong", musicId, input, coords)
  end
end
-- Function to change song status (volume/distance)
function changeSongStatus(musicId, restaurantId, musicIndex)
  local input = lib.inputDialog(locale("input_music_play_song"), {
    {
      type = "slider",
      icon = "volume-up",
      label = locale("input_music_song_vol"),
      required = true,
      min = 0,
      max = Config.restaurants[restaurantId].music[musicIndex].maxMusicVolume
    },
    {
      type = "slider",
      icon = "expand",
      label = locale("input_music_song_dist"),
      required = true,
      min = 0,
      max = Config.restaurants[restaurantId].music[musicIndex].maxMusicRadius
    }
  })
  
  if input and input[1] and input[2] then
    TriggerServerEvent("mt-restaurants:server:changeSongStatus", musicId, input)
  end
end
-- Function to stop a song
function stopSong(musicId)
  TriggerServerEvent("mt-restaurants:server:stopSong", musicId)
end
