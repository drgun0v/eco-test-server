local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1, L10_1, L11_1, L12_1, L13_1, L14_1, L15_1, L16_1, L17_1, L18_1, L19_1, L20_1, L21_1, L22_1, L23_1, L24_1, L25_1, L26_1, L27_1, L28_1, L29_1, L30_1, L31_1, L32_1
function L0_1(A0_2)
  local L1_2, L2_2
  L1_2 = TStudioUtils
  if L1_2 then
    L1_2 = TStudioUtils
    L1_2 = L1_2.Debug
    if L1_2 then
      L1_2 = TStudioUtils
      L1_2 = L1_2.Debug
      L2_2 = A0_2
      L1_2(L2_2)
  end
  else
    L1_2 = Config
    if L1_2 then
      L1_2 = Config
      L1_2 = L1_2.Debug
      if L1_2 then
        L1_2 = print
        L2_2 = A0_2
        L1_2(L2_2)
      end
    end
  end
end
function L1_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L2_2 = -1
  L3_2 = math
  L3_2 = L3_2.huge
  L4_2 = pairs
  L5_2 = A1_2
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = math
    L10_2 = L10_2.abs
    L11_2 = L9_2.height
    L11_2 = A0_2 - L11_2
    L10_2 = L10_2(L11_2)
    if L3_2 > L10_2 then
      L3_2 = L10_2
      L2_2 = L8_2
    end
  end
  L4_2 = TStudioUtils
  L4_2 = L4_2.Debug
  L5_2 = "^3[TStudio IPL MANAGER]^7 Closest floor: %d, Difference: %.2f"
  L6_2 = L5_2
  L5_2 = L5_2.format
  L7_2 = L2_2
  L8_2 = L3_2
  L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2 = L5_2(L6_2, L7_2, L8_2)
  L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2)
  L4_2 = L2_2
  L5_2 = L3_2
  return L4_2, L5_2
end
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = 0
  L2_2 = GetNumResources
  L2_2 = L2_2()
  L2_2 = L2_2 - 1
  L3_2 = 1
  for L4_2 = L1_2, L2_2, L3_2 do
    L5_2 = GetResourceByFindIndex
    L6_2 = L4_2
    L5_2 = L5_2(L6_2)
    if L5_2 == A0_2 then
      L5_2 = true
      return L5_2
    end
  end
  L1_2 = false
  return L1_2
end
function L3_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L1_2 = GetEntityCoords
  L2_2 = PlayerPedId
  L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2 = L2_2()
  L1_2 = L1_2(L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2)
  L2_2 = pairs
  L3_2 = A0_2.floors
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = L7_2.height
    L9_2 = math
    L9_2 = L9_2.abs
    L10_2 = L1_2.z
    L10_2 = L10_2 - L8_2
    L9_2 = L9_2(L10_2)
    L10_2 = 2.5
    if L9_2 <= L10_2 then
      L9_2 = true
      return L9_2
    end
  end
  L2_2 = false
  return L2_2
end
function L4_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L2_2 = GetEntityCoords
  L3_2 = PlayerPedId
  L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2 = L3_2()
  L2_2 = L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  L3_2 = vector2
  L4_2 = L2_2.x
  L5_2 = L2_2.y
  L3_2 = L3_2(L4_2, L5_2)
  L4_2 = vector2
  L5_2 = A0_2.center
  L5_2 = L5_2.x
  L6_2 = A0_2.center
  L6_2 = L6_2.y
  L4_2 = L4_2(L5_2, L6_2)
  L5_2 = L3_2 - L4_2
  L5_2 = #L5_2
  L6_2 = TStudioUtils
  L6_2 = L6_2.Debug
  L7_2 = "^3[TStudio IPL MANAGER]^7 Checking area: Center = (%.2f, %.2f), Player = (%.2f, %.2f), Distance = %.2f, Radius = %.2f"
  L8_2 = L7_2
  L7_2 = L7_2.format
  L9_2 = L4_2.x
  L10_2 = L4_2.y
  L11_2 = L3_2.x
  L12_2 = L3_2.y
  L13_2 = L5_2
  L14_2 = A1_2
  L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2 = L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  if A1_2 >= L5_2 then
    L6_2 = TStudioUtils
    L6_2 = L6_2.Debug
    L7_2 = "^2[TStudio IPL MANAGER]^7 Player is within the radius of the area."
    L6_2(L7_2)
    L6_2 = true
    return L6_2
  end
  L6_2 = TStudioUtils
  L6_2 = L6_2.Debug
  L7_2 = "^3[TStudio IPL MANAGER]^7 Player is not within the radius of the area."
  L6_2(L7_2)
  L6_2 = false
  return L6_2
end
function L5_1()
  local L0_2, L1_2
  L0_2 = L3_1
  L1_2 = Config
  L1_2 = L1_2.FloorConfigs
  L1_2 = L1_2.pillbox
  return L0_2(L1_2)
end
function L6_1()
  local L0_2, L1_2
  L0_2 = L3_1
  L1_2 = Config
  L1_2 = L1_2.FloorConfigs
  L1_2 = L1_2.opium
  return L0_2(L1_2)
end
function L7_1()
  local L0_2, L1_2, L2_2
  L0_2 = L4_1
  L1_2 = Config
  L1_2 = L1_2.FloorConfigs
  L1_2 = L1_2.pillbox
  L2_2 = 100.0
  return L0_2(L1_2, L2_2)
end
function L8_1()
  local L0_2, L1_2, L2_2
  L0_2 = L4_1
  L1_2 = Config
  L1_2 = L1_2.FloorConfigs
  L1_2 = L1_2.opium
  L2_2 = 100.0
  return L0_2(L1_2, L2_2)
end
function L9_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = TStudioUtils
  L0_2 = L0_2.Debug
  L1_2 = "^2[TStudio IPL MANAGER]^7 Activating entity set for floor"
  L0_2(L1_2)
  L0_2 = Citizen
  L0_2 = L0_2.Wait
  L1_2 = 500
  L0_2(L1_2)
  L0_2 = GetInteriorFromEntity
  L1_2 = PlayerPedId
  L1_2, L2_2, L3_2 = L1_2()
  L0_2 = L0_2(L1_2, L2_2, L3_2)
  if 0 ~= L0_2 then
    L1_2 = LoadInterior
    L2_2 = L0_2
    L1_2(L2_2)
    while true do
      L1_2 = IsInteriorReady
      L2_2 = L0_2
      L1_2 = L1_2(L2_2)
      if L1_2 then
        break
      end
      L1_2 = Citizen
      L1_2 = L1_2.Wait
      L2_2 = 50
      L1_2(L2_2)
    end
    L1_2 = IsInteriorEntitySetActive
    L2_2 = L0_2
    L3_2 = "r7_privacy_off"
    L1_2 = L1_2(L2_2, L3_2)
    if not L1_2 then
      L1_2 = TStudioUtils
      L1_2 = L1_2.Debug
      L2_2 = "^2[TStudio IPL MANAGER]^7 Activating interior entity set: r7_privacy_off"
      L1_2(L2_2)
      L1_2 = ActivateInteriorEntitySet
      L2_2 = L0_2
      L3_2 = "r7_privacy_off"
      L1_2(L2_2, L3_2)
      L1_2 = RefreshInterior
      L2_2 = L0_2
      L1_2(L2_2)
    end
  end
end
function L10_1()
  local L0_2, L1_2, L2_2
  L0_2 = TriggerServerEvent
  L1_2 = "checkResourceState"
  L2_2 = "tstudio_pillbox_md"
  L0_2(L1_2, L2_2)
  L0_2 = RegisterNetEvent
  L1_2 = "receiveResourceState"
  L0_2(L1_2)
  L0_2 = AddEventHandler
  L1_2 = "receiveResourceState"
  function L2_2(A0_3, A1_3)
    local L2_3
    if "tstudio_pillbox_md" == A0_3 and "started" == A1_3 then
      L2_3 = L5_1
      L2_3 = L2_3()
      if L2_3 then
        L2_3 = L9_1
        L2_3()
      end
    end
  end
  L0_2(L1_2, L2_2)
end
function L11_1(A0_2, A1_2)
  local L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2
  L2_2 = TStudioUtils
  L2_2 = L2_2.Debug
  L3_2 = "^2[TStudio IPL MANAGER]^7 Loading IPLs for floor: %d"
  L4_2 = L3_2
  L3_2 = L3_2.format
  L5_2 = A0_2
  L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2 = L3_2(L4_2, L5_2)
  L2_2(L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
  L2_2 = pairs
  L3_2 = A1_2[A0_2]
  L3_2 = L3_2.ipls
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    L8_2 = TStudioUtils
    L8_2 = L8_2.Debug
    L9_2 = "^2[TStudio IPL MANAGER]^7 Requesting IPL: %s"
    L10_2 = L9_2
    L9_2 = L9_2.format
    L11_2 = L7_2
    L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2 = L9_2(L10_2, L11_2)
    L8_2(L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2)
    L8_2 = RequestIpl
    L9_2 = L7_2
    L8_2(L9_2)
  end
  L2_2 = pairs
  L3_2 = A1_2
  L2_2, L3_2, L4_2, L5_2 = L2_2(L3_2)
  for L6_2, L7_2 in L2_2, L3_2, L4_2, L5_2 do
    if L6_2 ~= A0_2 then
      L8_2 = pairs
      L9_2 = L7_2.ipls
      L8_2, L9_2, L10_2, L11_2 = L8_2(L9_2)
      for L12_2, L13_2 in L8_2, L9_2, L10_2, L11_2 do
        L14_2 = TStudioUtils
        L14_2 = L14_2.Debug
        L15_2 = "^1[TStudio IPL MANAGER]^7 Removing IPL: %s"
        L16_2 = L15_2
        L15_2 = L15_2.format
        L17_2 = L13_2
        L15_2, L16_2, L17_2 = L15_2(L16_2, L17_2)
        L14_2(L15_2, L16_2, L17_2)
        L14_2 = RemoveIpl
        L15_2 = L13_2
        L14_2(L15_2)
      end
    end
  end
  L2_2 = L10_1
  L2_2()
end
function L12_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2
  L1_2 = nil
  function L2_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3
    L0_3 = GetEntityCoords
    L1_3 = PlayerPedId
    L1_3, L2_3, L3_3, L4_3, L5_3 = L1_3()
    L0_3 = L0_3(L1_3, L2_3, L3_3, L4_3, L5_3)
    L1_3 = L1_1
    L2_3 = L0_3.z
    L3_3 = A0_2.floors
    L1_3, L2_3 = L1_3(L2_3, L3_3)
    L3_3 = 2.5
    if L2_3 <= L3_3 then
      L3_3 = L1_2
      if L1_3 ~= L3_3 then
        L3_3 = L11_1
        L4_3 = L1_3
        L5_3 = A0_2.floors
        L3_3(L4_3, L5_3)
        L1_2 = L1_3
      end
    end
  end
  L3_2 = RegisterNetEvent
  L4_2 = "playerMoved"
  L3_2(L4_2)
  L3_2 = AddEventHandler
  L4_2 = "playerMoved"
  L5_2 = L2_2
  L3_2(L4_2, L5_2)
end
L13_1 = Citizen
L13_1 = L13_1.CreateThread
function L14_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2
  L0_2 = nil
  while true do
    L1_2 = GetEntityCoords
    L2_2 = PlayerPedId
    L2_2, L3_2, L4_2 = L2_2()
    L1_2 = L1_2(L2_2, L3_2, L4_2)
    L2_2 = true
    L3_2 = L7_1
    L3_2 = L3_2()
    if not L3_2 then
      L3_2 = L8_1
      L3_2 = L3_2()
      if not L3_2 then
        goto lbl_31
      end
    end
    L2_2 = false
    L3_2 = TStudioUtils
    L3_2 = L3_2.Debug
    L4_2 = "^2[TStudio IPL MANAGER]^7 Player is near a configured area"
    L3_2(L4_2)
    if L0_2 then
      L3_2 = L1_2 - L0_2
      L3_2 = #L3_2
      if not (L3_2 > 1.0) then
        goto lbl_31
      end
    end
    L3_2 = TriggerEvent
    L4_2 = "playerMoved"
    L3_2(L4_2)
    L0_2 = L1_2
    ::lbl_31::
    L3_2 = Citizen
    L3_2 = L3_2.Wait
    if L2_2 then
      L4_2 = 2000
      if L4_2 then
        goto lbl_39
      end
    end
    L4_2 = 500
    ::lbl_39::
    L3_2(L4_2)
  end
end
L13_1(L14_1)
L13_1 = TStudioUtils
L13_1 = L13_1.Debug
L14_1 = "^3[TStudio IPL MANAGER]^7 Removing all IPLs during initialization"
L13_1(L14_1)
L13_1 = pairs
L14_1 = Config
L14_1 = L14_1.FloorConfigs
L13_1, L14_1, L15_1, L16_1 = L13_1(L14_1)
for L17_1, L18_1 in L13_1, L14_1, L15_1, L16_1 do
  L19_1 = pairs
  L20_1 = L18_1.floors
  L19_1, L20_1, L21_1, L22_1 = L19_1(L20_1)
  for L23_1, L24_1 in L19_1, L20_1, L21_1, L22_1 do
    L25_1 = TStudioUtils
    L25_1 = L25_1.Debug
    L26_1 = "^1[TStudio IPL MANAGER]^7 Removing IPLs for floor: %d in resource: %s"
    L27_1 = L26_1
    L26_1 = L26_1.format
    L28_1 = L23_1
    L29_1 = tostring
    L30_1 = L18_1.resourceName
    if not L30_1 then
      L30_1 = "unknown"
    end
    L29_1, L30_1, L31_1, L32_1 = L29_1(L30_1)
    L26_1, L27_1, L28_1, L29_1, L30_1, L31_1, L32_1 = L26_1(L27_1, L28_1, L29_1, L30_1, L31_1, L32_1)
    L25_1(L26_1, L27_1, L28_1, L29_1, L30_1, L31_1, L32_1)
    L25_1 = pairs
    L26_1 = L24_1.ipls
    L25_1, L26_1, L27_1, L28_1 = L25_1(L26_1)
    for L29_1, L30_1 in L25_1, L26_1, L27_1, L28_1 do
      L31_1 = RemoveIpl
      L32_1 = L30_1
      L31_1(L32_1)
    end
  end
end
L13_1 = L12_1
L14_1 = Config
L14_1 = L14_1.FloorConfigs
L14_1 = L14_1.pillbox
L13_1(L14_1)
L13_1 = L12_1
L14_1 = Config
L14_1 = L14_1.FloorConfigs
L14_1 = L14_1.opium
L13_1(L14_1)
