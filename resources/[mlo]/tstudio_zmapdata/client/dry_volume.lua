local L0_1, L1_1, L2_1, L3_1
function L0_1(A0_2)
  local L1_2, L2_2
  L1_2 = GetResourceState
  L2_2 = A0_2
  L1_2 = L1_2(L2_2)
  L1_2 = "started" == L1_2
  return L1_2
end
function L1_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2
  L0_2 = Config
  L0_2 = L0_2.DryVolumes
  if not L0_2 then
    L0_2 = TStudioUtils
    L0_2 = L0_2.Debug
    L1_2 = "^3[TStudio DRY VOLUME]^7 No dry volumes configured"
    L0_2(L1_2)
    return
  end
  L0_2 = 0
  L1_2 = pairs
  L2_2 = Config
  L2_2 = L2_2.DryVolumes
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = L0_1
    L8_2 = L5_2
    L7_2 = L7_2(L8_2)
    if L7_2 then
      L7_2 = TStudioUtils
      L7_2 = L7_2.Debug
      L8_2 = "^2[TStudio DRY VOLUME]^7 Loading dry volumes for resource: %s"
      L9_2 = L8_2
      L8_2 = L8_2.format
      L10_2 = L5_2
      L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2 = L8_2(L9_2, L10_2)
      L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
      L7_2 = ipairs
      L8_2 = L6_2
      L7_2, L8_2, L9_2, L10_2 = L7_2(L8_2)
      for L11_2, L12_2 in L7_2, L8_2, L9_2, L10_2 do
        L13_2 = Citizen
        L13_2 = L13_2.CreateThread
        function L14_2()
          local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3
          L0_3 = CreateDryVolume
          L1_3 = L12_2.minX
          L2_3 = L12_2.minY
          L3_3 = L12_2.minZ
          L4_3 = L12_2.maxX
          L5_3 = L12_2.maxY
          L6_3 = L12_2.maxZ
          L0_3(L1_3, L2_3, L3_3, L4_3, L5_3, L6_3)
          L0_3 = L0_2
          L0_3 = L0_3 + 1
          L0_2 = L0_3
          L0_3 = TStudioUtils
          L0_3 = L0_3.Debug
          L1_3 = "^2[TStudio DRY VOLUME]^7 Created dry volume: %s"
          L2_3 = L1_3
          L1_3 = L1_3.format
          L3_3 = L12_2.name
          if not L3_3 then
            L3_3 = "Unnamed"
          end
          L1_3, L2_3, L3_3, L4_3, L5_3, L6_3 = L1_3(L2_3, L3_3)
          L0_3(L1_3, L2_3, L3_3, L4_3, L5_3, L6_3)
        end
        L13_2(L14_2)
      end
    else
      L7_2 = TStudioUtils
      L7_2 = L7_2.Debug
      L8_2 = "^3[TStudio DRY VOLUME]^7 Skipping dry volumes for inactive resource: %s"
      L9_2 = L8_2
      L8_2 = L8_2.format
      L10_2 = L5_2
      L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2 = L8_2(L9_2, L10_2)
      L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
    end
  end
  if L0_2 > 0 then
    L1_2 = TStudioUtils
    L1_2 = L1_2.Debug
    L2_2 = "^2[TStudio DRY VOLUME]^7 Successfully loaded %d dry volume(s)"
    L3_2 = L2_2
    L2_2 = L2_2.format
    L4_2 = L0_2
    L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2 = L2_2(L3_2, L4_2)
    L1_2(L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2)
  end
end
L2_1 = Citizen
L2_1 = L2_1.CreateThread
function L3_1()
  local L0_2, L1_2
  L0_2 = L1_1
  L0_2()
end
L2_1(L3_1)
