local activeTrainBlips = {}
local spawnedTrains = {}
local stationBlips = {}
local cachedMetroVariation = nil

-- Cache Live Telemetry untuk PIDS (Passenger Information Display System)
local livePIDSTrains = {}
local liveNextDispatchIn = 0

local hasPaidCurrentRide = false
local currentPaidCarriage = nil
local isSittingInMetro = false
local sittingCarriage = nil
local currentSeatIndex = 1
local customSeatZAdjust = 0.0
local paymentPending = false

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 225)
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

-- =========================================================================
-- RENDERER PAPAN INFORMASI ELEKTRONIK (PIDS - LED DISPLAY BOARD DI PERON)
-- =========================================================================
local function DrawPIDSScreen3D(x, y, z, stationTitle, line1, line2, statusColor)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    if not onScreen then return end

    local camCoords = GetGameplayCamCoords()
    local dist = #(camCoords - vector3(x, y, z))
    local scale = math.max(0.24, math.min(0.42, (1.0 / dist) * 2.5))

    -- Background Panel Hitam PIDS + Frame Border Atas Biru LST
    DrawRect(sx, sy + 0.012, 0.255, 0.076, 12, 16, 23, 225)
    DrawRect(sx, sy - 0.024, 0.255, 0.005, statusColor.r, statusColor.g, statusColor.b, 240)

    -- Baris Header: Nama Stasiun
    SetTextScale(scale * 0.78, scale * 0.78)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(56, 189, 248, 255)
    SetTextCentre(1)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(stationTitle)
    DrawText(sx, sy - 0.022)

    -- Baris Utama LED: Status Kereta Berikutnya & Hitung Mundur
    SetTextScale(scale * 0.90, scale * 0.90)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(1)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(line1)
    DrawText(sx, sy + 0.002)

    -- Baris Footer: Informasi Tambahan / Tujuan Berikutnya
    SetTextScale(scale * 0.70, scale * 0.70)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(190, 200, 215, 230)
    SetTextCentre(1)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(line2)
    DrawText(sx, sy + 0.026)
end

local bannedFreightModels = {
    [`freight`] = true,
    [`freightcar`] = true,
    [`freightcar2`] = true,
    [`freightcar3`] = true,
    [`freightgrain`] = true,
    [`freightcont1`] = true,
    [`freightcont2`] = true,
    [`freighttrailer`] = true,
    [`tankercar`] = true,
}

local requiredTrainModels = {
    `metrotrain`,
    `freight`,
    `freightcar`,
    `freightcar2`,
    `freightcar3`,
    `freightgrain`,
    `freightcont1`,
    `freightcont2`,
    `freighttrailer`,
    `tankercar`,
    `s_m_m_lsmetro_01`
}

local function PurgeAllFreightCars()
    local vehicles = GetGamePool('CVehicle')
    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) then
            local mdl = GetEntityModel(veh)
            if bannedFreightModels[mdl] then
                SetEntityAsMissionEntity(veh, true, true)
                DeleteMissionTrain(veh)
                DeleteVehicle(veh)
                if DoesEntityExist(veh) then
                    SetEntityCoords(veh, 0.0, 0.0, -500.0, false, false, false, false)
                    DeleteEntity(veh)
                end
            end
        end
    end
end

local function LoadTrainModels()
    for _, model in ipairs(requiredTrainModels) do
        if IsModelInCdimage(model) then
            RequestModel(model)
            local timeout = 0
            while not HasModelLoaded(model) and timeout < 250 do
                Wait(15)
                timeout = timeout + 1
            end
        end
    end
end

local function ReleaseTrainModels()
    for _, model in ipairs(requiredTrainModels) do
        if IsModelInCdimage(model) then
            SetModelAsNoLongerNeeded(model)
        end
    end
end

local function ForceDeleteTrain(train)
    if not DoesEntityExist(train) then return end
    for i = 35, 1, -1 do
        local car = GetTrainCarriage(train, i)
        if DoesEntityExist(car) and car ~= 0 then
            SetEntityAsMissionEntity(car, true, true)
            DeleteVehicle(car)
            if DoesEntityExist(car) then
                DeleteEntity(car)
            end
        end
    end
    SetEntityAsMissionEntity(train, true, true)
    DeleteMissionTrain(train)
    if DoesEntityExist(train) then
        DeleteVehicle(train)
        DeleteEntity(train)
    end
    PurgeAllFreightCars()
end

local function GetClosestMetroCarriage(coords, maxRadius)
    local vehicles = GetGamePool('CVehicle')
    local closestVeh = nil
    local closestDist = maxRadius or 12.0

    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) and GetEntityModel(veh) == `metrotrain` then
            local dist = #(coords - GetEntityCoords(veh))
            if dist < closestDist then
                closestDist = dist
                closestVeh = veh
            end
        end
    end

    return closestVeh, closestDist
end

local function IsPedInsideMetroCabin(ped, carriage)
    if not DoesEntityExist(carriage) then return false end
    local offset = GetOffsetFromEntityGivenWorldCoords(carriage, GetEntityCoords(ped))
    if math.abs(offset.x) <= 1.35 and offset.y >= -6.4 and offset.y <= 5.4 and offset.z >= -0.5 and offset.z <= 2.4 then
        return true
    end
    return false
end

local function IsPlayerOnSpecificTrain(train)
    if not DoesEntityExist(train) then return false end
    local playerPed = PlayerPedId()
    local carriage = GetTrainCarriage(train, 1)

    if isSittingInMetro and DoesEntityExist(sittingCarriage) then
        if sittingCarriage == train or (DoesEntityExist(carriage) and sittingCarriage == carriage) then
            return true
        end
    end

    if IsPedInsideMetroCabin(playerPed, train) then
        return true
    end
    if DoesEntityExist(carriage) and carriage ~= 0 and IsPedInsideMetroCabin(playerPed, carriage) then
        return true
    end

    return false
end

local function ApplySeatAttachment(playerPed, carriage, seatData)
    local chassisBone = GetEntityBoneIndexByName(carriage, "chassis")
    if chassisBone == -1 then
        chassisBone = GetEntityBoneIndexByName(carriage, "chassis_dummy")
    end

    local finalZ = (Config.DefaultSeatZ or 0.68) + customSeatZAdjust

    AttachEntityToEntity(
        playerPed, carriage, chassisBone,
        seatData.offset.x, seatData.offset.y, finalZ,
        0.0, 0.0, seatData.heading,
        false, false, false, false, 2, true
    )
end

local function SitInMetroSeat(carriage, seatIndex)
    if not DoesEntityExist(carriage) then return end
    local seatData = Config.SeatOffsets[seatIndex]
    if not seatData then return end

    local playerPed = PlayerPedId()
    local animDict = "amb@prop_human_seat_chair_mp@male@generic@base"
    RequestAnimDict(animDict)
    local timeout = 0
    while not HasAnimDictLoaded(animDict) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    isSittingInMetro = true
    sittingCarriage = carriage
    currentSeatIndex = seatIndex

    ApplySeatAttachment(playerPed, carriage, seatData)
    TaskPlayAnim(playerPed, animDict, "base", 8.0, -8.0, -1, 1, 0.0, false, false, false)
    ESX.ShowNotification("~b~[LST Metro]~s~ Duduk di kursi. Tekan ~y~[F]~s~ untuk berdiri, atau ~y~[Panah Atas/Bawah]~s~ untuk sesuaikan tinggi duduk.")
end

local function StandUpFromMetroSeat()
    if not isSittingInMetro then return end
    local playerPed = PlayerPedId()
    local targetCar = sittingCarriage

    isSittingInMetro = false
    sittingCarriage = nil

    DetachEntity(playerPed, true, false)
    ClearPedTasks(playerPed)

    if DoesEntityExist(targetCar) then
        local seatData = Config.SeatOffsets[currentSeatIndex] or Config.SeatOffsets[1]
        local aislePos = GetOffsetFromEntityInWorldCoords(targetCar, 0.0, seatData.offset.y, 0.68)
        SetEntityCoordsNoOffset(playerPed, aislePos.x, aislePos.y, aislePos.z, false, false, false)
    end
end

local function GetNearestSeatIndex(carriage, pedCoords)
    local bestIdx = 1
    local bestDist = 999.0
    for idx, seat in ipairs(Config.SeatOffsets) do
        local worldSeat = GetOffsetFromEntityInWorldCoords(carriage, seat.offset.x, seat.offset.y, Config.DefaultSeatZ or 0.68)
        local d = #(pedCoords - worldSeat)
        if d < bestDist then
            bestDist = d
            bestIdx = idx
        end
    end
    return bestIdx, bestDist
end

local function SpawnVerifiedMetroTrain(x, y, z, direction)
    PurgeAllFreightCars()

    if cachedMetroVariation then
        local t = CreateMissionTrain(cachedMetroVariation, x, y, z, direction)
        if DoesEntityExist(t) and GetEntityModel(t) == `metrotrain` then
            PurgeAllFreightCars()
            return t
        elseif DoesEntityExist(t) then
            ForceDeleteTrain(t)
        end
    end

    local candidates = { 25, 24, 26, 27, 23, 21, 22, 28 }
    local fallbackSingleCarVar = nil

    for _, varIdx in ipairs(candidates) do
        local testTrain = CreateMissionTrain(varIdx, x, y, z, direction)
        if DoesEntityExist(testTrain) and testTrain ~= 0 then
            local model = GetEntityModel(testTrain)
            if model == `metrotrain` then
                local secondCar = GetTrainCarriage(testTrain, 1)
                if DoesEntityExist(secondCar) and secondCar ~= 0 and GetEntityModel(secondCar) == `metrotrain` then
                    cachedMetroVariation = varIdx
                    PurgeAllFreightCars()
                    print(('^2[eco_subway] Rangkaian 2-Gerbong `metrotrain` murni ditemukan pada Variation Index: %s^7'):format(varIdx))
                    return testTrain
                else
                    fallbackSingleCarVar = varIdx
                    ForceDeleteTrain(testTrain)
                end
            else
                ForceDeleteTrain(testTrain)
            end
        end
        Wait(20)
    end

    if fallbackSingleCarVar then
        cachedMetroVariation = fallbackSingleCarVar
        local finalTrain = CreateMissionTrain(fallbackSingleCarVar, x, y, z, direction)
        PurgeAllFreightCars()
        return finalTrain
    end

    return 0
end

local function SetMetroDoors(train, shouldOpen, stationName)
    if not DoesEntityExist(train) then return end
    local carriage = GetTrainCarriage(train, 1)
    local entities = { train }
    if DoesEntityExist(carriage) and carriage ~= 0 then
        table.insert(entities, carriage)
    end

    for _, veh in ipairs(entities) do
        Entity(veh).state:set('isMetroBoarding', shouldOpen, true)
        if stationName then
            Entity(veh).state:set('currentStationName', stationName, true)
        end

        if shouldOpen then
            SetVehicleDoorsLocked(veh, 1)
            for d = 0, 5 do
                SetVehicleDoorOpen(veh, d, false, false)
            end
        else
            for d = 0, 5 do
                SetVehicleDoorShut(veh, d, false)
            end
            SetVehicleDoorsShut(veh, false)
            SetVehicleDoorsLocked(veh, 2)
        end
    end
end

RegisterNetEvent('eco_subway:client:stationAnnouncement', function(netTrain, stationIdx, status)
    if not NetworkDoesNetworkIdExist(netTrain) then return end
    local train = NetworkGetEntityFromNetworkId(netTrain)
    if not DoesEntityExist(train) then return end

    if not IsPlayerOnSpecificTrain(train) then return end

    local st = Config.Stations[stationIdx]
    local stName = st and st.name or "Stasiun"

    if status == "STOPPED" then
        local nextIdx = (stationIdx % #Config.Stations) + 1
        local nextName = Config.Stations[nextIdx] and Config.Stations[nextIdx].name or "-"
        ESX.ShowNotification(('~b~[LST Metro]~s~ Tiba di: ~y~%s~s~ | Tujuan berikutnya: ~c~%s~s~'):format(stName, nextName))
    elseif status == "CLOSING_DOORS" then
        ESX.ShowNotification('~y~[LST Metro]~s~ Perhatian: Pintu kereta sedang ditutup! Harap menjauh dari pintu.')
    elseif status == "EN_ROUTE" then
        local nextIdx = (stationIdx % #Config.Stations) + 1
        local nextName = Config.Stations[nextIdx] and Config.Stations[nextIdx].name or "-"
        ESX.ShowNotification(('~b~[LST Metro]~s~ Pintu telah tertutup. Berangkat menuju: ~y~%s~s~'):format(nextName))
    end
end)

local function PerformStationStop(train, stationIdx)
    if not DoesEntityExist(train) then return end
    local station = Config.Stations[stationIdx]
    if not station then return end

    local netTrain = NetworkGetNetworkIdFromEntity(train)

    SetTrainSpeed(train, 0.0)
    SetTrainCruiseSpeed(train, 0.0)
    Wait(500)

    SetMetroDoors(train, true, station.name)
    TriggerServerEvent('eco_subway:server:updateTrainStatus', netTrain, stationIdx, "STOPPED")
    print(('^2[eco_subway] Kereta NetID %s berhenti di %s - Pintu Terbuka (%s detik)^7'):format(netTrain, station.name, Config.Train.WaitAtStationSeconds or 15))

    local waitSeconds = (Config.Train.WaitAtStationSeconds or 15) - (Config.Train.DoorCloseWaitSeconds or 3)
    if waitSeconds < 5 then waitSeconds = 5 end

    for _ = 1, waitSeconds do
        if not DoesEntityExist(train) then return end
        SetTrainSpeed(train, 0.0)
        SetTrainCruiseSpeed(train, 0.0)
        Wait(1000)
    end

    if not DoesEntityExist(train) then return end

    TriggerServerEvent('eco_subway:server:updateTrainStatus', netTrain, stationIdx, "CLOSING_DOORS")
    SetMetroDoors(train, false, station.name)

    local closeWaitSec = Config.Train.DoorCloseWaitSeconds or 3
    for _ = 1, closeWaitSec do
        if not DoesEntityExist(train) then return end
        SetTrainSpeed(train, 0.0)
        SetTrainCruiseSpeed(train, 0.0)
        SetMetroDoors(train, false, station.name)
        Wait(1000)
    end

    if not DoesEntityExist(train) then return end

    TriggerServerEvent('eco_subway:server:updateTrainStatus', netTrain, stationIdx, "EN_ROUTE")

    Wait(500)
    if not DoesEntityExist(train) then return end

    SetTrainCruiseSpeed(train, Config.Train.ApproachSpeed or 8.0)
    Wait(3500)
    if DoesEntityExist(train) then
        SetTrainCruiseSpeed(train, Config.Train.CruiseSpeed or 20.0)
    end
end

CreateThread(function()
    SwitchTrainTrack(0, false)
    SwitchTrainTrack(3, true)
    SetRandomTrains(false)
    PurgeAllFreightCars()

    if Config.ShowStationBlips then
        for _, st in ipairs(Config.Stations) do
            local blip = AddBlipForCoord(st.coords.x, st.coords.y, st.coords.z)
            SetBlipSprite(blip, 513)
            SetBlipColour(blip, 26)
            SetBlipScale(blip, 0.7)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName("Stasiun Metro: " .. st.name)
            EndTextCommandSetBlipName(blip)
            table.insert(stationBlips, blip)
        end
    end
end)

RegisterNetEvent('eco_subway:client:clearAllTrains', function()
    if isSittingInMetro then
        StandUpFromMetroSeat()
    end
    for _, tr in ipairs(spawnedTrains) do
        ForceDeleteTrain(tr)
    end
    spawnedTrains = {}
    PurgeAllFreightCars()
    for netId, blip in pairs(activeTrainBlips) do
        RemoveBlip(blip)
    end
    activeTrainBlips = {}
end)

RegisterNetEvent('eco_subway:client:dispatchTrain', function(startStationIdx)
    local st = Config.Stations[startStationIdx] or Config.Stations[1]
    if not st then return end

    RequestCollisionAtCoord(st.coords.x, st.coords.y, st.coords.z)
    LoadTrainModels()
    PurgeAllFreightCars()

    local existingMetro = GetClosestMetroCarriage(st.coords, 18.0)
    if DoesEntityExist(existingMetro) then
        print('^3[eco_subway] Peron stasiun masih ditempati kereta lain. Menunda spawn.^7')
        ReleaseTrainModels()
        return
    end

    local train = SpawnVerifiedMetroTrain(st.coords.x, st.coords.y, st.coords.z, Config.Train.Direction)

    if not DoesEntityExist(train) or train == 0 then
        print('^1[eco_subway] Gagal membuat kereta. Pastikan Anda berada dekat peron stasiun saat memanggil kereta.^7')
        ReleaseTrainModels()
        return
    end

    table.insert(spawnedTrains, train)

    SetEntityAsMissionEntity(train, true, true)
    SetTrainSpeed(train, 0.0)
    SetTrainCruiseSpeed(train, 0.0)
    SetVehicleStrong(train, true)
    SetEntityInvincible(train, true)

    local driver = CreatePedInsideVehicle(train, 26, `s_m_m_lsmetro_01`, -1, true, true)
    if DoesEntityExist(driver) then
        SetEntityAsMissionEntity(driver, true, true)
        SetBlockingOfNonTemporaryEvents(driver, true)
        SetPedCanBeKnockedOffVehicle(driver, 1)
        SetEntityInvincible(driver, true)
    end

    local carriage = GetTrainCarriage(train, 1)
    if DoesEntityExist(carriage) and carriage ~= 0 then
        SetEntityAsMissionEntity(carriage, true, true)
        SetEntityInvincible(carriage, true)
    end

    local netTrain = NetworkGetNetworkIdFromEntity(train)
    TriggerServerEvent('eco_subway:server:registerTrain', netTrain, startStationIdx)

    ReleaseTrainModels()
    print(('^2[eco_subway] Kereta Metro LST (`metrotrain`) berhasil aktif di %s (NetID: %s)^7'):format(st.name, netTrain))

    StartMetroLoop(train, startStationIdx)
end)

function StartMetroLoop(train, startStationIdx)
    CreateThread(function()
        local lastStoppedStation = startStationIdx or 0

        if Config.Stations[startStationIdx] then
            PerformStationStop(train, startStationIdx)
        else
            SetTrainCruiseSpeed(train, Config.Train.CruiseSpeed or 20.0)
        end

        while DoesEntityExist(train) do
            Wait(200)
            local trainPos = GetEntityCoords(train)

            local closestIdx = nil
            local closestDist = 9999.0

            for idx, st in ipairs(Config.Stations) do
                local dist = #(trainPos - st.coords)
                if dist < closestDist then
                    closestDist = dist
                    closestIdx = idx
                end
            end

            if lastStoppedStation ~= 0 and Config.Stations[lastStoppedStation] then
                local distFromLast = #(trainPos - Config.Stations[lastStoppedStation].coords)
                if distFromLast > 85.0 then
                    lastStoppedStation = 0
                end
            end

            if closestIdx and closestIdx ~= lastStoppedStation then
                if closestDist <= (Config.Train.StopRadius or 11.5) then
                    lastStoppedStation = closestIdx
                    PerformStationStop(train, closestIdx)

                elseif closestDist <= (Config.Train.CrawlRadius or 28.0) then
                    SetTrainCruiseSpeed(train, Config.Train.CrawlSpeed or 3.0)

                elseif closestDist <= (Config.Train.ApproachRadius or 75.0) then
                    SetTrainCruiseSpeed(train, Config.Train.ApproachSpeed or 8.0)

                else
                    SetTrainCruiseSpeed(train, Config.Train.CruiseSpeed or 20.0)
                end
            else
                SetTrainCruiseSpeed(train, Config.Train.CruiseSpeed or 20.0)
            end
        end

        local netTrain = NetworkGetNetworkIdFromEntity(train)
        TriggerServerEvent('eco_subway:server:removeTrain', netTrain)
    end)
end

local function FormatSecondsToMMSS(totalSec)
    totalSec = math.max(0, math.floor(totalSec))
    local mins = math.floor(totalSec / 60)
    local secs = totalSec % 60
    if mins > 0 then
        return ("%d MENIT %02d DETIK"):format(mins, secs)
    else
        return ("%d DETIK"):format(secs)
    end
end

local function CalculateLoopDistance(fromStationIdx, toStationIdx, currentTrainPos)
    local totalStations = #Config.Stations
    local nextStationIdx = (fromStationIdx % totalStations) + 1

    local dist = #(currentTrainPos - Config.Stations[nextStationIdx].coords) * 1.18
    local stopsBetween = 0

    local cursor = nextStationIdx
    local guard = 0
    while cursor ~= toStationIdx and guard < totalStations + 2 do
        guard = guard + 1
        stopsBetween = stopsBetween + 1
        local afterCursor = (cursor % totalStations) + 1
        dist = dist + (#(Config.Stations[cursor].coords - Config.Stations[afterCursor].coords) * 1.18)
        cursor = afterCursor
    end

    return dist, stopsBetween
end

-- Fungsi Kalkulasi Teks Layar PIDS Real-Time untuk Stasiun `stIdx`
local function GetStationPIDSDisplayInfo(stIdx)
    local st = Config.Stations[stIdx]
    local nextStIdx = (stIdx % #Config.Stations) + 1
    local nextStName = Config.Stations[nextStIdx] and Config.Stations[nextStIdx].name or "-"
    local dwellTime = (Config.Train and Config.Train.WaitAtStationSeconds) or 15
    local avgSpeed = ((Config.Train and Config.Train.CruiseSpeed) or 20.0) * 0.82

    local headerTitle = ("[LST METRO] STASIUN %s"):format(string.upper(st.name))

    if #livePIDSTrains == 0 then
        local etaWait = FormatSecondsToMMSS(liveNextDispatchIn + 30)
        return headerTitle,
            ("~y~KERETA BERIKUTNYA: MENUNGGU DEPO (%s)~s~"):format(etaWait),
            ("Tujuan Berikutnya: %s | Tarif: $%s"):format(nextStName, Config.FarePrice),
            { r = 245, g = 158, b = 11 }
    end

    local bestEta = 999999
    local bestEtd = 999999
    local bestTrainCode = "LST-01"
    local trainStatusAtPlatform = nil

    for _, tr in ipairs(livePIDSTrains) do
        if (tr.status == "STOPPED" or tr.status == "CLOSING_DOORS") and tr.lastStationIdx == stIdx then
            trainStatusAtPlatform = tr.status
            bestEta = 0
            bestEtd = math.max(1, dwellTime - tr.elapsedInStatus)
            bestTrainCode = tr.code
            break
        else
            local remainingStopWait = (tr.status == "STOPPED" or tr.status == "CLOSING_DOORS")
                and math.max(0, dwellTime - tr.elapsedInStatus) or 0
            local trackDist, intermediateStops = CalculateLoopDistance(tr.lastStationIdx, stIdx, tr.coords)
            local travelSec = (trackDist / avgSpeed) + (intermediateStops * (dwellTime + 6)) + remainingStopWait

            if travelSec < bestEta then
                bestEta = travelSec
                bestEtd = travelSec + dwellTime
                bestTrainCode = tr.code
            end
        end
    end

    if trainStatusAtPlatform == "CLOSING_DOORS" then
        return headerTitle,
            ("~o~[%s] PINTU DITUTUP - KERETA SEGERA BERANGKAT!~s~"):format(bestTrainCode),
            ("Tujuan Berikutnya: ~y~%s~s~ | Harap Menjauh dari Pintu"):format(nextStName),
            { r = 249, g = 115, b = 22 }
    elseif trainStatusAtPlatform == "STOPPED" then
        return headerTitle,
            ("~g~[%s] SEDANG DI PERON | BERANGKAT: %s~s~"):format(bestTrainCode, FormatSecondsToMMSS(bestEtd)),
            ("Tujuan Berikutnya: ~y~%s~s~ | Silakan Naik ke Kabin"):format(nextStName),
            { r = 34, g = 197, b = 94 }
    else
        return headerTitle,
            ("KERETA BERIKUTNYA: ~y~%s~s~ (~g~%s~s~)"):format(bestTrainCode, FormatSecondsToMMSS(bestEta)),
            ("Tujuan Berikutnya: ~b~%s~s~ | Info Lengkap: ~y~/subwayschedule~s~"):format(nextStName),
            { r = 56, g = 189, b = 248 }
    end
end

-- Event penerima data sinkronisasi PIDS otomatis setiap 2 detik dari server
RegisterNetEvent('eco_subway:client:syncPIDSData', function(trainsData, nextDispatchIn)
    livePIDSTrains = trainsData or {}
    liveNextDispatchIn = nextDispatchIn or 0
end)

RegisterCommand('subwayschedule', function()
    TriggerServerEvent('eco_subway:server:requestSchedule')
end, false)

RegisterNetEvent('eco_subway:client:receiveSchedule', function(trainsData, nextDispatchIn)
    livePIDSTrains = trainsData or {}
    liveNextDispatchIn = nextDispatchIn or 0

    local playerCoords = GetEntityCoords(PlayerPedId())
    local nearestStIdx = 1
    local nearestStDist = 99999.0

    for idx, st in ipairs(Config.Stations) do
        local d = #(playerCoords - st.coords)
        if d < nearestStDist then
            nearestStDist = d
            nearestStIdx = idx
        end
    end

    local dwellTime = (Config.Train and Config.Train.WaitAtStationSeconds) or 15
    local avgSpeed = ((Config.Train and Config.Train.CruiseSpeed) or 20.0) * 0.82

    local options = {}

    if #trainsData == 0 then
        table.insert(options, {
            title = "Status Jaringan: Menunggu Keberangkatan Armada",
            description = ("Kereta berikutnya dijadwalkan keluar depo dalam: %s"):format(FormatSecondsToMMSS(nextDispatchIn)),
            icon = "clock",
            iconColor = "#f59e0b"
        })
    else
        for _, tr in ipairs(trainsData) do
            local lastStName = Config.Stations[tr.lastStationIdx] and Config.Stations[tr.lastStationIdx].name or "Jalur Rel"
            local nextIdx = (tr.lastStationIdx % #Config.Stations) + 1
            local nextStName = Config.Stations[nextIdx] and Config.Stations[nextIdx].name or "-"
            local stateLabel = (tr.status == "STOPPED" or tr.status == "CLOSING_DOORS")
                and ("Sedang Berhenti di %s (Berangkat dlm %s)"):format(lastStName, FormatSecondsToMMSS(dwellTime - tr.elapsedInStatus))
                or  ("Melaju: %s -> %s"):format(lastStName, nextStName)

            table.insert(options, {
                title = ("Armada Aktif: %s"):format(tr.code),
                description = stateLabel,
                icon = "train-subway",
                iconColor = "#38bdf8"
            })
        end
    end

    local orderedIndices = { nearestStIdx }
    for i = 1, #Config.Stations do
        if i ~= nearestStIdx then
            table.insert(orderedIndices, i)
        end
    end

    for _, stIdx in ipairs(orderedIndices) do
        local st = Config.Stations[stIdx]
        local isNearest = (stIdx == nearestStIdx)
        local badge = isNearest and " [STASIUN TERDEKAT]" or ""

        if #trainsData == 0 then
            table.insert(options, {
                title = ("#%d %s%s"):format(st.id, st.name, badge),
                description = ("ETA Ketibaan: ~%s | ETD Keberangkatan: ~%s"):format(
                    FormatSecondsToMMSS(nextDispatchIn + 30),
                    FormatSecondsToMMSS(nextDispatchIn + 30 + dwellTime)
                ),
                icon = isNearest and "location-dot" or "calendar-Alt"
            })
        else
            local bestEta = 999999
            local bestEtd = 999999
            local bestTrainCode = "-"
            local isCurrentlyAtPlatform = false

            for _, tr in ipairs(trainsData) do
                if (tr.status == "STOPPED" or tr.status == "CLOSING_DOORS") and tr.lastStationIdx == stIdx then
                    isCurrentlyAtPlatform = true
                    bestEta = 0
                    bestEtd = math.max(1, dwellTime - tr.elapsedInStatus)
                    bestTrainCode = tr.code
                    break
                else
                    local remainingStopWait = (tr.status == "STOPPED" or tr.status == "CLOSING_DOORS")
                        and math.max(0, dwellTime - tr.elapsedInStatus) or 0
                    local trackDist, intermediateStops = CalculateLoopDistance(tr.lastStationIdx, stIdx, tr.coords)
                    local travelSec = (trackDist / avgSpeed) + (intermediateStops * (dwellTime + 6)) + remainingStopWait

                    if travelSec < bestEta then
                        bestEta = travelSec
                        bestEtd = travelSec + dwellTime
                        bestTrainCode = tr.code
                    end
                end
            end

            if isCurrentlyAtPlatform then
                table.insert(options, {
                    title = ("#%d %s%s"):format(st.id, st.name, badge),
                    description = ("[%s] SEDANG DI PERON | ETD Berangkat: %s"):format(bestTrainCode, FormatSecondsToMMSS(bestEtd)),
                    icon = "door-open",
                    iconColor = "#22c55e"
                })
            else
                table.insert(options, {
                    title = ("#%d %s%s"):format(st.id, st.name, badge),
                    description = ("[%s] ETA Tiba: %s | ETD Berangkat: %s"):format(
                        bestTrainCode,
                        FormatSecondsToMMSS(bestEta),
                        FormatSecondsToMMSS(bestEtd)
                    ),
                    icon = isNearest and "location-dot" or "clock",
                    iconColor = isNearest and "#eab308" or "#94a3b8"
                })
            end
        end
    end

    if lib and lib.registerContext then
        lib.registerContext({
            id = 'eco_subway_schedule_menu',
            title = 'LST Metro - Live Forecast Jadwal',
            options = options
        })
        lib.showContext('eco_subway_schedule_menu')
    elseif ESX and ESX.UI and ESX.UI.Menu then
        local elements = {}
        for _, opt in ipairs(options) do
            table.insert(elements, {
                label = ("<b>%s</b><br><span style='font-size:12px;color:#cbd5e1;'>%s</span>"):format(opt.title, opt.description)
            })
        end
        ESX.UI.Menu.CloseAll()
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'subway_schedule', {
            title = 'LST Metro - Live Schedule',
            align = 'top-right',
            elements = elements
        }, function(_, menu)
            menu.close()
        end, function(_, menu)
            menu.close()
        end)
    else
        TriggerEvent('chat:addMessage', { color = { 56, 189, 248 }, args = { "[LST Metro Schedule]", "Forecast Ketibaan & Keberangkatan:" } })
        for _, opt in ipairs(options) do
            TriggerEvent('chat:addMessage', { color = { 255, 255, 255 }, args = { opt.title, opt.description } })
        end
    end
end)

exports('GetMetroStations', function()
    return Config.Stations
end)

-- Thread Utama Render PIDS Layar LED Peron & Interaksi Penumpang
CreateThread(function()
    while true do
        local sleep = 400
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)

        -- Render PIDS (Passenger Information Display System) di Peron Stasiun Terdekat
        if Config.DrawPlatformMarker then
            local maxDrawDist = Config.PIDSDrawDistance or 28.0
            local heightOffset = Config.PIDSHeightOffset or 2.15

            for idx, st in ipairs(Config.Stations) do
                local boardPos = st.pidsCoords or vector3(st.coords.x, st.coords.y, st.coords.z + heightOffset)
                local dist = #(pCoords - st.coords)
                if dist < maxDrawDist then
                    sleep = 0
                    local header, line1, line2, borderColor = GetStationPIDSDisplayInfo(idx)
                    DrawPIDSScreen3D(boardPos.x, boardPos.y, boardPos.z, header, line1, line2, borderColor)
                end
            end
        end

        local closestCarriage, cDist = GetClosestMetroCarriage(pCoords, 10.0)

        if DoesEntityExist(closestCarriage) then
            sleep = 0
            local insideCabin = IsPedInsideMetroCabin(playerPed, closestCarriage)

            if isSittingInMetro then
                ESX.ShowHelpNotification("Tekan ~INPUT_ENTER~ (F) untuk berdiri | ~INPUT_CELLPHONE_UP~ / ~INPUT_CELLPHONE_DOWN~ atur tinggi duduk")
                if IsControlJustReleased(0, 23) or IsControlJustReleased(0, 73) then
                    StandUpFromMetroSeat()
                elseif IsControlPressed(0, 172) then
                    customSeatZAdjust = customSeatZAdjust + 0.02
                    ApplySeatAttachment(playerPed, sittingCarriage, Config.SeatOffsets[currentSeatIndex])
                    Wait(50)
                elseif IsControlPressed(0, 173) then
                    customSeatZAdjust = customSeatZAdjust - 0.02
                    ApplySeatAttachment(playerPed, sittingCarriage, Config.SeatOffsets[currentSeatIndex])
                    Wait(50)
                end

            elseif insideCabin then
                if not hasPaidCurrentRide and not paymentPending then
                    paymentPending = true
                    local netVeh = NetworkGetNetworkIdFromEntity(closestCarriage)
                    TriggerServerEvent('eco_subway:server:payBoarding', netVeh, true)
                elseif hasPaidCurrentRide then
                    local nearestSeatIdx, _ = GetNearestSeatIndex(closestCarriage, pCoords)
                    local seatWorld = GetOffsetFromEntityInWorldCoords(
                        closestCarriage,
                        Config.SeatOffsets[nearestSeatIdx].offset.x,
                        Config.SeatOffsets[nearestSeatIdx].offset.y,
                        (Config.DefaultSeatZ or 0.68) + customSeatZAdjust
                    )
                    DrawText3D(seatWorld.x, seatWorld.y, seatWorld.z, "~g~[E]~s~ Duduk di Kursi")
                    ESX.ShowHelpNotification("Tekan ~INPUT_CONTEXT~ (E) untuk duduk di bangku Metro")

                    if IsControlJustReleased(0, 38) then
                        SitInMetroSeat(closestCarriage, nearestSeatIdx)
                    end
                end

            else
                if hasPaidCurrentRide and cDist > 3.5 then
                    hasPaidCurrentRide = false
                    currentPaidCarriage = nil
                    ESX.ShowNotification("~b~[LST Metro]~s~ Anda telah keluar dari kereta. Terima kasih telah menggunakan LST Metro.")
                end

                local isBoarding = Entity(closestCarriage).state.isMetroBoarding or (GetEntitySpeed(closestCarriage) < 0.2)
                if isBoarding and cDist < 5.5 then
                    ESX.ShowHelpNotification("Tekan ~INPUT_ENTER~ (F) untuk Tap Tiket & Duduk (~g~$" .. Config.FarePrice .. "~s~) atau jalan masuk ke kabin")
                    if IsControlJustReleased(0, 23) and not paymentPending then
                        paymentPending = true
                        local netVeh = NetworkGetNetworkIdFromEntity(closestCarriage)
                        TriggerServerEvent('eco_subway:server:payBoarding', netVeh, false)
                    end
                end
            end
        else
            if hasPaidCurrentRide then
                hasPaidCurrentRide = false
                currentPaidCarriage = nil
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('eco_subway:client:boardConfirmed', function(netVeh, autoWalkIn)
    paymentPending = false
    local carriage = NetworkGetEntityFromNetworkId(netVeh)
    if not DoesEntityExist(carriage) then return end

    hasPaidCurrentRide = true
    currentPaidCarriage = carriage

    if not autoWalkIn then
        local playerPed = PlayerPedId()
        local seatIdx = GetNearestSeatIndex(carriage, GetEntityCoords(playerPed))
        SitInMetroSeat(carriage, seatIdx)
    end
end)

RegisterNetEvent('eco_subway:client:denyBoarding', function(netVeh)
    paymentPending = false
    hasPaidCurrentRide = false
    local carriage = NetworkGetEntityFromNetworkId(netVeh)
    local playerPed = PlayerPedId()

    if isSittingInMetro then
        StandUpFromMetroSeat()
    end

    if DoesEntityExist(carriage) then
        local curOffset = GetOffsetFromEntityGivenWorldCoords(carriage, GetEntityCoords(playerPed))
        local sideX = (curOffset.x >= 0) and 2.6 or -2.6
        local ejectPos = GetOffsetFromEntityInWorldCoords(carriage, sideX, curOffset.y, 0.5)
        SetEntityCoordsNoOffset(playerPed, ejectPos.x, ejectPos.y, ejectPos.z, false, false, false)
    end
end)

RegisterNetEvent('eco_subway:client:syncTrainBlip', function(netTrain, trainCode)
    if not Config.ShowTrainBlips then return end

    CreateThread(function()
        local tries = 0
        while tries < 30 do
            Wait(1000)
            tries = tries + 1
            if NetworkDoesNetworkIdExist(netTrain) then
                local train = NetworkGetEntityFromNetworkId(netTrain)
                if DoesEntityExist(train) and not activeTrainBlips[netTrain] then
                    local blip = AddBlipForEntity(train)
                    SetBlipSprite(blip, 795)
                    SetBlipColour(blip, 26)
                    SetBlipScale(blip, 0.85)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentSubstringPlayerName(("Metro %s"):format(trainCode or "LST"))
                    EndTextCommandSetBlipName(blip)
                    activeTrainBlips[netTrain] = blip
                    break
                end
            end
        end
    end)
end)

RegisterNetEvent('eco_subway:client:removeTrainBlip', function(netTrain)
    if activeTrainBlips[netTrain] then
        RemoveBlip(activeTrainBlips[netTrain])
        activeTrainBlips[netTrain] = nil
    end
end)
