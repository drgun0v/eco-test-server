local activeOrders = {} -- [source] = { netVeh, state, pickup, destination, destName, serviceType, serviceName, driverName, plate, surgeMultiplier, vip, estimatedFare, startDistanceKm }

local function GetServiceConfig(sType)
    sType = tostring(sType or 'ecocab'):lower()
    if Config.Services and Config.Services[sType] then
        return Config.Services[sType]
    end
    return Config.Services['ecocab']
end

-- Generate plat nomor kendaraan yang sinkron dengan database nama driver eco_tablet
local function ResolveVehiclePlate(sType, driverName)
    local sCfg = GetServiceConfig(sType)
    if sCfg.isAutonomous then
        return 'LST-AI'
    end
    if Config.UseTabletExactPlate then
        return 'B1945ECO' -- Dirender di GTA sebagai B1945ECO (8 karakter maks GTA V), sinkron dengan 'B 1945 ECO' di NUI
    end
    -- Jika menggunakan nomor unik per indeks nama driver dari daftar 50 nama di eco_tablet
    local drvIdx = 45
    if driverName and Config.IndonesianDriverNames then
        for idx, name in ipairs(Config.IndonesianDriverNames) do
            if name == driverName then
                drvIdx = idx
                break
            end
        end
    end
    return string.format("B%04dECO", 1900 + drvIdx)
end

-- Kalkulasi Tarif Sesuai Kelas Layanan, Surge Pricing, dan Diskon EcoVIP
local function CalculateFare(sType, startCoords, destCoords, surgeMult, vipData)
    local sCfg = GetServiceConfig(sType)
    local distMeters = #(vector3(startCoords.x, startCoords.y, startCoords.z) - vector3(destCoords.x, destCoords.y, destCoords.z))
    local distKm = distMeters / 1000.0

    local base = (sCfg.baseFare or 0) + (distKm * (sCfg.pricePerKm or 14))
    if base < (sCfg.minFare or 15) then
        base = sCfg.minFare or 15
    end

    local mult = tonumber(surgeMult) or 1.0
    local subTotal = base * mult

    local discount = 0
    local isVip = vipData and (vipData.isVip == true or vipData.usedVip == true)
    if isVip then
        local discPct = tonumber(vipData.discountPercent) or 20
        discount = math.floor(subTotal * (discPct / 100.0))
    end

    local final = math.max(1, math.ceil(subTotal - discount))
    return final, distKm, math.ceil(base), discount
end

-- Export / Event untuk Aplikasi EcoCab di eco_tablet
RegisterNetEvent('eco_taxi:server:requestFareEstimate', function(destCoords, serviceType)
    local src = source
    local ped = GetPlayerPed(src)
    if not DoesEntityExist(ped) then return end

    local pCoords = GetEntityCoords(ped)
    local sType = tostring(serviceType or 'ecocab'):lower()
    local estimatedFare, distanceKm = CalculateFare(sType, pCoords, destCoords, 1.0, nil)

    TriggerClientEvent('eco_taxi:client:receiveFareEstimate', src, estimatedFare, distanceKm)
end)

-- Pemesanan Armada (EcoLuxe / EcoCab / EcoRide) dari eco_tablet
RegisterNetEvent('eco_taxi:server:bookRide', function(destCoords, destName, serviceType, driverName, surgeMultiplier, vipPayload)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    if activeOrders[src] then
        TriggerClientEvent('esx:showNotification', src, '~r~[EcoCab] Anda sudah memiliki pesanan armada yang sedang aktif!~s~')
        return
    end

    local ped = GetPlayerPed(src)
    if not DoesEntityExist(ped) then return end
    local pCoords = GetEntityCoords(ped)

    local sType = tostring(serviceType or 'ecocab'):lower()
    local sCfg = GetServiceConfig(sType)
    local sName = sCfg.name or 'EcoCab'
    local surge = tonumber(surgeMultiplier) or 1.0

    -- Pilih nama driver dari daftar 50 nama Indonesia jika belum dikirim oleh eco_tablet
    local resolvedDriverName = driverName
    if sCfg.isAutonomous then
        resolvedDriverName = "EcoLuxe Autonomous AI (Driverless)"
    elseif not resolvedDriverName or resolvedDriverName == "" then
        if Config.IndonesianDriverNames and #Config.IndonesianDriverNames > 0 then
            resolvedDriverName = Config.IndonesianDriverNames[math.random(1, #Config.IndonesianDriverNames)]
        else
            resolvedDriverName = "Budi Santoso"
        end
    end

    local vehiclePlate = ResolveVehiclePlate(sType, resolvedDriverName)
    local estimatedFare, distanceKm, baseFare, discountAmount = CalculateFare(sType, pCoords, destCoords, surge, vipPayload)

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
        driverName = resolvedDriverName,
        plate = vehiclePlate,
        surgeMultiplier = surge,
        vip = vipPayload,
        estimatedFare = estimatedFare,
        baseFare = baseFare,
        discountAmount = discountAmount,
        startDistanceKm = distanceKm,
        bookedAt = os.time()
    }

    print(('[eco_taxi] Order %s (%s) dari Player ID %s menuju %s | Driver: %s | Plat: %s | Est: $%s'):format(
        sName, sType, src, destName or 'Tujuan', resolvedDriverName, vehiclePlate, estimatedFare
    ))

    TriggerClientEvent('eco_taxi:client:dispatchSmartTaxi', src, pCoords, destCoords, destName, estimatedFare, sType, resolvedDriverName, vehiclePlate)
    TriggerClientEvent('esx:showNotification', src, ('~b~[%s]~s~ Armada dengan plat ~y~%s~s~ sedang menuju ke lokasi Anda.'):format(sName, vehiclePlate))
end)

-- Batalkan Pesanan
RegisterNetEvent('eco_taxi:server:cancelRide', function()
    local src = source
    if activeOrders[src] then
        local netVeh = activeOrders[src].netVeh
        activeOrders[src] = nil
        TriggerClientEvent('eco_taxi:client:cancelCurrentRide', src, netVeh)
        TriggerClientEvent('esx:showNotification', src, '~y~[EcoCab] Pesanan perjalanan telah dibatalkan.~s~')
    end
end)

-- Registrasi Network ID Kendaraan yang Di-spawn Klien
RegisterNetEvent('eco_taxi:server:registerTaxiEntity', function(netVeh)
    local src = source
    if activeOrders[src] then
        activeOrders[src].netVeh = netVeh
    end
end)

-- Selesaikan Perjalanan, Potong Pembayaran, Catat Trip History & Tampilkan Modal Rating (1-5 Bintang) di eco_tablet
RegisterNetEvent('eco_taxi:server:completeRide', function(actualKm)
    local src = source
    local order = activeOrders[src]
    if not order then return end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return end

    local sType = order.serviceType or 'ecocab'
    local sCfg = GetServiceConfig(sType)
    local kmTraveled = tonumber(actualKm) or order.startDistanceKm or 1.0
    if kmTraveled < 0.2 then
        kmTraveled = order.startDistanceKm or 1.0
    end

    -- Hitung tarif akhir aktual berdasarkan jarak tempuh
    local rawBase = (sCfg.baseFare or 0) + (kmTraveled * (sCfg.pricePerKm or 14))
    if rawBase < (sCfg.minFare or 15) then
        rawBase = sCfg.minFare or 15
    end

    local surgeMult = tonumber(order.surgeMultiplier) or 1.0
    local subTotal = rawBase * surgeMult

    local discountAmount = 0
    local isVip = order.vip and (order.vip.isVip == true or order.vip.usedVip == true)
    if isVip then
        local discPct = tonumber(order.vip.discountPercent) or 20
        discountAmount = math.floor(subTotal * (discPct / 100.0))
    end

    local finalFare = math.max(1, math.ceil(subTotal - discountAmount))

    if xPlayer.getMoney() >= finalFare then
        xPlayer.removeMoney(finalFare)
        if isVip then
            TriggerClientEvent('esx:showNotification', src, ('~g~[EcoVIP] Perjalanan selesai! Tarif: $%s (Hemat $%s via EcoVIP)~s~'):format(finalFare, discountAmount))
        else
            TriggerClientEvent('esx:showNotification', src, ('~g~[%s] Perjalanan selesai. Total tarif terpotong: $%s (%.1f km)~s~'):format(order.serviceName or 'EcoCab', finalFare, kmTraveled))
        end
    else
        local playerMoney = xPlayer.getMoney()
        if playerMoney > 0 then
            xPlayer.removeMoney(playerMoney)
        end
        TriggerClientEvent('esx:showNotification', src, ('~r~[EcoCab] Saldo tunai tidak mencukupi, sisa uang $%s ditarik.~s~'):format(playerMoney))
    end

    -- Catat ke database eco_taxi_trips dan kurangi kuota EcoVIP jika aktif
    local identifier = xPlayer.getIdentifier()
    if MySQL then
        pcall(function()
            MySQL.insert([[
                INSERT INTO eco_taxi_trips 
                (identifier, service_type, origin_name, dest_name, distance_km, base_fare, final_fare, discount_applied, surge_multiplier, driver_name)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ]], {
                identifier,
                sType,
                'Lokasi Penjemputan',
                order.destName or 'Tujuan Anda',
                kmTraveled,
                math.ceil(rawBase),
                finalFare,
                discountAmount,
                surgeMult,
                order.driverName or 'Driver EcoCab'
            })

            if isVip then
                MySQL.query([[
                    UPDATE eco_taxi_vip 
                    SET remaining_trips = GREATEST(0, remaining_trips - 1)
                    WHERE identifier = ? AND remaining_trips > 0
                ]], { identifier })
            end
        end)
    end

    -- Trigger juga event server eco_tablet agar state cache tablet disinkronkan
    TriggerEvent('eco_tablet:server:recordCompletedTrip', {
        serviceType = sType,
        originName = 'Lokasi Penjemputan',
        destName = order.destName,
        distanceKm = kmTraveled,
        baseFare = math.ceil(rawBase),
        finalFare = finalFare,
        discountApplied = discountAmount,
        surgeMultiplier = surgeMult,
        driverName = order.driverName,
        usedVip = isVip
    })

    activeOrders[src] = nil

    -- Kirim event ke client (ditangkap oleh eco_taxi dan eco_tablet untuk langsung membuka Modal Rating 1-5 Bintang!)
    TriggerClientEvent('eco_taxi:client:rideCompletedDismissTaxi', src, finalFare, order.driverName, sType)
end)

AddEventHandler('playerDropped', function()
    local src = source
    if activeOrders[src] then
        activeOrders[src] = nil
    end
end)
