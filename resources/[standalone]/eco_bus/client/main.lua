-- Pastikan Config sudah siap sebelum thread apapun berjalan
while Config == nil or Config.Bus == nil do
    Wait(50)
end

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

local function GetStopsForRoute(routeId)
    if Config.Routes and Config.Routes[routeId] and Config.Routes[routeId].stops then
        return Config.Routes[routeId].stops
    end
    return Config.RouteLoop or Config.MetroStops
end

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

local function IsStopZonePhysicallyOccupied(currentBus, stopVec3)
    local clearanceRadius = (Config.Bus and Config.Bus.ClearanceDistance) or 17.5
    local myPos = GetEntityCoords(currentBus)
    local myDistToStop = #(myPos - stopVec3)
    local vehicles = GetGamePool('CVehicle')

    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) and veh ~= currentBus and GetEntityModel(veh) == Config.Bus.Model then
            local otherPos = GetEntityCoords(veh)
            local otherDistToStop = #(otherPos - stopVec3)

            if otherDistToStop <= clearanceRadius then
                local otherState = Entity(veh).state
                if otherState.isBoardingOpen or otherState.isOccupyingStop then
                    return true, veh, otherDistToStop
                end

                if otherDistToStop < (myDistToStop - 0.5) then
                    return true, veh, otherDistToStop
                end

                if math.abs(otherDistToStop - myDistToStop) <= 0.5 and veh < currentBus then
                    return true, veh, otherDistToStop
                end
            end
        end
    end

    return false, nil, 999.0
end

local function GetBusInFront(currentBus, maxDist)
    local busPos = GetEntityCoords(currentBus)
    local vehicles = GetGamePool('CVehicle')
    local closestFrontVeh = nil
    local minDist = maxDist or 18.0

    for _, veh in ipairs(vehicles) do
        if DoesEntityExist(veh) and veh ~= currentBus and GetEntityModel(veh) == Config.Bus.Model then
            local vPos = GetEntityCoords(veh)
            local dist = #(busPos - vPos)
            if dist <= minDist then
                local relOffset = GetOffsetFromEntityGivenWorldCoords(currentBus, vPos.x, vPos.y, vPos.z)
                if relOffset.y > 1.5 and math.abs(relOffset.x) <= 4.5 then
                    minDist = dist
                    closestFrontVeh = veh
                end
            end
        end
    end
    return closestFrontVeh, minDist
end

local function GlideBusIntoStopBox(bus, driver, stopCoords)
    if not DoesEntityExist(bus) then return end

    local stopVec3 = vector3(stopCoords.x, stopCoords.y, stopCoords.z)
    local targetHeading = stopCoords.w or GetEntityHeading(bus)
    local startPos = GetEntityCoords(bus)
    local startHeading = GetEntityHeading(bus)

    local dist2D = #(vector2(startPos.x, startPos.y) - vector2(stopCoords.x, stopCoords.y))
    if dist2D > 24.0 then return end

    local diffH = (targetHeading - startHeading + 180.0) % 360.0 - 180.0

    local glideSpeed = Config.Bus.DockingSpeed or 3.5
    local durationMs = math.max(1100, math.min(5000, math.floor((dist2D / glideSpeed) * 1000)))
    local startTime = GetGameTimer()

    ClearPedTasks(driver)

    while DoesEntityExist(bus) do
        local occupied, otherVeh, otherDist = IsStopZonePhysicallyOccupied(bus, stopVec3)
        if occupied and otherDist < 12.0 then
            BringVehicleToHalt(bus, 1.0, 1, true)
            Wait(500)
            startPos = GetEntityCoords(bus)
            startHeading = GetEntityHeading(bus)
            diffH = (targetHeading - startHeading + 180.0) % 360.0 - 180.0
            dist2D = #(vector2(startPos.x, startPos.y) - vector2(stopCoords.x, stopCoords.y))
            durationMs = math.max(900, math.min(4500, math.floor((dist2D / glideSpeed) * 1000)))
            startTime = GetGameTimer()
        else
            local now = GetGameTimer()
            local elapsed = now - startTime
            local t = math.min(1.0, elapsed / durationMs)

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
    end

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

local function IssueBusDriveTask(driver, bus, targetCoords, speed, drivingStyle, stopRadius)
    SetDriveTaskDrivingStyle(driver, drivingStyle)
    SetDriverAggressiveness(driver, 0.0)
    SetDriverRacingModifier(driver, 0.0)

    TaskVehicleDriveToCoordLongrange(
        driver, bus,
        targetCoords.x, targetCoords.y, targetCoords.z,
        speed,
        drivingStyle,
        stopRadius
    )
end

RegisterNetEvent('eco_bus:client:dispatchNewBus', function(routeId, startStopIndex)
    if not startStopIndex then
        startStopIndex = routeId or 1
        routeId = 1
    end

    local stops = GetStopsForRoute(routeId)
    if not stops or #stops == 0 then return end

    local startStop = stops[startStopIndex]
    if not startStop then return end

    local stopVec = startStop.coords or vector4(startStop.x, startStop.y, startStop.z, 180.0)
    local targetHeading = stopVec.w or 180.0

    RequestCollisionAtCoord(stopVec.x, stopVec.y, stopVec.z)

    local nearbyVeh = GetClosestVehicle(stopVec.x, stopVec.y, stopVec.z, 12.0, 0, 71)
    if DoesEntityExist(nearbyVeh) then
        print(('^3[eco_bus] Titik spawn Rute #%s masih ditempati kendaraan lain (<12m). Menunda spawn.^7'):format(routeId))
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
    SetVehicleMaxSpeed(bus, Config.Bus.Speed or 10.0)

    local driver = CreatePedInsideVehicle(bus, 26, Config.Bus.DriverModel, -1, true, true)
    SetEntityAsMissionEntity(bus, true, true)
    SetEntityAsMissionEntity(driver, true, true)
    SetBlockingOfNonTemporaryEvents(driver, true)
    SetPedCanBeKnockedOffVehicle(driver, 1)
    SetPedFleeAttributes(driver, 0, false)
    SetPedCombatAttributes(driver, 3, false)
    SetDriverAbility(driver, 1.0)
    SetDriverAggressiveness(driver, 0.0)
    SetDriverRacingModifier(driver, 0.0)
    SetDriveTaskDrivingStyle(driver, Config.Bus.DrivingStyle or 524475)
    SetPedKeepTask(driver, true)

    SetVehicleStrong(bus, true)
    SetVehicleHasStrongAxles(bus, true)

    Entity(bus).state:set('busRouteId', routeId, true)
    Entity(bus).state:set('isOccupyingStop', false, true)

    local netVeh = NetworkGetNetworkIdFromEntity(bus)
    TriggerServerEvent('eco_bus:server:registerScheduledBus', netVeh, routeId)

    SetModelAsNoLongerNeeded(Config.Bus.Model)
    SetModelAsNoLongerNeeded(Config.Bus.DriverModel)

    print(('^2[eco_bus] Bus [Rute #%s] berhasil di-spawn presisi di Halte 1 dan mulai dinas.^7'):format(routeId))
    StartRouteLoop(bus, driver, routeId, startStopIndex)
end)

function StartRouteLoop(bus, driver, routeId, startStopIndex)
    CreateThread(function()
        local stops = GetStopsForRoute(routeId)
        local currentIdx = startStopIndex

        while DoesEntityExist(bus) and DoesEntityExist(driver) do
            local nextIdx = currentIdx + 1
            if nextIdx > #stops then
                nextIdx = 1
            end

            local nextStop = stops[nextIdx]
            local isWaypoint = nextStop.isWaypoint == true
            local stopCoords = nextStop.coords or vector4(nextStop.x, nextStop.y, nextStop.z, 0.0)
            local stopVec3 = vector3(stopCoords.x, stopCoords.y, stopCoords.z)

            local offsetDist = isWaypoint and 0.0 or (Config.Bus.ApproachOffset or 2.0)
            local aiDriveTarget = GetForwardOffsetCoords(stopVec3, stopCoords.w or 0.0, offsetDist)
            local targetSpeed = isWaypoint and (Config.Bus.CornerSpeed or 7.5) or (Config.Bus.Speed or 10.0)
            local activeStyle = isWaypoint and (Config.Bus.CornerDrivingStyle or 524475) or (Config.Bus.DrivingStyle or 524475)
            local stopRadius = isWaypoint and 8.0 or 5.0

            SetVehicleDoorsLocked(bus, 1)
            SetVehicleMaxSpeed(bus, targetSpeed)

            -- FASE 1: Jelajah menuju titik target
            IssueBusDriveTask(driver, bus, aiDriveTarget, targetSpeed, activeStyle, stopRadius)

            local readyToProceed = false
            local lastPos = GetEntityCoords(bus)
            local stuckTicks = 0
            local arrivalRadius = isWaypoint and (Config.Bus.WaypointRadius or 14.0) or (Config.Bus.ArrivalDistance or 14.5)
            local queueCheckRadius = Config.Bus.QueueStopDistance or 21.0
            local wasPaused = false

            while not readyToProceed do
                Wait(250)
                if not DoesEntityExist(bus) or not DoesEntityExist(driver) then return end

                local busPos = GetEntityCoords(bus)
                local distToCenter = #(busPos - stopVec3)
                local speed = GetEntitySpeed(bus)

                -- 1. Cek Antrean Halte dari jarak 21 meter
                if not isWaypoint and distToCenter <= queueCheckRadius then
                    local occupied, _, _ = IsStopZonePhysicallyOccupied(bus, stopVec3)
                    if occupied then
                        wasPaused = true
                        ClearPedTasks(driver)
                        BringVehicleToHalt(bus, 2.0, 1, true)
                        SetVehicleHandbrake(bus, true)
                        Wait(800)
                    else
                        if wasPaused then
                            wasPaused = false
                            SetVehicleHandbrake(bus, false)
                            IssueBusDriveTask(driver, bus, aiDriveTarget, targetSpeed, activeStyle, stopRadius)
                        end
                    end
                end

                -- 2. Cek Jarak Aman di Jalan Raya
                if not wasPaused then
                    local frontBus, fDist = GetBusInFront(bus, 16.5)
                    if frontBus and fDist < 16.5 then
                        wasPaused = true
                        BringVehicleToHalt(bus, 2.5, 1, true)
                        SetVehicleHandbrake(bus, true)
                        Wait(600)
                    else
                        if wasPaused then
                            wasPaused = false
                            SetVehicleHandbrake(bus, false)
                            IssueBusDriveTask(driver, bus, aiDriveTarget, targetSpeed, activeStyle, stopRadius)
                        end

                        if distToCenter <= arrivalRadius then
                            readyToProceed = true
                        elseif not isWaypoint and distToCenter <= (arrivalRadius + 4.0) and speed < 0.3 then
                            readyToProceed = true
                        else
                            if #(busPos - lastPos) < 0.25 then
                                stuckTicks = stuckTicks + 1
                                if isWaypoint and stuckTicks >= 14 then
                                    readyToProceed = true
                                elseif stuckTicks >= 20 then
                                    ClearPedTasks(driver)
                                    IssueBusDriveTask(driver, bus, aiDriveTarget, targetSpeed, activeStyle, stopRadius)
                                    stuckTicks = 0
                                end
                            else
                                stuckTicks = 0
                            end
                            lastPos = busPos
                        end
                    end
                end
            end

            if not isWaypoint then
                -- FASE 1.5: Halte harus benar-benar bersih (> 17.5m)
                while IsStopZonePhysicallyOccupied(bus, stopVec3) do
                    if not DoesEntityExist(bus) or not DoesEntityExist(driver) then return end
                    ClearPedTasks(driver)
                    BringVehicleToHalt(bus, 1.5, 1, true)
                    SetVehicleHandbrake(bus, true)
                    Wait(800)
                end

                Wait(1200)
                if not DoesEntityExist(bus) or not DoesEntityExist(driver) then return end

                Entity(bus).state:set('isOccupyingStop', true, true)
                SetVehicleHandbrake(bus, false)

                -- FASE 2: Guided Box Glide
                GlideBusIntoStopBox(bus, driver, stopCoords)

                -- FASE 3: Berhenti & Buka Pintu
                BringVehicleToHalt(bus, 0.5, 1, true)
                SetVehicleHandbrake(bus, true)
                FreezeEntityPosition(bus, true)

                Wait(500)

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

                Entity(bus).state:set('isBoardingOpen', false, true)
                SetVehicleDoorsShut(bus, false)
                FreezeEntityPosition(bus, false)
                SetVehicleHandbrake(bus, false)
                Wait(1200)

                local departedStopVec = stopVec3
                CreateThread(function()
                    local guardTicks = 0
                    while DoesEntityExist(bus) and guardTicks < 40 do
                        Wait(500)
                        guardTicks = guardTicks + 1
                        if #(GetEntityCoords(bus) - departedStopVec) > (Config.Bus.ClearanceDistance or 17.5) then
                            break
                        end
                    end
                    if DoesEntityExist(bus) then
                        Entity(bus).state:set('isOccupyingStop', false, true)
                    end
                end)
            end

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
            local busModel = (Config and Config.Bus and Config.Bus.Model) or `bus`
            local closestVeh = GetClosestVehicle(pCoords.x, pCoords.y, pCoords.z, 5.0, busModel, 70)

            if DoesEntityExist(closestVeh) and Entity(closestVeh).state.isBoardingOpen then
                sleep = 0
                local rId = Entity(closestVeh).state.busRouteId or 1
                local rName = (Config and Config.Routes and Config.Routes[rId] and Config.Routes[rId].name) or ("Rute " .. rId)
                ESX.ShowHelpNotification(("Tekan ~INPUT_ENTER~ untuk naik Bus (%s)"):format(rName))

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

RegisterNetEvent('eco_bus:client:syncScheduledBlip', function(netVeh, routeId)
    routeId = routeId or 1
    local routeConfig = Config.Routes and Config.Routes[routeId]
    local blipColor = (routeConfig and routeConfig.blipColor) or 38
    local blipLabel = (routeConfig and ("Bus " .. routeConfig.name)) or ("Bus Metro Rute " .. routeId)

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
                    SetBlipColour(blip, blipColor)
                    SetBlipScale(blip, 0.85)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentSubstringPlayerName(blipLabel)
                    EndTextCommandSetBlipName(blip)
                    activeBusBlips[netVeh] = blip
                    break
                end
            end
        end
    end)
end)

RegisterNetEvent('eco_bus:client:removeScheduledBus', function(netVeh)
    if activeBusBlips[netVeh] then
        RemoveBlip(activeBusBlips[netVeh])
        activeBusBlips[netVeh] = nil
    end
end)
