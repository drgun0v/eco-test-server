local L0_1, L1_1, L2_1, L3_1
L0_1 = "off"
function L1_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = GetInteriorFromEntity
  L1_2 = PlayerPedId
  L1_2, L2_2, L3_2 = L1_2()
  L0_2 = L0_2(L1_2, L2_2, L3_2)
  if 0 == L0_2 then
    return
  end
  L1_2 = L0_1
  if "off" == L1_2 then
    L1_2 = "on"
    L0_1 = L1_2
  else
    L1_2 = "off"
    L0_1 = L1_2
  end
  L1_2 = TriggerServerEvent
  L2_2 = "privacy_glass:toggleGlass"
  L3_2 = L0_1
  L1_2(L2_2, L3_2)
end
L2_1 = Citizen
L2_1 = L2_1.CreateThread
function L3_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2, L35_2, L36_2
  L0_2 = "Press ~INPUT_CONTEXT~ to toggle privacy glass"
  L1_2 = false
  while true do
    L2_2 = PlayerPedId
    L2_2 = L2_2()
    L3_2 = GetEntityCoords
    L4_2 = L2_2
    L3_2 = L3_2(L4_2)
    L4_2 = false
    L5_2 = true
    L6_2 = pairs
    L7_2 = Config
    L7_2 = L7_2.PrivacySwitch
    L7_2 = L7_2.positions
    L6_2, L7_2, L8_2, L9_2 = L6_2(L7_2)
    for L10_2, L11_2 in L6_2, L7_2, L8_2, L9_2 do
      L12_2 = L3_2 - L11_2
      L12_2 = #L12_2
      if L12_2 < 5.0 then
        L5_2 = false
        L13_2 = DrawMarker
        L14_2 = Config
        L14_2 = L14_2.PrivacySwitch
        L14_2 = L14_2.marker
        L14_2 = L14_2.type
        L15_2 = L11_2.x
        L16_2 = L11_2.y
        L17_2 = L11_2.z
        L18_2 = 0.0
        L19_2 = 0.0
        L20_2 = 0.0
        L21_2 = 0.0
        L22_2 = 0.0
        L23_2 = 0.0
        L24_2 = 0.6
        L25_2 = 0.6
        L26_2 = 0.6
        L27_2 = Config
        L27_2 = L27_2.PrivacySwitch
        L27_2 = L27_2.marker
        L27_2 = L27_2.r
        L28_2 = Config
        L28_2 = L28_2.PrivacySwitch
        L28_2 = L28_2.marker
        L28_2 = L28_2.g
        L29_2 = Config
        L29_2 = L29_2.PrivacySwitch
        L29_2 = L29_2.marker
        L29_2 = L29_2.b
        L30_2 = Config
        L30_2 = L30_2.PrivacySwitch
        L30_2 = L30_2.marker
        L30_2 = L30_2.alpha
        L31_2 = false
        L32_2 = true
        L33_2 = 2
        L34_2 = false
        L35_2 = nil
        L36_2 = false
        L13_2(L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2, L27_2, L28_2, L29_2, L30_2, L31_2, L32_2, L33_2, L34_2, L35_2, L36_2)
      end
      L13_2 = Config
      L13_2 = L13_2.PrivacySwitch
      L13_2 = L13_2.range
      if L12_2 < L13_2 then
        if not L1_2 then
          L13_2 = AddTextEntry
          L14_2 = "HelpNotify"
          L15_2 = L0_2
          L13_2(L14_2, L15_2)
          L1_2 = true
        end
        L13_2 = DisplayHelpTextThisFrame
        L14_2 = "HelpNotify"
        L15_2 = false
        L13_2(L14_2, L15_2)
        L13_2 = IsControlJustReleased
        L14_2 = 0
        L15_2 = 38
        L13_2 = L13_2(L14_2, L15_2)
        if L13_2 then
          L13_2 = L1_1
          L13_2()
        end
        L4_2 = true
      end
    end
    if not L4_2 then
      L1_2 = false
    end
    L6_2 = Citizen
    L6_2 = L6_2.Wait
    if L5_2 then
      L7_2 = 500
      if L7_2 then
        goto lbl_101
      end
    end
    L7_2 = 0
    ::lbl_101::
    L6_2(L7_2)
  end
end
L2_1(L3_1)
