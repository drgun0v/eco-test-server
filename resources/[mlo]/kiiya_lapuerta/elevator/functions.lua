-- Keep existing globals and cross-file variables as-is
-- Note: cloudOpacity and Config are assumed globals used across files. ⚠️ If these are not defined elsewhere, confirm their origin. [file:2]

-- State flags
isPlayerFrozen = false [file:2]

-- Toggle player input/freeze/invincibility/visibility/collision consistently
function SetPlayerFrozen(playerId, freezeEnabled)
  local targetPlayerId = playerId [file:2]
  SetPlayerControl(targetPlayerId, not freezeEnabled, false) [file:2]

  local ped = GetPlayerPed(targetPlayerId) [file:2]

  if not freezeEnabled then
    if not IsEntityVisible(ped) then
      SetEntityVisible(ped, true) [file:2]
    end
    if not IsPedInAnyVehicle(ped) then
      SetEntityCollision(ped, true) [file:2]
    end
    FreezeEntityPosition(ped, false) [file:2]
    SetPlayerInvincible(targetPlayerId, false) [file:2]
  else
    if IsEntityVisible(ped) then
      SetEntityVisible(ped, false) [file:2]
    end
    SetEntityCollision(ped, false) [file:2]
    FreezeEntityPosition(ped, true) [file:2]
    SetPlayerInvincible(targetPlayerId, true) [file:2]
    if not IsPedFatallyInjured(ped) then
      ClearPedTasksImmediately(ped) [file:2]
    end
  end
end [file:2]

-- Preload elevator SFX bank once
RequestAmbientAudioBank("MP_PROPERTIES_ELEVATOR_DOORS", 0, 0) [file:2]

-- Play elevator open SFX sequence
function PlayElevatorOpenSounds()
  PlaySoundFrontend(-1, "BUTTON", "MP_PROPERTIES_ELEVATOR_DOORS", 1) [file:2]
  PlaySoundFrontend(-1, "OPENING", "MP_PROPERTIES_ELEVATOR_DOORS", 1) [file:2]
  Wait(1000) [file:2]
  PlaySoundFrontend(-1, "OPENED", "MP_PROPERTIES_ELEVATOR_DOORS", 1) [file:2]
  Wait(1000) [file:2]
end [file:2]

-- Play elevator close/arrive SFX sequence
function PlayElevatorCloseSounds()
  PlaySoundFrontend(-1, "FAKE_ARRIVE", "MP_PROPERTIES_ELEVATOR_DOORS", 1) [file:2]
  Wait(1000) [file:2]
  PlaySoundFrontend(-1, "CLOSING", "MP_PROPERTIES_ELEVATOR_DOORS", 1) [file:2]
  Wait(1000) [file:2]
  PlaySoundFrontend(-1, "CLOSED", "MP_PROPERTIES_ELEVATOR_DOORS", 1) [file:2]
end [file:2]

-- Screen-safe teleport with collision wait and heading set
function TeleportWithFade(targetCoords, targetHeading)
  DoScreenFadeOut(1000) [file:2]
  while true do
    if IsScreenFadedOut() then break end
    Citizen.Wait(0) [file:2]
  end

  SetPlayerFrozen(PlayerId(), true) [file:2]

  while true do
    if IsScreenFadedOut() then break end
    Citizen.Wait(0) [file:2]
  end

  local ped = PlayerPedId() [file:2]

  -- First move without offset, request collision and wait up to 5s
  SetEntityCoordsNoOffset(ped, targetCoords, false, false, false, true) [file:2]
  local startTime = GetGameTimer() [file:2]
  RequestCollisionAtCoord(targetCoords) [file:2]
  while true do
    if HasCollisionLoadedAroundEntity(ped) then break end
    if (GetGameTimer() - startTime) >= 5000 then break end
    Citizen.Wait(0) [file:2]
  end

  Citizen.Wait(1000) [file:2]

  -- Re-assert coords, clear tasks, set heading
  SetEntityCoordsNoOffset(ped, targetCoords, false, false, false, true) [file:2]
  ClearPedTasksImmediately(ped) [file:2]
  SetEntityHeading(ped, targetHeading) [file:2]

  SetPlayerFrozen(PlayerId(), false) [file:2]
  DoScreenFadeIn(1000) [file:2]
  PlayElevatorCloseSounds() [file:2]
end [file:2]

-- Frame-time world visuals setup
function PrepareWorldFrame()
  SetCloudHatOpacity(cloudOpacity) -- ⚠️ Assumes global cloudOpacity is defined elsewhere [file:2]
  HideHudAndRadarThisFrame() [file:2]
  SetDrawOrigin(0.0, 0.0, 0.0, 0) [file:2]
end [file:2]

-- Create blips from Config.Locations
function CreateLocationBlips()
  local locations = Config.Locations -- ⚠️ Assumes global Config is defined elsewhere [file:2]
  for index = 1, #locations, 1 do
    local entry = locations[index] [file:2]
    if entry.blipType then
      local blip = AddBlipForCoord(entry.blipCoords) [file:2]
      SetBlipSprite(blip, entry.blipType) [file:2]
      SetBlipColour(blip, entry.blipColor) [file:2]
      SetBlipAsShortRange(blip, true) [file:2]

      BeginTextCommandSetBlipName("STRING") [file:2]
      AddTextComponentString(entry.label) [file:2]
      EndTextCommandSetBlipName(blip) [file:2]
    end
  end
end [file:2]

-- Public teleport alias preserved
function Teleport(targetCoords, targetHeading)
  TeleportWithFade(targetCoords, targetHeading) [file:2]
end [file:2]
