local ESX

CreateThread(function()
    if Config.Farming.framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    end
end)

lib.callback.register('mt-agriculture:server:sellToMarket', function(source, itemsToSell)
    local src = source
    if not ESX then return false, 'no_esx' end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false, 'no_player' end

    if type(itemsToSell) ~= 'table' then
        return false, 'invalid_items'
    end

    local totalPayout = 0

    for itemName, count in pairs(itemsToSell) do
        count = tonumber(count) or 0
        if count > 0 then
            local price = Config.Market.prices[itemName]
            if price then
                local currentCount = exports.ox_inventory:GetItem(src, itemName, nil, true) or 0
                if currentCount >= count then
                    local removed = exports.ox_inventory:RemoveItem(src, itemName, count)
                    if removed then
                        totalPayout = totalPayout + (price * count)
                    end
                end
            end
        end
    end

    if totalPayout > 0 then
        xPlayer.addMoney(totalPayout)
        return true, totalPayout
    else
        return false, 'no_items_sold'
    end
end)
