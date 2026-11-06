local activeHike = nil
local hikeBlip = nil

-- Setup Blips, Ped Ranger, Trailhead & Summit Props
CreateThread(function()
    -- 1. Blip & Ped Ranger Station
    if Config.RangerStation.blip.enabled then
        local blip = AddBlipForCoord(Config.RangerStation.coords.x, Config.RangerStation.coords.y, Config.RangerStation.coords.z)
        SetBlipSprite(blip, Config.RangerStation.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.RangerStation.blip.scale)
        SetBlipColour(blip, Config.RangerStation.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(Config.RangerStation.blip.label)
        EndTextCommandSetBlipName(blip)
    end

    local rangerPed = SpawnEventPed(Config.RangerStation.pedModel, Config.RangerStation.coords)
    exports.ox_target:addLocalEntity(rangerPed, {
        {
            name = 'eco_ranger_menu',
            icon = 'fa-solid fa-mountain-sun',
            label = 'Pos Ekspedisi Four Summit',
            onSelect = function()
                OpenRangerMenu()
            end
        }
    })

    -- 2. Spawn Trailheads & Summit Boxes
    for id, data in pairs(Config.Summits) do
        local thCoords = data.trailhead.trailheadBase or data.trailhead.coords
        local thProp = SpawnEventProp(data.trailhead.prop, thCoords)

        exports.ox_target:addLocalEntity(thProp, {
            {
                name = 'trailhead_' .. id,
                icon = 'fa-solid fa-person-hiking',
                label = ('Mulai Pendakian: %s (%s)'):format(data.name, data.elevation),
                onSelect = function()
                    StartSummitStage(id)
                end
            }
        })

        local sumProp = SpawnEventProp(data.summit.prop, data.summit.coords)
        exports.ox_target:addLocalEntity(sumProp, {
            {
                name = 'summit_' .. id,
                icon = 'fa-solid fa-stamp',
                label = ('Stempel Paspor: Puncak %s'):format(data.name),
                onSelect = function()
                    ClaimSummitStamp(id)
                end
            }
        })
    end
end)

-- Menu Interaksi Ranger HQ
function OpenRangerMenu()
    lib.registerContext({
        id = 'eco_ranger_hq_menu',
        title = '🏔️ San Andreas Four Summit HQ',
        options = {
            {
                title = 'Beli Buku Paspor Ekspedisi',
                description = ('Harga registrasi buku paspor: $%d'):format(Config.PassportPrice),
                icon = 'book-atlas',
                onSelect = function()
                    TriggerServerEvent('eco_sportsevent:server:buyPassport')
                end
            },
            {
                title = 'Klaim Gelar "Four Summit Conqueror"',
                description = 'Tukarkan paspor dengan 4 stempel lengkap untuk menerima Grand Badge & masuk Hall of Fame!',
                icon = 'trophy',
                onSelect = function()
                    TriggerServerEvent('eco_sportsevent:server:claimGrandBadge')
                end
            },
            {
                title = 'Papan Kehormatan (Hall of Fame)',
                description = 'Lihat daftar penakluk Four Summit San Andreas.',
                icon = 'medal',
                onSelect = function()
                    local hofList = lib.callback.await('eco_sportsevent:server:getHallOfFame', false)
                    local options = {}
                    if #hofList == 0 then
                        table.insert(options, { title = 'Belum ada penakluk terdaftar.', disabled = true })
                    else
                        for idx, row in ipairs(hofList) do
                            table.insert(options, {
                                title = ('#%d - %s'):format(idx, row.character_name),
                                description = ('Paspor: %s | Selesai: %s'):format(row.passport_serial, row.completed_at),
                                icon = 'award'
                            })
                        end
                    end
                    lib.registerContext({
                        id = 'eco_ranger_hof_list',
                        title = '🏆 Four Summit Hall of Fame',
                        menu = 'eco_ranger_hq_menu',
                        options = options
                    })
                    lib.showContext('eco_ranger_hof_list')
                end
            }
        }
    })
    lib.showContext('eco_ranger_hq_menu')
end

-- Memulai Pendakian Etape di Trailhead
function StartSummitStage(summitId)
    local summitData = Config.Summits[summitId]
    if not summitData then return end

    if IsPedInAnyVehicle(cache.ped, false) then
        return lib.notify({ type = 'error', description = 'Anda harus turun dari kendaraan sebelum memulai pendakian!' })
    end

    local hasPassport, alreadyDone = lib.callback.await('eco_sportsevent:server:canStartStage', false, summitId)
    if not hasPassport then
        return lib.notify({ type = 'error', description = 'Anda wajib membawa Four Summit Passport di tas Anda!' })
    end
    if alreadyDone then
        return lib.notify({ type = 'inform', description = ('Puncak %s sudah terstempel di paspor Anda.'):format(summitData.name) })
    end

    activeHike = {
        id = summitId,
        name = summitData.name,
        startTime = GetGameTimer(),
        lastPos = GetEntityCoords(cache.ped),
        vehicleStrike = 0
    }

    if hikeBlip and DoesBlipExist(hikeBlip) then RemoveBlip(hikeBlip) end
    hikeBlip = AddBlipForCoord(summitData.summit.coords.x, summitData.summit.coords.y, summitData.summit.coords.z)
    SetBlipSprite(hikeBlip, 430)
    SetBlipColour(hikeBlip, 5)
    SetBlipRoute(hikeBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Target Puncak: ' .. summitData.name)
    EndTextCommandSetBlipName(hikeBlip)

    lib.notify({
        type = 'success',
        title = 'Pendakian Dimulai: ' .. summitData.name,
        description = 'Berjalanlah menuju puncak! Dilarang menaiki kendaraan apa pun hingga stempel didapatkan.',
        duration = 7000
    })

    -- Loop Pemantauan Anti-Cheat & No-Vehicle
    CreateThread(function()
        while activeHike and activeHike.id == summitId do
            Wait(1000)
            local ped = cache.ped
            local currentPos = GetEntityCoords(ped)

            -- 1. Pengecekan Pingsan / Mati
            if IsEntityDead(ped) or IsPedFatallyInjured(ped) then
                FailCurrentHike('Anda pingsan/cedera parah di tengah jalur pendakian!')
                break
            end

            -- 2. Pengecekan Masuk Kendaraan
            if IsPedInAnyVehicle(ped, false) then
                activeHike.vehicleStrike = activeHike.vehicleStrike + 1
                if activeHike.vehicleStrike > Config.VehicleGraceSeconds then
                    FailCurrentHike('Diskualifikasi! Anda terdeteksi menggunakan kendaraan selama etape mendaki.')
                    break
                else
                    lib.notify({
                        type = 'warning',
                        description = ('Peringatan! Segera keluar dari kendaraan (%d/%d dtk)!'):format(activeHike.vehicleStrike, Config.VehicleGraceSeconds)
                    })
                end
            else
                activeHike.vehicleStrike = 0
            end

            -- 3. Pengecekan Kecepatan / Anti-Teleport / Carry Kendaraan
            local dist = #(currentPos - activeHike.lastPos)
            if dist > (Config.MaxFootSpeed * 2.2) and not IsPedFalling(ped) and not IsPedRagdoll(ped) then
                FailCurrentHike('Diskualifikasi! Perpindahan kecepatan tidak wajar terdeteksi.')
                break
            end
            activeHike.lastPos = currentPos
        end
    end)
end

function FailCurrentHike(reason)
    activeHike = nil
    if hikeBlip and DoesBlipExist(hikeBlip) then RemoveBlip(hikeBlip) end
    lib.notify({
        type = 'error',
        title = 'Ekspedisi Etape Gagal!',
        description = reason .. ' Silakan ulangi dari pos Trailhead kaki gunung.',
        duration = 8000
    })
end

-- Klaim Stempel di Puncak
function ClaimSummitStamp(summitId)
    local summitData = Config.Summits[summitId]
    if not activeHike or activeHike.id ~= summitId then
        return lib.notify({
            type = 'error',
            description = ('Anda belum melakukan check-in pendakian dari Trailhead kaki %s!'):format(summitData.name)
        })
    end

    if IsPedInAnyVehicle(cache.ped, false) then
        return FailCurrentHike('Dilarang berada di dalam kendaraan!')
    end

    if lib.progressBar({
        duration = 5000,
        label = ('Mencap Paspor di Puncak %s...'):format(summitData.name),
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = {
            dict = 'amb@medic@standing@timeofdeath@base',
            clip = 'base'
        }
    }) then
        TriggerServerEvent('eco_sportsevent:server:stampSummit', summitId)
        activeHike = nil
        if hikeBlip and DoesBlipExist(hikeBlip) then RemoveBlip(hikeBlip) end
    end
end
