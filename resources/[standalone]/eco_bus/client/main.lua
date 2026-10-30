local activeBusBlips = {}

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

-- Menghitung titik offset di depan koordinat halte sesuai arah heading (agar moncong bus tidak berhenti sebelum box)
local function GetForwardOffsetCoords(coords, heading, distance)
    local rad = math.rad(heading or 0.0)
    local forwardX = -math.sin(rad)
    local forwardY =  math.cos(rad)
    return vector3(
        coords.x + (forwardX * distance),
        coords.y + (forwardY * distance),
        coords.z
    )
end

local function DrawOrientedStopBox(coords, heading, size, r, g, b, a)
    local rad = math.rad(heading or 0.0)
    local cosH = math.cos(rad)
    local sinH = math.sin(rad)

    local halfW = size.x / 2.0
    local halfL = size.y / 2.0
    local height = size.z

    local foundGround, groundZ = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 1.5, false)
    local baseZ = foundGround and (groundZ + 0.03) or (coords.z - 0.92)
    local topZ = baseZ + height

    local function getCorner(ox, oy, z)
        local wx = coords.x + (ox * cosH) - (oy * sinH)
        local wy = coords.y + (ox * sinH) + (oy * cosH)
        return vector3(wx, wy, z)
    end

    local b1 = getCorner(-halfW, -halfL, baseZ)
    local b2 = getCorner( halfW, -halfL, baseZ)
    local b3 = getCorner( halfW,  halfL, baseZ)
    local b4 = getCorner(-halfW,  halfL, baseZ)

    local t1 = getCorner(-halfW, -halfL, topZ)
    local t2 = getCorner( halfW, -halfL, topZ)
    local t3 = getCorner( halfW,  halfL, topZ)
    local t4 = getCorner(-halfW,  halfL, topZ)

    DrawPoly(b1.x, b1.y, b1.z, b2.x, b2.y, b2.z, b3.x, b3.y, b3.z, r, g, b, math.floor(a * 0.45))
    DrawPoly(b1.x, b1.y, b1.z, b3.x, b3.y, b3.z, b4.x, b4.y, b4.z, r, g, b, math.floor(a * 0.45))
    DrawPoly(b3.x, b3.y, b3.z, b2.x, b2.y, b2.z, b1.x, b1.y, b1.z, r, g, b, math.floor(a * 0.45))
    DrawPoly(b4.x, b4.y, b4.z, b3.x, b3.y, b3.z, b1.x, b1.y, b1.z, r, g, b, math.floor(a * 0.45))

    local lineAlpha = 235
    DrawLine(b1.x, b1.y, b1.z, b2.x, b2.y, b2.z, r, g, b, lineAlpha)
    DrawLine(b2.x, b2.y, b2.z, b3.x, b3.y, b3.z, r, g, b, lineAlpha)
    DrawLine(b3.x, b3.y, b3.z, b4.x, b4.y, b4.z, r, g, b, lineAlpha)
    DrawLine(b4.x, b4.y, b4.z, b1.x, b1.y, b1.z, r, g, b, lineAlpha)

    DrawLine(t1.x, t1.y, t1.z, t2.x, t2.y, t2.z, r, g, b, lineAlpha)
    DrawLine(t2.x, t2.y, t2.z, t3.x, t3.y, t3.z, r, g, b, lineAlpha)
    DrawLine(t3.x, t3.y, t3.z, t4.x, t4.y, t4.z, r, g, b, lineAlpha)
    DrawLine(t4.x, t4.y, t4.z, t1.x, t1.y, t1.z, r, g, b, lineAlpha)

    DrawLine(b1.x, b1.y, b1.z, t1.x, t1.y, t1.z, r, g, b, lineAlpha)
    DrawLine(b2.x, b2.y, b2.z, t2.x, t2.y, t2.z, r, g, b, lineAlpha)
    DrawLine(b3.x, b3.y, b3.z, t3.x, t3.y, t3.z, r, g, b, lineAlpha)
    DrawLine(b4.x, b4.y, b4.z, t4.x, t4.y, t4.z, r, g, b, lineAlpha)

    local arrowTip = getCorner(0.0, halfL * 0.75, baseZ + 0.05)
    local arrowLeft = getCorner(-halfW * 0.45, halfL * 0.25, baseZ + 0.05)
    local arrowRight = getCorner(halfW * 0.45, halfL * 0.25, baseZ + 0.05)
    DrawLine(arrowLeft.x, arrowLeft.y, arrowLeft.z, arrowTip.x, arrowTip.y, arrowTip.z, 255, 255, 255, 220)
    DrawLine(arrowRight.x, arrowRight.y, arrowRight.z, arrowTip.x, arrowTip.y, arrowTip.z, 255, 255, 255, 220)
end

-- Fungsi Guided Docking: Menggerakkan bus maju masuk ke dalam Box secara mulus & presisi 100%
local function GlideBusIntoStopBox(bus, driver, stopCoords)
    if not DoesEntityExist(bus) then return end

    local targetHeading = stopCoords.w or GetEntityHeading(bus)
    local startPos = GetEntityCoords(bus)
    local startHeading = GetEntityHeading(bus)

    local dist2D = #(vector2(startPos.x, startPos.y) - vector2(stopCoords.x, stopCoords.y))
    if dist2D > 20.0 then return end

    -- Hitung selisih sudut putar terpendek (-180 s/d 180)
    local diffH = (targetHeading - startHeading + 180.0) % 360.0 - 180.0

    -- Durasi glide proporsional dengan jarak agar kecepatan terlihat seperti bus merayap alami (~3.5 - 4.0 m/s)
    local glideSpeed = Config.Bus.DockingSpeed or 4.0
    local durationMs = math.max(900, math.min(4500, math.floor((dist2D / glideSpeed) * 1000)))
    local startTime = GetGameTimer()

    -- Putar roda kemudi visual & matikan kendali AI liar
    ClearPedTasks(driver)

    while DoesEntityExist(bus) do
        local now = GetGameTimer()
        local elapsed = now - startTime
        local t = math.min(1.0, elapsed / durationMs)

        -- Ease-out cubic: masuk dengan kecepatan konstan lalu mengerem halus tepat di tengah box
        local ease = 1.0 - math.pow(1.0 - t, 2.2)

        local nx = startPos.x + (stopCoords.x - startPos.x) * ease
        local ny = startPos.y + (stopCoords.y - startPos.y) * ease
        local nz = startPos.z + (stopCoords.z - startPos.z) * ease
        local nh = startHeading + (diffH * ease)

        SetEntityCoordsNoOffset(bus, nx, ny, nz, false, false, false)
        SetEntityHeading(bus, nh)
        SetVehicleOnGroundProperly(bus)

        if t >= 1.0 then
            break
        end
        Wait(0)
    end

    -- Pastikan kunci akhir 100% di tengah koordinat box
    SetEntityCoordsNoOffset(bus, stopCoords.x, stopCoords.y, stopCoords.z, false, false, false)
    SetEntityHeading(bus, targetHeading)
    SetVehicleOnGroundProperly(bus)
end

local function GetFirstFreePassengerSeat(vehicle)
    local maxSeats = GetVehicleMaxNumberOfPassengers(vehicle)
    for seat = 0, maxSeats - 1 do
        if IsVehicleSeatFree(vehicle, seat) then
            return seat
        end
    end
    return nil
end

CreateThread(function()
    while true do
        local sleep = 1000
        if Config.DrawStopBox then
            local routes = Config.RouteLoop or Config.MetroStops
            if routes then
                local playerPed = PlayerPedId()
                local pCoords = GetEntityCoords(playerPed)

                for _, stop in ipairs(routes) do
                    local sc = stop.coords or vector4(stop.x, stop.y, stop.z, stop.w or 0.0)
                    local sVec3 = vector3(sc.x, sc.y, sc.z)
                    local dist = #(pCoords - sVec3)

                    if dist < 65.0 then
                        sleep = 0
                        local boxColor = Config.StopBoxColor or { r = 255, g = 195, b = 0, a = 110 }
                        local boxSize = Config.StopBoxSize or vector3(3.4, 13.5, 0.4)

                        DrawOrientedStopBox(sVec3, sc.w or 0.0, boxSize, boxColor.r, boxColor.g, boxColor.b, boxColor.a)

                        if dist < 25.0 then
                            DrawText3D(sc.x, sc.y, sc.z + 1.25, ("~y~[HALTE %s]~s~ %s"):format(stop.id or "", stop.name or "Bus Stop"))
                        end
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('eco_bus:client:dispatchNewBus', function(startStopIndex)
    local routes = Config.RouteLoop or Config.MetroStops
    if not routes or #routes == 0 then return end

    local startStop = routes[startStopIndex]
    if not startStop then return end

    local stopVec = startStop.coords or vector4(startStop.x, startStop.y, startStop.z, 180.0)
    local targetHeading = stopVec.w or 180.0

    RequestCollisionAtCoord(stopVec.x, stopVec.y, stopVec.z)

    local nearbyVeh = GetClosestVehicle(stopVec.x, stopVec.y, stopVec.z, 8.0, 0, 71)
    if DoesEntityExist(nearbyVeh) then
        print('^3[eco_bus] Titik spawn masih terhalang kendaraan lain. Menunda spawn.^7')
        return
    end

    RequestModel(Config.Bus.Model)
    RequestModel(Config.Bus.DriverModel)
    local timeout = 0
    while (not HasModelLoaded(Config.Bus.Model) or not HasModelLoaded(Config.Bus.DriverModel)) and timeout < 200 do
        Wait(20)
        timeout = timeout + 1
    end

    local bus = CreateVehicle(Config.Bus.Model, stopVec.x, stopVec.y, stopVec.z, targetHeading, true, true)

    if not DoesEntityExist(bus) or bus == 0 then
        print('^1[eco_bus] Gagal membuat kendaraan. Kemungkinan Anda terlalu jauh dari lokasi halte 1!^7')
        return
    end

    SetVehicleOnGroundProperly(bus)
    SetEntityHeading(bus, targetHeading)

    local driver = CreatePedInsideVehicle(bus, 26, Config.Bus.DriverModel, -1, true, true)
    SetEntityAsMissionEntity(bus, true, true)
    SetEntityAsMissionEntity(driver, true, true)
    SetBlockingOfNonTemporaryEvents(driver, true)
    SetPedCanBeKnockedOffVehicle(driver, 1)
    SetPedFleeAttributes(driver, 0, false)
    SetPedCombatAttributes(driver, 3, false)
    SetDriverAbility(driver, 1.0)
    SetDriverAggressiveness(driver, 0.0)

    SetVehicleStrong(bus, true)
    SetVehicleHasStrongAxles(bus, true)

    local netVeh = NetworkGetNetworkIdFromEntity(bus)
    TriggerServerEvent('eco_bus:server:registerScheduledBus', netVeh)

    SetModelAsNoLongerNeeded(Config.Bus.Model)
    SetModelAsNoLongerNeeded(Config.Bus.DriverModel)

    print('^2[eco_bus] Bus berhasil di-spawn presisi di Box Halte 1 dan mulai dinas.^7')
    StartRouteLoop(bus, driver, startStopIndex)
end)

function StartRouteLoop(bus, driver, startStopIndex)
    CreateThread(function()
        local routes = Config.RouteLoop or Config.MetroStops
        local currentIdx = startStopIndex

        while DoesEntityExist(bus) and DoesEntityExist(driver) do
            local nextIdx = currentIdx + 1
            if nextIdx > #routes then
                nextIdx = 1
            end

            local nextStop = routes[nextIdx]
            local stopCoords = nextStop.coords or vector4(nextStop.x, nextStop.y, nextStop.z, 0.0)
            local stopVec3 = vector3(stopCoords.x, stopCoords.y, stopCoords.z)

            -- SOLUSI AI BERHENTI DI BELAKANG BOX:
            -- Karena panjang bus ~13.5m (moncong +6.75m di depan titik pusat), AI GTA V selalu mengerem
            -- saat moncong bus baru menyentuh garis belakang box.
            -- Kita beri target AI 7.5 meter di DEPAN pusat box agar bodi bus masuk penuh ke dalam box!
            local aiDriveTarget = GetForwardOffsetCoords(stopVec3, stopCoords.w or 0.0, 7.5)

            SetVehicleDoorsLocked(bus, 1)

            -- FASE 1: Jelajah menuju titik depan box
            TaskVehicleDriveToCoordLongrange(
                driver, bus,
                aiDriveTarget.x, aiDriveTarget.y, aiDriveTarget.z,
                Config.Bus.Speed,
                Config.Bus.DrivingStyle,
                6.0
            )

            local readyToDock = false
            local lastPos = GetEntityCoords(bus)
            local stuckTicks = 0

            while not readyToDock do
                Wait(400)
                if not DoesEntityExist(bus) or not DoesEntityExist(driver) then return end

                local busPos = GetEntityCoords(bus)
                local distToBoxCenter = #(busPos - stopVec3)
                local speed = GetEntitySpeed(bus)

                -- Begitu pusat bus sudah masuk radius 14 meter dari tengah box, ambil alih untuk glide masuk ke dalam box
                if distToBoxCenter <= (Config.Bus.ArrivalDistance or 15.0) then
                    readyToDock = true
                elseif distToBoxCenter <= 19.0 and speed < 0.3 then
                    readyToDock = true
                else
                    if #(busPos - lastPos) < 0.25 then
                        stuckTicks = stuckTicks + 1
                        if stuckTicks >= 15 then
                            ClearPedTasks(driver)
                            TaskVehicleDriveToCoordLongrange(
                                driver, bus,
                                aiDriveTarget.x, aiDriveTarget.y, aiDriveTarget.z,
                                Config.Bus.Speed,
                                Config.Bus.DrivingStyle,
                                6.0
                            )
                            stuckTicks = 0
                        end
                    else
                        stuckTicks = 0
                    end
                    lastPos = busPos
                end
            end

            -- FASE 2: Guided Box Glide (Memasukkan seluruh bodi bus tepat ke tengah Box Kuning secara halus)
            GlideBusIntoStopBox(bus, driver, stopCoords)

            -- FASE 3: Kunci Posisi di Dalam Box & Buka Pintu
            BringVehicleToHalt(bus, 0.5, 1, true)
            SetVehicleHandbrake(bus, true)
            FreezeEntityPosition(bus, true)

            Wait(500)

            -- Buka Pintu Penumpang
            SetVehicleDoorOpen(bus, 0, false, false)
            SetVehicleDoorOpen(bus, 1, false, false)
            SetVehicleDoorOpen(bus, 2, false, false)
            SetVehicleDoorOpen(bus, 3, false, false)
            Entity(bus).state:set('isBoardingOpen', true, true)

            if nextStop.unloadAll then
                local playerPed = PlayerPedId()
                if IsPedInVehicle(playerPed, bus, false) then
                    ESX.ShowNotification("~y~Halte Akhir: Harap turun dari bus.~s~")
                    TaskLeaveVehicle(playerPed, bus, 0)
                end
            end

            Wait((Config.Bus.WaitAtStopSeconds or 12) * 1000)

            -- Tutup Pintu & Lanjutkan Perjalanan
            Entity(bus).state:set('isBoardingOpen', false, true)
            SetVehicleDoorsShut(bus, false)
            FreezeEntityPosition(bus, false)
            SetVehicleHandbrake(bus, false)
            Wait(1000)

            currentIdx = nextIdx
        end

        local netVeh = NetworkGetNetworkIdFromEntity(bus)
        TriggerServerEvent('eco_bus:server:removeScheduledBus', netVeh)
    end)
end

-- Interaksi Naik Bus
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()

        if not IsPedInAnyVehicle(playerPed, false) then
            local pCoords = GetEntityCoords(playerPed)
            local closestVeh = GetClosestVehicle(pCoords.x, pCoords.y, pCoords.z, 5.0, Config.Bus.Model, 70)

            if DoesEntityExist(closestVeh) and Entity(closestVeh).state.isBoardingOpen then
                sleep = 0
                ESX.ShowHelpNotification("Tekan ~INPUT_ENTER~ untuk naik Bus Transit")

                if IsControlJustReleased(0, 23) then
                    local netVeh = NetworkGetNetworkIdFromEntity(closestVeh)
                    TriggerServerEvent('eco_bus:server:payBoarding', netVeh)
                end
            end
        end
        Wait(sleep)
    end
end)

RegisterNetEvent('eco_bus:client:boardConfirmed', function(netVeh)
    local bus = NetworkGetEntityFromNetworkId(netVeh)
    if DoesEntityExist(bus) then
        local playerPed = PlayerPedId()
        local seat = GetFirstFreePassengerSeat(bus)

        if seat then
            TaskEnterVehicle(playerPed, bus, 10000, seat, 1.0, 1, 0)
            ESX.ShowNotification("~g~Selamat menikmati perjalanan bus transit.~s~")
        else
            ESX.ShowNotification("~r~Kapasitas kursi bus ini sudah penuh.~s~")
        end
    end
end)

RegisterNetEvent('eco_bus:client:syncScheduledBlip', function(netVeh)
    CreateThread(function()
        local tries = 0
        while tries < 30 do
            Wait(1000)
            tries = tries + 1
            if NetworkDoesNetworkIdExist(netVeh) then
                local veh = NetworkGetEntityFromNetworkId(netVeh)
                if DoesEntityExist(veh) and not activeBusBlips[netVeh] then
                    local blip = AddBlipForEntity(veh)
                    SetBlipSprite(blip, 513)
                    SetBlipColour(blip, 38)
                    SetBlipScale(blip, 0.85)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentSubstringPlayerName("Bus Metro (Looping)")
                    EndTextCommandSetBlipName(blip)
                    activeBusBlips[netVeh] = blip
                    break
                end
            end
        end
    end)
end)

RegisterNetEvent('eco_bus:client:removeScheduledBlip', function(netVeh)
    if activeBusBlips[netVeh] then
        RemoveBlip(activeBusBlips[netVeh])
        activeBusBlips[netVeh] = nil
    end
end)
