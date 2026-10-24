local L0_1, L1_1, L2_1, L3_1, L4_1
L0_1 = setmetatable
L1_1 = {}
L1_1.__class = "RageMenuKeys"
L1_1.__type = "keys"
L2_1 = {}
function L3_1(A0_2, A1_2, A2_2)
  local L3_2, L4_2
  if "KEY_PRESSED" == A2_2 then
    L3_2 = SendNUIMessage
    L4_2 = {}
    L4_2.action = "keypress"
    L4_2.data = A1_2
    L3_2(L4_2)
  elseif "KEY_RELEASED" == A2_2 then
    L3_2 = SendNUIMessage
    L4_2 = {}
    L4_2.action = "keyrelease"
    L4_2.data = A1_2
    L3_2(L4_2)
  end
end
L2_1.__newindex = L3_1
L0_1 = L0_1(L1_1, L2_1)
Keys = L0_1
function L0_1(A0_2, A1_2, A2_2, A3_2)
  local L4_2, L5_2, L6_2, L7_2, L8_2, L9_2
  L4_2 = {}
  L4_2.action = A0_2
  L4_2.description = A1_2
  L4_2.defaultType = A2_2
  L4_2.defaultKey = A3_2
  L5_2 = RegisterCommand
  L6_2 = "+ragemenu_%s"
  L7_2 = L6_2
  L6_2 = L6_2.format
  L8_2 = A0_2
  L6_2 = L6_2(L7_2, L8_2)
  function L7_2()
    local L0_3, L1_3
    L0_3 = Keys
    L1_3 = A0_2
    L0_3[L1_3] = "KEY_PRESSED"
  end
  L8_2 = false
  L5_2(L6_2, L7_2, L8_2)
  L5_2 = RegisterCommand
  L6_2 = "-ragemenu_%s"
  L7_2 = L6_2
  L6_2 = L6_2.format
  L8_2 = A0_2
  L6_2 = L6_2(L7_2, L8_2)
  function L7_2()
    local L0_3, L1_3
    L0_3 = Keys
    L1_3 = A0_2
    L0_3[L1_3] = "KEY_RELEASED"
  end
  L8_2 = false
  L5_2(L6_2, L7_2, L8_2)
  L5_2 = RegisterKeyMapping
  L6_2 = "+ragemenu_%s"
  L7_2 = L6_2
  L6_2 = L6_2.format
  L8_2 = A0_2
  L6_2 = L6_2(L7_2, L8_2)
  L7_2 = A1_2
  L8_2 = A2_2
  L9_2 = A3_2
  L5_2(L6_2, L7_2, L8_2, L9_2)
  return L4_2
end
RegisterKey = L0_1
L0_1 = RegisterKey
L1_1 = "UP"
L2_1 = "Menu Up"
L3_1 = "KEYBOARD"
L4_1 = "UP"
L0_1(L1_1, L2_1, L3_1, L4_1)
L0_1 = RegisterKey
L1_1 = "DOWN"
L2_1 = "Menu Down"
L3_1 = "KEYBOARD"
L4_1 = "DOWN"
L0_1(L1_1, L2_1, L3_1, L4_1)
L0_1 = RegisterKey
L1_1 = "LEFT"
L2_1 = "Menu Left"
L3_1 = "KEYBOARD"
L4_1 = "LEFT"
L0_1(L1_1, L2_1, L3_1, L4_1)
L0_1 = RegisterKey
L1_1 = "RIGHT"
L2_1 = "Menu Right"
L3_1 = "KEYBOARD"
L4_1 = "RIGHT"
L0_1(L1_1, L2_1, L3_1, L4_1)
L0_1 = RegisterKey
L1_1 = "ENTER"
L2_1 = "Menu Select"
L3_1 = "KEYBOARD"
L4_1 = "RETURN"
L0_1(L1_1, L2_1, L3_1, L4_1)
L0_1 = RegisterKey
L1_1 = "CLOSE"
L2_1 = "Menu Close"
L3_1 = "KEYBOARD"
L4_1 = "BACK"
L0_1(L1_1, L2_1, L3_1, L4_1)
