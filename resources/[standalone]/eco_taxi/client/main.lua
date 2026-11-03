local currentTaxi = nil
local currentDriver = nil
local currentTaxiBlip = nil
local activeRideData = nil
local inRideHUD = false

local function DrawTaximeterHUD(destName, liveFare, distanceKm, speedKmh, sName)
    local sx, sy = 0.88, 0.82
    DrawRect(sx, sy, 0.19, 0.12, 12, 16, 23, 230)
    DrawRect(sx, sy - 0.058, 0.19, 0.005, 56, 189, 248, 255)

    SetTextFont(4)
    SetTextScale(0.30, 0.30)
    SetTextColour(56, 189, 248, 255)
    SetTextEntry("STRING")
    AddTextComponentString((sName or "ECOCAB"):upper())
    DrawText(sx - 0.085, sy - 0.052)

    SetTextFont(4)
    SetTextScale(0.32, 0.32)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString(("Tujuan : ~y~%s~s~"):format(destName:sub(1, 18)))
    DrawText(sx - 0.085, sy - 0.026)

    SetTextFont(4)
    SetTextScale(0.40, 0.40)
    SetTextColour(34, 197, 94, 255)
    SetTextEntry("STRING")
    AddTextComponentString(("Argo : ~g~$%d~s~ (%.1f km)"):format(liveFare, distanceKm))
    DrawText(sx - 0.085, sy + 0.002)

    SetTextFont(4)
    SetTextScale(0.28, 0.28)
    SetTextColour(148, 163, 184, 220)
    SetTextEntry("STRING")
    AddTextComponentString(("Kecepatan: %d km/h"):format(speedKmh))
    DrawText(sx - 0.085, sy + 0.032)
end

-- Helper mencari node jalan raya terdekat pada jarak aman
local function FindRoadSpawnPoint(playerCoords)
    local minD = Config.Drive.SpawnDistanceMin or 70.0
    local maxD = Config.Drive.SpawnDistanceMax or 120.0
    local found = false
    local spawnCoords = nil
    local spawnHeading = 0.0

    for i = 1, 15 do
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

-- Helper mencari SPBU terdekat
local function FindNearestGasStation(coords)
    if not Config.GasStations or #Config.GasStations == 0 then return nil end
    local nearest = nil
    local minDist = 999999.0
    for _, gs in ipairs(Config.GasStations) do
        local dist = #(coords - gs.coords)
        if dist < minDist then
            minDist = dist
            nearest = gs
        end
    end
    return nearest
end

-- Pembuatan Armada Taksi / Ojek (EcoLuxe, EcoCab, EcoRide)
RegisterNetEvent('eco_taxi:client:dispatchSmartTaxi', function(pickupCoords, destCoords, destName, estimatedFare, serviceType, driverName)
    if DoesEntityExist(currentTaxi) then return end

    local sType = serviceType or 'ecocab'
    local sCfg = (Config.Services and Config.Services[sType]) or {
        name = 'EcoCab',
        model = `taxi`,
        isAutonomous = false,
        driverModel = `s_m_m_trucker_01`,
        cruiseSpeed = 22.2,
        isBike = false,
        maxPassengers = 3
    }

    local spawnCoords, spawnHeading = FindRoadSpawnPoint(pickupCoords)
    if not spawnCoords then
        print('^1[eco_taxi] Gagal menemukan titik node jalan untuk spawn armada.^7')
        return
    end

    local driverPedModel = sCfg.driverModel or `s_m_m_trucker_01`
    if sCfg.driverModelPool and #sCfg.driverModelPool > 0 then
        driverPedModel = sCfg.driverModelPool[math.random(1, #sCfg.driverModelPool)]
    end

    RequestModel(sCfg.model)
    RequestModel(driverPedModel)
    local timeout = 0
    while (not HasModelLoaded(sCfg.model) or not HasModelLoaded(driverPedModel)) and timeout < 250 do
        Wait(20)
        timeout = timeout + 1
    end

    local taxi = CreateVehicle(sCfg.model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnHeading, true, true)
    SetVehicleOnGroundProperly(taxi)
    SetEntityHeading(taxi, spawnHeading)
    SetVehicleEngineOn(taxi, true, true, false)
    SetVehicleDoorsLocked(taxi, 1)

    local driver = CreatePedInsideVehicle(taxi, 26, driverPedModel, -1, true, true)
    if sCfg.isAutonomous then
        SetEntityVisible(driver, false, false)
        SetEntityAlpha(driver, 0, false)
    else
        SetEntityVisible(driver, true, false)
        SetEntityAlpha(driver, 255, false)
    end

    SetEntityAsMissionEntity(driver, true, true)
    SetBlockingOfNonTemporaryEvents(driver, true)
    SetPedCanBeKnockedOffVehicle(driver, 1)
    SetPedFleeAttributes(driver, 0, false)
    SetPedCombatAttributes(driver, 3, false)
    SetDriverAbility(driver, 1.0)
    SetDriverAggressiveness(driver, 0.0)
    SetDriveTaskDrivingStyle(driver, sCfg.drivingStyle or 524475)
    SetPedKeepTask(driver, true)

    SetVehicleStrong(taxi, true)
    SetVehicleHasStrongAxles(taxi, true)

    currentTaxi = taxi
    currentDriver = driver

    local netVeh = NetworkGetNetworkIdFromEntity(taxi)
    TriggerServerEvent('eco_taxi:server:registerTaxiEntity', netVeh)

    local blip = AddBlipForEntity(taxi)
    SetBlipSprite(blip, sCfg.isBike and 226 or 198)
    SetBlipColour(blip, sCfg.isBike and 25 or (sCfg.isAutonomous and 38 or 5))
    SetBlipScale(blip, 0.9)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(sCfg.name .. " (" .. (driverName or "Driver") .. ")")
    EndTextCommandSetBlipName(blip)
    currentTaxiBlip = blip

    SetModelAsNoLongerNeeded(sCfg.model)
    SetModelAsNoLongerNeeded(driverPedModel)

    activeRideData = {
        taxi = taxi,
        driver = driver,
        pickup = pickupCoords,
        dest = destCoords,
        destName = destName,
        estimatedFare = estimatedFare,
        serviceType = sType,
        serviceCfg = sCfg,
        driverName = driverName,
        state = 'DISPATCHED_TO_PICKUP'
    }

    StartTaxiCycle()
end)

-- Siklus Pengendalian Armada Taksi / Ojek
function StartTaxiCycle()
    CreateThread(function()
        local taxi = activeRideData.taxi
        local driver = activeRideData.driver
        local pickup = activeRideData.pickup
        local dest = activeRideData.dest
        local destName = activeRideData.destName
        local sCfg = activeRideData.serviceCfg

        -- FASE 1: Menuju Titik Penjemputan
        TaskVehicleDriveToCoordLongrange(
            driver, taxi,
            pickup.x, pickup.y, pickup.z,
            sCfg.cruiseSpeed or 16.0,
            sCfg.drivingStyle or 524475,
            Config.Drive.PickupRadius or 6.0
        )

        local arrivedAtPickup = false
        while DoesEntityExist(taxi) and not arrivedAtPickup do
            Wait(400)
            local dist = #(GetEntityCoords(taxi) - pickup)
            if dist <= (Config.Drive.PickupRadius or 6.0) then
                arrivedAtPickup = true
            elseif dist <= 16.0 and GetEntitySpeed(taxi) < 0.5 then
                arrivedAtPickup = true
            end
        end

        if not DoesEntityExist(taxi) then return end

        BringVehicleToHalt(taxi, 2.0, 1, true)
        SetVehicleHandbrake(taxi, true)
        SoundVehicleHornThisFrame(taxi)
        SetVehicleDoorsLocked(taxi, 1)

        ESX.ShowNotification(("~b~[EcoCab]~s~ %s Anda telah tiba di lokasi. Silakan naik."):format(sCfg.name))

        local playerPed = PlayerPedId()
        local passengerBoarded = false
        local waitCounter = 0
        local maxWait = (Config.Drive.WaitAtPickupSeconds or 60) * 2

        while DoesEntityExist(taxi) and not passengerBoarded and waitCounter < maxWait do
            Wait(500)
            waitCounter = waitCounter + 1
            if IsPedInVehicle(playerPed, taxi, false) then
                local seat = GetPedVehicleSeat(playerPed)
                if seat >= 0 then
                    passengerBoarded = true
                end
            end
        end

        if not passengerBoarded then
            ESX.ShowNotification("~r~[EcoCab] Waktu tunggu pemesanan habis. Armada kembali ke pangkalan.~s~")
            DismissAndDespawnTaxi(taxi, driver)
            return
        end

        if sCfg.isBike then
            SetPedHelmet(playerPed, true)
            GiveMountNameToPed(playerPed, taxi)
        end

        -- FASE 2: Perjalanan Menuju Destinasi Pilihan
        SetVehicleHandbrake(taxi, false)
        if not sCfg.isBike then
            SetVehicleDoorsLocked(taxi, 4)
        end

        ESX.ShowNotification(('~b~[EcoCab]~s~ Perjalanan dimulai menuju ~y~%s~s~.'):format(destName))
        inRideHUD = true

        local startPos = GetEntityCoords(taxi)
        local totalDistanceCoveredKm = 0.0
        local lastCoord = startPos

        local triggerGasEvent = false
        if sCfg.isBike and (sCfg.gasEventChance or 18) > 0 then
            local roll = math.random(1, 100)
            if roll <= (sCfg.gasEventChance or 18) then
                triggerGasEvent = true
            end
        end

        local gasDone = false
        local gasStation = FindNearestGasStation(startPos)

        TaskVehicleDriveToCoordLongrange(
            driver, taxi,
            dest.x, dest.y, dest.z,
            sCfg.cruiseSpeed or 16.0,
            sCfg.drivingStyle or 524475,
            Config.Drive.DestinationRadius or 8.0
        )

        local arrivedAtDestination = false
        local loopCount = 0

        while DoesEntityExist(taxi) and not arrivedAtDestination do
            Wait(300)
            loopCount = loopCount + 1

            local currentPos = GetEntityCoords(taxi)
            local legDist = #(currentPos - lastCoord)
            if legDist > 1.0 then
                totalDistanceCoveredKm = totalDistanceCoveredKm + (legDist / 1000.0)
                lastCoord = currentPos
            end

            -- Event Mampir Pom Bensin (EcoRide)
            if triggerGasEvent and not gasDone and gasStation and loopCount > 15 then
                gasDone = true
                TriggerEvent('eco_taxi:client:driverFuelStop', gasStation.name)
                ESX.ShowNotification("~y~[EcoRide] Driver: 'Waduh kak, bensin tiris nih! Mampir pom bensin sebentar ya kak.'~s~")

                TaskVehicleDriveToCoordLongrange(
                    driver, taxi,
                    gasStation.coords.x, gasStation.coords.y, gasStation.coords.z,
                    12.0,
                    sCfg.drivingStyle or 524475,
                    5.0
                )

                local atGas = false
                local gasWait = 0
                while DoesEntityExist(taxi) and not atGas and gasWait < 60 do
                    Wait(500)
                    gasWait = gasWait + 1
                    if #(GetEntityCoords(taxi) - gasStation.coords) <= 7.0 then
                        atGas = true
                    end
                end

                if DoesEntityExist(taxi) then
                    BringVehicleToHalt(taxi, 2.0, 1, true)
                    SetVehicleHandbrake(taxi, true)
                    ESX.ShowNotification("~b~[EcoRide]~s~ Mengisi bahan bakar di " .. gasStation.name .. "...")
                    Wait(sCfg.gasStopDuration or 8000)
                    SetVehicleHandbrake(taxi, false)
                    ESX.ShowNotification("~g~[EcoRide] Driver: 'Beres kak! Lanjut gas ke tujuan.'~s~")

                    TaskVehicleDriveToCoordLongrange(
                        driver, taxi,
                        dest.x, dest.y, dest.z,
                        sCfg.cruiseSpeed or 16.0,
                        sCfg.drivingStyle or 524475,
                        Config.Drive.DestinationRadius or 8.0
                    )
                end
            end

            local distToDest = #(currentPos - dest)
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

        -- FASE 3: Tiba di Tujuan, Menepi & Pembayaran
        BringVehicleToHalt(taxi, 2.0, 1, true)
        SetVehicleHandbrake(taxi, true)
        SetVehicleDoorsLocked(taxi, 1)

        if IsPedInVehicle(playerPed, taxi, false) then
            TaskLeaveVehicle(playerPed, taxi, 0)
        end

        TriggerServerEvent('eco_taxi:server:completeRide', totalDistanceCoveredKm)

        Wait(4000)
        DismissAndDespawnTaxi(taxi, driver)
    end)
end

-- Thread Render Live HUD Taximeter saat berada di dalam armada
CreateThread(function()
    while true do
        local sleep = 500
        if inRideHUD and DoesEntityExist(currentTaxi) and activeRideData then
            sleep = 0
            local speedKmh = math.floor(GetEntitySpeed(currentTaxi) * 3.6)
            local currentPos = GetEntityCoords(currentTaxi)
            local remainingKm = #(currentPos - activeRideData.dest) / 1000.0
            local sCfg = activeRideData.serviceCfg or {}
            local currentLiveFare = (sCfg.baseFare or 25) + (remainingKm * (sCfg.pricePerKm or 14))
            DrawTaximeterHUD(activeRideData.destName, currentLiveFare, remainingKm, speedKmh, sCfg.name)
        end
        Wait(sleep)
    end
end)

function DismissAndDespawnTaxi(taxi, driver)
    if currentTaxiBlip then
        RemoveBlip(currentTaxiBlip)
        currentTaxiBlip = nil
    end

    if DoesEntityExist(taxi) and DoesEntityExist(driver) then
        SetVehicleDoorsLocked(taxi, 2)
        SetVehicleHandbrake(taxi, false)
        TaskVehicleDriveWander(driver, taxi, 12.0, 524475)
        SetTimeout(25000, function()
            if DoesEntityExist(driver) then DeleteEntity(driver) end
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
    if DoesEntityExist(currentTaxi) and DoesEntityExist(currentDriver) then
        DismissAndDespawnTaxi(currentTaxi, currentDriver)
    end
end)

-- Exports untuk eco_tablet
exports('GetQuickDestinations', function()
    return Config.QuickDestinations
end)

exports('RequestEcoCabRide', function(destCoords, destName, serviceType, driverName, surgeMultiplier, vipPayload)
    TriggerServerEvent('eco_taxi:server:bookRide', destCoords, destName, serviceType, driverName, surgeMultiplier, vipPayload)
end)

exports('CancelEcoCabRide', function()
    TriggerServerEvent('eco_taxi:server:cancelRide')
end)