local ESX

CreateThread(function()
    if Config.Farming.framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    end
end)

local function PlayerHasJob(src, jobName)
    if not ESX then return false end
    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then return false end
    return xPlayer.job and xPlayer.job.name == (jobName or Config.Farming.jobName)
end

exports('PlayerHasJob', PlayerHasJob)
