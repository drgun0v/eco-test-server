local isOnDuty = false
local currentBus = nil
local currentStopIndex = 1
local routeBlip = nil
local isHandlingPassengers = false
local abandonedTimer = 0
local timerActive = false
local busPassengers = {}
local hasAnnouncedStop = false
local isRouteFinished = false

local function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function UpdateBusHUD(stateText)
    local stop = Config.MetroStops[currentStopIndex]
    SendNUIMessage({
        action = "updateStop",
        stopName = isRouteFinished and "Terminal (Selesai)" or (stop and stop.name or "Selesai"),
        current = math.min(currentStopIndex, #Config.MetroStops),
        total = #Config.MetroStops,
        stateText = stateText or "Menuju halte..."
    })
end

local function SetRouteToStop(index)
    hasAnnouncedStop = false
    if routeBlip then RemoveBlip(routeBlip) end

    local stop = Config.MetroStops[index]
    if not stop then return end

    routeBlip = AddBlipForCoord(stop.x, stop.y, stop.z)
    SetBlipSprite(routeBlip, 1)
    SetBlipColour(routeBlip, 5)
    SetBlipRoute(routeBlip, true)
    SetBlipRouteColour(routeBlip, 5)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Halte: " .. stop.name)
    EndTextCommandSetBlipName(routeBlip)

    UpdateBusHUD("Silakan berkendara menuju halte.")
end

local function CleanUpJob(deleteBus)
    isOnDuty = false
    isRouteFinished = false
    currentStopIndex = 1
    isHandlingPassengers = false
    timerActive = false
    abandonedTimer = 0

    SendNUIMessage({ action = "hideHud" })

    if routeBlip then
        RemoveBlip(routeBlip)
        routeBlip = nil
    end

    for _, ped in ipairs(busPassengers) do
        if DoesEntityExist(ped) then
            DeletePed(ped)
        end
    end
    busPassengers = {}

    if deleteBus and currentBus and DoesEntityExist(currentBus) then
        DeleteVehicle(currentBus)
        currentBus = nil
    end
end

local function HandlePassengersAtStop(stop)
    isHandlingPassengers = true
    SetVehicleHandbrake(currentBus, true)
    FreezeEntityPosition(currentBus, true)

    SendNUIMessage({ action = "playAirBrakes" })
    Wait(300)
    SendNUIMessage({ action = "playDoorChime" })

    SetVehicleDoorOpen(currentBus, 0, false, false)
    SetVehicleDoorOpen(currentBus, 1, false, false)

    local numToLeave = 0
    if stop.unloadType == UnloadType.All then
        numToLeave = #busPassengers
    else
        numToLeave = math.min(#busPassengers, math.random(1, 2))
    end

    if numToLeave > 0 then
        UpdateBusHUD("Penumpang sedang turun dari bus...")
        for i = 1, numToLeave do
            local ped = table.remove(busPassengers, 1)
            if DoesEntityExist(ped) then
                TaskLeaveVehicle(ped, currentBus, 0)
                SetTimeout(2500, function()
                    if DoesEntityExist(ped) then
                        TaskWanderStandard(ped, 10.0, 10)
                        SetPedAsNoLongerNeeded(ped)
                    end
                end)
            end
            Wait(1200)
        end
    end

    local numToBoard = (stop.unloadType == UnloadType.All) and 0 or math.random(1, 3)
    if numToBoard > 0 then
        UpdateBusHUD("Penumpang baru sedang naik...")
        for _ = 1, numToBoard do
            local maxSeats = GetVehicleMaxNumberOfPassengers(currentBus)
            local freeSeat = -1
            for seat = 0, maxSeats - 1 do
                if IsVehicleSeatFree(currentBus, seat) then
                    freeSeat = seat
                    break
                end
            end

            if freeSeat ~= -1 then
                local modelName = Config.PassengerModels[math.random(#Config.PassengerModels)]
                local model = joaat(modelName)
                RequestModel(model)
                while not HasModelLoaded(model) do Wait(10) end

                local offset = GetOffsetFromEntityInWorldCoords(currentBus, 2.5, math.random(-2, 2) * 1.0, 0.0)
                local ped = CreatePed(26, model, offset.x, offset.y, offset.z, GetEntityHeading(currentBus), true, false)
                SetEntityAsMissionEntity(ped, true, true)
                SetBlockingOfNonTemporaryEvents(ped, true)

                TaskEnterVehicle(ped, currentBus, 10000, freeSeat, 1.0, 1, 0)
                table.insert(busPassengers, ped)
                SetModelAsNoLongerNeeded(model)
                Wait(2000)
            end
        end
    end

    SendNUIMessage({ action = "playDoorChime" })
    Wait(1000)

    SetVehicleDoorShut(currentBus, 0, false)
    SetVehicleDoorShut(currentBus, 1, false)

    Wait(500)
    SendNUIMessage({ action = "playAirBrakes" })

    FreezeEntityPosition(currentBus, false)
    SetVehicleHandbrake(currentBus, false)
    isHandlingPassengers = false

    if currentStopIndex == #Config.MetroStops then
        Wait(1000)
        SendNUIMessage({
            action = "announceStop",
            stopName = "This bus is now out of service. Please make sure you have all your personal belongings. Have a great day!"
        })
    end
end

local function SpawnJobBus()
    local model = joaat(Config.BusModel)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end

    local pos = Config.SpawnPoint
    currentBus = CreateVehicle(model, pos.x, pos.y, pos.z, pos.w, true, false)
    SetVehicleEngineOn(currentBus, true, true, false)
    TaskWarpPedIntoVehicle(PlayerPedId(), currentBus, -1)
    SetModelAsNoLongerNeeded(model)

    currentStopIndex = 1
    isOnDuty = true
    isRouteFinished = false

    SendNUIMessage({ action = "showHud" })
    SetRouteToStop(currentStopIndex)
end

local function OpenBusMenu()
    local elements = {}

    if not isOnDuty then
        table.insert(elements, {label = 'Mulai Dinas Supir Bus (Deposit: $' .. Config.Deposit .. ')', value = 'start'})
    else
        if isRouteFinished then
            table.insert(elements, {label = 'Selesaikan Shift & Ambil Reward ($' .. Config.Reward .. ')', value = 'finish'})
        else
            table.insert(elements, {label = 'Batalkan Pekerjaan (Exit Job - Tanpa Reward)', value = 'quit'})
        end
    end

    ESX.UI.Menu.CloseAll()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bus_job_menu', {
        title    = 'Layanan Metro Bus',
        align    = 'top-left',
        elements = elements
    }, function(data, menu)
        menu.close()

        if data.current.value == 'start' then
            ESX.TriggerServerCallback('esx_busjob:startJob', function(success, message)
                ESX.ShowNotification(message)
                if success then
                    SpawnJobBus()
                end
            end)
        elseif data.current.value == 'finish' then
            TriggerServerEvent('esx_busjob:returnBus', false)
            CleanUpJob(true)
        elseif data.current.value == 'quit' then
            ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'bus_confirm_quit', {
                title    = 'TIDAK MENDAPATKAN REWARD JIKA KELUAR! Yakin?',
                align    = 'top-left',
                elements = {
                    {label = 'Ya, Kembalikan Bus & Batalkan', value = 'confirm'},
                    {label = 'Lanjutkan Bertugas', value = 'cancel'}
                }
            }, function(confirmData, confirmMenu)
                confirmMenu.close()
                if confirmData.current.value == 'confirm' then
                    TriggerServerEvent('esx_busjob:returnBus', true)
                    CleanUpJob(true)
                end
            end, function(_, confirmMenu)
                confirmMenu.close()
            end)
        end
    end, function(_, menu)
        menu.close()
    end)
end

CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local pCoords = GetEntityCoords(playerPed)
        local spawnV3 = vector3(Config.SpawnPoint.x, Config.SpawnPoint.y, Config.SpawnPoint.z)
        local dist = #(pCoords - spawnV3)

        if dist < 20.0 then
            sleep = 0
            DrawMarker(36, spawnV3.x, spawnV3.y, spawnV3.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.2, 0, 150, 255, 150, false, true, 2, false, nil, nil, false)
            if dist < 3.0 then
                DrawText3D(spawnV3.x, spawnV3.y, spawnV3.z + 1.0, "[E] Menu Supir Bus")
                if IsControlJustReleased(0, 38) then
                    OpenBusMenu()
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        local sleep = 1000
        if isOnDuty and currentBus and DoesEntityExist(currentBus) then
            local playerPed = PlayerPedId()
            local pCoords = GetEntityCoords(playerPed)

            if not isRouteFinished then
                local stop = Config.MetroStops[currentStopIndex]

                if stop then
                    local stopCoords = vector3(stop.x, stop.y, stop.z)
                    local dist = #(pCoords - stopCoords)

                    if dist < 50.0 and not hasAnnouncedStop and IsPedInVehicle(playerPed, currentBus, false) then
                        hasAnnouncedStop = true
                        SendNUIMessage({
                            action = "announceStop",
                            stopName = stop.announceText or stop.name
                        })
                    end

                    if dist < 45.0 then
                        sleep = 0
                        DrawMarker(1, stop.x, stop.y, stop.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 1.0, 72, 202, 228, 150, false, false, 2, false, nil, nil, false)

                        if dist < 4.5 and IsPedInVehicle(playerPed, currentBus, false) and not isHandlingPassengers then
                            DrawText3D(stop.x, stop.y, stop.z + 1.0, "[E] Buka Pintu & Proses Halte")
                            if IsControlJustReleased(0, 38) then
                                HandlePassengersAtStop(stop)

                                if currentStopIndex < #Config.MetroStops then
                                    currentStopIndex = currentStopIndex + 1
                                    SetRouteToStop(currentStopIndex)
                                    ESX.ShowNotification("Halte selesai. Silakan menuju titik berikutnya.")
                                else
                                    isRouteFinished = true
                                    TriggerServerEvent('esx_busjob:finishRoute')
                                    if routeBlip then RemoveBlip(routeBlip) end
                                    routeBlip = AddBlipForCoord(Config.SpawnPoint.x, Config.SpawnPoint.y, Config.SpawnPoint.z)
                                    SetBlipSprite(routeBlip, 357)
                                    SetBlipColour(routeBlip, 2)
                                    SetBlipRoute(routeBlip, true)
                                    UpdateBusHUD("Semua rute beres! Kembalikan bus ke Terminal.")
                                    ESX.ShowNotification("Semua rute beres! Bawa bus kembali ke terminal.")
                                end
                            end
                        end
                    end
                end
            else
                local spawnV3 = vector3(Config.SpawnPoint.x, Config.SpawnPoint.y, Config.SpawnPoint.z)
                local distToTerminal = #(pCoords - spawnV3)

                if distToTerminal < 20.0 and IsPedInVehicle(playerPed, currentBus, false) then
                    sleep = 0
                    DrawMarker(1, spawnV3.x, spawnV3.y, spawnV3.z - 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 4.0, 4.0, 1.0, 50, 255, 50, 150, false, false, 2, false, nil, nil, false)
                    DrawText3D(spawnV3.x, spawnV3.y, spawnV3.z + 1.0, "[E] Selesaikan Shift & Simpan Bus")
                    if IsControlJustReleased(0, 38) then
                        TriggerServerEvent('esx_busjob:returnBus', false)
                        CleanUpJob(true)
                    end
                end
            end
        end
        Wait(sleep)
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        if isOnDuty and currentBus and DoesEntityExist(currentBus) then
            local playerPed = PlayerPedId()
            local inVehicle = IsPedInVehicle(playerPed, currentBus, false)

            if not inVehicle then
                if not timerActive then
                    timerActive = true
                    abandonedTimer = Config.AbandonTimeout
                    ESX.ShowNotification("Perhatian: Anda keluar dari Bus. Bus akan ditarik dalam 3 menit jika tidak kembali!", "error")
                else
                    abandonedTimer = abandonedTimer - 1
                    if abandonedTimer <= 0 then
                        CleanUpJob(true)
                        TriggerServerEvent('esx_busjob:timeoutRemove')
                    end
                end
            else
                if timerActive then
                    timerActive = false
                    abandonedTimer = 0
                    ESX.ShowNotification("Anda kembali ke dalam Bus. Timer dibatalkan.", "success")
                end
            end
        end
    end
end)