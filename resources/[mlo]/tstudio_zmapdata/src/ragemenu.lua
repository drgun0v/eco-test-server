local L0_1, L1_1, L2_1, L3_1, L4_1
L0_1 = {}
RageMenu = L0_1
L0_1 = setmetatable
L1_1 = {}
L1_1.__class = "RageMenu"
L1_1.__type = "RageMenu"
L1_1.CurrentMenu = nil
L2_1 = GetCurrentResourceName
L2_1 = L2_1()
L1_1.CurrentResourceName = L2_1
L1_1.Loaded = false
L2_1 = {}
L1_1.Menus = L2_1
L2_1 = {}
L1_1.OpenedMenus = L2_1
L2_1 = {}
L1_1.NUICallbacks = L2_1
L2_1 = {}
L0_1 = L0_1(L1_1, L2_1)
RageMenu = L0_1
function L0_1(A0_2)
  local L1_2, L2_2
  L1_2 = SendNUIMessage
  L2_2 = A0_2
  L1_2(L2_2)
end
function L1_1(A0_2, A1_2)
  local L2_2
  L2_2 = RageMenu
  L2_2 = L2_2.NUICallbacks
  L2_2[A0_2] = A1_2
end
L2_1 = RageMenu
function L3_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2, L9_2
  L5_2 = RegisterKeyMapping
  L6_2 = string
  L6_2 = L6_2.format
  L7_2 = "keys-%s"
  L8_2 = A2_2
  L6_2 = L6_2(L7_2, L8_2)
  L7_2 = A3_2
  L8_2 = "keyboard"
  L9_2 = A1_2
  L5_2(L6_2, L7_2, L8_2, L9_2)
  L5_2 = RegisterCommand
  L6_2 = string
  L6_2 = L6_2.format
  L7_2 = "keys-%s"
  L8_2 = A2_2
  L6_2 = L6_2(L7_2, L8_2)
  function L7_2()
    local L0_3, L1_3
    L0_3 = A4_2
    if nil ~= L0_3 then
      L0_3 = A4_2
      L0_3()
    end
  end
  L8_2 = false
  L5_2(L6_2, L7_2, L8_2)
end
L2_1.RegisterKey = L3_1
L2_1 = RageMenu
function L3_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2, A6_2)
  local L7_2, L8_2, L9_2, L10_2
  L7_2 = {}
  L8_2 = RageMenu
  L9_2 = L8_2
  L8_2 = L8_2.GenerateUUID
  L8_2 = L8_2(L9_2)
  L7_2.uuid = L8_2
  L8_2 = GetCurrentResourceName
  L8_2 = L8_2()
  L7_2.resource = L8_2
  L7_2.title = A1_2
  L7_2.subtitle = A2_2
  L8_2 = A5_2 or L8_2
  if not A5_2 then
    L8_2 = 10
  end
  L7_2.maxItems = L8_2
  L8_2 = A3_2 or L8_2
  if not A3_2 then
    L8_2 = "top-left"
  end
  L7_2.position = L8_2
  L7_2.banner = A4_2
  L7_2.headerGradient = A6_2
  L8_2 = {}
  L7_2.items = L8_2
  function L8_2(A0_3, A1_3)
    local L2_3, L3_3, L4_3, L5_3
    L2_3 = {}
    L3_3 = RageMenu
    L4_3 = L3_3
    L3_3 = L3_3.GenerateUUID
    L3_3 = L3_3(L4_3)
    L2_3.uuid = L3_3
    L2_3.name = A1_3
    L2_3.type = "placeholder"
    function L3_3(A0_4, A1_4)
      local L2_4, L3_4, L4_4, L5_4, L6_4, L7_4
      L2_4 = A0_4
      L3_4 = {}
      L4_4 = L2_4.uuid
      L3_4.uuid = L4_4
      L4_4 = A1_4 or L4_4
      if not A1_4 then
        L4_4 = L2_4.name
      end
      L3_4.name = L4_4
      L3_4.type = "placeholder"
      L4_4 = L0_1
      L5_4 = {}
      L5_4.action = "updateItem"
      L6_4 = {}
      L7_4 = RageMenu
      L7_4 = L7_4.CurrentMenu
      L7_4 = L7_4.uuid
      L6_4.menuUUID = L7_4
      L6_4.oldItem = L2_4
      L6_4.newItem = L3_4
      L5_4.data = L6_4
      L4_4(L5_4)
    end
    L2_3.Update = L3_3
    L3_3 = table
    L3_3 = L3_3.insert
    L4_3 = A0_3.items
    L5_3 = L2_3
    L3_3(L4_3, L5_3)
    return L2_3
  end
  L7_2.AddPlaceholder = L8_2
  function L8_2(A0_3, A1_3, A2_3, A3_3, A4_3, A5_3, A6_3)
    local L7_3, L8_3, L9_3, L10_3
    L7_3 = L7_2
    A1_3.parent = L7_3
    L7_3 = {}
    L8_3 = RageMenu
    L9_3 = L8_3
    L8_3 = L8_3.GenerateUUID
    L8_3 = L8_3(L9_3)
    L7_3.uuid = L8_3
    L7_3.name = A2_3
    L7_3.description = A3_3
    L7_3.background = A6_3
    L7_3.rightLabel = A4_3
    L7_3.disabled = A5_3
    L7_3.type = "button"
    L8_3 = A1_3.uuid
    L7_3.submenu = L8_3
    L8_3 = {}
    L7_3._events = L8_3
    function L8_3(A0_4, A1_4, A2_4)
      local L3_4, L4_4, L5_4
      L3_4 = A0_4._events
      L3_4 = L3_4[A1_4]
      if not L3_4 then
        L3_4 = A0_4._events
        L4_4 = {}
        L3_4[A1_4] = L4_4
      end
      L3_4 = table
      L3_4 = L3_4.insert
      L4_4 = A0_4._events
      L4_4 = L4_4[A1_4]
      L5_4 = A2_4
      L3_4(L4_4, L5_4)
    end
    L7_3.On = L8_3
    function L8_3(A0_4, A1_4, ...)
      local L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4
      L2_4 = A0_4._events
      L2_4 = L2_4[A1_4]
      if L2_4 then
        L2_4 = pairs
        L3_4 = A0_4._events
        L3_4 = L3_4[A1_4]
        L2_4, L3_4, L4_4, L5_4 = L2_4(L3_4)
        for L6_4, L7_4 in L2_4, L3_4, L4_4, L5_4 do
          L8_4 = L7_4
          L9_4 = ...
          L8_4(L9_4)
        end
      end
    end
    L7_3.Trigger = L8_3
    L8_3 = table
    L8_3 = L8_3.insert
    L9_3 = A0_3.items
    L10_3 = L7_3
    L8_3(L9_3, L10_3)
    return L7_3
  end
  L7_2.AddSubmenu = L8_2
  function L8_2(A0_3, A1_3, A2_3, A3_3, A4_3, A5_3)
    local L6_3, L7_3, L8_3, L9_3
    L6_3 = {}
    L7_3 = RageMenu
    L8_3 = L7_3
    L7_3 = L7_3.GenerateUUID
    L7_3 = L7_3(L8_3)
    L6_3.uuid = L7_3
    L6_3.name = A1_3
    L6_3.description = A2_3
    L6_3.background = A5_3
    L6_3.rightLabel = A3_3
    L6_3.disabled = A4_3
    L6_3.type = "button"
    L7_3 = {}
    L6_3._events = L7_3
    function L7_3(A0_4, A1_4, A2_4)
      local L3_4, L4_4, L5_4
      L3_4 = A0_4._events
      L3_4 = L3_4[A1_4]
      if not L3_4 then
        L3_4 = A0_4._events
        L4_4 = {}
        L3_4[A1_4] = L4_4
      end
      L3_4 = table
      L3_4 = L3_4.insert
      L4_4 = A0_4._events
      L4_4 = L4_4[A1_4]
      L5_4 = A2_4
      L3_4(L4_4, L5_4)
    end
    L6_3.On = L7_3
    function L7_3(A0_4, A1_4, ...)
      local L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4
      L2_4 = A0_4._events
      L2_4 = L2_4[A1_4]
      if L2_4 then
        L2_4 = pairs
        L3_4 = A0_4._events
        L3_4 = L3_4[A1_4]
        L2_4, L3_4, L4_4, L5_4 = L2_4(L3_4)
        for L6_4, L7_4 in L2_4, L3_4, L4_4, L5_4 do
          L8_4 = L7_4
          L9_4 = ...
          L8_4(L9_4)
        end
      end
    end
    L6_3.Trigger = L7_3
    function L7_3(A0_4, A1_4, A2_4, A3_4)
      local L4_4
      L4_4 = {}
      L4_4.title = A1_4
      L4_4.image = A2_4
      L4_4.items = A3_4
      A0_4.sidepanel = L4_4
    end
    L6_3.AddSidePanel = L7_3
    function L7_3(A0_4, A1_4, A2_4, A3_4, A4_4)
      local L5_4, L6_4, L7_4, L8_4, L9_4, L10_4
      L5_4 = A0_4
      L6_4 = {}
      L7_4 = L5_4.uuid
      L6_4.uuid = L7_4
      L7_4 = A1_4 or L7_4
      if not A1_4 then
        L7_4 = L5_4.name
      end
      L6_4.name = L7_4
      L7_4 = A2_4 or L7_4
      if not A2_4 then
        L7_4 = L5_4.description
      end
      L6_4.description = L7_4
      L7_4 = A4_4 or L7_4
      if not A4_4 then
        L7_4 = L5_4.background
      end
      L6_4.background = L7_4
      L7_4 = A3_4 or L7_4
      if not A3_4 then
        L7_4 = L5_4.rightLabel
      end
      L6_4.rightLabel = L7_4
      L6_4.type = "button"
      L7_4 = L5_4._events
      L6_4._events = L7_4
      L7_4 = L0_1
      L8_4 = {}
      L8_4.action = "updateItem"
      L9_4 = {}
      L10_4 = RageMenu
      L10_4 = L10_4.CurrentMenu
      L10_4 = L10_4.uuid
      L9_4.menuUUID = L10_4
      L9_4.oldItem = L5_4
      L9_4.newItem = L6_4
      L8_4.data = L9_4
      L7_4(L8_4)
    end
    L6_3.Update = L7_3
    L7_3 = table
    L7_3 = L7_3.insert
    L8_3 = A0_3.items
    L9_3 = L6_3
    L7_3(L8_3, L9_3)
    return L6_3
  end
  L7_2.AddButton = L8_2
  function L8_2(A0_3, A1_3, A2_3, A3_3, A4_3, A5_3, A6_3, A7_3)
    local L8_3, L9_3, L10_3, L11_3
    L8_3 = {}
    L9_3 = RageMenu
    L10_3 = L9_3
    L9_3 = L9_3.GenerateUUID
    L9_3 = L9_3(L10_3)
    L8_3.uuid = L9_3
    L8_3.name = A1_3
    L8_3.description = A2_3
    L8_3.background = A3_3
    L8_3.type = "slider"
    L9_3 = {}
    L10_3 = A4_3 or L10_3
    if not A4_3 then
      L10_3 = 0
    end
    L9_3.min = L10_3
    L10_3 = A5_3 or L10_3
    if not A5_3 then
      L10_3 = 100
    end
    L9_3.max = L10_3
    L10_3 = A6_3 or L10_3
    if not A6_3 then
      L10_3 = 0
    end
    L9_3.value = L10_3
    L10_3 = A7_3 or L10_3
    if not A7_3 then
      L10_3 = 1
    end
    L9_3.step = L10_3
    L8_3.other = L9_3
    L9_3 = {}
    L8_3._events = L9_3
    function L9_3(A0_4, A1_4, A2_4)
      local L3_4, L4_4, L5_4
      L3_4 = A0_4._events
      L3_4 = L3_4[A1_4]
      if not L3_4 then
        L3_4 = A0_4._events
        L4_4 = {}
        L3_4[A1_4] = L4_4
      end
      L3_4 = table
      L3_4 = L3_4.insert
      L4_4 = A0_4._events
      L4_4 = L4_4[A1_4]
      L5_4 = A2_4
      L3_4(L4_4, L5_4)
    end
    L8_3.On = L9_3
    function L9_3(A0_4, A1_4, ...)
      local L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4
      L2_4 = A0_4._events
      L2_4 = L2_4[A1_4]
      if L2_4 then
        L2_4 = pairs
        L3_4 = A0_4._events
        L3_4 = L3_4[A1_4]
        L2_4, L3_4, L4_4, L5_4 = L2_4(L3_4)
        for L6_4, L7_4 in L2_4, L3_4, L4_4, L5_4 do
          L8_4 = L7_4
          L9_4 = ...
          L8_4(L9_4)
        end
      end
    end
    L8_3.Trigger = L9_3
    L9_3 = table
    L9_3 = L9_3.insert
    L10_3 = A0_3.items
    L11_3 = L8_3
    L9_3(L10_3, L11_3)
    return L8_3
  end
  L7_2.AddSlider = L8_2
  function L8_2(A0_3, A1_3, A2_3, A3_3, A4_3, A5_3)
    local L6_3, L7_3, L8_3, L9_3
    L6_3 = {}
    L7_3 = RageMenu
    L8_3 = L7_3
    L7_3 = L7_3.GenerateUUID
    L7_3 = L7_3(L8_3)
    L6_3.uuid = L7_3
    L6_3.name = A1_3
    L6_3.description = A2_3
    L6_3.background = A3_3
    L6_3.type = "list"
    L7_3 = {}
    L8_3 = type
    if not L8_3 then
      L8_3 = "default"
    end
    L7_3.type = L8_3
    L8_3 = A4_3 or L8_3
    if not A4_3 then
      L8_3 = {}
    end
    L7_3.items = L8_3
    L8_3 = A5_3 - 1
    if not L8_3 then
      L8_3 = 0
    end
    L7_3.current = L8_3
    L6_3.other = L7_3
    L7_3 = {}
    L6_3._events = L7_3
    function L7_3(A0_4, A1_4, A2_4)
      local L3_4, L4_4, L5_4
      L3_4 = A0_4._events
      L3_4 = L3_4[A1_4]
      if not L3_4 then
        L3_4 = A0_4._events
        L4_4 = {}
        L3_4[A1_4] = L4_4
      end
      L3_4 = table
      L3_4 = L3_4.insert
      L4_4 = A0_4._events
      L4_4 = L4_4[A1_4]
      L5_4 = A2_4
      L3_4(L4_4, L5_4)
    end
    L6_3.On = L7_3
    function L7_3(A0_4, A1_4, ...)
      local L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4
      L2_4 = A0_4._events
      L2_4 = L2_4[A1_4]
      if L2_4 then
        L2_4 = pairs
        L3_4 = A0_4._events
        L3_4 = L3_4[A1_4]
        L2_4, L3_4, L4_4, L5_4 = L2_4(L3_4)
        for L6_4, L7_4 in L2_4, L3_4, L4_4, L5_4 do
          L8_4 = L7_4
          L9_4 = ...
          L8_4(L9_4)
        end
      end
    end
    L6_3.Trigger = L7_3
    L7_3 = table
    L7_3 = L7_3.insert
    L8_3 = A0_3.items
    L9_3 = L6_3
    L7_3(L8_3, L9_3)
    return L6_3
  end
  L7_2.AddList = L8_2
  function L8_2(A0_3, A1_3, A2_3, A3_3, A4_3)
    local L5_3, L6_3, L7_3, L8_3
    L5_3 = {}
    L6_3 = RageMenu
    L7_3 = L6_3
    L6_3 = L6_3.GenerateUUID
    L6_3 = L6_3(L7_3)
    L5_3.uuid = L6_3
    L5_3.name = A1_3
    L5_3.description = A2_3
    L5_3.background = A3_3
    L5_3.type = "checkbox"
    L6_3 = {}
    L7_3 = A4_3 or L7_3
    if not A4_3 then
      L7_3 = false
    end
    L6_3.checked = L7_3
    L5_3.other = L6_3
    L6_3 = {}
    L5_3._events = L6_3
    function L6_3(A0_4, A1_4, A2_4)
      local L3_4, L4_4, L5_4
      L3_4 = A0_4._events
      L3_4 = L3_4[A1_4]
      if not L3_4 then
        L3_4 = A0_4._events
        L4_4 = {}
        L3_4[A1_4] = L4_4
      end
      L3_4 = table
      L3_4 = L3_4.insert
      L4_4 = A0_4._events
      L4_4 = L4_4[A1_4]
      L5_4 = A2_4
      L3_4(L4_4, L5_4)
    end
    L5_3.On = L6_3
    function L6_3(A0_4, A1_4, ...)
      local L2_4, L3_4, L4_4, L5_4, L6_4, L7_4, L8_4, L9_4
      L2_4 = A0_4._events
      L2_4 = L2_4[A1_4]
      if L2_4 then
        L2_4 = pairs
        L3_4 = A0_4._events
        L3_4 = L3_4[A1_4]
        L2_4, L3_4, L4_4, L5_4 = L2_4(L3_4)
        for L6_4, L7_4 in L2_4, L3_4, L4_4, L5_4 do
          L8_4 = L7_4
          L9_4 = ...
          L8_4(L9_4)
        end
      end
    end
    L5_3.Trigger = L6_3
    L6_3 = table
    L6_3 = L6_3.insert
    L7_3 = A0_3.items
    L8_3 = L5_3
    L6_3(L7_3, L8_3)
    return L5_3
  end
  L7_2.AddCheckbox = L8_2
  function L8_2(A0_3, A1_3)
    local L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3
    L2_3 = pairs
    L3_3 = A0_3.items
    L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
    for L6_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
      L8_3 = L7_3.uuid
      L9_3 = A1_3.uuid
      if L8_3 == L9_3 then
        L8_3 = table
        L8_3 = L8_3.remove
        L9_3 = A0_3.items
        L10_3 = L6_3
        L8_3(L9_3, L10_3)
        L8_3 = L7_2
        L9_3 = L8_3
        L8_3 = L8_3.Reopen
        L8_3(L9_3)
      end
    end
  end
  L7_2.RemoveItem = L8_2
  function L8_2(A0_3)
    local L1_3, L2_3, L3_3
    L1_3 = RageMenu
    L2_3 = L1_3
    L1_3 = L1_3.Close
    L3_3 = L7_2
    L1_3(L2_3, L3_3)
    L1_3 = Wait
    L2_3 = 100
    L1_3(L2_3)
    L1_3 = RageMenu
    L2_3 = L1_3
    L1_3 = L1_3.OpenMenu
    L3_3 = L7_2
    L1_3(L2_3, L3_3)
  end
  L7_2.Reopen = L8_2
  L8_2 = table
  L8_2 = L8_2.insert
  L9_2 = RageMenu
  L9_2 = L9_2.Menus
  L10_2 = L7_2
  L8_2(L9_2, L10_2)
  L8_2 = L7_2 or L8_2
  if not L7_2 then
    L8_2 = {}
  end
  return L8_2
end
L2_1.CreateMenu = L3_1
L2_1 = RageMenu
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  if A1_2 then
    L2_2 = A1_2.uuid
    if L2_2 then
      goto lbl_7
    end
  end
  do return end
  ::lbl_7::
  L2_2 = {}
  L3_2 = pairs
  L4_2 = A1_2.items
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = {}
    L10_2 = pairs
    L11_2 = L8_2
    L10_2, L11_2, L12_2, L13_2 = L10_2(L11_2)
    for L14_2, L15_2 in L10_2, L11_2, L12_2, L13_2 do
      L16_2 = type
      L17_2 = L15_2
      L16_2 = L16_2(L17_2)
      if "function" ~= L16_2 and "_events" ~= L14_2 then
        L9_2[L14_2] = L15_2
      end
    end
    L10_2 = table
    L10_2 = L10_2.insert
    L11_2 = L2_2
    L12_2 = L9_2
    L10_2(L11_2, L12_2)
  end
  L3_2 = nil
  L4_2 = A1_2.headerGradient
  if L4_2 then
    L4_2 = A1_2.headerGradient
    L4_2 = L4_2.topColor
    if L4_2 then
      L4_2 = A1_2.headerGradient
      L4_2 = L4_2.bottomColor
      if L4_2 then
        L4_2 = {}
        L5_2 = {}
        L6_2 = A1_2.headerGradient
        L6_2 = L6_2.topColor
        L6_2 = L6_2.r
        L5_2.r = L6_2
        L6_2 = A1_2.headerGradient
        L6_2 = L6_2.topColor
        L6_2 = L6_2.g
        L5_2.g = L6_2
        L6_2 = A1_2.headerGradient
        L6_2 = L6_2.topColor
        L6_2 = L6_2.b
        L5_2.b = L6_2
        L4_2.topColor = L5_2
        L5_2 = {}
        L6_2 = A1_2.headerGradient
        L6_2 = L6_2.bottomColor
        L6_2 = L6_2.r
        L5_2.r = L6_2
        L6_2 = A1_2.headerGradient
        L6_2 = L6_2.bottomColor
        L6_2 = L6_2.g
        L5_2.g = L6_2
        L6_2 = A1_2.headerGradient
        L6_2 = L6_2.bottomColor
        L6_2 = L6_2.b
        L5_2.b = L6_2
        L4_2.bottomColor = L5_2
        L3_2 = L4_2
      end
    end
  end
  L4_2 = {}
  L5_2 = A1_2.uuid
  L4_2.uuid = L5_2
  L5_2 = A1_2.resource
  L4_2.resource = L5_2
  L5_2 = A1_2.title
  L4_2.title = L5_2
  L5_2 = A1_2.subtitle
  L4_2.subtitle = L5_2
  L5_2 = A1_2.maxItems
  L4_2.maxItems = L5_2
  L5_2 = A1_2.position
  L4_2.position = L5_2
  L5_2 = A1_2.banner
  L4_2.banner = L5_2
  L4_2.headerGradient = L3_2
  L4_2.items = L2_2
  L5_2 = L0_1
  L6_2 = {}
  L6_2.action = "setVisible"
  L7_2 = {}
  L7_2.visible = true
  L7_2.data = L4_2
  L6_2.data = L7_2
  L5_2(L6_2)
  L5_2 = RageMenu
  L5_2.CurrentMenu = A1_2
  L5_2 = table
  L5_2 = L5_2.insert
  L6_2 = RageMenu
  L6_2 = L6_2.OpenedMenus
  L7_2 = A1_2
  L5_2(L6_2, L7_2)
end
L2_1.OpenMenu = L3_1
L2_1 = RageMenu
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = RageMenu
  L2_2 = L2_2.CurrentMenu
  if L2_2 then
    L2_2 = L0_1
    L3_2 = {}
    L3_2.action = "setVisible"
    L4_2 = {}
    L4_2.visible = false
    L5_2 = {}
    L4_2.data = L5_2
    L3_2.data = L4_2
    L2_2(L3_2)
    L2_2 = RageMenu
    L2_2.CurrentMenu = nil
    L2_2 = RageMenu
    L3_2 = L2_2
    L2_2 = L2_2.RemoveOpenedMenu
    L4_2 = A1_2.uuid
    L2_2(L3_2, L4_2)
  end
end
L2_1.Close = L3_1
L2_1 = RageMenu
function L3_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = RageMenu
  L1_2 = L1_2.CurrentMenu
  if L1_2 then
    L1_2 = L0_1
    L2_2 = {}
    L2_2.action = "setVisible"
    L3_2 = {}
    L3_2.visible = false
    L4_2 = {}
    L3_2.data = L4_2
    L2_2.data = L3_2
    L1_2(L2_2)
    L1_2 = RageMenu
    L2_2 = {}
    L1_2.OpenedMenus = L2_2
    L1_2 = RageMenu
    L1_2.CurrentMenu = nil
  end
end
L2_1.CloseAll = L3_1
L2_1 = RageMenu
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2
  if not A1_2 then
    return
  end
  L2_2 = RageMenu
  L2_2 = L2_2.CurrentMenu
  L3_2 = nil ~= A1_2
  L4_2 = RageMenu
  L5_2 = L4_2
  L4_2 = L4_2.Close
  L6_2 = L2_2
  L4_2(L5_2, L6_2)
  L4_2 = RageMenu
  L5_2 = L4_2
  L4_2 = L4_2.PlaySound
  L6_2 = "Back"
  L4_2(L5_2, L6_2)
  if L3_2 then
    L4_2 = RageMenu
    L5_2 = L4_2
    L4_2 = L4_2.OpenMenu
    L6_2 = L2_2.parent
    return L4_2(L5_2, L6_2)
  end
end
L2_1.GoBack = L3_1
L2_1 = RageMenu
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L2_2 = RageMenu
  L2_2 = L2_2.CurrentMenu
  if L2_2 then
    L2_2 = pairs
    L3_2 = RageMenu
    L3_2 = L3_2.CurrentMenu
    L3_2 = L3_2.items
    L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
    for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
      L8_2 = L7_2.uuid
      L9_2 = A1_2.uuid
      if L8_2 == L9_2 then
        L8_2 = L7_2.disabled
        if L8_2 then
          L8_2 = RageMenu
          L9_2 = L8_2
          L8_2 = L8_2.PlaySound
          L10_2 = "Error"
          L8_2, L9_2, L10_2, L11_2, L12_2 = L8_2(L9_2, L10_2)
          return L8_2, L9_2, L10_2, L11_2, L12_2
        end
        L8_2 = L7_2.submenu
        L8_2 = nil ~= L8_2
        if L8_2 then
          L9_2 = RageMenu
          L10_2 = L9_2
          L9_2 = L9_2.GetMenuByUUID
          L11_2 = L7_2.submenu
          L9_2 = L9_2(L10_2, L11_2)
          if not L9_2 then
          else
            L10_2 = RageMenu
            L11_2 = L10_2
            L10_2 = L10_2.Close
            L12_2 = RageMenu
            L12_2 = L12_2.CurrentMenu
            L10_2(L11_2, L12_2)
            L10_2 = RageMenu
            L11_2 = L10_2
            L10_2 = L10_2.OpenMenu
            L12_2 = L9_2
            L10_2(L11_2, L12_2)
            L10_2 = table
            L10_2 = L10_2.insert
            L11_2 = RageMenu
            L11_2 = L11_2.OpenedMenus
            L12_2 = L9_2
            L10_2(L11_2, L12_2)
          end
        end
        L9_2 = RageMenu
        L10_2 = L9_2
        L9_2 = L9_2.PlaySound
        L11_2 = "Select"
        L9_2(L10_2, L11_2)
        L10_2 = L7_2
        L9_2 = L7_2.Trigger
        L11_2 = "click"
        L12_2 = L7_2
        L9_2(L10_2, L11_2, L12_2)
      end
    end
  end
end
L2_1.SelectItem = L3_1
L2_1 = RageMenu
function L3_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L3_2 = RageMenu
  L3_2 = L3_2.CurrentMenu
  if L3_2 then
    L3_2 = GetCurrentResourceName
    L3_2 = L3_2()
    if "ragemenu" ~= L3_2 then
      L3_2 = pairs
      L4_2 = RageMenu
      L4_2 = L4_2.CurrentMenu
      L4_2 = L4_2.items
      L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
      for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
        L9_2 = L8_2.uuid
        L10_2 = A1_2.uuid
        if L9_2 == L10_2 then
          L9_2 = L8_2.type
          if "placeholder" ~= L9_2 then
            L9_2 = L8_2.type
            if "slider" == L9_2 then
              L9_2 = RageMenu
              L10_2 = L9_2
              L9_2 = L9_2.PlaySound
              L11_2 = "Slider"
              L9_2(L10_2, L11_2)
            else
              L9_2 = L8_2.type
              if "list" == L9_2 then
                L9_2 = RageMenu
                L10_2 = L9_2
                L9_2 = L9_2.PlaySound
                L11_2 = "LeftRight"
                L9_2(L10_2, L11_2)
              else
                L9_2 = L8_2.type
                if "checkbox" == L9_2 then
                  L9_2 = RageMenu
                  L10_2 = L9_2
                  L9_2 = L9_2.PlaySound
                  L11_2 = "Select"
                  L9_2(L10_2, L11_2)
                end
              end
            end
            L10_2 = L8_2
            L9_2 = L8_2.Trigger
            L11_2 = "change"
            L12_2 = A2_2
            L13_2 = A1_2
            L9_2(L10_2, L11_2, L12_2, L13_2)
          end
        end
      end
    end
  end
end
L2_1.ChangeItem = L3_1
L2_1 = RageMenu
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L2_2 = {}
  L3_2 = {}
  L3_2.audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET"
  L3_2.audioRef = "NAV_UP_DOWN"
  L3_2.loop = false
  L2_2.UpDown = L3_2
  L3_2 = {}
  L3_2.audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET"
  L3_2.audioRef = "NAV_LEFT_RIGHT"
  L3_2.loop = false
  L2_2.LeftRight = L3_2
  L3_2 = {}
  L3_2.audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET"
  L3_2.audioRef = "SELECT"
  L3_2.loop = false
  L2_2.Select = L3_2
  L3_2 = {}
  L3_2.audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET"
  L3_2.audioRef = "BACK"
  L3_2.loop = false
  L2_2.Back = L3_2
  L3_2 = {}
  L3_2.audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET"
  L3_2.audioRef = "ERROR"
  L3_2.loop = false
  L2_2.Error = L3_2
  L3_2 = {}
  L3_2.audioName = "HUD_FRONTEND_DEFAULT_SOUNDSET"
  L3_2.audioRef = "CONTINUOUS_SLIDER"
  L3_2.loop = true
  L2_2.Slider = L3_2
  L3_2 = L2_2[A1_2]
  if not L3_2 then
    return
  end
  L3_2 = L2_2[A1_2]
  L3_2 = L3_2.loop
  L4_2 = L2_2[A1_2]
  L4_2 = L4_2.audioRef
  L5_2 = L2_2[A1_2]
  L5_2 = L5_2.audioName
  L6_2 = nil
  if not L3_2 then
    L7_2 = PlaySoundFrontend
    L8_2 = -1
    L9_2 = L4_2
    L10_2 = L5_2
    L11_2 = true
    L7_2(L8_2, L9_2, L10_2, L11_2)
  elseif not L6_2 then
    L7_2 = Citizen
    L7_2 = L7_2.CreateThread
    function L8_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3
      L0_3 = GetSoundId
      L0_3 = L0_3()
      L6_2 = L0_3
      L0_3 = PlaySoundFrontend
      L1_3 = L6_2
      L2_3 = L4_2
      L3_3 = L5_2
      L4_3 = true
      L0_3(L1_3, L2_3, L3_3, L4_3)
      L0_3 = Citizen
      L0_3 = L0_3.Wait
      L1_3 = 0.01
      L0_3(L1_3)
      L0_3 = StopSound
      L1_3 = L6_2
      L0_3(L1_3)
      L0_3 = ReleaseSoundId
      L1_3 = L6_2
      L0_3(L1_3)
      L0_3 = nil
      L6_2 = L0_3
    end
    L7_2(L8_2)
  end
end
L2_1.PlaySound = L3_1
L2_1 = RageMenu
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  L2_2 = pairs
  L3_2 = RageMenu
  L3_2 = L3_2.Menus
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = L7_2.uuid
    if L8_2 == A1_2 then
      return L7_2
    end
  end
end
L2_1.GetMenuByUUID = L3_1
L2_1 = RageMenu
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L2_2 = pairs
  L3_2 = RageMenu
  L3_2 = L3_2.OpenedMenus
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = L7_2.uuid
    if L8_2 == A1_2 then
      L8_2 = table
      L8_2 = L8_2.remove
      L9_2 = RageMenu
      L9_2 = L9_2.OpenedMenus
      L10_2 = L6_2
      L8_2(L9_2, L10_2)
    end
  end
end
L2_1.RemoveOpenedMenu = L3_1
L2_1 = RageMenu
function L3_1(A0_2)
  local L1_2
  L1_2 = RageMenu
  L1_2 = L1_2.CurrentMenu
  L1_2 = nil ~= L1_2
  return L1_2
end
L2_1.IsOpen = L3_1
L2_1 = RageMenu
function L3_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2
  function L1_2(A0_3)
    local L1_3, L2_3, L3_3, L4_3, L5_3
    L1_3 = math
    L1_3 = L1_3.random
    L2_3 = 16
    L1_3 = L1_3(L2_3)
    L1_3 = L1_3 - 1
    if "x" == A0_3 then
      L2_3 = L1_3 + 1
      if L2_3 then
        goto lbl_17
        L1_3 = L2_3 or L1_3
      end
    end
    L2_3 = L1_3 % 4
    L1_3 = L2_3 + 9
    ::lbl_17::
    L2_3 = "0123456789abcdef"
    L3_3 = L2_3
    L2_3 = L2_3.sub
    L4_3 = L1_3
    L5_3 = L1_3
    return L2_3(L3_3, L4_3, L5_3)
  end
  L2_2 = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  L3_2 = L2_2
  L2_2 = L2_2.gsub
  L4_2 = "[xy]"
  L5_2 = L1_2
  L2_2 = L2_2(L3_2, L4_2, L5_2)
  return L2_2
end
L2_1.GenerateUUID = L3_1
L2_1 = RageMenu
function L3_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  if not A1_2 then
    return
  end
  L2_2 = L0_1
  L3_2 = {}
  L3_2.action = "copyClipboard"
  L4_2 = {}
  L4_2.value = A1_2
  L3_2.data = L4_2
  L2_2(L3_2)
end
L2_1.CopyClipboard = L3_1
L2_1 = L1_1
L3_1 = "activeItem"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = A1_2
  L3_2 = true
  L2_2(L3_2)
end
L2_1(L3_1, L4_1)
L2_1 = L1_1
L3_1 = "upDownSound"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = RageMenu
  L3_2 = L2_2
  L2_2 = L2_2.PlaySound
  L4_2 = "UpDown"
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = true
  L2_2(L3_2)
end
L2_1(L3_1, L4_1)
L2_1 = L1_1
L3_1 = "selectItem"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = A0_2.item
  L3_2 = RageMenu
  L4_2 = L3_2
  L3_2 = L3_2.SelectItem
  L5_2 = L2_2
  L3_2(L4_2, L5_2)
  L3_2 = A1_2
  L4_2 = true
  L3_2(L4_2)
end
L2_1(L3_1, L4_1)
L2_1 = L1_1
L3_1 = "changeItem"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L2_2 = A0_2.oldItem
  L3_2 = A0_2.newItem
  L4_2 = RageMenu
  L5_2 = L4_2
  L4_2 = L4_2.ChangeItem
  L6_2 = L2_2
  L7_2 = L3_2
  L4_2(L5_2, L6_2, L7_2)
  L4_2 = A1_2
  L5_2 = true
  L4_2(L5_2)
end
L2_1(L3_1, L4_1)
L2_1 = L1_1
L3_1 = "closeMenu"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = RageMenu
  L3_2 = L2_2
  L2_2 = L2_2.GoBack
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = A1_2
  L3_2 = true
  L2_2(L3_2)
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNUICallback
L3_1 = "activeItem"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = RageMenu
  L2_2 = L2_2.NUICallbacks
  L2_2 = L2_2.activeItem
  if L2_2 then
    L2_2 = RageMenu
    L2_2 = L2_2.NUICallbacks
    L2_2 = L2_2.activeItem
    L3_2 = A0_2
    L4_2 = A1_2
    L2_2(L3_2, L4_2)
  end
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNUICallback
L3_1 = "upDownSound"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = RageMenu
  L2_2 = L2_2.NUICallbacks
  L2_2 = L2_2.upDownSound
  if L2_2 then
    L2_2 = RageMenu
    L2_2 = L2_2.NUICallbacks
    L2_2 = L2_2.upDownSound
    L3_2 = A0_2
    L4_2 = A1_2
    L2_2(L3_2, L4_2)
  end
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNUICallback
L3_1 = "selectItem"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = RageMenu
  L2_2 = L2_2.NUICallbacks
  L2_2 = L2_2.selectItem
  if L2_2 then
    L2_2 = RageMenu
    L2_2 = L2_2.NUICallbacks
    L2_2 = L2_2.selectItem
    L3_2 = A0_2
    L4_2 = A1_2
    L2_2(L3_2, L4_2)
  end
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNUICallback
L3_1 = "changeItem"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = RageMenu
  L2_2 = L2_2.NUICallbacks
  L2_2 = L2_2.changeItem
  if L2_2 then
    L2_2 = RageMenu
    L2_2 = L2_2.NUICallbacks
    L2_2 = L2_2.changeItem
    L3_2 = A0_2
    L4_2 = A1_2
    L2_2(L3_2, L4_2)
  end
end
L2_1(L3_1, L4_1)
L2_1 = RegisterNUICallback
L3_1 = "closeMenu"
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2
  L2_2 = RageMenu
  L2_2 = L2_2.NUICallbacks
  L2_2 = L2_2.closeMenu
  if L2_2 then
    L2_2 = RageMenu
    L2_2 = L2_2.NUICallbacks
    L2_2 = L2_2.closeMenu
    L3_2 = A0_2
    L4_2 = A1_2
    L2_2(L3_2, L4_2)
  end
end
L2_1(L3_1, L4_1)
L2_1 = exports
L3_1 = "NUICallback"
function L4_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2, L5_2
  L3_2 = RageMenu
  L3_2 = L3_2.NUICallbacks
  if nil ~= L3_2 then
    L3_2 = RageMenu
    L3_2 = L3_2.NUICallbacks
    L3_2 = L3_2[A0_2]
    if nil ~= L3_2 then
      goto lbl_14
    end
  end
  L3_2 = print
  L4_2 = "Not found"
  do return L3_2(L4_2) end
  ::lbl_14::
  L3_2 = RageMenu
  L3_2 = L3_2.NUICallbacks
  L3_2 = L3_2[A0_2]
  L4_2 = A1_2
  L5_2 = A2_2
  L3_2(L4_2, L5_2)
end
L2_1(L3_1, L4_1)
L2_1 = CreateThread
function L3_1()
  local L0_2, L1_2, L2_2, L3_2
  while true do
    L0_2 = Wait
    L1_2 = 0
    L0_2(L1_2)
    L0_2 = RageMenu
    L1_2 = L0_2
    L0_2 = L0_2.IsOpen
    L0_2 = L0_2(L1_2)
    if L0_2 then
      L0_2 = DisableAllControlActions
      L1_2 = 0
      L0_2(L1_2)
      L0_2 = EnableControlAction
      L1_2 = 0
      L2_2 = 1
      L3_2 = true
      L0_2(L1_2, L2_2, L3_2)
      L0_2 = EnableControlAction
      L1_2 = 0
      L2_2 = 2
      L3_2 = true
      L0_2(L1_2, L2_2, L3_2)
      L0_2 = EnableControlAction
      L1_2 = 0
      L2_2 = 21
      L3_2 = true
      L0_2(L1_2, L2_2, L3_2)
      L0_2 = EnableControlAction
      L1_2 = 0
      L2_2 = 30
      L3_2 = true
      L0_2(L1_2, L2_2, L3_2)
      L0_2 = EnableControlAction
      L1_2 = 0
      L2_2 = 31
      L3_2 = true
      L0_2(L1_2, L2_2, L3_2)
      L0_2 = EnableControlAction
      L1_2 = 0
      L2_2 = 32
      L3_2 = true
      L0_2(L1_2, L2_2, L3_2)
      L0_2 = EnableControlAction
      L1_2 = 0
      L2_2 = 33
      L3_2 = true
      L0_2(L1_2, L2_2, L3_2)
      L0_2 = EnableControlAction
      L1_2 = 0
      L2_2 = 34
      L3_2 = true
      L0_2(L1_2, L2_2, L3_2)
      L0_2 = EnableControlAction
      L1_2 = 0
      L2_2 = 35
      L3_2 = true
      L0_2(L1_2, L2_2, L3_2)
    end
  end
end
L2_1(L3_1)
