local L0_1, L1_1
L0_1 = print
L1_1 = "^5[^3 TStudio Elevator^5]^7 Loading Elevator.lua..."
L0_1(L1_1)
L0_1 = {}
Elevator = L0_1
L0_1 = Elevator
L1_1 = Elevator
L0_1.__index = L1_1
L0_1 = Elevator
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L1_2 = setmetatable
  L2_2 = {}
  L3_2 = Elevator
  L1_2 = L1_2(L2_2, L3_2)
  L2_2 = A0_2.floors
  L1_2.floors = L2_2
  L1_2.thread = false
  L2_2 = A0_2.locale
  L1_2.locale = L2_2
  L2_2 = A0_2.marker
  L1_2.marker = L2_2
  L2_2 = A0_2.header
  L1_2.header = L2_2
  L2_2 = table
  L2_2 = L2_2.sortKeys
  L3_2 = L1_2.floors
  L2_2 = L2_2(L3_2)
  L1_2.floors = L2_2
  L2_2 = nil
  L3_2 = L1_2.header
  if L3_2 then
    L3_2 = L1_2.header
    L3_2 = L3_2.topColor
    if L3_2 then
      L3_2 = L1_2.header
      L3_2 = L3_2.bottomColor
      if L3_2 then
        L3_2 = print
        L4_2 = "^2[Elevator]^7 Creating gradient:"
        L5_2 = L1_2.header
        L5_2 = L5_2.topColor
        L5_2 = L5_2.r
        L6_2 = L1_2.header
        L6_2 = L6_2.topColor
        L6_2 = L6_2.g
        L7_2 = L1_2.header
        L7_2 = L7_2.topColor
        L7_2 = L7_2.b
        L3_2(L4_2, L5_2, L6_2, L7_2)
        L3_2 = {}
        L4_2 = {}
        L5_2 = L1_2.header
        L5_2 = L5_2.topColor
        L5_2 = L5_2.r
        L4_2.r = L5_2
        L5_2 = L1_2.header
        L5_2 = L5_2.topColor
        L5_2 = L5_2.g
        L4_2.g = L5_2
        L5_2 = L1_2.header
        L5_2 = L5_2.topColor
        L5_2 = L5_2.b
        L4_2.b = L5_2
        L3_2.topColor = L4_2
        L4_2 = {}
        L5_2 = L1_2.header
        L5_2 = L5_2.bottomColor
        L5_2 = L5_2.r
        L4_2.r = L5_2
        L5_2 = L1_2.header
        L5_2 = L5_2.bottomColor
        L5_2 = L5_2.g
        L4_2.g = L5_2
        L5_2 = L1_2.header
        L5_2 = L5_2.bottomColor
        L5_2 = L5_2.b
        L4_2.b = L5_2
        L3_2.bottomColor = L4_2
        L2_2 = L3_2
    end
  end
  else
    L3_2 = print
    L4_2 = "^1[Elevator]^7 No header gradient configured"
    L3_2(L4_2)
  end
  L3_2 = RageMenu
  L4_2 = L3_2
  L3_2 = L3_2.CreateMenu
  L5_2 = L1_2.locale
  L5_2 = L5_2["menu-title"]
  L6_2 = L1_2.locale
  L6_2 = L6_2["menu-description"]
  L7_2 = nil
  L8_2 = nil
  L9_2 = nil
  L10_2 = L2_2
  L3_2 = L3_2(L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L1_2.menu = L3_2
  L3_2 = pairs
  L4_2 = L1_2.floors
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = L1_2.menu
    L10_2 = L9_2
    L9_2 = L9_2.AddButton
    L11_2 = L8_2.name
    L12_2 = string
    L12_2 = L12_2.format
    L13_2 = L1_2.locale
    L13_2 = L13_2["floor-description"]
    L14_2 = L8_2.name
    L12_2 = L12_2(L13_2, L14_2)
    L13_2 = L1_2.locale
    L13_2 = L13_2["floor-label"]
    L9_2 = L9_2(L10_2, L11_2, L12_2, L13_2)
    L11_2 = L9_2
    L10_2 = L9_2.On
    L12_2 = "click"
    function L13_2(A0_3)
      local L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3
      L1_3 = L1_2.floors
      L2_3 = L7_2
      L1_3 = L1_3[L2_3]
      L2_3 = GetEntityCoords
      L3_3 = PlayerPedId
      L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3 = L3_3()
      L2_3 = L2_3(L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3)
      L3_3 = vector3
      L4_3 = L1_3.pos
      L4_3 = L4_3.x
      L5_3 = L1_3.pos
      L5_3 = L5_3.y
      L6_3 = L1_3.pos
      L6_3 = L6_3.z
      L3_3 = L3_3(L4_3, L5_3, L6_3)
      L3_3 = L2_3 - L3_3
      L3_3 = #L3_3
      L4_3 = currentFloor
      L5_3 = L7_2
      if L4_3 ~= L5_3 then
        L4_3 = DoScreenFadeOut
        L5_3 = 300
        L4_3(L5_3)
        while true do
          L4_3 = IsScreenFadedOut
          L4_3 = L4_3()
          if L4_3 then
            break
          end
          L4_3 = Wait
          L5_3 = 100
          L4_3(L5_3)
        end
        L4_3 = SetEntityCoordsNoOffset
        L5_3 = PlayerPedId
        L5_3 = L5_3()
        L6_3 = L1_3.pos
        L6_3 = L6_3.x
        L7_3 = L1_3.pos
        L7_3 = L7_3.y
        L8_3 = L1_3.pos
        L8_3 = L8_3.z
        L9_3 = true
        L10_3 = true
        L11_3 = false
        L4_3(L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3)
        L4_3 = SetEntityHeading
        L5_3 = PlayerPedId
        L5_3 = L5_3()
        L6_3 = L1_3.pos
        L6_3 = L6_3.w
        L4_3(L5_3, L6_3)
        L4_3 = DoScreenFadeIn
        L5_3 = 300
        L4_3(L5_3)
        L4_3 = L7_2
        currentFloor = L4_3
      end
    end
    L10_2(L11_2, L12_2, L13_2)
  end
  L4_2 = L1_2
  L3_2 = L1_2.StartThread
  L3_2(L4_2)
  return L1_2
end
L0_1.new = L1_1
L0_1 = Elevator
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = RageMenu
  L3_2 = L2_2
  L2_2 = L2_2.OpenMenu
  L4_2 = A0_2.menu
  L2_2(L3_2, L4_2)
end
L0_1.OpenMenu = L1_1
L0_1 = Elevator
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  A0_2.thread = true
  L1_2 = pairs
  L2_2 = A0_2.floors
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = CreateThread
    function L8_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3
      while true do
        L0_3 = A0_2.thread
        if not L0_3 then
          break
        end
        L0_3 = Wait
        L1_3 = 1
        L0_3(L1_3)
        L0_3 = GetEntityCoords
        L1_3 = PlayerPedId
        L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3 = L1_3()
        L0_3 = L0_3(L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3)
        L1_3 = vector3
        L2_3 = L6_2.pos
        L2_3 = L2_3.x
        L3_3 = L6_2.pos
        L3_3 = L3_3.y
        L4_3 = L6_2.pos
        L4_3 = L4_3.z
        L1_3 = L1_3(L2_3, L3_3, L4_3)
        L1_3 = L0_3 - L1_3
        L1_3 = #L1_3
        if L1_3 < 2 then
          L2_3 = DrawMarker
          L3_3 = A0_2.marker
          L3_3 = L3_3.type
          L4_3 = L6_2.pos
          L4_3 = L4_3.x
          L5_3 = L6_2.pos
          L5_3 = L5_3.y
          L6_3 = L6_2.pos
          L6_3 = L6_3.z
          L7_3 = 0.0
          L8_3 = 0.0
          L9_3 = 0.0
          L10_3 = 0.0
          L11_3 = 0.0
          L12_3 = 0.0
          L13_3 = 0.6
          L14_3 = 0.6
          L15_3 = 0.6
          L16_3 = A0_2.marker
          L16_3 = L16_3.r
          L17_3 = A0_2.marker
          L17_3 = L17_3.g
          L18_3 = A0_2.marker
          L18_3 = L18_3.b
          L19_3 = A0_2.marker
          L19_3 = L19_3.alpha
          L20_3 = false
          L21_3 = true
          L22_3 = 2
          L23_3 = false
          L24_3 = nil
          L25_3 = false
          L2_3(L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3, L12_3, L13_3, L14_3, L15_3, L16_3, L17_3, L18_3, L19_3, L20_3, L21_3, L22_3, L23_3, L24_3, L25_3)
          if L1_3 < 1 then
            L2_3 = Config
            if L2_3 then
              L2_3 = Config
              L2_3 = L2_3.CustomHelpNotify
              if L2_3 then
                L2_3 = type
                L3_3 = Config
                L3_3 = L3_3.CustomHelpNotify
                L2_3 = L2_3(L3_3)
                if "function" == L2_3 then
                  L2_3 = Config
                  L2_3 = L2_3.CustomHelpNotify
                  L3_3 = A0_2.locale
                  L3_3 = L3_3["elevator-help-notify"]
                  L2_3(L3_3)
              end
            end
            else
              L2_3 = AddTextEntry
              L3_3 = "HelpNotify"
              L4_3 = A0_2.locale
              L4_3 = L4_3["elevator-help-notify"]
              L2_3(L3_3, L4_3)
              L2_3 = DisplayHelpTextThisFrame
              L3_3 = "HelpNotify"
              L4_3 = false
              L2_3(L3_3, L4_3)
            end
            L2_3 = IsControlJustReleased
            L3_3 = 0
            L4_3 = 38
            L2_3 = L2_3(L3_3, L4_3)
            if L2_3 then
              L2_3 = print
              L3_3 = "^2[Elevator]^7 E key pressed! Opening menu for floor index:"
              L4_3 = L5_2
              L2_3(L3_3, L4_3)
              L2_3 = A0_2
              L3_3 = L2_3
              L2_3 = L2_3.OpenMenu
              L4_3 = L5_2
              L2_3(L3_3, L4_3)
            end
          else
            L2_3 = RageMenu
            L3_3 = L2_3
            L2_3 = L2_3.IsOpen
            L2_3 = L2_3(L3_3)
            if L2_3 then
              L2_3 = RageMenu
              L3_3 = L2_3
              L2_3 = L2_3.CloseAll
              L2_3(L3_3)
            end
          end
        else
          L2_3 = Wait
          L3_3 = 1000
          L2_3(L3_3)
        end
      end
    end
    L7_2(L8_2)
  end
end
L0_1.StartThread = L1_1
