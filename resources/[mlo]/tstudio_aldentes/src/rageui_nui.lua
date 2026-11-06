local L0_1, L1_1, L2_1
L0_1 = RegisterNUICallback
L1_1 = "playSound"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2
  L2_2 = nil
  L3_2 = A0_2.loop
  if not L3_2 then
    L3_2 = PlaySoundFrontend
    L4_2 = -1
    L5_2 = A0_2.set
    L6_2 = A0_2.name
    L7_2 = 1
    L3_2(L4_2, L5_2, L6_2, L7_2)
  elseif not L2_2 then
    L3_2 = CreateThread
    function L4_2()
      local L0_3, L1_3, L2_3, L3_3, L4_3
      L0_3 = GetSoundId
      L0_3 = L0_3()
      L2_2 = L0_3
      L0_3 = PlaySoundFrontend
      L1_3 = L2_2
      L2_3 = A0_2.set
      L3_3 = A0_2.name
      L4_3 = true
      L0_3(L1_3, L2_3, L3_3, L4_3)
      L0_3 = Wait
      L1_3 = 0.01
      L0_3(L1_3)
      L0_3 = StopSound
      L1_3 = L2_2
      L0_3(L1_3)
      L0_3 = ReleaseSoundId
      L1_3 = L2_2
      L0_3(L1_3)
      L0_3 = nil
      L2_2 = L0_3
    end
    L3_2(L4_2)
  end
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "rageui:click"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2
  L2_2 = A0_2.item
  L2_2 = L2_2.uuid
  L3_2 = RageUI
  L3_2 = L3_2.CurrentMenu
  if nil == L3_2 then
    return
  end
  L3_2 = pairs
  L4_2 = RageUI
  L4_2 = L4_2.CurrentMenu
  L4_2 = L4_2.Items
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = L8_2.uuid
    if L9_2 == L2_2 then
      L10_2 = L8_2
      L9_2 = L8_2.Trigger
      L11_2 = "click"
      L12_2 = A0_2.item
      L9_2(L10_2, L11_2, L12_2)
      break
    end
  end
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "rageui:change"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L2_2 = A0_2.item
  L2_2 = L2_2.uuid
  L3_2 = A0_2.item
  L3_2 = L3_2.type
  L4_2 = RageUI
  L4_2 = L4_2.CurrentMenu
  if nil == L4_2 then
    return
  end
  L4_2 = pairs
  L5_2 = RageUI
  L5_2 = L5_2.CurrentMenu
  L5_2 = L5_2.Items
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = L9_2.uuid
    if L10_2 == L2_2 then
      L11_2 = L9_2
      L10_2 = L9_2.Trigger
      L12_2 = "change"
      L13_2 = A0_2.item
      L13_2 = L13_2.options
      L13_2 = L13_2.current
      L10_2(L11_2, L12_2, L13_2)
      break
    end
  end
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNUICallback
L1_1 = "rageui:back"
function L2_1(A0_2, A1_2)
  local L2_2, L3_2
  L2_2 = RageUI
  L2_2 = L2_2.CurrentMenu
  if nil ~= L2_2 then
    L2_2 = RageUI
    L2_2 = L2_2.OpenedMenus
    L2_2 = #L2_2
    if not (L2_2 <= 1) then
      goto lbl_18
    end
  end
  L2_2 = RageUI
  L3_2 = {}
  L2_2.OpenedMenus = L3_2
  L2_2 = RageUI
  L3_2 = L2_2
  L2_2 = L2_2.Close
  do return L2_2(L3_2) end
  ::lbl_18::
  L2_2 = RageUI
  L3_2 = L2_2
  L2_2 = L2_2.Back
  L2_2(L3_2)
end
L0_1(L1_1, L2_1)
