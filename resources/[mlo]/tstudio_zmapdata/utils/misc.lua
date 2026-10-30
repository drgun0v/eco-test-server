local L0_1, L1_1, L2_1
L0_1 = RegisterNetEvent
L1_1 = "checkResourceState"
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = GetResourceState
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L2_2 = TriggerClientEvent
  L3_2 = "receiveResourceState"
  L4_2 = source
  L5_2 = A0_2
  L6_2 = L1_2
  L2_2(L3_2, L4_2, L5_2, L6_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNetEvent
L1_1 = "privacy_glass:toggleGlass"
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2
  L1_2 = TriggerClientEvent
  L2_2 = "privacy_glass:updateGlass"
  L3_2 = -1
  L4_2 = A0_2
  L1_2(L2_2, L3_2, L4_2)
end
L0_1(L1_1, L2_1)
L0_1 = RegisterNetEvent
L1_1 = "privacy_glass:updateGlass"
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2
  L1_2 = GetInteriorFromEntity
  L2_2 = PlayerPedId
  L2_2, L3_2, L4_2, L5_2, L6_2 = L2_2()
  L1_2 = L1_2(L2_2, L3_2, L4_2, L5_2, L6_2)
  if 0 == L1_2 then
    return
  end
  L2_2 = LoadInterior
  L3_2 = L1_2
  L2_2(L3_2)
  while true do
    L2_2 = IsInteriorReady
    L3_2 = L1_2
    L2_2 = L2_2(L3_2)
    if L2_2 then
      break
    end
    L2_2 = Citizen
    L2_2 = L2_2.Wait
    L3_2 = 50
    L2_2(L3_2)
  end
  L2_2 = Config
  L2_2 = L2_2.PrivacySwitch
  L2_2 = L2_2.entitySetA
  L3_2 = Config
  L3_2 = L3_2.PrivacySwitch
  L3_2 = L3_2.entitySetB
  if "on" == A0_2 then
    L4_2 = IsInteriorEntitySetActive
    L5_2 = L1_2
    L6_2 = L2_2
    L4_2 = L4_2(L5_2, L6_2)
    if L4_2 then
      L4_2 = DeactivateInteriorEntitySet
      L5_2 = L1_2
      L6_2 = L2_2
      L4_2(L5_2, L6_2)
    end
    L4_2 = ActivateInteriorEntitySet
    L5_2 = L1_2
    L6_2 = L3_2
    L4_2(L5_2, L6_2)
  else
    L4_2 = IsInteriorEntitySetActive
    L5_2 = L1_2
    L6_2 = L3_2
    L4_2 = L4_2(L5_2, L6_2)
    if L4_2 then
      L4_2 = DeactivateInteriorEntitySet
      L5_2 = L1_2
      L6_2 = L3_2
      L4_2(L5_2, L6_2)
    end
    L4_2 = ActivateInteriorEntitySet
    L5_2 = L1_2
    L6_2 = L2_2
    L4_2(L5_2, L6_2)
  end
  L4_2 = RefreshInterior
  L5_2 = L1_2
  L4_2(L5_2)
end
L0_1(L1_1, L2_1)
