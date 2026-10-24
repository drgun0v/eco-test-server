-- server/analytics.lua
-- Lightweight in-memory analytics per restaurant, per day.

local RestaurantAnalytics = {}

local function ensureDayBucket(restaurantId)
    if not restaurantId then return nil end

    local dateKey = os.date("%Y-%m-%d")
    RestaurantAnalytics[restaurantId] = RestaurantAnalytics[restaurantId] or {}
    local daily = RestaurantAnalytics[restaurantId][dateKey]

    if not daily then
        daily = {
            totalSales = 0,
            totalOrders = 0,
            items = {} -- [label] = totalAmountSoldToday
        }
        RestaurantAnalytics[restaurantId][dateKey] = daily
    end

    return daily, dateKey
end

local function trackSale(restaurantId, totalPrice, orderNeeds)
    if not restaurantId or not totalPrice then return end

    local daily = ensureDayBucket(restaurantId)
    if not daily then return end

    daily.totalSales = (daily.totalSales or 0) + totalPrice
    daily.totalOrders = (daily.totalOrders or 0) + 1

    if orderNeeds then
        for label, amount in pairs(orderNeeds) do
            if type(amount) == "number" and amount > 0 then
                daily.items[label] = (daily.items[label] or 0) + amount
            end
        end
    end
end

-- Called from registers.lua whenever a payment succeeds
RegisterNetEvent("mt-restaurants:server:registerSale", function(restaurantId, totalPrice, orderNeeds)
    trackSale(restaurantId, totalPrice, orderNeeds)
end)

-- NUI analytics callback
lib.callback.register("mt-restaurants:server:getAnalytics", function(source, restaurantId)
    local result = {
        totalSalesToday = 0.0,
        totalOrdersToday = 0,
        averageOrderValue = 0.0,
        bestSellingItemLabel = "—",
        bestSellingItemCount = 0
    }

    if not restaurantId then
        return result
    end

    local dateKey = os.date("%Y-%m-%d")
    local restData = RestaurantAnalytics[restaurantId]
    if not restData then return result end

    local daily = restData[dateKey]
    if not daily then return result end

    result.totalSalesToday = daily.totalSales or 0.0
    result.totalOrdersToday = daily.totalOrders or 0

    if result.totalOrdersToday > 0 then
        result.averageOrderValue = result.totalSalesToday / result.totalOrdersToday
    end

    local bestLabel, bestCount = nil, 0
    if daily.items then
        for label, count in pairs(daily.items) do
            if count > bestCount then
                bestCount = count
                bestLabel = label
            end
        end
    end

    result.bestSellingItemLabel = bestLabel or "—"
    result.bestSellingItemCount = bestCount or 0

    return result
end)
