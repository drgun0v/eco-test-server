-- server/orders.lua
-- Lightweight "last X receipts" storage per restaurant.

local CompletedOrders = {}
local MAX_RECEIPTS = 25

local function addCompletedOrder(restaurantId, orderData)
    if not restaurantId or type(orderData) ~= "table" then return end

    CompletedOrders[restaurantId] = CompletedOrders[restaurantId] or {}
    local list = CompletedOrders[restaurantId]

    -- newest first
    table.insert(list, 1, orderData)

    -- keep only last MAX_RECEIPTS
    if #list > MAX_RECEIPTS then
        table.remove(list)
    end
end

-- Called from registers.lua on successful payment
RegisterNetEvent("mt-restaurants:server:registerReceipt", function(restaurantId, orderData)
    addCompletedOrder(restaurantId, orderData)
end)

-- NUI callback: get last receipts for current restaurant
lib.callback.register("mt-restaurants:server:getReceipts", function(source, restaurantId)
    if not restaurantId then return {} end
    return CompletedOrders[restaurantId] or {}
end)
