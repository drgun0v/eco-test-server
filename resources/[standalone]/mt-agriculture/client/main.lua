local ESX
local PlayerData = {}

CreateThread(function()
    ESX = exports['es_extended']:getSharedObject()
    while not ESX.GetPlayerData().job do Wait(100) end
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:setJob', function(job)
    PlayerData.job = job
end)

local function IsFarmer()
    return PlayerData.job and PlayerData.job.name == Config.Farming.jobName
end

-- Market buyer ped + sell menu
CreateThread(function()
    local pedCfg = Config.Market and Config.Market.buyerPed
    if not pedCfg then return end

    local model = pedCfg.model
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(4, model, pedCfg.coords.x, pedCfg.coords.y, pedCfg.coords.z - 1.0, pedCfg.coords.w, false, true)
    SetModelAsNoLongerNeeded(model)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)

    if not Config.Farming.useTarget then return end

    exports.ox_target:addLocalEntity(ped, {
        {
            name  = 'mt_agri_market_sell',
            icon  = 'fa-solid fa-dollar-sign',
            label = 'Sell Farm Products',
            onSelect = function()
                if not IsFarmer() then
                    lib.notify({ description = 'You are not a farmer.', type = 'error' })
                    return
                end

                local sellable = {}
                for itemName, price in pairs(Config.Market.prices or {}) do
                    local count = exports.ox_inventory:Search('count', itemName)
                    if count and count > 0 then
                        sellable[#sellable+1] = {
                            title    = ('%s ($%s each, you have %s)'):format(itemName, price, count),
                            itemName = itemName,
                            count    = count,
                        }
                    end
                end

                if #sellable == 0 then
                    lib.notify({ description = 'You have nothing to sell.', type = 'error' })
                    return
                end

                local input = {}
                for i, data in ipairs(sellable) do
                    input[#input+1] = {
                        type        = 'number',
                        label       = data.title,
                        description = 'Enter amount to sell (max ' .. data.count .. ')',
                        required    = false,
                        icon        = 'fa-solid fa-boxes-stacked',
                        default     = 0,
                        name        = data.itemName
                    }
                end

                local result = lib.inputDialog('Sell to Market', input)
                if not result then return end

                local itemsToSell = {}
                for idx, data in ipairs(sellable) do
                    local amount = tonumber(result[idx]) or 0
                    if amount > 0 then
                        itemsToSell[data.itemName] = amount
                    end
                end

                if next(itemsToSell) == nil then
                    return
                end

                local ok, totalOrReason = lib.callback.await('mt-agriculture:server:sellToMarket', false, itemsToSell)
                if ok then
                    lib.notify({ description = ('You earned $%s from selling goods.'):format(totalOrReason), type = 'success' })
                else
                    lib.notify({ description = 'Sale failed: ' .. (totalOrReason or ''), type = 'error' })
                end
            end
        }
    })
end)
