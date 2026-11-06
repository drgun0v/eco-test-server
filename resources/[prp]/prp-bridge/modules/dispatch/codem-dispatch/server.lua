local dispatch = {}
local alertEvent = ("%s:bridge:codemDispatch"):format(GetCurrentResourceName())

---@param src number | string
---@param jobs string[]
---@param coords vector3
---@param data AlertData
---@param blip AlertBlip
---@param alertFlash? boolean
function dispatch.sendAlert(src, jobs, coords, data, blip, alertFlash)
    local target = tonumber(src)
    if not target or target <= 0 then
        lib.print.warn("CodeM dispatch requires a player source")
        return
    end

    -- CustomDispatch is a client export; CodeM adds its security key there.
    TriggerClientEvent(alertEvent, target, {
        type = data.type or "Robbery",
        header = data.title,
        text = data.description or data.message or data.text or data.title,
        code = data.code,
        coords = coords,
        job = jobs,
    })
end

return dispatch
