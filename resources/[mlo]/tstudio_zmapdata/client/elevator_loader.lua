local L0_1, L1_1
L0_1 = Locales
if not L0_1 then
  L0_1 = {}
end
Locales = L0_1
L0_1 = table
function L1_1(A0_2)
  local L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2
  L1_2 = {}
  L2_2 = {}
  L3_2 = pairs
  L4_2 = A0_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2 in L3_2, L4_2, L5_2, L6_2 do
    L8_2 = table
    L8_2 = L8_2.insert
    L9_2 = L2_2
    L10_2 = L7_2
    L8_2(L9_2, L10_2)
  end
  L3_2 = table
  L3_2 = L3_2.sort
  L4_2 = L2_2
  function L5_2(A0_3, A1_3)
    local L2_3
    L2_3 = A1_3 < A0_3
    return L2_3
  end
  L3_2(L4_2, L5_2)
  L3_2 = ipairs
  L4_2 = L2_2
  L3_2, L4_2, L5_2, L6_2 = L3_2(L4_2)
  for L7_2, L8_2 in L3_2, L4_2, L5_2, L6_2 do
    L9_2 = A0_2[L8_2]
    L1_2[L8_2] = L9_2
  end
  return L1_2
end
L0_1.sortKeys = L1_1
L0_1 = CreateThread
function L1_1()
  local L0_2, L1_2, L2_2, L3_2, L4_2, L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2
  L0_2 = Config
  if L0_2 then
    L0_2 = Config
    L0_2 = L0_2.ElevatorsEnabled
    if false == L0_2 then
      L0_2 = print
      L1_2 = "^5[^3 TStudio Elevator Loader^5]^7 \226\143\185\239\184\143 Elevators disabled in config"
      L0_2(L1_2)
      return
    end
  end
  L0_2 = print
  L1_2 = "^5[^3 TStudio Elevator Loader^5]^7 Script loaded!"
  L0_2(L1_2)
  L0_2 = Config
  if L0_2 then
    L0_2 = Config
    L0_2 = L0_2.Debug
    if L0_2 then
      L0_2 = print
      L1_2 = "^5[^3 TStudio Elevator Loader^5]^7 \240\159\148\142 Checking for elevator configurations..."
      L0_2(L1_2)
    end
  end
  L0_2 = 0
  L1_2 = 0
  L2_2 = GetNumResources
  L2_2 = L2_2()
  L3_2 = {}
  L4_2 = 0
  L5_2 = L2_2 - 1
  L6_2 = 1
  for L7_2 = L4_2, L5_2, L6_2 do
    L8_2 = GetResourceByFindIndex
    L9_2 = L7_2
    L8_2 = L8_2(L9_2)
    if L8_2 then
      L9_2 = string
      L9_2 = L9_2.match
      L10_2 = L8_2
      L11_2 = "^tstudio_"
      L9_2 = L9_2(L10_2, L11_2)
      if L9_2 then
        L9_2 = string
        L9_2 = L9_2.gsub
        L10_2 = L8_2
        L11_2 = "^tstudio_"
        L12_2 = ""
        L9_2 = L9_2(L10_2, L11_2, L12_2)
        L10_2 = ".lua"
        L9_2 = L9_2 .. L10_2
        L10_2 = "elevators/"
        L11_2 = L9_2
        L10_2 = L10_2 .. L11_2
        L11_2 = LoadResourceFile
        L12_2 = GetCurrentResourceName
        L12_2 = L12_2()
        L13_2 = L10_2
        L11_2 = L11_2(L12_2, L13_2)
        if L11_2 then
          L12_2 = table
          L12_2 = L12_2.insert
          L13_2 = L3_2
          L14_2 = L10_2
          L12_2(L13_2, L14_2)
        end
      end
    end
  end
  L4_2 = Config
  if L4_2 then
    L4_2 = Config
    L4_2 = L4_2.Debug
    if L4_2 then
      L4_2 = print
      L5_2 = "^5[^3 TStudio Elevator Loader^5]^7 Found %d elevator config(s) to process"
      L6_2 = L5_2
      L5_2 = L5_2.format
      L7_2 = #L3_2
      L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L5_2(L6_2, L7_2)
      L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
    end
  end
  L4_2 = ipairs
  L5_2 = L3_2
  L4_2, L5_2, L6_2, L7_2 = L4_2(L5_2)
  for L8_2, L9_2 in L4_2, L5_2, L6_2, L7_2 do
    L10_2 = LoadResourceFile
    L11_2 = GetCurrentResourceName
    L11_2 = L11_2()
    L12_2 = L9_2
    L10_2 = L10_2(L11_2, L12_2)
    if L10_2 then
      L11_2 = load
      L12_2 = L10_2
      L11_2, L12_2 = L11_2(L12_2)
      if L11_2 then
        L13_2 = pcall
        L14_2 = L11_2
        L13_2, L14_2 = L13_2(L14_2)
        if L13_2 and L14_2 then
          L15_2 = GetResourceState
          L16_2 = L14_2.resourceName
          L15_2 = L15_2(L16_2)
          if "started" == L15_2 or "starting" == L15_2 then
            L16_2 = Config
            if L16_2 then
              L16_2 = Config
              L16_2 = L16_2.Debug
              if L16_2 then
                L16_2 = print
                L17_2 = "^5[^3 TStudio Elevator Loader^5]^7 Loading elevators for: ^2%s^7"
                L18_2 = L17_2
                L17_2 = L17_2.format
                L19_2 = L14_2.resourceName
                L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L17_2(L18_2, L19_2)
                L16_2(L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
              end
            end
            L16_2 = Config
            if L16_2 then
              L16_2 = Config
              L16_2 = L16_2.Locale
              if L16_2 then
                goto lbl_136
              end
            end
            L16_2 = "en"
            ::lbl_136::
            L17_2 = L14_2.locales
            if L17_2 then
              L17_2 = L14_2.locales
              L17_2 = L17_2[L16_2]
            end
            if not L17_2 then
              L18_2 = print
              L19_2 = "^5[^3 TStudio Elevator Loader^5]^7 \226\154\160\239\184\143 Warning: No '%s' locale found for ^1%s^7, skipping"
              L20_2 = L19_2
              L19_2 = L19_2.format
              L21_2 = L16_2
              L22_2 = L14_2.resourceName
              L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L19_2(L20_2, L21_2, L22_2)
              L18_2(L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
              L1_2 = L1_2 + 1
            else
              L18_2 = L14_2.marker
              if not L18_2 then
                L18_2 = print
                L19_2 = "^5[^3 TStudio Elevator Loader^5]^7 \226\154\160\239\184\143 Warning: No marker config found for ^1%s^7, skipping"
                L20_2 = L19_2
                L19_2 = L19_2.format
                L21_2 = L14_2.resourceName
                L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L19_2(L20_2, L21_2)
                L18_2(L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
                L1_2 = L1_2 + 1
              else
                L18_2 = ipairs
                L19_2 = L14_2.elevators
                L18_2, L19_2, L20_2, L21_2 = L18_2(L19_2)
                for L22_2, L23_2 in L18_2, L19_2, L20_2, L21_2 do
                  L24_2 = Elevator
                  L24_2 = L24_2.new
                  L25_2 = {}
                  L26_2 = L23_2.floors
                  L25_2.floors = L26_2
                  L25_2.locale = L17_2
                  L26_2 = L14_2.marker
                  L25_2.marker = L26_2
                  L26_2 = L14_2.header
                  L25_2.header = L26_2
                  L24_2(L25_2)
                end
                L18_2 = Config
                if L18_2 then
                  L18_2 = Config
                  L18_2 = L18_2.Debug
                  if L18_2 then
                    L18_2 = print
                    L19_2 = "^5[^3 TStudio Elevator Loader^5]^7 \226\156\133 Loaded %d elevator(s) for ^2%s^7"
                    L20_2 = L19_2
                    L19_2 = L19_2.format
                    L21_2 = L14_2.elevators
                    L21_2 = #L21_2
                    L22_2 = L14_2.resourceName
                    L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L19_2(L20_2, L21_2, L22_2)
                    L18_2(L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
                  end
                end
                L0_2 = L0_2 + 1
              end
            end
          else
            L16_2 = Config
            if L16_2 then
              L16_2 = Config
              L16_2 = L16_2.Debug
              if L16_2 then
                L16_2 = print
                L17_2 = "^5[^3 TStudio Elevator Loader^5]^7 \226\143\173\239\184\143 Skipping ^3%s^7 (resource state: %s)"
                L18_2 = L17_2
                L17_2 = L17_2.format
                L19_2 = L14_2.resourceName
                L20_2 = L15_2 or L20_2
                if not L15_2 then
                  L20_2 = "not found"
                end
                L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L17_2(L18_2, L19_2, L20_2)
                L16_2(L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
              end
            end
            L1_2 = L1_2 + 1
          end
        else
          L15_2 = print
          L16_2 = "^5[^3 TStudio Elevator Loader^5]^7 \226\157\140 Error executing config %s: %s"
          L17_2 = L16_2
          L16_2 = L16_2.format
          L18_2 = L9_2
          L19_2 = tostring
          L20_2 = L14_2
          L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L19_2(L20_2)
          L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L16_2(L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
          L15_2(L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
        end
      else
        L13_2 = print
        L14_2 = "^5[^3 TStudio Elevator Loader^5]^7 \226\157\140 Error loading config %s: %s"
        L15_2 = L14_2
        L14_2 = L14_2.format
        L16_2 = L9_2
        L17_2 = tostring
        L18_2 = L12_2
        L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L17_2(L18_2)
        L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L14_2(L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
        L13_2(L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
      end
    else
      L11_2 = Config
      if L11_2 then
        L11_2 = Config
        L11_2 = L11_2.Debug
        if L11_2 then
          L11_2 = print
          L12_2 = "^5[^3 TStudio Elevator Loader^5]^7 \226\157\140 Config file not found: %s"
          L13_2 = L12_2
          L12_2 = L12_2.format
          L14_2 = L9_2
          L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L12_2(L13_2, L14_2)
          L11_2(L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
        end
      end
    end
  end
  L4_2 = Config
  if L4_2 then
    L4_2 = Config
    L4_2 = L4_2.Debug
    if L4_2 then
      L4_2 = print
      L5_2 = "^5[^3 TStudio Elevator Loader^5]^7 \226\156\133 Finished! Loaded: ^2%d^7 | Skipped: ^3%d^7"
      L6_2 = L5_2
      L5_2 = L5_2.format
      L7_2 = L0_2
      L8_2 = L1_2
      L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2 = L5_2(L6_2, L7_2, L8_2)
      L4_2(L5_2, L6_2, L7_2, L8_2, L9_2, L10_2, L11_2, L12_2, L13_2, L14_2, L15_2, L16_2, L17_2, L18_2, L19_2, L20_2, L21_2, L22_2, L23_2, L24_2, L25_2, L26_2)
    end
  end
end
L0_1(L1_1)
