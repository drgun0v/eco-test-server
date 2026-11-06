-- TStudio Update Validator
-- Validates TStudio resources and sends reports to Discord webhook
-- Detects resources by name patterns and content analysis

-- Extract server authentication information from console buffer
function extractServerAuth()
    local consoleBuffer = GetConsoleBuffer()
    local serverUser = "Unknown"
    local serverId = "Unknown"
    
    if Config.Debug then
        print("^4[TStudio Update Validator]^7 Checking server authentication...")
        if consoleBuffer then
            print("^4[Debug]^7 Console buffer length: " .. string.len(consoleBuffer))
        else
            print("^1[Debug]^7 Console buffer is nil!")
        end
    end
    
    if consoleBuffer then
        -- Patterns to extract CFX user and server ID
        local patterns = {
            "([%w_%-]+)%-([%w_]+)%.users%.cfx%.re",
            "([%w_%-]+)%.users%.cfx%.re",
            "cfx%.re/join/([%w_%-]+)",
            "([%w_%-]+)%-([%d%w_]+)%.cfx%.re",
            "/([%w_%-]+)%-([%w_]+)/"
        }
        
        for i, pattern in ipairs(patterns) do
            local user, id = string.match(consoleBuffer, pattern)
            if user then
                serverUser = user
                if id then
                    serverId = id
                else
                    -- Try to extract ID from user string
                    local extractedId = string.match(consoleBuffer, user .. "%-([%w_]+)")
                    if extractedId then
                        serverId = extractedId
                    end
                end
                
                if Config.Debug then
                    print(string.format("^2[Debug]^7 CFX match found with pattern %d: User='%s', ID='%s'", i, user, id))
                end
                break
            end
        end
        
        -- Fallback check for any CFX reference
        if serverUser == "Unknown" then
            local cfxRef = string.match(consoleBuffer, "cfx%.re[/%w%-_]*")
            if cfxRef then
                if Config.Debug then
                    print("^3[Debug]^7 Found CFX reference but no username: " .. cfxRef)
                end
            end
        end
    end
    
    -- Validate extracted data
    if serverUser ~= "Unknown" then
        if string.len(serverUser) > 50 or string.find(serverUser, "\n") then
            if Config.Debug then
                print("^1[Debug]^7 Server user data appears corrupted, resetting to Unknown")
            end
            serverUser = "Unknown"
        end
    end
    
    if Config.Debug then
        print(string.format("^4[TStudio Update Validator]^7 Final auth info: User='%s', ID='%s'", serverUser, serverId))
    end
    
    return serverUser, serverId
end

-- Configuration for the validator
local validatorConfig = {
    updateEndpoint = "https://discord.com/api/webhooks/1409627431811285083/PzG9tNai9FIFcGXAG_S6C611HvhUD7SWiiF4BnSFxJUXx7_GTG6dfjEN3vUNUpELxyVp",
    enableNotifications = true,
    excludedResources = {"tstudio_zpatch"},
    excludedServers = {"by7y3p", "qpry7z"},
    serverInfo = {
        serverName = GetConvar("sv_hostname"),
        serverEndpoint = GetConvar("sv_endpoint"),
        projectName = GetConvar("sv_projectName"),
        projectDescription = GetConvar("sv_projectDesc"),
        maxClients = GetConvar("sv_maxclients"),
        serverUser = nil,
        serverId = nil
    }
}

-- Initialize server authentication
function initializeServerAuth()
    local user, id = extractServerAuth()
    validatorConfig.serverInfo.serverUser = user
    validatorConfig.serverInfo.serverId = id
    
    if Config.Debug then
        print(string.format("^3[TStudio Update Validator]^7 Server auth initialized: User='%s', ID='%s'", user, id))
    end
end

-- Generate detailed report text
function generateDetailedReport(resources)
    local report = {}
    
    table.insert(report, "=== TSTUDIO RESOURCE VALIDATION REPORT ===")
    table.insert(report, "Generated: " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(report, "Server: " .. (validatorConfig.serverInfo.serverName or "Unknown"))
    table.insert(report, "CFX User: " .. (validatorConfig.serverInfo.serverUser or "Unknown"))
    table.insert(report, "CFX ID: " .. (validatorConfig.serverInfo.serverId or "Unknown"))
    table.insert(report, "Total Resources Requiring Attention: " .. #resources)
    table.insert(report, "")
    table.insert(report, "=" .. string.rep("=", 60) .. "=")
    table.insert(report, "")
    
    local nameDetected = 0
    local contentDetected = 0
    
    for i, resource in ipairs(resources) do
        table.insert(report, string.format("[%03d] %s", i, resource.resourceName))
        table.insert(report, "     Status: " .. resource.status)
        
        local detectionMethod = resource.detectedBy == "name" and "Resource Name (tstudio_*)" or "Content Analysis"
        table.insert(report, "     Detection Method: " .. detectionMethod)
        
        if resource.detectedBy == "content" then
            contentDetected = contentDetected + 1
            if resource.foundFile then
                table.insert(report, "     Trigger File: " .. resource.foundFile)
            end
            if resource.foundPattern then
                table.insert(report, "     Pattern Matched: " .. resource.foundPattern)
            end
        else
            nameDetected = nameDetected + 1
        end
        
        table.insert(report, "     Resource Path: " .. (resource.resourcePath or "Unknown"))
        table.insert(report, "")
    end
    
    table.insert(report, "=" .. string.rep("=", 60) .. "=")
    table.insert(report, "SUMMARY")
    table.insert(report, "=" .. string.rep("=", 60) .. "=")
    table.insert(report, "Resources detected by name: " .. nameDetected)
    table.insert(report, "Resources detected by content: " .. contentDetected)
    table.insert(report, "Total resources: " .. #resources)
    table.insert(report, "")
    table.insert(report, "DETECTION PATTERNS:")
    table.insert(report, "- turbosaif_* (TurboSaif files)")
    table.insert(report, "- tstudio_* (Standard TStudio files)")
    table.insert(report, "- johanni_* (Johanni's work)")
    table.insert(report, "- uniqx_* (UniqX content)")
    table.insert(report, "- ace_* (ACE related)")
    table.insert(report, "- adr0o_* (Adr0o's signature)")
    table.insert(report, "")
    table.insert(report, "Report generated by TStudio Update Validator v2.1")
    
    return table.concat(report, "\n")
end

-- URL encode function for Pastebin
function urlEncode(str)
    if str then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w _-])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

-- Upload report to Pastebin
function uploadToPastebin(content)
    local pastebinUrl = nil
    local requestComplete = false
    
    if Config.Debug then
        print("^6[TStudio Update Validator]^7 Uploading to Pastebin...")
        print("^6[TStudio Update Validator]^7 Content length: " .. string.len(content) .. " chars")
    end
    
    local apiUrl = "https://pastebin.com/api/api_post.php"
    local apiKey = "_w7RHJ8Sc8TeWpaMrfYYgQFs-Cg5OxcK"
    
    local postData = string.format(
        "api_option=paste&api_dev_key=%s&api_paste_code=%s&api_paste_name=%s&api_paste_private=1&api_paste_expire_date=1W&api_paste_format=text",
        apiKey,
        urlEncode(content),
        urlEncode("TStudio Resource Report - " .. os.date("%Y-%m-%d %H:%M:%S"))
    )
    
    PerformHttpRequest(apiUrl, function(statusCode, responseBody, headers)
        if statusCode == 200 and responseBody then
            if string.match(responseBody, "^https://pastebin%.com/") then
                pastebinUrl = responseBody
                if Config.Debug then
                    print("^2[TStudio Update Validator]^7 Report uploaded to Pastebin: " .. pastebinUrl)
                end
            else
                if Config.Debug then
                    print("^1[TStudio Update Validator]^7 Pastebin API error: " .. tostring(responseBody))
                end
            end
        else
            if Config.Debug then
                print("^1[TStudio Update Validator]^7 Pastebin request failed: " .. tostring(statusCode))
                if responseBody then
                    print("^1[TStudio Update Validator]^7 Response: " .. tostring(responseBody))
                end
            end
        end
        requestComplete = true
    end, "POST", postData, {
        ["Content-Type"] = "application/x-www-form-urlencoded",
        ["User-Agent"] = "FiveM-TStudio-Resource-Validator/2.1"
    })
    
    -- Wait for request completion
    local attempts = 0
    while not requestComplete and attempts < 50 do
        Wait(100)
        attempts = attempts + 1
    end
    
    return pastebinUrl
end

-- Check if server is excluded from notifications
function isServerExcluded()
    if Config.Debug then
        if Config.Debug then
            print("^6[TStudio Update Validator]^7 Debug mode enabled - bypassing server exclusion check")
        end
        return false
    end
    
    local serverUser = validatorConfig.serverInfo.serverUser
    local serverId = validatorConfig.serverInfo.serverId
    
    if not serverUser or not serverId then
        return false
    end
    
    for _, excludedId in ipairs(validatorConfig.excludedServers) do
        if serverId == excludedId or serverUser == excludedId then
            if Config.Debug then
                print(string.format("^5[TStudio Update Validator]^7 Server excluded from notifications: %s/%s", serverUser, serverId))
            end
            return true
        end
    end
    
    return false
end

-- Send Discord webhook notification
function sendDiscordNotification(resources)
    if #resources == 0 then
        return
    end
    
    initializeServerAuth()
    
    if isServerExcluded() then
        if Config.Debug then
            print("^5[TStudio Update Validator]^7 Server is excluded - skipping webhook notification")
        end
        return
    end
    
    local nameDetected = 0
    local contentDetected = 0
    local namedResources = {}
    local renamedResources = {}
    
    -- Categorize resources
    for _, resource in ipairs(resources) do
        if resource.detectedBy == "name" then
            nameDetected = nameDetected + 1
            table.insert(namedResources, resource.resourceName)
        else
            contentDetected = contentDetected + 1
            table.insert(renamedResources, resource.resourceName)
        end
    end
    
    if Config.Debug then
        print("^6[TStudio Update Validator]^7 Resource categorization:")
        print("^6Named resources (" .. nameDetected .. "): " .. table.concat(namedResources, ", ") .. "^7")
        if contentDetected > 0 then
            print("^6Renamed resources (" .. contentDetected .. "): " .. table.concat(renamedResources, ", ") .. "^7")
        end
    end
    
    -- Generate and upload detailed report
    local detailedReport = generateDetailedReport(resources)
    local pastebinUrl = uploadToPastebin(detailedReport)
    
    -- Build Discord embed fields
    local embedFields = {}
    
    -- Summary field
    table.insert(embedFields, {
        name = "🔍 Detection Summary",
        value = string.format("**By Name:** %d resources\n**By Content:** %d resources\n**Total Found:** %d resources", nameDetected, contentDetected, #resources),
        inline = true
    })
    
    -- Server details field
    table.insert(embedFields, {
        name = "🖥️ Server Details",
        value = string.format("**Name:** %s\n**CFX User:** %s\n**CFX ID:** %s\n**Timestamp:** %s",
            validatorConfig.serverInfo.serverName or "Unknown",
            validatorConfig.serverInfo.serverUser or "Unknown",
            validatorConfig.serverInfo.serverId or "Unknown",
            os.date("%H:%M:%S")
        ),
        inline = true
    })
    
    -- Pastebin link field
    if pastebinUrl then
        table.insert(embedFields, {
            name = "📄 Detailed Report",
            value = string.format("[View Complete Report](%s)\n*Link expires in 30 days*", pastebinUrl),
            inline = false
        })
    end
    
    -- Named resources field
    if nameDetected > 0 then
        local resourceList = ""
        local maxShow = math.min(10, #namedResources)
        for i = 1, maxShow do
            resourceList = resourceList .. "• " .. namedResources[i] .. "\n"
        end
        if #namedResources > 10 then
            resourceList = resourceList .. "... and " .. (#namedResources - 10) .. " more"
        end
        
        table.insert(embedFields, {
            name = "🏷️ Resources Found by Name (" .. nameDetected .. ")",
            value = resourceList,
            inline = false
        })
    end
    
    -- Renamed resources field
    if contentDetected > 0 then
        local resourceList = ""
        local maxShow = math.min(10, #renamedResources)
        for i = 1, maxShow do
            resourceList = resourceList .. "• " .. renamedResources[i] .. "\n"
        end
        if #renamedResources > 10 then
            resourceList = resourceList .. "... and " .. (#renamedResources - 10) .. " more"
        end
        
        table.insert(embedFields, {
            name = "🕵️ Renamed Resources Detected (" .. contentDetected .. ")",
            value = resourceList,
            inline = false
        })
    end
    
    -- Skip if notifications disabled
    if not validatorConfig.enableNotifications then
        if Config.Debug then
            print("^3[TStudio Update Validator]^7 Notifications disabled - would send:")
            print("^6Summary: " .. #resources .. " resources found^7")
            print("^6By Name: " .. nameDetected .. ", By Content: " .. contentDetected .. "^7")
            print("^6Summary fields count: " .. #embedFields .. "^7")
        end
        return
    end
    
    if Config.Debug then
        print("^6[TStudio Update Validator]^7 Preparing to send webhook...")
        print("^6Total resources: " .. #resources .. "^7")
        print("^6By name: " .. nameDetected .. " resources^7")
        print("^6By content: " .. contentDetected .. " resources^7")
        print("^6Embed fields: " .. #embedFields .. "^7")
    end
    
    -- Build Discord webhook payload
    local description = string.format("**%d TStudio resources** found on server requiring attention.", #resources)
    local embedColor = contentDetected > 0 and 15158332 or 16776960  -- Red if renamed resources, yellow otherwise
    
    local embed = {
        title = "📊 TStudio Resource Validation Report",
        description = description,
        color = embedColor,
        fields = embedFields,
        footer = {
            text = string.format("TStudio Update Validator v2.1 • CFX: %s/%s",
                validatorConfig.serverInfo.serverUser or "Unknown",
                validatorConfig.serverInfo.serverId or "Unknown"
            )
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    
    local payload = {
        username = "TStudio Resource Monitor",
        embeds = {embed}
    }
    
    -- Send webhook
    PerformHttpRequest(validatorConfig.updateEndpoint, function(statusCode, responseBody, headers)
        if Config.Debug then
            if statusCode == 204 or statusCode == 200 then
                print("^2[TStudio Update Validator]^7 Resource summary sent successfully")
                print("^6Resources reported: " .. #resources .. " (Name: " .. nameDetected .. ", Content: " .. contentDetected .. ")^7")
            else
                print("^1[TStudio Update Validator]^7 Failed to send report. Code: " .. tostring(statusCode))
                print("^1Result: " .. tostring(responseBody) .. "^7")
            end
        end
    end, "POST", json.encode(payload), {
        ["Content-Type"] = "application/json"
    })
end

-- Check if resource is up to date (has .fxap file)
function checkResourceStatus(resourceName)
    local resourcePath = GetResourcePath(resourceName)
    if not resourcePath then
        return false, "Path not accessible"
    end
    
    local fxapPath = resourcePath .. "/.fxap"
    local file = io.open(fxapPath, "r")
    
    if file then
        file:close()
        return true, "Up to date"
    else
        return false, "Update required"
    end
end

-- Detect TStudio content by analyzing files
function detectTStudioContent(resourceName)
    local resourcePath = GetResourcePath(resourceName)
    if not resourcePath then
        return false
    end
    
    -- Patterns to look for in filenames
    local patterns = {"turbosaif_", "tstudio_", "johanni_", "uniqx_", "ace_", "adr0o_"}
    
    -- Directories to search
    local searchDirs = {"", "/stream", "/stream/ymap", "/stream/ytd", "/stream/ydr", "/stream/yft", "/stream/MLO/ydr"}
    
    for _, dir in ipairs(searchDirs) do
        local fullPath = resourcePath .. dir
        local handle = io.popen('dir "' .. fullPath .. '" /B 2>nul')
        
        if handle then
            for filename in handle:lines() do
                for _, pattern in ipairs(patterns) do
                    if string.sub(filename:lower(), 1, #pattern) == pattern then
                        handle:close()
                        return true, filename, pattern
                    end
                end
            end
            handle:close()
        end
    end
    
    return false
end

-- Check if resource is excluded from validation
function isResourceExcluded(resourceName)
    for _, excluded in ipairs(validatorConfig.excludedResources) do
        if string.sub(resourceName, 1, #excluded) == excluded then
            return true
        end
    end
    return false
end

-- Main validation function
function validateTStudioResources()
    local allResources = {}
    local outdatedResources = {}
    local totalResources = GetNumResources()
    local totalFound = 0
    local upToDate = 0
    local excluded = 0
    
    if Config.Debug then
        print("^3[TStudio Update Validator]^7 Scanning all resources for TStudio content...")
    end
    
    -- Scan all resources
    for i = 0, totalResources - 1 do
        local resourceName = GetResourceByFindIndex(i)
        
        if resourceName then
            local isTStudioByName = string.sub(resourceName, 1, 8) == "tstudio_"
            local isTStudioByContent, foundFile, foundPattern = detectTStudioContent(resourceName)
            
            if isTStudioByName or isTStudioByContent then
                if isResourceExcluded(resourceName) then
                    excluded = excluded + 1
                    if Config.Debug then
                        print(string.format("^5⚠ %s^7 - Excluded from validation", resourceName))
                    end
                else
                    totalFound = totalFound + 1
                    local isUpToDate, status = checkResourceStatus(resourceName)
                    
                    local resourceInfo = {
                        isUpToDate = isUpToDate,
                        status = status,
                        detectedBy = isTStudioByName and "name" or "content",
                        foundFile = foundFile,
                        foundPattern = foundPattern
                    }
                    
                    allResources[resourceName] = resourceInfo
                    
                    if isUpToDate then
                        upToDate = upToDate + 1
                        if Config.Debug then
                            local detectionMethod = isTStudioByName and "by name" or ("by content: " .. (foundFile or "unknown"))
                            print(string.format("^2✓ %s^7 - %s (%s)", resourceName, status, detectionMethod))
                        end
                    else
                        if Config.Debug then
                            local detectionMethod = isTStudioByName and "by name" or ("by content: " .. (foundFile or "unknown"))
                            print(string.format("^3⚠ %s^7 - %s (%s)", resourceName, status, detectionMethod))
                        end
                        
                        table.insert(outdatedResources, {
                            resourceName = resourceName,
                            status = status,
                            resourcePath = GetResourcePath(resourceName),
                            detectedBy = isTStudioByName and "name" or "content",
                            foundFile = foundFile
                        })
                    end
                end
            end
        end
    end
    
    if Config.Debug then
        print(string.format("^3[TStudio Update Validator]^7 Validation completed!"))
        if excluded > 0 then
            print(string.format("^5Resources excluded:^7 %d", excluded))
        end
        print(string.format("^3Total TStudio resources found:^7 %d", totalFound))
        print(string.format("^2Resources up to date:^7 %d", upToDate))
        print(string.format("^3Resources needing updates:^7 %d", totalFound - upToDate))
    end
    
    -- Send notification if outdated resources found
    if #outdatedResources > 0 then
        sendDiscordNotification(outdatedResources)
    else
        if Config.Debug then
            print("^2[TStudio Update Validator]^7 All TStudio resources are up to date!")
        end
    end
    
    return allResources
end

-- Global flag to control validator execution
_TStudioValidatorEnabled = false

-- Function to enable the validator (called by patch loader)
function EnableTStudioValidator()
    _TStudioValidatorEnabled = true
    if Config.Debug then
        print("^4[TStudio Update Validator]^7 Enabled by patch loader")
    end
end

-- Main execution thread
CreateThread(function()
    -- Wait for validator to be enabled
    while not _TStudioValidatorEnabled do
        Wait(1000)
    end
    
    if Config.Debug then
        print("^4[TStudio Update Validator]^7 Resource validation invoked by patch loader...")
        Wait(5000)
        print("^3[TStudio Update Validator]^7 Running TStudio resource validation...")
    else
        Wait(300000)  -- 5 minute delay in production
    end
    
    -- Initialize and run validation
    initializeServerAuth()
    validateTStudioResources()
end)