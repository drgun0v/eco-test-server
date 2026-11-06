Elevator = {}
Elevator.__index = Elevator

---@class Elevator
---@field floors vector4[]
---@field thread boolean
---@field menu RageMenu
function Elevator.new(data)
  local self = setmetatable({}, Elevator)
  self.floors = data.floors
  self.thread = falseprint
  self.floors = table.sortKeys(self.floors)

  self.menu = RageUI:Create("main", Locale["menu-title"], Locale["menu-description"])
  for i, floor in pairs(self.floors) do
    local Button = self.menu:Button(floor.name, string.format(Locale["floor-description"], floor.name), Locale["floor-label"])
    Button:On("click", function(item)
      local floor = self.floors[i]
      local playerPos = GetEntityCoords(PlayerPedId())
      local distance = #(playerPos - vector3(floor.pos.x, floor.pos.y, floor.pos.z))

      if currentFloor ~= i then
        DoScreenFadeOut(300)
        while not IsScreenFadedOut() do
          Wait(100)
        end
        SetEntityCoordsNoOffset(PlayerPedId(), floor.pos.x, floor.pos.y, floor.pos.z, true, true, false)
        SetEntityHeading(PlayerPedId(), floor.pos.w)
        DoScreenFadeIn(300)
        currentFloor = i
      end
    end)
  end

  self:StartThread()

  return self
end

function Elevator:OpenMenu(currentFloor)
  self.menu:Open()
end

function Elevator:StartThread()
  self.thread = true
  
  for index, floor in pairs(self.floors) do
    CreateThread(function ()
      while self.thread do
        Wait(1)
        local playerPos = GetEntityCoords(PlayerPedId())
        local distance = #(playerPos - vector3(floor.pos.x, floor.pos.y, floor.pos.z))

        if distance < 2 then
          DrawMarker(Config.Marker.type, floor.pos.x, floor.pos.y, floor.pos.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.6, 0.6, 0.6, Config.Marker.r, Config.Marker.g, Config.Marker.b, Config.Marker.alpha, false, true, 2, false, nil, false)

          if distance < 1 then
            AddTextEntry('HelpNotify', Locale["elevator-help-notify"])
            DisplayHelpTextThisFrame('HelpNotify', false)
            if IsControlJustReleased(0, 38) then
              self:OpenMenu(index)
            end
          else
            if self.menu._Visible then
              self.menu:Close()
            end
          end
        else
          Wait(1000)
        end
      end
    end)
  end
end