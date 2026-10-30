-- TStudio Patch Loader
-- Automatically loads compatibility patches for active map resources
-- Manages dependencies and prevents conflicts between patches

-- Prefix for console messages
local messagePrefix = "^5[^3 TStudio Patch Loader^5]"

-- Check if array1 is a subset of array2
function isSubsetOf(array1, array2)
    for _, item in ipairs(array1) do
        if not tableContains(array2, item) then
            return false
        end
    end
    return true
end

-- Check if table contains a specific value
function tableContains(table, value)
    for _, item in ipairs(table) do
        if item == value then
            return true
        end
    end
    return false
end

-- Start a fix resource if needed
function startFix(fixResourceName, patchName)
    local resourceState = GetResourceState(fixResourceName)
    
    if resourceState == "missing" then
        print(string.format("%s ❌ Map fix resource missing: ^1%s^7", messagePrefix, fixResourceName))
        print(string.format("%s ⚠️ Please download ^3%s^7 from: ^4https://github.com/TStudio3d/tstudio_maps_patches^7", messagePrefix, fixResourceName))
        return
    end
    
    if resourceState ~= "started" then
        print(string.format("%s ✅ Starting map fix for ^2%s^7 → ^3%s^7", messagePrefix, patchName, fixResourceName))
        StartResource(fixResourceName)
    else
        print(string.format("%s ⚠️ Map fix already active for ^2%s^7 → ^3%s^7", messagePrefix, patchName, fixResourceName))
    end
end

-- Main event handler for resource start
AddEventHandler("onResourceStart", function(resourceName)
    local currentResource = GetCurrentResourceName()
    
    -- Only run when this resource starts
    if resourceName ~= currentResource then
        return
    end
    
    -- Wait a moment for other resources to initialize
    Wait(1000)
    
    local compatibilityPatches = Config.CompatibilityPatches
    
    print(string.format("%s 🔎 Check for Patches ^2", messagePrefix))
    
    -- Sort patches by number of required maps (descending)
    -- This ensures more specific patches are processed first
    table.sort(compatibilityPatches, function(a, b)
        return #a.requiredMaps > #b.requiredMaps
    end)
    
    local activatedPatches = {}
    
    -- Process each compatibility patch
    for _, patch in ipairs(compatibilityPatches) do
        local allRequiredMapsActive = true
        
        -- Check if all required maps are started
        for _, requiredMap in ipairs(patch.requiredMaps) do
            local mapState = GetResourceState(requiredMap)
            if mapState ~= "started" then
                allRequiredMapsActive = false
                break
            end
        end
        
        if allRequiredMapsActive then
            local isConflicting = false
            
            -- Check for conflicts with already activated patches
            for _, activatedPatch in ipairs(activatedPatches) do
                if isSubsetOf(patch.requiredMaps, activatedPatch.requiredMaps) then
                    isConflicting = true
                    break
                end
            end
            
            -- Only activate if no conflicts found
            if not isConflicting then
                table.insert(activatedPatches, patch)
                startFix(patch.fixResource, patch.name)
            end
        end
    end
end)