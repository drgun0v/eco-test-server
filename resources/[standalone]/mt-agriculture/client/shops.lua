CreateThread(function()
    local shop = Config.SeedShop
    if not shop then return end

    local model = shop.ped.model
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local ped = CreatePed(
        4,
        model,
        shop.ped.coords.x,
        shop.ped.coords.y,
        shop.ped.coords.z - 1.0,
        shop.ped.coords.w,
        false,
        true
    )

    SetModelAsNoLongerNeeded(model)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)

    if not Config.Farming.useTarget then return end

    exports.ox_target:addLocalEntity(ped, {
        {
            name  = 'mt_agri_seedshop_open',
            icon  = 'fa-solid fa-seedling',
            label = 'Buy Seeds',
            onSelect = function()
                -- Fix: Use 'type' + 'id' (id is 1 because we only added 1 location in server.lua)
                exports.ox_inventory:openInventory('shop', { type = shop.id, id = 1 })
            end
        }
    })
end)
