-- Export untuk penggunaan item summit_passport di ox_inventory
exports('useSummitPassport', function(event, item, inventory, slot, data)
    if event == 'usingItem' then
        local src = inventory.id
        local slotData = exports.ox_inventory:GetSlot(src, slot)
        if slotData and slotData.metadata then
            TriggerClientEvent('eco_sportsevent:client:openPassportUI', src, slotData.metadata)
        else
            TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Data paspor kosong atau rusak.' })
        end
        return false
    end
end)
