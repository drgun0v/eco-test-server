local L0_1, L1_1
L0_1 = {}
TStudioUtils = L0_1
L0_1 = TStudioUtils
function L1_1(A0_2)
  local L1_2, L2_2
  L1_2 = Config
  L1_2 = L1_2.Debug
  if not L1_2 then
    return
  end
  L1_2 = print
  L2_2 = A0_2
  L1_2(L2_2)
end
L0_1.Debug = L1_1
