local L0_1, L1_1
L0_1 = Citizen
L0_1 = L0_1.CreateThread
function L1_1()
  local L0_2, L1_2, L2_2, L3_2
  L0_2 = GetInteriorAtCoords
  L1_2 = 1864.11328
  L2_2 = 3748.07275
  L3_2 = 32.05642
  L0_2 = L0_2(L1_2, L2_2, L3_2)
  InteriorID = L0_2
  L0_2 = RemoveIpl
  L1_2 = "lr_cs4_10_interior_v_tattoo2_milo_"
  L0_2(L1_2)
  L0_2 = DisableInterior
  L1_2 = InteriorID
  L2_2 = true
  L0_2(L1_2, L2_2)
  L0_2 = RefreshInterior
  L1_2 = InteriorID
  L0_2(L1_2)
end
L0_1(L1_1)