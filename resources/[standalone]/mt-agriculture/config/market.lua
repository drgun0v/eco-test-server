Config = Config or {}

Config.Market = {
    buyerPed = {
        model  = `cs_old_man1`,
        coords = vec4(147.0, -1039.0, 29.3, 250.0),
    },
    prices = {
        wheat_raw = 8,
        flour_bag = 60,
    }
}

Config.SeedShop = {
    id    = 'farm_supply',
    label = 'Farm Supply',
    ped   = {
        model  = `cs_old_man2`,
        coords = vec4(2473.846191, 4445.077148, 35.613208, 272.125977),
    },
    items = {
        { name = 'wheat_seed', price = 5, count = 500 },
    }
}
