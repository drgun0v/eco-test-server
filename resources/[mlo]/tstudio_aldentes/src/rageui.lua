local L0_1, L1_1, L2_1
L0_1 = setmetatable
L1_1 = {}
L2_1 = RageUI
L0_1 = L0_1(L1_1, L2_1)
RageUI = L0_1
L0_1 = RageUI
L1_1 = RageUI
L0_1.__index = L1_1
L0_1 = RageUI
L0_1.CurrentMenu = nil
L0_1 = RageUI
L1_1 = {}
L0_1.OpenedMenus = L1_1
L0_1 = RageUI
function L1_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2
  L5_2 = {}
  L5_2.Name = A1_2
  L5_2.Title = A2_2
  L5_2.Subtitle = A3_2
  L6_2 = A4_2 or L6_2
  if not A4_2 then
    L6_2 = {}
  end
  L5_2.Options = L6_2
  L6_2 = {}
  L5_2.Items = L6_2
  L5_2._Visible = false
  L6_2 = {}
  L5_2._Events = L6_2
  function L6_2(A0_3, A1_3, A2_3)
    local L3_3, L4_3, L5_3
    L3_3 = A0_3._Events
    L3_3 = L3_3[A1_3]
    if not L3_3 then
      L3_3 = A0_3._Events
      L4_3 = {}
      L3_3[A1_3] = L4_3
    end
    L3_3 = table
    L3_3 = L3_3.insert
    L4_3 = A0_3._Events
    L4_3 = L4_3[A1_3]
    L5_3 = A2_3
    L3_3(L4_3, L5_3)
  end
  L5_2.On = L6_2
  function L6_2(A0_3, A1_3, A2_3)
    local L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3
    L3_3 = A0_3._Events
    L3_3 = L3_3[A1_3]
    if L3_3 then
      L3_3 = pairs
      L4_3 = A0_3._Events
      L4_3 = L4_3[A1_3]
      L3_3, L4_3, L5_3, L6_3 = L3_3(L4_3)
      for L7_3, L8_3 in L3_3, L4_3, L5_3, L6_3 do
        L9_3 = L8_3
        L10_3 = A2_3
        L9_3(L10_3)
      end
    end
  end
  L5_2.Trigger = L6_2
  L6_2 = setmetatable
  L7_2 = L5_2
  L8_2 = RageUI
  return L6_2(L7_2, L8_2)
end
L0_1.Create = L1_1
L0_1 = RageUI
function L1_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2)
  local L6_2, L7_2, L8_2, L9_2
  L6_2 = {}
  L6_2.type = "button"
  L6_2.label = A1_2
  L6_2.description = A2_2
  L6_2.rightLabel = A3_2
  L6_2.background = A5_2
  L6_2.options = A4_2
  L7_2 = uuid
  L7_2 = L7_2()
  L6_2.uuid = L7_2
  L7_2 = {}
  L6_2._Events = L7_2
  function L7_2(A0_3, A1_3, A2_3)
    local L3_3, L4_3, L5_3
    L3_3 = A0_3._Events
    L3_3 = L3_3[A1_3]
    if not L3_3 then
      L3_3 = A0_3._Events
      L4_3 = {}
      L3_3[A1_3] = L4_3
    end
    L3_3 = table
    L3_3 = L3_3.insert
    L4_3 = A0_3._Events
    L4_3 = L4_3[A1_3]
    L5_3 = A2_3
    L3_3(L4_3, L5_3)
  end
  L6_2.On = L7_2
  function L7_2(A0_3, A1_3, ...)
    local L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3
    L2_3 = A0_3._Events
    L2_3 = L2_3[A1_3]
    if L2_3 then
      L2_3 = pairs
      L3_3 = A0_3._Events
      L3_3 = L3_3[A1_3]
      L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
      for L6_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
        L8_3 = L7_3
        L9_3 = ...
        L8_3(L9_3)
      end
    end
  end
  L6_2.Trigger = L7_2
  L7_2 = table
  L7_2 = L7_2.insert
  L8_2 = A0_2.Items
  L9_2 = L6_2
  L7_2(L8_2, L9_2)
  L7_2 = setmetatable
  L8_2 = L6_2
  L9_2 = RageUI
  return L7_2(L8_2, L9_2)
end
L0_1.Button = L1_1
L0_1 = RageUI
function L1_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2
  L5_2 = {}
  L5_2.type = "checkbox"
  L5_2.label = A1_2
  L5_2.description = A2_2
  L6_2 = uuid
  L6_2 = L6_2()
  L5_2.uuid = L6_2
  L6_2 = {}
  L7_2 = A3_2 or L7_2
  if not A3_2 then
    L7_2 = false
  end
  L6_2.checked = L7_2
  if A4_2 then
    L7_2 = A4_2.style
    if L7_2 then
      goto lbl_21
    end
  end
  L7_2 = "tick"
  ::lbl_21::
  L6_2.style = L7_2
  L5_2.options = L6_2
  L6_2 = {}
  L5_2._Events = L6_2
  function L6_2(A0_3, A1_3, A2_3)
    local L3_3, L4_3, L5_3
    L3_3 = A0_3._Events
    L3_3 = L3_3[A1_3]
    if not L3_3 then
      L3_3 = A0_3._Events
      L4_3 = {}
      L3_3[A1_3] = L4_3
    end
    L3_3 = table
    L3_3 = L3_3.insert
    L4_3 = A0_3._Events
    L4_3 = L4_3[A1_3]
    L5_3 = A2_3
    L3_3(L4_3, L5_3)
  end
  L5_2.On = L6_2
  function L6_2(A0_3, A1_3, ...)
    local L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3
    L2_3 = A0_3._Events
    L2_3 = L2_3[A1_3]
    if L2_3 then
      L2_3 = pairs
      L3_3 = A0_3._Events
      L3_3 = L3_3[A1_3]
      L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
      for L6_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
        L8_3 = L7_3
        L9_3 = ...
        L8_3(L9_3)
      end
    end
  end
  L5_2.Trigger = L6_2
  L6_2 = table
  L6_2 = L6_2.insert
  L7_2 = A0_2.Items
  L8_2 = L5_2
  L6_2(L7_2, L8_2)
  L6_2 = setmetatable
  L7_2 = L5_2
  L8_2 = RageUI
  return L6_2(L7_2, L8_2)
end
L0_1.Checkbox = L1_1
L0_1 = RageUI
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2
  L2_2 = {}
  L2_2.type = "placeholder"
  L2_2.label = A1_2
  L3_2 = uuid
  L3_2 = L3_2()
  L2_2.uuid = L3_2
  L3_2 = {}
  L2_2._Events = L3_2
  L3_2 = table
  L3_2 = L3_2.insert
  L4_2 = A0_2.Items
  L5_2 = L2_2
  L3_2(L4_2, L5_2)
  L3_2 = setmetatable
  L4_2 = L2_2
  L5_2 = RageUI
  return L3_2(L4_2, L5_2)
end
L0_1.Placeholder = L1_1
L0_1 = RageUI
function L1_1(A0_2, A1_2, A2_2, A3_2, A4_2, A5_2)
  local L6_2, L7_2, L8_2, L9_2
  L6_2 = {}
  L6_2.type = "slider"
  L6_2.label = A1_2
  L7_2 = A2_2 or L7_2
  if not A2_2 then
    L7_2 = nil
  end
  L6_2.description = L7_2
  L7_2 = uuid
  L7_2 = L7_2()
  L6_2.uuid = L7_2
  L7_2 = {}
  L8_2 = A3_2 or L8_2
  if not A3_2 then
    L8_2 = 0
  end
  L7_2.min = L8_2
  L8_2 = A4_2 or L8_2
  if not A4_2 then
    L8_2 = 100
  end
  L7_2.max = L8_2
  L8_2 = A5_2 or L8_2
  if not A5_2 then
    L8_2 = 0
  end
  L7_2.current = L8_2
  L6_2.options = L7_2
  L7_2 = {}
  L6_2._Events = L7_2
  function L7_2(A0_3, A1_3, A2_3)
    local L3_3, L4_3, L5_3
    L3_3 = A0_3._Events
    L3_3 = L3_3[A1_3]
    if not L3_3 then
      L3_3 = A0_3._Events
      L4_3 = {}
      L3_3[A1_3] = L4_3
    end
    L3_3 = table
    L3_3 = L3_3.insert
    L4_3 = A0_3._Events
    L4_3 = L4_3[A1_3]
    L5_3 = A2_3
    L3_3(L4_3, L5_3)
  end
  L6_2.On = L7_2
  function L7_2(A0_3, A1_3, ...)
    local L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3
    L2_3 = A0_3._Events
    L2_3 = L2_3[A1_3]
    if L2_3 then
      L2_3 = pairs
      L3_3 = A0_3._Events
      L3_3 = L3_3[A1_3]
      L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
      for L6_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
        L8_3 = L7_3
        L9_3 = ...
        L8_3(L9_3)
      end
    end
  end
  L6_2.Trigger = L7_2
  L7_2 = table
  L7_2 = L7_2.insert
  L8_2 = A0_2.Items
  L9_2 = L6_2
  L7_2(L8_2, L9_2)
  L7_2 = setmetatable
  L8_2 = L6_2
  L9_2 = RageUI
  return L7_2(L8_2, L9_2)
end
L0_1.Slider = L1_1
L0_1 = RageUI
function L1_1(A0_2, A1_2, A2_2, A3_2, A4_2)
  local L5_2, L6_2, L7_2, L8_2
  L5_2 = {}
  L5_2.type = "select"
  L5_2.label = A1_2
  L6_2 = A2_2 or L6_2
  if not A2_2 then
    L6_2 = nil
  end
  L5_2.description = L6_2
  L6_2 = uuid
  L6_2 = L6_2()
  L5_2.uuid = L6_2
  L6_2 = {}
  L7_2 = A3_2 or L7_2
  if not A3_2 then
    L7_2 = {}
  end
  L6_2.items = L7_2
  L7_2 = A4_2 or L7_2
  if not A4_2 then
    L7_2 = 0
  end
  L6_2.current = L7_2
  L5_2.options = L6_2
  L6_2 = {}
  L5_2._Events = L6_2
  function L6_2(A0_3, A1_3, A2_3)
    local L3_3, L4_3, L5_3
    L3_3 = A0_3._Events
    L3_3 = L3_3[A1_3]
    if not L3_3 then
      L3_3 = A0_3._Events
      L4_3 = {}
      L3_3[A1_3] = L4_3
    end
    L3_3 = table
    L3_3 = L3_3.insert
    L4_3 = A0_3._Events
    L4_3 = L4_3[A1_3]
    L5_3 = A2_3
    L3_3(L4_3, L5_3)
  end
  L5_2.On = L6_2
  function L6_2(A0_3, A1_3, ...)
    local L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3
    L2_3 = A0_3._Events
    L2_3 = L2_3[A1_3]
    if L2_3 then
      L2_3 = pairs
      L3_3 = A0_3._Events
      L3_3 = L3_3[A1_3]
      L2_3, L3_3, L4_3, L5_3 = L2_3(L3_3)
      for L6_3, L7_3 in L2_3, L3_3, L4_3, L5_3 do
        L8_3 = L7_3
        L9_3 = ...
        L8_3(L9_3)
      end
    end
  end
  L5_2.Trigger = L6_2
  L6_2 = table
  L6_2 = L6_2.insert
  L7_2 = A0_2.Items
  L8_2 = L5_2
  L6_2(L7_2, L8_2)
  L6_2 = setmetatable
  L7_2 = L5_2
  L8_2 = RageUI
  return L6_2(L7_2, L8_2)
end
L0_1.Select = L1_1
L0_1 = RageUI
function L1_1(A0_2)
  local L1_2
  L1_2 = A0_2.Name
  return L1_2
end
L0_1.Name = L1_1
L0_1 = RageUI
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2
  A0_2._Visible = A1_2
  L2_2 = A0_2._Visible
  if L2_2 then
    L2_2 = SendNUIMessage
    L3_2 = {}
    L3_2.action = "toggle"
    L4_2 = {}
    L4_2.component = "rageui"
    L4_2.bool = true
    L5_2 = {}
    L6_2 = A0_2.Name
    L5_2.name = L6_2
    L6_2 = A0_2.Title
    L5_2.title = L6_2
    L6_2 = A0_2.Subtitle
    L5_2.subtitle = L6_2
    L5_2.maxItems = 12
    L6_2 = RageUI
    L7_2 = L6_2
    L6_2 = L6_2.SerializeItems
    L8_2 = A0_2.Items
    L6_2 = L6_2(L7_2, L8_2)
    L5_2.items = L6_2
    L4_2.data = L5_2
    L3_2.data = L4_2
    L2_2(L3_2)
  elseif not A1_2 then
    L2_2 = SendNUIMessage
    L3_2 = {}
    L3_2.action = "toggle"
    L4_2 = {}
    L4_2.component = "rageui"
    L4_2.bool = false
    L3_2.data = L4_2
    L2_2(L3_2)
    L2_2 = SetNuiFocus
    L3_2 = false
    L4_2 = false
    L2_2(L3_2, L4_2)
    L2_2 = SetNuiFocusKeepInput
    L3_2 = false
    L2_2(L3_2)
  end
end
L0_1.Visible = L1_1
L0_1 = RageUI
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = RageUI
  L1_2 = L1_2.OpenedMenus
  L1_2 = #L1_2
  L3_2 = A0_2
  L2_2 = A0_2.Visible
  L4_2 = true
  L2_2(L3_2, L4_2)
  L2_2 = table
  L2_2 = L2_2.insert
  L3_2 = RageUI
  L3_2 = L3_2.OpenedMenus
  L4_2 = A0_2
  L2_2(L3_2, L4_2)
  L2_2 = {}
  L3_2 = A0_2.Name
  L2_2.name = L3_2
  L3_2 = A0_2.Title
  L2_2.title = L3_2
  L3_2 = A0_2.Subtitle
  L2_2.subtitle = L3_2
  L2_2.maxItems = 12
  L3_2 = RageUI
  L4_2 = L3_2
  L3_2 = L3_2.SerializeItems
  L5_2 = A0_2.Items
  L3_2 = L3_2(L4_2, L5_2)
  L2_2.items = L3_2
  if L1_2 > 0 then
    L3_2 = SendNUIMessage
    L4_2 = {}
    L4_2.action = "rageui:update"
    L4_2.data = L2_2
    L3_2(L4_2)
  else
  end
  L3_2 = SetNuiFocus
  L4_2 = true
  L5_2 = false
  L3_2(L4_2, L5_2)
  L3_2 = SetNuiFocusKeepInput
  L4_2 = true
  L3_2(L4_2)
  L3_2 = RageUI
  L3_2.CurrentMenu = A0_2
  L4_2 = A0_2
  L3_2 = A0_2.Trigger
  L5_2 = "visible"
  L6_2 = true
  L3_2(L4_2, L5_2, L6_2)
end
L0_1.Open = L1_1
L0_1 = RageUI
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = RageUI
  L1_2 = L1_2.OpenedMenus
  L1_2 = #L1_2
  L2_2 = RageUI
  L2_2 = L2_2.OpenedMenus
  L3_2 = L1_2 - 1
  L2_2 = L2_2[L3_2]
  L3_2 = RageUI
  L3_2 = L3_2.OpenedMenus
  L3_2 = L3_2[L1_2]
  L4_2 = L2_2.Name
  L5_2 = L3_2.Name
  if L4_2 == L5_2 then
    L4_2 = RageUI
    L5_2 = {}
    L4_2.OpenedMenus = L5_2
    L4_2 = SetNuiFocus
    L5_2 = false
    L6_2 = false
    L4_2(L5_2, L6_2)
    L4_2 = SetNuiFocusKeepInput
    L5_2 = false
    L4_2(L5_2)
    L4_2 = RageUI
    L5_2 = L4_2
    L4_2 = L4_2.Close
    return L4_2(L5_2)
  end
  if L2_2 then
    L5_2 = L2_2
    L4_2 = L2_2.Open
    L4_2(L5_2)
    L4_2 = table
    L4_2 = L4_2.remove
    L5_2 = RageUI
    L5_2 = L5_2.OpenedMenus
    L6_2 = L1_2
    L4_2(L5_2, L6_2)
    L4_2 = RageUI
    L4_2.CurrentMenu = L2_2
  end
end
L0_1.Back = L1_1
L0_1 = RageUI
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = RageUI
  L1_2 = L1_2.CurrentMenu
  L2_2 = L1_2
  L1_2 = L1_2.Trigger
  L3_2 = "visible"
  L4_2 = false
  L1_2(L2_2, L3_2, L4_2)
  L2_2 = A0_2
  L1_2 = A0_2.Visible
  L3_2 = false
  L1_2(L2_2, L3_2)
end
L0_1.Close = L1_1
L0_1 = RageUI
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L2_2 = {}
  L3_2 = pairs
  L4_2 = A1_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = table
    L9_2 = L9_2.insert
    L10_2 = L2_2
    L11_2 = {}
    L12_2 = L8_2.type
    L11_2.type = L12_2
    L12_2 = L8_2.label
    L11_2.label = L12_2
    L12_2 = L8_2.description
    L11_2.description = L12_2
    L12_2 = L8_2.rightLabel
    L11_2.rightLabel = L12_2
    L12_2 = L8_2.background
    L11_2.background = L12_2
    L12_2 = L8_2.uuid
    L11_2.uuid = L12_2
    L12_2 = L8_2.options
    L11_2.options = L12_2
    L9_2(L10_2, L11_2)
  end
  return L2_2
end
L0_1.SerializeItems = L1_1
function L0_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  function L0_2(A0_3)
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
  L1_2 = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
  L2_2 = L1_2
  L1_2 = L1_2.gsub
  L3_2 = "[xy]"
  L4_2 = L0_2
  L1_2 = L1_2(L2_2, L3_2, L4_2)
  return L1_2
end
uuid = L0_1
L0_1 = exports
L1_1 = "GetRageUI"
function L2_1()
  local L0_2, L1_2
  L0_2 = RageUI
  return L0_2
end
L0_1(L1_1, L2_1)
