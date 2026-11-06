local L0_1, L1_1, L2_1, L3_1, L4_1, L5_1
function L0_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2
  L1_2 = 1
  L2_2 = #A0_2
  L3_2 = 1
  for L4_2 = L1_2, L2_2, L3_2 do
    L5_2 = A0_2[L4_2]
    L6_2 = L5_2.enabled
    if L6_2 then
      L6_2 = GetInteriorAtCoordsWithType
      L7_2 = L5_2.coords
      L7_2 = L7_2.x
      L8_2 = L5_2.coords
      L8_2 = L8_2.y
      L9_2 = L5_2.coords
      L9_2 = L9_2.z
      L10_2 = L5_2.name
      L6_2 = L6_2(L7_2, L8_2, L9_2, L10_2)
      if L6_2 and 0 ~= L6_2 then
        L7_2 = DisableInterior
        L8_2 = L6_2
        L9_2 = true
        L7_2(L8_2, L9_2)
        L7_2 = UnpinInterior
        L8_2 = L6_2
        L7_2(L8_2)
        L7_2 = TStudioUtils
        L7_2 = L7_2.Debug
        L8_2 = "^1[TStudio IPL BLOCKER]^7 Successfully disabled interior %s (ID: %d)"
        L9_2 = L8_2
        L8_2 = L8_2.format
        L10_2 = L5_2.name
        L11_2 = L6_2
        L8_2, L9_2, L10_2, L11_2, L12_2, L13_2 = L8_2(L9_2, L10_2, L11_2)
        L7_2(L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
      else
        L7_2 = L5_2.ipl
        if not L7_2 then
          L7_2 = L5_2.name
        end
        L8_2 = IsIplActive
        L9_2 = L7_2
        L8_2 = L8_2(L9_2)
        if L8_2 then
          L8_2 = RemoveIpl
          L9_2 = L7_2
          L8_2(L9_2)
          L8_2 = TStudioUtils
          L8_2 = L8_2.Debug
          L9_2 = "^1[TStudio IPL BLOCKER]^7 Successfully removed IPL %s at %s"
          L10_2 = L9_2
          L9_2 = L9_2.format
          L11_2 = L7_2
          L12_2 = L5_2.coords
          L9_2, L10_2, L11_2, L12_2, L13_2 = L9_2(L10_2, L11_2, L12_2)
          L8_2(L9_2, L10_2, L11_2, L12_2, L13_2)
        else
          L8_2 = Config
          L8_2 = L8_2.Debug
          if L8_2 then
            L8_2 = TStudioUtils
            L8_2 = L8_2.Debug
            L9_2 = "^1[TStudio IPL BLOCKER]^7 Failed to find interior %s or IPL %s at %s"
            L10_2 = L9_2
            L9_2 = L9_2.format
            L11_2 = L5_2.name
            L12_2 = L7_2
            L13_2 = L5_2.coords
            L9_2, L10_2, L11_2, L12_2, L13_2 = L9_2(L10_2, L11_2, L12_2, L13_2)
            L8_2(L9_2, L10_2, L11_2, L12_2, L13_2)
          end
        end
      end
    else
      L6_2 = Config
      L6_2 = L6_2.Debug
      if L6_2 then
        L6_2 = TStudioUtils
        L6_2 = L6_2.Debug
        L7_2 = "^3[TStudio IPL BLOCKER]^7 Skipping disabled interior %s at %s"
        L8_2 = L7_2
        L7_2 = L7_2.format
        L9_2 = L5_2.name
        if not L9_2 then
          L9_2 = "unknown"
        end
        L10_2 = L5_2.coords
        L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2 = L7_2(L8_2, L9_2, L10_2)
        L6_2(L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2)
      end
    end
  end
end
L1_1 = false
function L2_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2
  L1_2 = L1_1
  if L1_2 then
    L1_2 = TStudioUtils
    L1_2 = L1_2.Debug
    L2_2 = "^3[TStudio IPL BLOCKER]^7 Interiors already processed, skipping..."
    L1_2(L2_2)
    return
  end
  if A0_2 then
    L1_2 = #A0_2
    if 0 ~= L1_2 then
      goto lbl_19
    end
  end
  L1_2 = TStudioUtils
  L1_2 = L1_2.Debug
  L2_2 = "^2[TStudio IPL BLOCKER]^7 No active resources reported by server, not processing any interiors."
  L1_2(L2_2)
  do return end
  ::lbl_19::
  L1_2 = TStudioUtils
  L1_2 = L1_2.Debug
  L2_2 = "^2[TStudio IPL BLOCKER]^7 Processing interiors for active resources only..."
  L1_2(L2_2)
  L1_2 = ipairs
  L2_2 = A0_2
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = Config
    L7_2 = L7_2.Interiors
    L7_2 = L7_2[L6_2]
    if L7_2 then
      L8_2 = TStudioUtils
      L8_2 = L8_2.Debug
      L9_2 = "^2[TStudio IPL BLOCKER]^7 Processing interiors for resource: %s"
      L10_2 = L9_2
      L9_2 = L9_2.format
      L11_2 = L6_2
      L9_2, L10_2, L11_2 = L9_2(L10_2, L11_2)
      L8_2(L9_2, L10_2, L11_2)
      L8_2 = L0_1
      L9_2 = L7_2
      L8_2(L9_2)
    else
      L8_2 = TStudioUtils
      L8_2 = L8_2.Debug
      L9_2 = "^3[TStudio IPL BLOCKER]^7 Resource %s not found in config, skipping"
      L10_2 = L9_2
      L9_2 = L9_2.format
      L11_2 = L6_2
      L9_2, L10_2, L11_2 = L9_2(L10_2, L11_2)
      L8_2(L9_2, L10_2, L11_2)
    end
  end
  L1_2 = true
  L1_1 = L1_2
  L1_2 = TStudioUtils
  L1_2 = L1_2.Debug
  L2_2 = "^2[TStudio IPL BLOCKER]^7 Interior blocking process completed"
  L1_2(L2_2)
end
L3_1 = RegisterNetEvent
L4_1 = "tstudio_zmapdata:resourcesReady"
function L5_1(A0_2)
  local L1_2, L2_2
  L1_2 = TStudioUtils
  L1_2 = L1_2.Debug
  L2_2 = "^2[TStudio IPL BLOCKER]^7 Received resources ready notification from server"
  L1_2(L2_2)
  L1_2 = L2_1
  L2_2 = A0_2
  L1_2(L2_2)
end
L3_1(L4_1, L5_1)
