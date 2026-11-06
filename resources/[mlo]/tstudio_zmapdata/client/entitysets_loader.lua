local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1, L6_1, L7_1, L8_1, L9_1
L0_1 = Config
L0_1 = L0_1.EntitySets
if not L0_1 then
  L0_1 = {}
end
function L1_1(A0_2)
  local L1_2, L2_2
  if A0_2 then
    L1_2 = A0_2.coords
    if L1_2 then
      L1_2 = A0_2.ipl
      if L1_2 then
        goto lbl_14
      end
    end
  end
  L1_2 = TStudioUtils
  L1_2 = L1_2.Debug
  L2_2 = "^1[TStudio ENTITY SETS]^7 Invalid configuration. Skipping..."
  L1_2(L2_2)
  do return end
  ::lbl_14::
  L1_2 = RequestIpl
  L2_2 = A0_2.ipl
  L1_2(L2_2)
  L1_2 = Citizen
  L1_2 = L1_2.CreateThread
  function L2_2()
    local L0_3, L1_3, L2_3, L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3
    L0_3 = 0
    L1_3 = 30
    while true do
      L2_3 = IsIplActive
      L3_3 = A0_2.ipl
      L2_3 = L2_3(L3_3)
      if not (not L2_3 and L0_3 < L1_3) then
        break
      end
      L0_3 = L0_3 + 1
      L2_3 = Citizen
      L2_3 = L2_3.Wait
      L3_3 = 1000
      L2_3(L3_3)
    end
    L2_3 = IsIplActive
    L3_3 = A0_2.ipl
    L2_3 = L2_3(L3_3)
    if not L2_3 then
      L2_3 = TStudioUtils
      L2_3 = L2_3.Debug
      L3_3 = "^1[TStudio ENTITY SETS]^7 IPL '%s' failed to load after %d seconds"
      L4_3 = L3_3
      L3_3 = L3_3.format
      L5_3 = A0_2.ipl
      L6_3 = L1_3
      L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3 = L3_3(L4_3, L5_3, L6_3)
      L2_3(L3_3, L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3)
      return
    end
    L2_3 = GetInteriorAtCoords
    L3_3 = A0_2.coords
    L3_3 = L3_3.x
    L4_3 = A0_2.coords
    L4_3 = L4_3.y
    L5_3 = A0_2.coords
    L5_3 = L5_3.z
    L2_3 = L2_3(L3_3, L4_3, L5_3)
    L3_3 = IsValidInterior
    L4_3 = L2_3
    L3_3 = L3_3(L4_3)
    if L3_3 then
      L3_3 = ipairs
      L4_3 = A0_2.entitySets
      if not L4_3 then
        L4_3 = {}
      end
      L3_3, L4_3, L5_3, L6_3 = L3_3(L4_3)
      for L7_3, L8_3 in L3_3, L4_3, L5_3, L6_3 do
        L9_3 = L8_3.enable
        if L9_3 then
          L9_3 = ActivateInteriorEntitySet
          L10_3 = L2_3
          L11_3 = L8_3.name
          L9_3(L10_3, L11_3)
        else
          L9_3 = DeactivateInteriorEntitySet
          L10_3 = L2_3
          L11_3 = L8_3.name
          L9_3(L10_3, L11_3)
        end
      end
      L3_3 = RefreshInterior
      L4_3 = L2_3
      L3_3(L4_3)
      L3_3 = TStudioUtils
      L3_3 = L3_3.Debug
      L4_3 = "^2[TStudio ENTITY SETS]^7 Applied entity sets for '%s'"
      L5_3 = L4_3
      L4_3 = L4_3.format
      L6_3 = A0_2.name
      L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3 = L4_3(L5_3, L6_3)
      L3_3(L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3)
    else
      L3_3 = TStudioUtils
      L3_3 = L3_3.Debug
      L4_3 = "^1[TStudio ENTITY SETS]^7 Invalid interior for '%s'"
      L5_3 = L4_3
      L4_3 = L4_3.format
      L6_3 = A0_2.name
      L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3 = L4_3(L5_3, L6_3)
      L3_3(L4_3, L5_3, L6_3, L7_3, L8_3, L9_3, L10_3, L11_3)
    end
  end
  L1_2(L2_2)
end
L2_1 = ipairs
L3_1 = L0_1
L2_1, L3_1, L4_1, L5_1 = L2_1(L3_1)
for L6_1, L7_1 in L2_1, L3_1, L4_1, L5_1 do
  L8_1 = L1_1
  L9_1 = L7_1
  L8_1(L9_1)
end
