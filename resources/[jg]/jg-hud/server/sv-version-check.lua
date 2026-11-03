-- Configuration
local RESOURCE_NAME = "jg-hud"
local VERSION_URL = "https://raw.githubusercontent.com/jgscripts/versions/main/" .. RESOURCE_NAME .. ".txt"

-- Compare two version strings (e.g., "1.2.3" vs "1.2.4")
-- Returns true if currentVersion is older than latestVersion
local function IsVersionOutdated(currentVersion, latestVersion)
    -- Parse current version into number array
    local currentParts = {}
    for part in string.gmatch(currentVersion, "[^.]+") do
        table.insert(currentParts, tonumber(part))
    end
    
    -- Parse latest version into number array
    local latestParts = {}
    for part in string.gmatch(latestVersion, "[^.]+") do
        table.insert(latestParts, tonumber(part))
    end
    
    -- Compare each version part
    local maxLength = math.max(#currentParts, #latestParts)
    for i = 1, maxLength do
        local current = currentParts[i] or 0
        local latest = latestParts[i] or 0
        
        if current < latest then
            return true
        end
    end
    
    return false
end

-- Check for resource updates
PerformHttpRequest(VERSION_URL, function(statusCode, responseBody, headers)
    -- Check if request was successful
    if statusCode ~= 200 then
        print("^1Unable to perform update check")
        return
    end
    
    -- Get current resource version
    local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
    
    if not currentVersion then
        return
    end
    
    -- Skip check for dev versions
    if currentVersion == "dev" then
        print("^3Using dev version")
        return
    end
    
    -- Extract first line from response (latest version)
    local latestVersion = responseBody:match("^[^\n]+")
    
    if not latestVersion then
        return
    end
    
    -- Remove "v" prefix from versions for comparison
    local currentVersionNumber = currentVersion:sub(2)
    local latestVersionNumber = latestVersion:sub(2)
    
    -- Check if update is available
    if IsVersionOutdated(currentVersionNumber, latestVersionNumber) then
        print("^3Update available for " .. RESOURCE_NAME .. "! (current: ^1" .. currentVersion .. "^3, latest: ^2" .. latestVersion .. "^3)")
        print("^3Release notes: discord.gg/jgscripts")
    end
end, "GET")

-- Check FXServer artifact version for known issues
local function CheckArtifactVersion()
    -- Get FXServer version
    local serverVersion = GetConvar("version", "unknown")
    
    -- Extract artifact number from version string (e.g., "v1.0.0.1234" -> "1234")
    local artifactNumber = string.match(serverVersion, "v%d+%.%d+%.%d+%.(%d+)")
    
    -- Check artifact status
    PerformHttpRequest("https://artifacts.jgscripts.com/check?artifact=" .. artifactNumber, function(statusCode, responseBody, headers, errorData)
        -- Check if request was successful
        if statusCode ~= 200 or errorData then
            print("^1Could not check artifact version^0")
            return
        end
        
        if not responseBody then
            return
        end
        
        -- Parse JSON response
        local data = json.decode(responseBody)
        
        -- Check if artifact has known issues
        if data.status == "BROKEN" then
            print("^1WARNING: The current FXServer version you are using (artifacts version) has known issues. Please update to the latest stable artifacts: https://artifacts.jgscripts.com^0")
            print("^0Artifact version:^3", artifactNumber, "\n^0Known issues:^3", data.reason, "^0")
        end
    end)
end

-- Run artifact check on startup
CreateThread(function()
    CheckArtifactVersion()
end)