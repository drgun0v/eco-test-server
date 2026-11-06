local spawnedPeds = {}
local spawnedProps = {}

-- Fungsi helper spawn ped
function SpawnEventPed(model, coords)
    lib.requestModel(model)
    local ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, coords.w, false, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    table.insert(spawnedPeds, ped)
    return ped
end

-- Fungsi helper spawn prop
function SpawnEventProp(model, coords)
    lib.requestModel(model)
    local obj = CreateObject(model, coords.x, coords.y, coords.z - 1.0, false, false, false)
    SetEntityHeading(obj, coords.w or 0.0)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    table.insert(spawnedProps, obj)
    return obj
end

-- Buka NUI Paspor
RegisterNetEvent('eco_sportsevent:client:openPassportUI', function(passportData)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openPassport',
        data = passportData
    })
end)

RegisterNUICallback('closePassport', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Cleanup saat resource direstart
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, ped in ipairs(spawnedPeds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    for _, prop in ipairs(spawnedProps) do
        if DoesEntityExist(prop) then DeleteEntity(prop) end
    end
end)
