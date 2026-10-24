CreateThread(function()
    if not Config.Farming.useTarget then return end

    for id, mill in pairs(Config.Processing or {}) do
        exports.ox_target:addSphereZone({
            coords  = mill.coords,
            radius  = mill.radius or 2.0,
            debug   = false,
            options = {
                {
                    name  = 'mt_agri_proc_' .. id,
                    icon  = 'fa-solid fa-industry',
                    label = ('Process %s → %s'):format(mill.inputItem, mill.outputItem),
                    onSelect = function()
                        local ok = lib.progressCircle({
                            duration   = mill.time or 10000,
                            label      = 'Processing wheat...',
                            position   = 'bottom',
                            useWhileDead = false,
                            canCancel  = true,
                            disable    = { move = true, car = true, combat = true },
                        })
                        if not ok then return end

                        local success, reason = lib.callback.await('mt-agriculture:server:processWheat', false, id)
                        if success then
                            lib.notify({ description = 'You processed wheat into flour.', type = 'success' })
                        else
                            lib.notify({ description = 'Processing failed: ' .. (reason or ''), type = 'error' })
                        end
                    end
                }
            }
        })
    end
end)
