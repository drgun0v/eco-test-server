local ActiveDrivers = {}

ESX.RegisterServerCallback('esx_busjob:startJob', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return cb(false, 'Data pemain tidak ditemukan.') end

    if ActiveDrivers[source] then
        return cb(false, 'Anda sedang dalam shift kerja bus.')
    end

    if xPlayer.getMoney() >= Config.Deposit then
        xPlayer.removeMoney(Config.Deposit, 'Bus Job Deposit')
        ActiveDrivers[source] = { hasDeposit = true, completed = false }
        cb(true, 'Deposit $' .. Config.Deposit .. ' berhasil ditarik. Selamat bertugas!')
    elseif xPlayer.getAccount('bank').money >= Config.Deposit then
        xPlayer.removeAccountMoney('bank', Config.Deposit, 'Bus Job Deposit')
        ActiveDrivers[source] = { hasDeposit = true, completed = false }
        cb(true, 'Deposit $' .. Config.Deposit .. ' ditarik dari bank. Selamat bertugas!')
    else
        cb(false, 'Uang Anda tidak mencukupi untuk membayar deposit $' .. Config.Deposit)
    end
end)

RegisterNetEvent('esx_busjob:finishRoute', function()
    local src = source
    if ActiveDrivers[src] then
        ActiveDrivers[src].completed = true
    end
end)

RegisterNetEvent('esx_busjob:returnBus', function(isQuit)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local session = ActiveDrivers[src]

    if not xPlayer or not session then return end

    if isQuit then
        if session.hasDeposit then
            xPlayer.addMoney(Config.Deposit, 'Bus Job Deposit Refund')
            TriggerClientEvent('esx:showNotification', src, 'Anda membatalkan rute. Deposit $' .. Config.Deposit .. ' dikembalikan. TIDAK MENDAPAT REWARD.')
        end
    else
        if session.completed then
            local totalPayout = Config.Deposit + Config.Reward
            xPlayer.addMoney(totalPayout, 'Bus Job Payout & Deposit')
            TriggerClientEvent('esx:showNotification', src, 'Shift selesai! Deposit $' .. Config.Deposit .. ' dikembalikan & Reward rute $' .. Config.Reward .. ' diterima.')
        else
            if session.hasDeposit then
                xPlayer.addMoney(Config.Deposit, 'Bus Job Deposit Refund')
                TriggerClientEvent('esx:showNotification', src, 'Rute belum selesai seluruhnya. Hanya deposit $' .. Config.Deposit .. ' yang dikembalikan.')
            end
        end
    end

    ActiveDrivers[src] = nil
end)

RegisterNetEvent('esx_busjob:timeoutRemove', function()
    local src = source
    local session = ActiveDrivers[src]
    if session then
        ActiveDrivers[src] = nil
        TriggerClientEvent('esx:showNotification', src, 'Bus ditarik oleh dinas perhubungan karena ditinggalkan terlalu lama. Deposit hangus.')
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    if ActiveDrivers[src] then
        ActiveDrivers[src] = nil
    end
end)

ESX.RegisterCommand('skipbusroute', 'admin', function(xPlayer, args, showError)
    if xPlayer then
        xPlayer.triggerEvent('esx_busjob:skipToLastStop')
    end
end, false, {help = 'Skip rute bus ke halte terakhir (Khusus Admin)'})