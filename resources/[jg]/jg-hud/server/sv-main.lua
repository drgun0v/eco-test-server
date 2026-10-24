-- Enable fly through windscreen if custom seatbelt integration is not used
if not Config.UseCustomSeatbeltIntegration then
    SetConvarReplicated("game_enableFlyThroughWindscreen", "true")
end

-- Thread to check and stop conflicting resource
CreateThread(function()
    -- Wait 10 seconds after server start
    Wait(10000)
    
    -- Safely attempt to stop jg-vehicleindicators if running
    pcall(function()
        local resourceState = GetResourceState("jg-vehicleindicators")
        
        if resourceState == "started" then
            StopResource("jg-vehicleindicators")
        end
    end)
end)