local dispatch = {}
local alertEvent = ("%s:bridge:codemDispatch"):format(GetCurrentResourceName())

-- Each importing resource owns its event so an alert is forwarded only once.
RegisterNetEvent(alertEvent, function(data)
    if source ~= 65535 then return end
    exports['codem-dispatch']:CustomDispatch(data)
end)

return dispatch
