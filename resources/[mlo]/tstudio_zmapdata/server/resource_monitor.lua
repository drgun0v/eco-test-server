-- TStudio Resource Monitor
-- Monitors configured resources and notifies clients when they're ready
-- Handles resource restarts and player connections

-- Main monitoring thread
CreateThread(function()
    local resourceStates = {}
    local resourceCount = 0
    local missingResources = {}
    local availableResources = {}
    
    -- Scan all configured resources
    for resourceName, _ in pairs(Config.Interiors) do
        local resourceState = GetResourceState(resourceName)
        
        if resourceState ~= "missing" and resourceState ~= "unknown" then
            resourceStates[resourceName] = false
            resourceCount = resourceCount + 1
            table.insert(availableResources, resourceName)
            TStudioUtils.Debug(string.format(
                "^2[TStudio RESOURCE MONITOR]^7 Found resource to monitor: %s (state: %s)", 
                resourceName, 
                resourceState
            ))
        else
            table.insert(missingResources, resourceName)
            TStudioUtils.Debug(string.format(
                "^3[TStudio RESOURCE MONITOR]^7 Skipping resource (not found): %s (state: %s)", 
                resourceName, 
                resourceState
            ))
        end
    end
    
    -- Log missing resources if any
    if #missingResources > 0 then
        TStudioUtils.Debug(string.format(
            "^3[TStudio RESOURCE MONITOR]^7 Skipped %d missing resources: %s", 
            #missingResources, 
            table.concat(missingResources, ", ")
        ))
    end
    
    -- Exit if no resources to monitor
    if resourceCount == 0 then
        TStudioUtils.Debug("^3[TStudio RESOURCE MONITOR]^7 No existing resources to monitor - not triggering IPL blocker event")
        return
    end
    
    TStudioUtils.Debug(string.format(
        "^2[TStudio RESOURCE MONITOR]^7 Monitoring %d existing resources for IPL blocker...", 
        resourceCount
    ))
    
    local startTime = GetGameTimer()
    local timeout = 120000 -- 2 minutes
    
    -- Monitor resources until all are ready or timeout
    while true do
        local elapsedTime = GetGameTimer() - startTime
        
        -- Check for timeout
        if elapsedTime >= timeout then
            TStudioUtils.Debug("^3[TStudio RESOURCE MONITOR]^7 Timeout reached after 2 minutes - proceeding with available resources")
            TriggerClientEvent("tstudio_zmapdata:resourcesReady", -1, availableResources)
            break
        end
        
        local allReady = true
        local readyCount = 0
        local totalCount = 0
        
        -- Check status of all monitored resources
        for resourceName, _ in pairs(resourceStates) do
            totalCount = totalCount + 1
            local currentState = GetResourceState(resourceName)
            
            if currentState == "started" then
                if not resourceStates[resourceName] then
                    resourceStates[resourceName] = true
                    TStudioUtils.Debug(string.format(
                        "^2[TStudio RESOURCE MONITOR]^7 Resource ready: %s", 
                        resourceName
                    ))
                end
                readyCount = readyCount + 1
            else
                allReady = false
            end
        end
        
        -- All resources ready - notify clients
        if allReady then
            TStudioUtils.Debug(string.format(
                "^2[TStudio RESOURCE MONITOR]^7 All %d resources ready! Notifying clients...", 
                totalCount
            ))
            TriggerClientEvent("tstudio_zmapdata:resourcesReady", -1, availableResources)
            break
        else
            -- Periodic status update (every 10 seconds)
            if elapsedTime % 10000 < 2000 then
                TStudioUtils.Debug(string.format(
                    "^3[TStudio RESOURCE MONITOR]^7 Resources ready: %d/%d - waiting...", 
                    readyCount, 
                    totalCount
                ))
            end
        end
        
        Wait(2000)
    end
    
    TStudioUtils.Debug("^2[TStudio RESOURCE MONITOR]^7 Resource monitoring completed")
end)

-- Handle resource restarts
AddEventHandler("onResourceStart", function(resourceName)
    local resourceConfig = Config.Interiors[resourceName]
    
    if resourceConfig then
        local resourceState = GetResourceState(resourceName)
        
        if resourceState ~= "missing" and resourceState ~= "unknown" then
            TStudioUtils.Debug(string.format(
                "^2[TStudio RESOURCE MONITOR]^7 Monitored resource restarted: %s - re-notifying clients", 
                resourceName
            ))
            
            -- Wait a moment then re-notify clients with current resource list
            SetTimeout(1000, function()
                local currentResources = {}
                
                for resName, _ in pairs(Config.Interiors) do
                    local state = GetResourceState(resName)
                    if state ~= "missing" and state ~= "unknown" then
                        table.insert(currentResources, resName)
                    end
                end
                
                TriggerClientEvent("tstudio_zmapdata:resourcesReady", -1, currentResources)
            end)
        else
            TStudioUtils.Debug(string.format(
                "^3[TStudio RESOURCE MONITOR]^7 Resource %s restarted but not found on server (state: %s)", 
                resourceName, 
                resourceState
            ))
        end
    end
end)

-- Handle player connections
AddEventHandler("playerJoining", function()
    local playerId = source
    local availableResources = {}
    local hasResources = false
    
    -- Build list of available resources
    for resourceName, _ in pairs(Config.Interiors) do
        local resourceState = GetResourceState(resourceName)
        if resourceState ~= "missing" and resourceState ~= "unknown" then
            hasResources = true
            table.insert(availableResources, resourceName)
        end
    end
    
    if hasResources then
        -- Check if all resources are ready
        local allReady = true
        for _, resourceName in ipairs(availableResources) do
            local state = GetResourceState(resourceName)
            if state ~= "started" then
                allReady = false
                break
            end
        end
        
        if allReady then
            -- All resources ready - notify player
            SetTimeout(2000, function()
                TStudioUtils.Debug(string.format(
                    "^2[TStudio RESOURCE MONITOR]^7 Notifying reconnected player (ID: %d) about ready resources", 
                    playerId
                ))
                TriggerClientEvent("tstudio_zmapdata:resourcesReady", playerId, availableResources)
            end)
        else
            TStudioUtils.Debug(string.format(
                "^3[TStudio RESOURCE MONITOR]^7 Player (ID: %d) connected but not all resources ready yet", 
                playerId
            ))
        end
    else
        -- No resources to monitor - notify with empty list
        SetTimeout(2000, function()
            TStudioUtils.Debug(string.format(
                "^2[TStudio RESOURCE MONITOR]^7 Notifying reconnected player (ID: %d) - no resources to monitor", 
                playerId
            ))
            TriggerClientEvent("tstudio_zmapdata:resourcesReady", playerId, {})
        end)
    end
end)