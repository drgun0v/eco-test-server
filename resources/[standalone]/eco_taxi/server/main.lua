local activeOrders = {} -- [source] = { netVeh, state, origin, dest, fare, serviceType, driverName, surgeMultiplier, vip }

local function GetServiceConfig(sType)
    if Config.Services and Config.Services[sType] then
        return Config.Services[sType]
    end
    return {
        name = 'EcoCab',
        baseFare = 25,
        pricePerKm = 14,
        minFare = 30
    }
end

local function CalculateFare(sType, startCoords, destCoords, surgeMult, vipData)
    local sCfg = GetServiceConfig(sType)
    local distMeters = #(vector3(startCoords.x, startCoords.y, startCoords.z) - vector3(destCoords.x, destCoords.y, destCoords.z))
    local distKm = distMeters / 1000.0

    local base = sCfg.baseFare + (distKm * sCfg.pricePerKm)
    if base < sCfg.minFare then base = sCfg.minFare end

    local mult = surgeMult or 1.0
    local subTotal = base * mult

    local discount = 0
    local isVip = vipData and (vipData.isVip or vipData.usedVip)
    if isVip then
        discount = math.floor(subTotal * ((vipData.discountPercent or 20) / 100))
    end

    local final = math.max(1, math.ceil(subTotal - discount))
    return final, distKm, math.ceil(base), discount
end

-- Export / Event untuk Perkiraan Tarif
RegisterNetEvent('eco_taxi:server:requestFareEstimate', function(destCoords, serviceType)
    local src = source
    local ped = GetPlayerPed(src)
    if not DoesEntityExist(ped) then return end
    local pCoords = GetEntityCoords(ped)
    local sType = serviceType or 'ecocab'
    local estimatedFare, distanceKm = CalculateFare(sType, pCoords, destCoords, 1.0, nil)
    TriggerClientEvent('eco_taxi:client:receiveFareEstimate', src, estimatedFare, distanceKm)
end)

-- Pemesanan Taksi / Ojek EcoCab dari Tablet
RegisterNetEvent('eco_taxi:server:bookRide', function(destCoords, destName, serviceType, driverName, surgeMultiplier, vipPayload)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if activeOrders[src] then
        TriggerClientEvent('esx:showNotification', src, '~r~[EcoCab] Anda sudah memiliki armada yang sedang aktif!~s~')
        return
    end

    local ped = GetPlayerPed(src)
    local pCoords = GetEntityCoords(ped)
    local sType = serviceType or 'ecocab'
    local sCfg = GetServiceConfig(sType)
    local sName = sCfg.name or 'EcoCab'
    local surge = tonumber(surgeMultiplier) or 1.0

    local estimatedFare, distanceKm = CalculateFare(sType, pCoords, destCoords, surge, vipPayload)

    if xPlayer.getMoney() < estimatedFare then
        TriggerClientEvent('esx:showNotification', src, ('~r~[EcoCab] Saldo tunai Anda tidak mencukupi untuk estimasi tarif ($%s)!~s~'):format(estimatedFare))
        return
    end

    activeOrders[src] = {
        state = 'DISPATCHED',
        customer = src,
        pickup = pCoords,
        destination = destCoords,
        destName = destName or 'Tujuan Pilihan',
        serviceType = sType,
        serviceName = sName,
        driverName = driverName or 'Driver EcoCab',
        surgeMultiplier = surge,
        vip = vipPayload,
        estimatedFare = estimatedFare,
        startDistanceKm = distanceKm,
        bookedAt = os.time()
    }

    print(('[eco_taxi] Order %s baru dari Player ID %s ke %s (Est: $%s, Surge: %.2fx, VIP: %s)'):format(
        sName, src, destName, estimatedFare, surge, tostring(vipPayload and (vipPayload.isVip or vipPayload.usedVip) or false)
    ))

    TriggerClientEvent('eco_taxi:client:dispatchSmartTaxi', src, pCoords, destCoords, destName, estimatedFare, sType, driverName)
    TriggerClientEvent('esx:showNotification', src, ('~b~[EcoCab]~s~ Layanan ~y~%s~s~ sedang menuju lokasi Anda.'):format(sName))
end)

-- Batalkan Pesanan Taksi
RegisterNetEvent('eco_taxi:server:cancelRide', function()
    local src = source
    if activeOrders[src] then
        local netVeh = activeOrders[src].netVeh
        activeOrders[src] = nil
        TriggerClientEvent('eco_taxi:client:cancelCurrentRide', src, netVeh)
        TriggerClientEvent('esx:showNotification', src, '~y~[EcoCab] Pesanan telah dibatalkan.~s~')
    end
end)

RegisterNetEvent('eco_taxi:server:registerTaxiEntity', function(netVeh)
    local src = source
    if activeOrders[src] then
        activeOrders[src].netVeh = netVeh
    end
end)

-- Selesaikan Perjalanan & Pembayaran Akhir
RegisterNetEvent('eco_taxi:server:completeRide', function(actualKm)
    local src = source
    local order = activeOrders[src]
    if not order then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local kmTraveled = tonumber(actualKm) or order.startDistanceKm
    local finalFare, _, baseFare, discountAmount = CalculateFare(order.serviceType, order.pickup, order.destination, order.surgeMultiplier, order.vip)
    local isVip = order.vip and (order.vip.isVip or order.vip.usedVip)

    if xPlayer.getMoney() >= finalFare then
        xPlayer.removeMoney(finalFare)
        if isVip then
            TriggerClientEvent('esx:showNotification', src, ('~g~[EcoVIP] Trip selesai! Tarif terpotong: $%s (Hemat $%s via Voucher VIP)~s~'):format(finalFare, discountAmount))
        else
            TriggerClientEvent('esx:showNotification', src, ('~g~[EcoCab] Perjalanan selesai. Total tarif terpotong: $%s (%.1f km)~s~'):format(finalFare, kmTraveled))
        end
    else
        local playerMoney = xPlayer.getMoney()
        xPlayer.removeMoney(playerMoney)
        TriggerClientEvent('esx:showNotification', src, ('~r~[EcoCab] Saldo tidak mencukupi, sisa uang tunai $%s ditarik.~s~'):format(playerMoney))
    end

    -- Trigger event ke eco_tablet untuk simpan ke database eco_taxi_trips dan potong kuota voucher VIP
    TriggerEvent('eco_tablet:server:recordCompletedTrip', {
        serviceType = order.serviceType,
        originName = 'Lokasi Penjemputan',
        destName = order.destName,
        distanceKm = kmTraveled,
        baseFare = baseFare,
        finalFare = finalFare,
        discountApplied = discountAmount,
        surgeMultiplier = order.surgeMultiplier,
        driverName = order.driverName or 'Driver EcoCab',
        usedVip = isVip
    })

    activeOrders[src] = nil
    TriggerClientEvent('eco_taxi:client:rideCompletedDismissTaxi', src, finalFare, order.driverName, order.serviceType)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if activeOrders[src] then
        activeOrders[src] = nil
    end
end)