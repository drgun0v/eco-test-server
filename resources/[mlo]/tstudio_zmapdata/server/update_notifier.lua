-- TStudio Discord Webhook Validation System
-- Sends validation reports to Discord with optional file attachments
-- Supports both simple embeds and multipart form data with files

-- Send validation report to Discord webhook
function sendWithFile(webhookUrl, embedData, filePath, fileName)
    -- If no file path or filename provided, send simple embed
    if not filePath or not fileName then
        local payload = {
            embeds = { embedData }
        }
        
        PerformHttpRequest(webhookUrl, function(statusCode, responseBody, headers)
            if Config.Debug then
                if statusCode == 204 or statusCode == 200 then
                    print("^2[TStudio Update Validator]^7 Validation summary processed successfully")
                else
                    print("^1[TStudio Update Validator]^7 Failed to process validation summary. Code: " .. tostring(statusCode))
                end
            end
        end, "POST", json.encode(payload), {
            ["Content-Type"] = "application/json"
        })
        return
    end
    
    -- Try to open the file for reading
    local file = io.open(filePath, "r")
    if not file then
        if Config.Debug then
            print("^1[TStudio Update Validator]^7 Unable to access validation document: " .. filePath)
        end
        return
    end
    
    -- Read file content and close
    local fileContent = file:read("*all")
    file:close()
    
    -- Generate unique boundary for multipart form data
    local boundary = "----TStudioValidationBoundary" .. tostring(math.random(1000000, 9999999))
    
    -- Build multipart form data
    local formData = {}
    
    -- Add JSON payload part
    table.insert(formData, "--" .. boundary)
    table.insert(formData, "Content-Disposition: form-data; name=\"payload_json\"")
    table.insert(formData, "Content-Type: application/json")
    table.insert(formData, "")
    table.insert(formData, json.encode({
        embeds = { embedData }
    }))
    
    -- Add file attachment part
    table.insert(formData, "--" .. boundary)
    table.insert(formData, "Content-Disposition: form-data; name=\"file\"; filename=\"" .. fileName .. "\"")
    table.insert(formData, "Content-Type: text/plain")
    table.insert(formData, "")
    table.insert(formData, fileContent)
    table.insert(formData, "--" .. boundary .. "--")
    
    -- Join all parts with CRLF
    local requestBody = table.concat(formData, "\r\n")
    
    -- Send multipart request
    PerformHttpRequest(webhookUrl, function(statusCode, responseBody, headers)
        if Config.Debug then
            if statusCode == 204 or statusCode == 200 then
                print("^2[TStudio Update Validator]^7 Validation report with documentation processed successfully")
            else
                print("^1[TStudio Update Validator]^7 Failed to process validation report with documentation. Code: " .. tostring(statusCode))
                if responseBody then
                    print("^1[Debug Response]^7 " .. tostring(responseBody))
                end
            end
        end
        
        -- Clean up temporary file if it exists
        if filePath then
            os.remove(filePath)
        end
    end, "POST", requestBody, {
        ["Content-Type"] = "multipart/form-data; boundary=" .. boundary
    })
end

-- Export the webhook module
local DiscordWebhook = {}
DiscordWebhook.sendWithFile = sendWithFile

return DiscordWebhook