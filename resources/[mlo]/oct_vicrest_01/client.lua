local L0_1, L1_1
L0_1 = CreateThread
function L1_1()
  local L0_2, L1_2, L2_2
  L0_2 = SetStaticEmitterEnabled
  L1_2 = "se_tutorial_emitter_02"
  L2_2 = true
  L0_2(L1_2, L2_2)
end
L0_1(L1_1)
