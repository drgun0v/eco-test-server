CreateThread(function()
    local shop = Config.SeedShop
    if not shop then return end

    local inventory = {}

    for _, v in ipairs(shop.items or {}) do
        inventory[#inventory+1] = {
            name     = v.name,
            price    = v.price,
            count    = v.count,
            metadata = v.metadata or {}
        }
    end

    exports.ox_inventory:RegisterShop(shop.id, {
        name      = shop.label,
        inventory = inventory,
        -- WE ADD THE LOCATION HERE SO OX INVENTORY KNOWS WHERE IT IS
        locations = {
            vec3(shop.ped.coords.x, shop.ped.coords.y, shop.ped.coords.z)
        }
    })
end)