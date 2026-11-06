while Config == nil or Config.Services == nil do
    Wait(50)
end

local currentTaxi = nil
local currentDriver = nil
local currentTaxiBlip = nil
local activeRideData = nil
local inRideHUD = false
local isBoardingAnimation = false

-- Renderer Teks Aman (Bebas crash 0xCD015E5BB0D96A57 di build b3889)
local function DrawSafeText(text, x, y, scale, r, g, b, a, center)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(scale or 0.32, scale or 0.32)
    SetTextColour(r or 255, g or 255, b or 255, a or 255)
    if center then
        SetTextCentre(true)
    end
    SetTextEntry("STRING")
    AddTextComponentString(tostring(text or ""))
    DrawText(x, y)
end

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        DrawRect(_x, _y + 0.012, 0.26, 0.032, 12, 16, 23, 215)
        DrawSafeText(text, _x, _y, 0.32, 255, 176, 0, 255, true)
    end
end

-- Taximeter Mini HUD Dinamis Sesuai Kelas Layanan (EcoLuxe / EcoCab / EcoRide)
local function DrawTaximeterHUD(serviceName, destName, liveFare, distanceKm, speedKmh, maxSpeedKmh, isAutonomous, plateText)
    local sx, sy = 0.88, 0.82
    DrawRect(sx, sy, 0.20, 0.125, 12, 16, 23, 235)
    DrawRect(sx, sy - 0.060, 0.20, 0.005, 56, 189, 248, 255)

    local safeDest = tostring(destName or "Tujuan")
    if #safeDest > 18 then
        safeDest = safeDest:sub(1, 18)
    end

    local fareNum = math.floor(tonumber(liveFare) or 0)
    local distNum = tonumber(distanceKm) or 0.0
    local spdNum = math.floor(tonumber(speedKmh) or 0)
    local maxSpd = math.floor(tonumber(maxSpeedKmh) or 80)
    local headerTitle = string.format("%s [%s]", tostring(serviceName or "ECOCAB"):upper(), tostring(plateText or "B1945ECO"))
    local modeLabel = isAutonomous and "AI Otonom" or "Driver Aktif"

    DrawSafeText(headerTitle, sx - 0.090, sy - 0.054, 0.29, 56, 189, 248, 255, false)
    DrawSafeText("Tujuan : " .. safeDest, sx - 0.090, sy - 0.028, 0.31, 255, 255, 255, 255, false)
    DrawSafeText(string.format("Argo : USD %d (%.1f km)", fareNum, distNum), sx - 0.090, sy + 0.000, 0.36, 34, 197, 94, 255, false)
    DrawSafeText(string.format("Kecepatan: %d/%d km/h | %s", spdNum, maxSpd, modeLabel), sx - 0.090, sy + 0.032, 0.26, 148, 163, 184, 230, false)
end

-- Mencari titik spawn jalan raya yang aman
local function FindRoadSpawnPoint(playerCoords)
    local minD = Config.Drive.SpawnDistanceMin or 70.0
    local maxD = Config.Drive.SpawnDistanceMax or 120.0
    local found = false
    local spawnCoords = nil
    local spawnHeading = 0.0

    for i = 1, 14 do
        local angle = math.random(0, 360)
        local rad = math.rad(angle)
        local dist = math.random(math.floor(minD), math.floor(maxD))
        local testX = playerCoords.x + (math.cos(rad) * dist)
        local testY = playerCoords.y + (math.sin(rad) * dist)

        local success, nodeCoords, nodeHeading = GetClosestVehicleNodeWithHeading(testX, testY, playerCoords.z, 1, 3.0, 0)
        if success and #(nodeCoords - playerCoords) >= minD then
            spawnCoords = nodeCoords
            spawnHeading = nodeHeading
            found = true
            break
        end
    end

    if not found then
        local _, fallbackCoords, fallbackHeading = GetClosestVehicleNodeWithHeading(playerCoords.x + 80.0, playerCoords.y, playerCoords.z, 1, 3.0, 0)
        spawnCoords = fallbackCoords
        spawnHeading = fallbackHeading
    end

    return spawnCoords, spawnHeading
end

-- Mencari Pom Bensin (SPBU) terdekat untuk random event EcoRide
local function FindNearestGasStation(coords)
    if not Config.GasStations or #Config.GasStations == 0 then return nil end
    local nearest = nil
    local minDist = 999999.0
    for _, gs in ipairs(Config.GasStations) do
        local d = #(coords - gs.coords)
        if d < minDist then
            minDist = d
            nearest = gs
        end
    end
    return nearest
end

-- Memilih kursi penumpang sesuai tipe kendaraan (Motor = Jok Belakang Seat 0, Mobil = Kursi Belakang Seat 1/2 atau Depan 0, maks 3 penumpang)
local function GetBestPassengerSeat(veh, ped, isBike)
    if isBike then
        -- Untuk motor (faggio), maksimum 1 penumpang di jok belakang (seat index 0)
        return 0, 1
    end

    local offset = GetOffsetFromEntityGivenWorldCoords(veh, GetEntityCoords(ped))
    if offset.x >= 0.0 then
        if IsVehicleSeatFree(veh, 2) then return 2, 3 end -- Belakang Kanan
        if IsVehicleSeatFree(veh, 1) then return 1, 2 end -- Belakang Kiri
    else
        if IsVehicleSeatFree(veh, 1) then return 1, 2 end -- Belakang Kiri
        if IsVehicleSeatFree(veh, 2) then return 2, 3 end -- Belakang Kanan
    end
    if IsVehicleSeatFree(veh, 0) then return 0, 1 end -- Penumpang Depan Kanan (Kapasitas maks 3 penumpang)
    return 1, 2
end

-- Memastikan Ped Driver selalu berada di kursi kemudi (-1) dan tidak bisa dibajak
local function EnsureDriverInSeat(taxi, sCfg, chosenDriverModel)
    if not DoesEntityExist(taxi) then return nil end
    sCfg = sCfg or (activeRideData and activeRideData.serviceCfg) or Config.Services['ecocab']

    local currentSeatDriver = GetPedInVehicleSeat(taxi, -1)
    if DoesEntityExist(currentSeatDriver) and currentSeatDriver ~= PlayerPedId() then
        currentDriver = currentSeatDriver
        return currentDriver
    end

    if DoesEntityExist(currentDriver) and currentDriver ~= PlayerPedId() then
        SetPedIntoVehicle(currentDriver, taxi, -1)
        return currentDriver
    end

    local pedModel = chosenDriverModel or (activeRideData and activeRideData.driverModel) or sCfg.driverModel or `s_m_m_trucker_01`
    RequestModel(pedModel)
    local t = 0
    while not HasModelLoaded(pedModel) and t < 100 do
        Wait(10)
        t = t + 1
    end

    local newDriver = CreatePedInsideVehicle(taxi, 26, pedModel, -1, true, true)
    if sCfg.isAutonomous then
        -- EcoLuxe: AI Otonom Tanpa Supir Terlihat
        SetEntityVisible(newDriver, false, false)
        SetEntityAlpha(newDriver, 0, false)
    else
        -- EcoCab & EcoRide: Supir Terlihat
        SetEntityVisible(newDriver, true, false)
        SetEntityAlpha(newDriver, 255, false)
        if sCfg.isBike then
            -- Kenakan helm otomatis pada driver EcoRide
            SetPedHelmet(newDriver, true)
            SetPedHelmetFlag(newDriver, 4096)
            GivePedHelmet(newDriver, false, 4096, -1)
        end
    end

    SetEntityInvincible(newDriver, true)
    SetEntityAsMissionEntity(newDriver, true, true)
    SetBlockingOfNonTemporaryEvents(newDriver, true)
    SetPedCanBeKnockedOffVehicle(newDriver, 1)
    SetPedCanBeDraggedOut(newDriver, false)
    SetPedStayInVehicleWhenJacked(newDriver, true)
    SetPedConfigFlag(newDriver, 251, true)
    SetPedConfigFlag(newDriver, 255, true)
    SetPedFleeAttributes(newDriver, 0, false)
    SetPedCombatAttributes(newDriver, 3, false)
    SetDriverAbility(newDriver, 1.0)
    SetDriverAggressiveness(newDriver, 0.0)
    SetDriveTaskDrivingStyle(newDriver, sCfg.drivingStyle or Config.Drive.DrivingStyle or 524475)
    SetPedKeepTask(newDriver, true)

    currentDriver = newDriver
    if activeRideData then
        activeRideData.driver = newDriver
    end
    return newDriver
end

-- Fungsi Boarding Penumpang 100% Anti-Bajak Kursi Driver (Support Mobil & Motor Faggio)
local function BoardPlayerIntoPassengerSeat(taxi)
    if isBoardingAnimation or not DoesEntityExist(taxi) then return end
    isBoardingAnimation = true

    CreateThread(function()
        local playerPed = PlayerPedId()
        local sCfg = (activeRideData and activeRideData.serviceCfg) or Config.Services['ecocab']
        local isBike = sCfg.isBike == true
        local targetSeat, targetDoor = GetBestPassengerSeat(taxi, playerPed, isBike)

        ClearPedTasksImmediately(playerPed)

        SetVehicleDoorsLocked(taxi, 1)
        if not isBike then
            SetVehicleIndividualDoorsLocked(taxi, 0, 2) -- Kunci pintu kemudi depan kiri pada mobil
            SetVehicleDoorOpen(taxi, targetDoor, false, false)
        end

        TaskEnterVehicle(playerPed, taxi, 3500, targetSeat, 2.0, 1, 0)

        local startTry = GetGameTimer()
        while (GetGameTimer() - startTry) < 2400 do
            Wait(0)
            DisableControlAction(0, 23, true)

            if not DoesEntityExist(taxi) then
                isBoardingAnimation = false
                return
            end

            if IsPedInVehicle(playerPed, taxi, false) and GetPedInVehicleSeat(taxi, -1) ~= playerPed then
                break
            end

            if GetSeatPedIsTryingToEnter(playerPed) == -1 then
                ClearPedTasksImmediately(playerPed)
                break
            end
        end

        if DoesEntityExist(taxi) then
            if not IsPedInVehicle(playerPed, taxi, false) or GetPedInVehicleSeat(taxi, -1) == playerPed then
                ClearPedTasksImmediately(playerPed)
                SetPedIntoVehicle(playerPed, taxi, targetSeat)
            end
            if not isBike then
                SetVehicleDoorShut(taxi, targetDoor, false)
            end
            EnsureDriverInSeat(taxi, sCfg)
        end

        isBoardingAnimation = false
    end)
end

-- Event Dispatch Armada dari Server (Mendukung EcoLuxe, EcoCab, EcoRide)
RegisterNetEvent('eco_taxi:client:dispatchSmartTaxi', function(pickupCoords, destCoords, destName, estimatedFare, serviceType, driverName, vehiclePlate)
    if DoesEntityExist(currentTaxi) then return end

    local sType = tostring(serviceType or 'ecocab'):lower()
    local sCfg = (Config.Services and Config.Services[sType]) or Config.Services['ecocab']

    local spawnCoords, spawnHeading = FindRoadSpawnPoint(pickupCoords)
    if not spawnCoords then
        print('^1[eco_taxi] Gagal menemukan titik node jalan untuk spawn armada.^7')
        return
    end

    -- Pilih ped driver (untuk EcoRide dipilih random dari s_m_y_ammucity_01, ig_josef, ig_mp_agent14)
    local chosenDriverModel = sCfg.driverModel or `s_m_m_trucker_01`
    if sCfg.driverModelPool and #sCfg.driverModelPool > 0 then
        chosenDriverModel = sCfg.driverModelPool[math.random(1, #sCfg.driverModelPool)]
    end

    RequestModel(sCfg.model)
    RequestModel(chosenDriverModel)
    local timeout = 0
    while (not HasModelLoaded(sCfg.model) or not HasModelLoaded(chosenDriverModel)) and timeout < 250 do
        Wait(20)
        timeout = timeout + 1
    end

    local taxi = CreateVehicle(sCfg.model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnHeading, true, true)
    SetVehicleOnGroundProperly(taxi)
    SetEntityHeading(taxi, spawnHeading)
    SetVehicleEngineOn(taxi, true, true, false)
    SetVehicleDoorsLocked(taxi, 1)
    if not sCfg.isBike then
        SetVehicleIndividualDoorsLocked(taxi, 0, 2)
    end

    -- Set Plat Nomor Kendaraan Sesuai Database Driver eco_tablet ('LST-AI' untuk EcoLuxe / 'B1945ECO' untuk Driver)
    local finalPlate = vehiclePlate or sCfg.plate or (sCfg.isAutonomous and "LST-AI" or "B1945ECO")
    SetVehicleNumberPlateText(taxi, finalPlate)

    currentTaxi = taxi
    local driver = EnsureDriverInSeat(taxi, sCfg, chosenDriverModel)

    SetVehicleStrong(taxi, true)
    SetVehicleHasStrongAxles(taxi, true)

    -- Terapkan limit kecepatan sesuai kelas layanan (120 km/h, 80 km/h, atau 60 km/h)
    local maxSpeedMs = (sCfg.maxSpeedKmh or 80.0) / 3.6
    SetVehicleMaxSpeed(taxi, maxSpeedMs)
    SetVehicleEnginePowerMultiplier(taxi, sCfg.isBike and 1.15 or 1.25)

    local netVeh = NetworkGetNetworkIdFromEntity(taxi)
    TriggerServerEvent('eco_taxi:server:registerTaxiEntity', netVeh)

    local blip = AddBlipForEntity(taxi)
    SetBlipSprite(blip, sCfg.isBike and 226 or 198)
    SetBlipColour(blip, sCfg.isBike and 25 or (sCfg.isAutonomous and 38 or 5))
    SetBlipScale(blip, 0.9)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(string.format("%s (%s)", sCfg.name, finalPlate))
    EndTextCommandSetBlipName(blip)
    currentTaxiBlip = blip

    SetModelAsNoLongerNeeded(sCfg.model)
    SetModelAsNoLongerNeeded(chosenDriverModel)

    activeRideData = {
        taxi = taxi,
        driver = driver,
        driverModel = chosenDriverModel,
        driverName = driverName or (sCfg.isAutonomous and "EcoLuxe Autonomous AI" or "Driver EcoCab"),
        plate = finalPlate,
        serviceType = sType,
        serviceCfg = sCfg,
        pickup = pickupCoords,
        dest = destCoords,
        destName = destName or "Tujuan Pilihan",
        estimatedFare = estimatedFare or sCfg.minFare,
        state = 'DISPATCHED_TO_PICKUP'
    }

    StartTaxiAutonomousCycle()
end)

function StartTaxiAutonomousCycle()
    CreateThread(function()
        local taxi = activeRideData.taxi
        local driver = activeRideData.driver
        local pickup = activeRideData.pickup
        local dest = activeRideData.dest
        local destName = activeRideData.destName
        local sCfg = activeRideData.serviceCfg

        local cruiseSpeedMs = sCfg.cruiseSpeed or ((sCfg.maxSpeedKmh or 80.0) / 3.6)
        local pickupSpeedMs = sCfg.pickupSpeed or math.min(cruiseSpeedMs, 22.22)
        local drivingStyle = sCfg.drivingStyle or Config.Drive.DrivingStyle or 524475

        -- FASE 1: Menuju Titik Penjemputan Pemesan
        SetVehicleMaxSpeed(taxi, pickupSpeedMs)
        TaskVehicleDriveToCoordLongrange(
            driver, taxi,
            pickup.x, pickup.y, pickup.z,
            pickupSpeedMs,
            drivingStyle,
            Config.Drive.PickupRadius or 6.0
        )

        local arrivedAtPickup = false
        while DoesEntityExist(taxi) and not arrivedAtPickup do
            Wait(300)
            local taxiCoords = GetEntityCoords(taxi)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local distToPickup = #(taxiCoords - pickup)
            local distToPlayer = #(taxiCoords - playerCoords)

            if distToPickup <= (Config.Drive.PickupRadius or 6.0) or distToPlayer <= 10.0 then
                arrivedAtPickup = true
            elseif (distToPickup <= 18.0 or distToPlayer <= 18.0) and GetEntitySpeed(taxi) < 0.8 then
                arrivedAtPickup = true
            end
        end

        if not DoesEntityExist(taxi) then return end

        activeRideData.state = 'WAITING_PASSENGER'
        BringVehicleToHalt(taxi, 2.0, 1, true)
        SetVehicleHandbrake(taxi, true)
        SoundVehicleHornThisFrame(taxi)
        SetVehicleDoorsLocked(taxi, 1)
        if not sCfg.isBike then
            SetVehicleIndividualDoorsLocked(taxi, 0, 2)
        end

        ESX.ShowNotification(('~b~[%s]~s~ Armada (~y~%s~s~) telah tiba. Dekati dan tekan ~y~[E]~s~ atau ~y~[F]~s~ untuk naik.'):format(sCfg.name, activeRideData.plate))

        local playerPed = PlayerPedId()
        local passengerBoarded = false
        local waitCounter = 0
        local maxWait = (Config.Drive.WaitAtPickupSeconds or 60) * 4

        while DoesEntityExist(taxi) and not passengerBoarded and waitCounter < maxWait do
            Wait(250)
            waitCounter = waitCounter + 1

            if IsPedInVehicle(playerPed, taxi, false) then
                if GetPedInVehicleSeat(taxi, -1) == playerPed then
                    local passSeat, _ = GetBestPassengerSeat(taxi, playerPed, sCfg.isBike)
                    ClearPedTasksImmediately(playerPed)
                    SetPedIntoVehicle(playerPed, taxi, passSeat)
                end

                for s = 0, GetVehicleMaxNumberOfPassengers(taxi) - 1 do
                    if GetPedInVehicleSeat(taxi, s) == playerPed then
                        passengerBoarded = true
                        activeRideData.state = 'IN_RIDE'
                        break
                    end
                end
            end
        end

        if not passengerBoarded then
            ESX.ShowNotification(('~r~[%s] Waktu tunggu habis. Armada kembali ke pangkalan.~s~'):format(sCfg.name))
            DismissAndDespawnTaxi(taxi, driver)
            return
        end

        -- Pastikan AI Driver berada di kursi -1 sebelum berangkat
        driver = EnsureDriverInSeat(taxi, sCfg)

        -- Jika EcoRide (Motor): Pasang Helm Keselamatan pada Driver & Penumpang setelah naik!
        if sCfg.isBike then
            SetPedHelmet(driver, true)
            SetPedHelmetFlag(driver, 4096)
            GivePedHelmet(driver, false, 4096, -1)

            SetPedHelmet(playerPed, true)
            SetPedHelmetFlag(playerPed, 4096)
            GivePedHelmet(playerPed, false, 4096, -1)
            SetPedCanBeKnockedOffVehicle(playerPed, 1)
            ESX.ShowNotification("~g~[EcoRide]~s~ Helm keselamatan dikenakan otomatis. Selamat menikmati perjalanan!")
        end

        -- FASE 2: Perjalanan Menuju Destinasi Pilihan
        SetVehicleHandbrake(taxi, false)
        SetVehicleDoorsLocked(taxi, 1)
        ESX.ShowNotification(('~b~[%s]~s~ Perjalanan dimulai menuju ~y~%s~s~ (Limit: %d km/h).'):format(sCfg.name, destName, math.floor(sCfg.maxSpeedKmh or 80)))

        inRideHUD = true
        local startPos = GetEntityCoords(taxi)
        local totalDistanceCoveredKm = 0.0
        local lastCoord = startPos

        -- Kunci batas kecepatan sesuai layanan: EcoLuxe 120km/h, EcoCab 80km/h, EcoRide 60km/h
        SetVehicleMaxSpeed(taxi, cruiseSpeedMs)

        -- Evaluasi Peluang Event Random: Driver EcoRide Mampir Isi Bensin di SPBU Terdekat
        local shouldStopForGas = false
        if sCfg.isBike and (sCfg.gasEventChance or 25) > 0 then
            if math.random(1, 100) <= (sCfg.gasEventChance or 25) then
                shouldStopForGas = true
            end
        end

        local gasStopCompleted = false
        local nearestGasStation = FindNearestGasStation(startPos)

        TaskVehicleDriveToCoordLongrange(
            driver, taxi,
            dest.x, dest.y, dest.z,
            cruiseSpeedMs,
            drivingStyle,
            Config.Drive.DestinationRadius or 8.0
        )

        local arrivedAtDestination = false
        local rideTicks = 0

        while DoesEntityExist(taxi) and not arrivedAtDestination do
            Wait(250)
            rideTicks = rideTicks + 1

            local currentPos = GetEntityCoords(taxi)
            local legDist = #(currentPos - lastCoord)
            if legDist > 1.0 then
                totalDistanceCoveredKm = totalDistanceCoveredKm + (legDist / 1000.0)
                lastCoord = currentPos
            end

            -- Eksekusi Event Random Mampir Pom Bensin untuk EcoRide
            if shouldStopForGas and not gasStopCompleted and nearestGasStation and rideTicks >= 16 then
                gasStopCompleted = true

                -- Kirim event ke eco_tablet agar muncul banner peringatan kuning di layar iPad!
                TriggerEvent('eco_taxi:client:driverFuelStop', nearestGasStation.name)
                ESX.ShowNotification(("~y~[EcoRide] %s: 'Waduh kak, bensin motor tipis nih! Kita mampir isi bensin sebentar di %s ya.'~s~"):format(activeRideData.driverName, nearestGasStation.name))

                TaskVehicleDriveToCoordLongrange(
                    driver, taxi,
                    nearestGasStation.coords.x, nearestGasStation.coords.y, nearestGasStation.coords.z,
                    math.min(cruiseSpeedMs, 14.0),
                    drivingStyle,
                    5.5
                )

                local reachedGas = false
                local gasTimer = 0
                while DoesEntityExist(taxi) and not reachedGas and gasTimer < 80 do
                    Wait(500)
                    gasTimer = gasTimer + 1
                    local cPos = GetEntityCoords(taxi)
                    local dGas = #(cPos - nearestGasStation.coords)
                    if dGas <= 7.5 or (dGas <= 16.0 and GetEntitySpeed(taxi) < 0.6) then
                        reachedGas = true
                    end
                    if not IsPedInVehicle(playerPed, taxi, false) then
                        break
                    end
                end

                if DoesEntityExist(taxi) and IsPedInVehicle(playerPed, taxi, false) then
                    BringVehicleToHalt(taxi, 2.0, 1, true)
                    SetVehicleHandbrake(taxi, true)
                    ESX.ShowNotification(("~b~[EcoRide]~s~ Sedang mengisi bahan bakar motor di ~y~%s~s~..."):format(nearestGasStation.name))
                    Wait(sCfg.gasStopDuration or 8000)

                    if DoesEntityExist(taxi) then
                        SetVehicleHandbrake(taxi, false)
                        SetVehicleMaxSpeed(taxi, cruiseSpeedMs)
                        ESX.ShowNotification(("~g~[EcoRide] %s: 'Tangki sudah penuh kak! Yuk kita lanjut gas ke %s.'~s~"):format(activeRideData.driverName, destName))

                        TaskVehicleDriveToCoordLongrange(
                            driver, taxi,
                            dest.x, dest.y, dest.z,
                            cruiseSpeedMs,
                            drivingStyle,
                            Config.Drive.DestinationRadius or 8.0
                        )
                    end
                end
            end

            local distToDest = #(GetEntityCoords(taxi) - dest)
            if distToDest <= (Config.Drive.DestinationRadius or 8.0) then
                arrivedAtDestination = true
            elseif distToDest <= 18.0 and GetEntitySpeed(taxi) < 0.5 then
                arrivedAtDestination = true
            end

            if not IsPedInVehicle(playerPed, taxi, false) then
                arrivedAtDestination = true
            end
        end

        inRideHUD = false
        if not DoesEntityExist(taxi) then return end

        -- FASE 3: Tiba di Tujuan, Menepi, Lepas Helm & Pembayaran + Trigger Modal Rating eco_tablet
        BringVehicleToHalt(taxi, 2.0, 1, true)
        SetVehicleHandbrake(taxi, true)
        SetVehicleDoorsLocked(taxi, 1)

        if IsPedInVehicle(playerPed, taxi, false) then
            TaskLeaveVehicle(playerPed, taxi, 0)
        end

        if sCfg.isBike then
            Wait(1400)
            RemovePedHelmet(playerPed, true)
            SetPedCanBeKnockedOffVehicle(playerPed, 0)
        end

        -- Kirim jarak tempuh ke server untuk potong argo & munculkan Rating 1-5 Bintang di eco_tablet
        TriggerServerEvent('eco_taxi:server:completeRide', totalDistanceCoveredKm)

        Wait(4000)
        DismissAndDespawnTaxi(taxi, driver)
    end)
end

-- Thread Render Live HUD Taximeter Sesuai Tarif Kelas Layanan
CreateThread(function()
    while true do
        local sleep = 500
        if inRideHUD and activeRideData and DoesEntityExist(currentTaxi) then
            sleep = 0
            local sCfg = activeRideData.serviceCfg or Config.Services['ecocab']
            local speedKmh = math.floor(GetEntitySpeed(currentTaxi) * 3.6)
            local currentPos = GetEntityCoords(currentTaxi)
            local traveledKm = #(currentPos - activeRideData.pickup) / 1000.0
            local currentLiveFare = (sCfg.baseFare or 0) + (traveledKm * (sCfg.pricePerKm or 14))
            if currentLiveFare < (sCfg.minFare or 15) then
                currentLiveFare = sCfg.minFare or 15
            end
            DrawTaximeterHUD(
                sCfg.name,
                activeRideData.destName,
                currentLiveFare,
                traveledKm,
                speedKmh,
                sCfg.maxSpeedKmh or 80.0,
                sCfg.isAutonomous,
                activeRideData.plate
            )
        end
        Wait(sleep)
    end
end)

-- =========================================================================
-- THREAD PROTEKSI ANTI-BAJAK KURSI DRIVER & BOARDING PENUMPANG (0ms)
-- =========================================================================
CreateThread(function()
    while true do
        local sleep = 250
        if DoesEntityExist(currentTaxi) then
            local playerPed = PlayerPedId()
            local pCoords = GetEntityCoords(playerPed)
            local tCoords = GetEntityCoords(currentTaxi)
            local dist = #(pCoords - tCoords)

            if dist < 18.0 and not IsPedInAnyVehicle(playerPed, false) then
                sleep = 0
                DisableControlAction(0, 23, true) -- Blokir F (INPUT_ENTER)
                DisableControlAction(0, 75, true) -- Blokir F (INPUT_VEH_EXIT)

                if GetVehiclePedIsTryingToEnter(playerPed) == currentTaxi and GetSeatPedIsTryingToEnter(playerPed) == -1 then
                    BoardPlayerIntoPassengerSeat(currentTaxi)
                end

                if dist < 7.5 then
                    local sCfg = (activeRideData and activeRideData.serviceCfg) or Config.Services['ecocab']
                    local promptLabel = sCfg.isBike
                        and string.format("[%s] Tekan [E] / [F] Naik Jok Penumpang", sCfg.name)
                        or  string.format("[%s] Tekan [E] / [F] Naik Kursi Penumpang", sCfg.name)

                    DrawText3D(tCoords.x, tCoords.y, tCoords.z + 1.15, promptLabel)

                    if IsControlJustPressed(0, 38) or IsDisabledControlJustPressed(0, 23) then
                        if activeRideData and activeRideData.state == 'DISPATCHED_TO_PICKUP' then
                            activeRideData.state = 'WAITING_PASSENGER'
                            BringVehicleToHalt(currentTaxi, 1.5, 1, true)
                            SetVehicleHandbrake(currentTaxi, true)
                        end
                        BoardPlayerIntoPassengerSeat(currentTaxi)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

function DismissAndDespawnTaxi(taxi, driver)
    inRideHUD = false
    if currentTaxiBlip then
        RemoveBlip(currentTaxiBlip)
        currentTaxiBlip = nil
    end

    if DoesEntityExist(taxi) then
        local sCfg = activeRideData and activeRideData.serviceCfg
        driver = EnsureDriverInSeat(taxi, sCfg)
        if DoesEntityExist(driver) then
            SetVehicleDoorsLocked(taxi, 2)
            SetVehicleHandbrake(taxi, false)
            TaskVehicleDriveWander(driver, taxi, 12.0, Config.Drive.DrivingStyle or 524475)
        end
        SetTimeout(20000, function()
            if DoesEntityExist(driver) then
                RemovePedHelmet(driver, true)
                DeleteEntity(driver)
            end
            if DoesEntityExist(taxi) then DeleteVehicle(taxi) end
            currentTaxi = nil
            currentDriver = nil
            activeRideData = nil
        end)
    else
        currentTaxi = nil
        currentDriver = nil
        activeRideData = nil
    end
end

RegisterNetEvent('eco_taxi:client:cancelCurrentRide', function()
    inRideHUD = false
    local playerPed = PlayerPedId()
    RemovePedHelmet(playerPed, true)
    SetPedCanBeKnockedOffVehicle(playerPed, 0)
    if DoesEntityExist(currentTaxi) then
        DismissAndDespawnTaxi(currentTaxi, currentDriver)
    end
end)

-- Event Selesai Trip: Pastikan armada menepi & pergi sementara eco_tablet membuka modal rating 1-5 bintang
RegisterNetEvent('eco_taxi:client:rideCompletedDismissTaxi', function(finalFare, driverName, serviceType)
    inRideHUD = false
end)

-- =========================================================================
-- EXPORTS UNTUK ECO_TABLET
-- =========================================================================
exports('GetQuickDestinations', function()
    return Config.QuickDestinations
end)

exports('RequestEcoCabRide', function(destCoords, destName, serviceType, driverName, surgeMultiplier, vipPayload)
    TriggerServerEvent('eco_taxi:server:bookRide', destCoords, destName, serviceType, driverName, surgeMultiplier, vipPayload)
end)

exports('CancelEcoCabRide', function()
    TriggerServerEvent('eco_taxi:server:cancelRide')
end)

-- Command Testing Cepat (/testtaxi [1-10] [ecoluxe/ecocab/ecoride])
RegisterCommand('testtaxi', function(source, args)
    local destId = tonumber(args[1]) or 1
    local sType = tostring(args[2] or 'ecocab'):lower()
    local dest = Config.QuickDestinations[destId] or Config.QuickDestinations[1]
    TriggerServerEvent('eco_taxi:server:bookRide', dest.coords, dest.name, sType, nil, 1.0, nil)
end, false)
