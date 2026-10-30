-- Globals preserved: Config, _menuPool, mainMenu, ShowMenu, MenuSetup, CallMenu, pairsByKeys [file:3]

-- Internal state (kept global in this file for compatibility with other files using them)
nearbyElevatorEntries = {}            -- previously L3_1, list of { coords, elevator, floor } [file:3]
currentPromptContext = {}             -- previously L4_1, data for current prompt action [file:3]
isPlayerNearElevator = false          -- previously L2_1, proximity boolean [file:3]
activationRadius = Config.ActivateRadius -- previously L8_1, radius threshold from config [file:3]
activeNotification = nil              -- previously L5_1, which notification type is active ("menu" or other) [file:3]
proximityStateLatched = false         -- previously L6_1, tracks if inside proximity loop [file:3]
currentNearbyIndex = nil              -- previously L7_1, index in nearbyElevatorEntries currently closest [file:3]

-- Utility: iterate table keys in sorted order
function pairsByKeys(t, comparator)
  local keyArray = {} [file:3]
  for key in pairs(t) do
    table.insert(keyArray, key) [file:3]
  end
  table.sort(keyArray, comparator) [file:3]
  local i = 0 [file:3]
  function iterator()
    i = i + 1 [file:3]
    local k = keyArray[i] [file:3]
    if k == nil then
      return nil [file:3]
    else
      return k, t[k] [file:3]
    end
  end
  return iterator [file:3]
end [file:3]

-- Notification helper (displays help text if not already on screen)
function ShowHelpNotification(text, allowRepeat)
  if allowRepeat == nil then allowRepeat = true end [file:3]
  local helpOn = IsHelpMessageOnScreen() [file:3]
  if not helpOn then
    AddTextEntry("Notification", text) [file:3]
    BeginTextCommandDisplayHelp("Notification") [file:3]
    EndTextCommandDisplayHelp(0, false, false, -1) [file:3]
  end
end [file:3]

-- Build flat list of all elevator entries for proximity checks
function BuildElevatorEntries()
  local entries = {} [file:3]
  for elevatorIndex = 1, #Config.Elevators, 1 do
    local elevator = Config.Elevators[elevatorIndex] [file:3]
    for floorIndex = 1, #elevator.floors, 1 do
      local floor = elevator.floors[floorIndex] [file:3]
      table.insert(entries, {
        coords = floor.coords,
        elevator = elevatorIndex,
        floor = floorIndex
      }) [file:3]
    end
  end
  return entries [file:3]
end [file:3]

-- Show/hide main menu
function ShowMenu(visible)
  mainMenu:Visible(visible) [file:3]
end [file:3]

-- Create the NativeUI pool and main menu
function MenuSetup()
  local pos = nil [file:3]
  if Config.MenuPosition then
    pos = Config.MenuPositions[Config.MenuPosition] [file:3]
  end

  _menuPool = NativeUI.CreatePool() [file:3]
  mainMenu = NativeUI.CreateMenu(
    Config.Translation[Config.Language].menu_header,
    Config.Translation[Config.Language].menu_title,
    pos.x,
    pos.y
  ) [file:3]
  _menuPool:Add(mainMenu) [file:3]

  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(0) [file:3]
      _menuPool:ProcessMenus() [file:3]
    end
  end) [file:3]
end [file:3]

-- Populate and show the elevator menu for the given elevator, focused on current floor
function CallMenu(elevatorIndex, currentFloorIndex)
  local elevator = Config.Elevators[elevatorIndex] [file:3]

  mainMenu:Clear() [file:3]

  for idx = 1, #elevator.floors, 1 do
    mainMenu:AddItem(NativeUI.CreateItem(elevator.floors[idx].label, "")) [file:3]
  end

  mainMenu.OnItemSelect = function(_, __, selectedIndex)
    local target = Config.Elevators[elevatorIndex].floors[selectedIndex].coords [file:3]
    if selectedIndex ~= currentFloorIndex then
      Teleport(vector3(target.x, target.y, target.z), target.w) [file:3]
      ShowMenu(false) [file:3]
    else
      ShowHelpNotification(Config.Translation[Config.Language].same_floor, true) [file:3]
    end
  end [file:3]

  _menuPool:RefreshIndex() [file:3]
  ShowMenu(true) [file:3]
end [file:3]

-- Proximity entered handler: set state to show "menu" prompt for selected index
function OnEnterProximity(entryIndex)
  isPlayerNearElevator = true [file:3]
  activeNotification = "menu" [file:3]
  currentPromptContext = nearbyElevatorEntries[entryIndex] [file:3]
end [file:3]

-- Proximity exited handler: clear state
function OnExitProximity(entryIndex)
  isPlayerNearElevator = false [file:3]
  activeNotification = nil [file:3]
  currentPromptContext = {} [file:3]
end [file:3]

-- Initial data and setup
nearbyElevatorEntries = BuildElevatorEntries() [file:3]
MenuSetup() [file:3]

-- Event to clear menu prompt state when lift menu closes
AddEventHandler("liftMenuClosed", function()
  activeNotification = "menu" [file:3]
end) [file:3]

-- Thread: periodic proximity scan to elevator spots
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(1000) [file:3]

    local ped = PlayerPedId() [file:3]
    local pcoords = GetEntityCoords(ped) [file:3]

    local found = false [file:3]
    local foundIndex = nil [file:3]

    for i = 1, #nearbyElevatorEntries, 1 do
      local entry = nearbyElevatorEntries[i].coords [file:3]
      local dist = GetDistanceBetweenCoords(
        entry.x, entry.y, entry.z,
        pcoords.x, pcoords.y, pcoords.z, true
      ) [file:3]
      if dist < activationRadius then
        found = true [file:3]
        foundIndex = i [file:3]
      end
    end

    if found then
      if not proximityStateLatched or currentNearbyIndex ~= foundIndex then
        proximityStateLatched = true [file:3]
        currentNearbyIndex = foundIndex [file:3]
        OnEnterProximity(foundIndex) [file:3]
      end
    else
      if proximityStateLatched then
        proximityStateLatched = false [file:3]
        OnExitProximity(currentNearbyIndex) [file:3]
      end
    end
  end
end) [file:3]

-- Thread: handle on-screen prompt and key press to open menu
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0) [file:3]

    if activeNotification ~= nil then
      ShowHelpNotification(Config.Translation[Config.Language].notification) [file:3]

      if IsControlJustReleased(0, 51) then -- INPUT_CONTEXT (E)
        if activeNotification == "menu" then
          CallMenu(currentPromptContext.elevator, currentPromptContext.floor) [file:3]
        end
        activeNotification = nil [file:3]
      end
    else
      Citizen.Wait(500) [file:3]
    end
  end
end) [file:3]
