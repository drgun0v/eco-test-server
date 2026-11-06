-- Helper ambil nama karakter & uang (Kompatibel ESX / QBCore / Qbox)
local function GetPlayerDetails(src)
    if GetResourceState('es_extended') == 'started' then
        local ESX = exports['es_extended']:getSharedObject()
        local xPlayer = ESX.GetPlayerFromId(src)
        if xPlayer then
            return xPlayer.identifier, xPlayer.getName(), function(amount)
                if xPlayer.getMoney() >= amount then
                    xPlayer.removeMoney(amount)
                    return true
                end
                return false
            end
        end
    elseif GetResourceState('qb-core') == 'started' then
        local QBCore = exports['qb-core']:GetCoreObject()
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local charName = Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
            return Player.PlayerData.citizenid, charName, function(amount)
                return Player.Functions.RemoveMoney('cash', amount, 'four-summit-passport')
            end
        end
    end
    return ('id_%s'):format(src), GetPlayerName(src), function() return true end
end

-- Pembelian Buku Paspor Ekspedisi
RegisterNetEvent('eco_sportsevent:server:buyPassport', function()
    local src = source
    local identifier, charName, deductCash = GetPlayerDetails(src)

    if not deductCash(Config.PassportPrice) then
        return TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = ('Uang tunai tidak cukup ($%d diperlukan).'):format(Config.PassportPrice)
        })
    end

    local serial = ('FS-%d-%d'):format(math.random(1000, 9999), os.time() % 1000)
    local metadata = {
        serialNumber = serial,
        ownerName = charName,
        stamps = {
            josiah   = { completed = false, timestamp = nil },
            chiliad  = { completed = false, timestamp = nil },
            gordo    = { completed = false, timestamp = nil },
            chianski = { completed = false, timestamp = nil }
        },
        grandTotal = 0,
        claimedGrand = false,
        description = ('Pemegang: %s | No. Seri: %s | Stempel: 0/4'):format(charName, serial)
    }

    exports.ox_inventory:AddItem(src, Config.PassportItem, 1, metadata)
    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        description = 'Buku Paspor Four Summit berhasil diterbitkan! Cek di dalam tas Anda.'
    })
end)

-- Validasi Sebelum Memulai Etape di Trailhead
lib.callback.register('eco_sportsevent:server:canStartStage', function(source, summitId)
    local items = exports.ox_inventory:Search(source, 'slots', Config.PassportItem)
    if not items or #items == 0 then return false, false end

    local passport = items[1]
    local stamps = passport.metadata and passport.metadata.stamps
    local isDone = stamps and stamps[summitId] and stamps[summitId].completed or false
    return true, isDone
end)

-- Pemberian Stempel Puncak & Badge Satuan
RegisterNetEvent('eco_sportsevent:server:stampSummit', function(summitId)
    local src = source
    local summitCfg = Config.Summits[summitId]
    if not summitCfg then return end

    -- Validasi jarak server-side ke titik puncak
    local ped = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(ped)
    local targetCoords = vector3(summitCfg.summit.coords.x, summitCfg.summit.coords.y, summitCfg.summit.coords.z)
    if #(playerCoords - targetCoords) > 15.0 then
        return
    end

    local items = exports.ox_inventory:Search(src, 'slots', Config.PassportItem)
    if not items or #items == 0 then
        return TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Paspor tidak ditemukan di tas Anda!' })
    end

    local passport = items[1]
    local meta = passport.metadata or {}
    meta.stamps = meta.stamps or {}

    if meta.stamps[summitId] and meta.stamps[summitId].completed then
        return TriggerClientEvent('ox_lib:notify', src, { type = 'inform', description = 'Puncak ini sudah distempel sebelumnya.' })
    end

    -- Catat stempel baru
    meta.stamps[summitId] = {
        completed = true,
        timestamp = os.date('%d/%m/%Y %H:%M')
    }

    -- Hitung total stempel
    local count = 0
    for _, v in pairs(meta.stamps) do
        if v.completed then count = count + 1 end
    end
    meta.grandTotal = count
    meta.description = ('Pemegang: %s | No. Seri: %s | Stempel: %d/4'):format(meta.ownerName or 'Pendaki', meta.serialNumber or 'N/A', count)

    exports.ox_inventory:SetMetadata(src, passport.slot, meta)

    -- Berikan Badge Puncak Satuan
    exports.ox_inventory:AddItem(src, summitCfg.badgeItem, 1, {
        owner = meta.ownerName,
        summit = summitCfg.name,
        date = meta.stamps[summitId].timestamp,
        description = ('Dianugerahkan kepada %s pada %s'):format(meta.ownerName or 'Pendaki', meta.stamps[summitId].timestamp)
    })

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        title = 'Puncak Ditaklukkan!',
        description = ('Stempel %s sah! Anda memperoleh badge "%s" (%d/4 Puncak).'):format(summitCfg.name, summitCfg.badgeLabel, count),
        duration = 8000
    })
end)

-- Klaim Grand Badge "Four Summit Conqueror"
RegisterNetEvent('eco_sportsevent:server:claimGrandBadge', function()
    local src = source
    local identifier, charName = GetPlayerDetails(src)

    local items = exports.ox_inventory:Search(src, 'slots', Config.PassportItem)
    if not items or #items == 0 then
        return TriggerClientEvent('ox_lib:notify', src, { type = 'error', description = 'Bawa Buku Paspor Ekspedisi Anda!' })
    end

    local passport = items[1]
    local meta = passport.metadata
    if not meta or (meta.grandTotal or 0) < 4 then
        return TriggerClientEvent('ox_lib:notify', src, {
            type = 'error',
            description = ('Stempel belum lengkap (%d/4). Taklukkan keempat puncak terlebih dahulu!'):format(meta and meta.grandTotal or 0)
        })
    end

    if meta.claimedGrand then
        return TriggerClientEvent('ox_lib:notify', src, { type = 'inform', description = 'Paspor ini sudah pernah digunakan untuk klaim Grand Badge.' })
    end

    meta.claimedGrand = true
    meta.description = meta.description .. ' [CONQUEROR VERIFIED]'
    exports.ox_inventory:SetMetadata(src, passport.slot, meta)

    exports.ox_inventory:AddItem(src, Config.GrandBadgeItem, 1, {
        owner = meta.ownerName or charName,
        serial = meta.serialNumber,
        completedAt = os.date('%d/%m/%Y %H:%M'),
        description = ('Penakluk Resmi Four Summit San Andreas - %s'):format(meta.ownerName or charName)
    })

    -- Simpan ke Hall of Fame SQL
    MySQL.insert('INSERT IGNORE INTO eco_foursummit_hof (identifier, character_name, passport_serial, josiah_date, chiliad_date, gordo_date, chianski_date) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        identifier,
        meta.ownerName or charName,
        meta.serialNumber or 'FS-0000',
        meta.stamps.josiah and meta.stamps.josiah.timestamp or '-',
        meta.stamps.chiliad and meta.stamps.chiliad.timestamp or '-',
        meta.stamps.gordo and meta.stamps.gordo.timestamp or '-',
        meta.stamps.chianski and meta.stamps.chianski.timestamp or '-'
    })

    TriggerClientEvent('ox_lib:notify', src, {
        type = 'success',
        title = '🏆 FOUR SUMMIT CONQUEROR!',
        description = 'Selamat! Anda menerima Grand Badge "Four Summit" dan nama Anda terukir di Hall of Fame!',
        duration = 10000
    })
end)

-- Callback daftar Hall of Fame
lib.callback.register('eco_sportsevent:server:getHallOfFame', function()
    local result = MySQL.query.await('SELECT character_name, passport_serial, DATE_FORMAT(completed_at, "%d/%m/%Y") as completed_at FROM eco_foursummit_hof ORDER BY id ASC LIMIT 25')
    return result or {}
end)
