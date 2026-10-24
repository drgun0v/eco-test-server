local L0_1, L1_1, L2_1, L3_1
function L0_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2
  L0_2 = "water.xml"
  L1_2 = "cfx-nteam-newlake"
  L2_2 = LoadWaterFromPath
  L3_2 = L1_2
  L4_2 = L0_2
  L2_2 = L2_2(L3_2, L4_2)
  if not L2_2 then
    L3_2 = print
    L4_2 = "Error loading "
    L5_2 = L0_2
    L4_2 = L4_2 .. L5_2
    L3_2(L4_2)
  end
end
L1_1 = Citizen
L1_1 = L1_1.CreateThread
L2_1 = L0_1
L1_1(L2_1)
L1_1 = AddEventHandler
L2_1 = "onResourceStop"
function L3_1(A0_2)
  local L1_2
  L1_2 = GetCurrentResourceName
  L1_2 = L1_2()
  if A0_2 == L1_2 then
    L1_2 = ResetWater
    L1_2()
  end
end
L1_1(L2_1, L3_1)
L1_1 = Citizen
L1_1 = L1_1.CreateThread
function L2_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L0_2 = {}
  L1_2 = "az_music_southcentral_05"
  L2_2 = "hash_1a5dd0fc_upkmlvda_collision"
  L3_2 = "az_walla_ls_florence_04"
  L4_2 = "hash_d6656a66_buyrnyj_collision"
  L5_2 = "az_walla_ls_florence_01"
  L6_2 = "az_walla_ls_florence_03"
  L7_2 = "az_walla_ls_florence_02"
  L8_2 = "az_los_santos_florence"
  L0_2[1] = L1_2
  L0_2[2] = L2_2
  L0_2[3] = L3_2
  L0_2[4] = L4_2
  L0_2[5] = L5_2
  L0_2[6] = L6_2
  L0_2[7] = L7_2
  L0_2[8] = L8_2
  L1_2 = ipairs
  L2_2 = L0_2
  L1_2, L2_2, L3_2, L4_2 = L1_2(L2_2)
  for L5_2, L6_2 in L1_2, L2_2, L3_2, L4_2 do
    L7_2 = ClearAmbientZoneState
    L8_2 = L6_2
    L9_2 = false
    L7_2(L8_2, L9_2)
    L7_2 = SetAmbientZoneState
    L8_2 = L6_2
    L9_2 = false
    L10_2 = false
    L7_2(L8_2, L9_2, L10_2)
  end
end
L1_1(L2_1)
