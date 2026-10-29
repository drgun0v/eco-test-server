Config = {}

-- Framework: 'auto', 'esx', 'qb'/'qbcore', 'qbox'/'qbx_core', or 'standalone'
Config.Framework = 'auto'

-- Inventory: 'auto', 'ox'/'ox_inventory', 'esx', 'qb'/'qbcore', 'qbox'/'qbx_core', or 'none'
-- In auto mode ox_inventory is preferred when it is running.
Config.Inventory = 'auto'

Config.Debug = false

Config.TicketRequired = true
Config.TicketItem = 'bus_ticket'
Config.TicketAmount = 1

Config.StartCooldownSeconds = 20

Config.Controls = {
    OpenMenu = 38, -- E
    Board = 23, -- F
    MenuAccept = 201, -- Enter
    MenuCancel = 177, -- Backspace
    MenuLeft = 174, -- Arrow left
    MenuRight = 175 -- Arrow right
}

Config.Bus = {
    Model = 'bus',
    DriverModel = 's_m_m_trucker_01',
    DriveSpeed = 17.0,
    DrivingStyle = 786603,
    ArrivalDistance = 15.0,
    DepartureDelaySeconds = 7,
    CleanupDelaySeconds = 30,
    RouteTimeoutSeconds = 900,
    StuckCheckSeconds = 12,
    StuckMinMoveDistance = 6.0,
    MaxStuckRecoveries = 5,
    MaxPassengers = 14
}

Config.BusStopDrawDistance = 18.0
Config.BusStopInteractDistance = 2.5
Config.BoardDistance = 7.5
Config.ServerStartDistance = 15.0
Config.ServerBoardDistance = 18.0
Config.MaxNodeDistance = 80.0
Config.ModelLoadTimeoutMs = 10000
Config.NetworkControlTimeoutMs = 3000
Config.SeatEnterTimeoutMs = 12000

Config.Blips = {
    BusStops = {
        enabled = true,
        sprite = 513,
        colour = 38,
        scale = 0.65,
        name = 'Bus Stop'
    },
    ActiveBus = {
        enabled = true,
        sprite = 513,
        colour = 5,
        scale = 0.75,
        name = 'City Bus'
    }
}

Config.BusStops = {
    { name = '59th Wabash', x = -177.46, y = -1703.52, z = 30.1 },
    { name = '59th Indiana', x = -71.64, y = -1547.37, z = 29.41 },
    { name = 'Legion Square', x = 304.28, y = -765.14, z = 29.31 },
    { name = 'Jungle Boys', x = -505.22, y = 23.47, z = 44.79 },
    { name = 'Jerk n Jam', x = -488.27, y = 263.31, z = 83.01 },
    { name = 'Golf Club Hills', x = -930.9, y = -119.49, z = 37.78 },
    { name = 'Legion Square', x = 304.28, y = -765.14, z = 29.31 },
    { name = 'Marshfield Garden', x = -1172.15, y = -949.7, z = 2.5 },
    { name = '78th Kingston Ave', x = 366.15, y = -1786.53, z = 29.17 },
    { name = '60th Calumet Ave', x = 774.13, y = -1754.74, z = 29.51 },
    { name = '46th Champlain', x = -116.46, y = -1282.05, z = 29.33 }
}
