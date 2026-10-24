lib.callback.register('mt-agriculture:server:processWheat', function(source, millId)
    local src = source
    if not exports['mt-agriculture']:PlayerHasJob(src, Config.Farming.jobName) then
        return false, 'not_farmer'
    end

    local mill = Config.Processing[millId]
    if not mill then
        return false, 'invalid_station'
    end

    local hasEnough = exports.ox_inventory:Search(src, 'count', mill.inputItem) or 0
    if hasEnough < mill.inputPerRun then
        return false, 'not_enough_input'
    end

    local removed = exports.ox_inventory:RemoveItem(src, mill.inputItem, mill.inputPerRun)
    if not removed then
        return false, 'remove_failed'
    end

    local added = exports.ox_inventory:AddItem(src, mill.outputItem, mill.outputCount)
    if not added then
        exports.ox_inventory:AddItem(src, mill.inputItem, mill.inputPerRun)
        return false, 'inv_full'
    end

    return true
end)
