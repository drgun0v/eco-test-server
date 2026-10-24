Config = Config or {}

Config.Processing = {
    wheatMill = {
        id          = 'wheat_mill_1',
        label       = 'Grain Mill',
        coords      = vec3(2330.0, 5024.0, 44.0),
        radius      = 3.0,

        inputItem   = 'wheat_raw',
        inputPerRun = 5,
        outputItem  = 'flour_bag',
        outputCount = 1,
        time        = 10 * 1000, -- ms
    },
}
