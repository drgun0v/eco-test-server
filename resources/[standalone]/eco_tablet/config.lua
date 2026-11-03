Config = {}

-- Pengaturan Item, Command & Keybind Pembuka iPad EcoTablet
Config.ItemName = 'eco_tablet'
Config.RequireItemForCommand = false
Config.Commands = { 'tablet', 'ecolink', 'ecotablet', 'ecocab' }
Config.DefaultKeybind = 'F4'

-- Animasi & Prop iPad saat dibuka
Config.TabletProp = `prop_cs_tablet`
Config.AnimDict = 'amb@code_human_in_bus_passenger_idles@female@tablet@idle_a'
Config.AnimName = 'idle_a'
Config.BoneIndex = 28422
Config.PropOffset = vector3(-0.05, 0.0, 0.0)
Config.PropRotation = vector3(0.0, 0.0, 0.0)

-- =========================================================================
-- KONFIGURASI PARAMETER OPERASIONAL ECOBUS (SINKRON DENGAN eco_bus v1.6.0)
-- =========================================================================
Config.BusTransit = {
    LineName = 'Los Santos EcoBus Multi-Route',
    HeadwaySeconds = 180,
    MaxBusesPerRoute = 2,
    TotalMaxBuses = 4,
    FarePrice = 15,
    TicketItem = 'bus_ticket',
    CruiseSpeed = 10.0,
    CornerSpeed = 7.5,
    DockingSpeed = 3.5,
    ArrivalDistance = 14.5,
    WaypointRadius = 15.0,
    WaitAtStopSeconds = 12
}

Config.BusRoutes = {
    [1] = {
        id = 1,
        shortName = 'Rute 1',
        name = 'Route 1 - Strawberry Loop',
        color = '#ff9f0a',
        headwaySeconds = 180,
        maxBuses = 2,
        nodes = {
            { id = 1, stopId = 1, name = 'Bus Depot',      coords = vector4(261.86267089844, -1217.6439208984, 29.434476852417, 269.24642944336), unloadAll = true,  isWaypoint = false },
            { id = 2, stopId = 2, name = 'Strawberry TOD', coords = vector4(265.42486572266, -1187.0051269531, 29.482809066772, 89.877502441406), unloadAll = false, isWaypoint = false },
            { id = 3, stopId = 3, name = 'Vespucci Blvd',  coords = vector4(359.0325012207, -1064.2998046875, 29.371976852417, 269.32781982422),  unloadAll = false, isWaypoint = false },
            { id = 4, stopId = 4, name = 'Crusade Rd',     coords = vector4(448.01779174805, -1251.4504394531, 30.2868309021, 91.012718200684),   unloadAll = false, isWaypoint = false }
        }
    },
    [2] = {
        id = 2,
        shortName = 'Rute 2',
        name = 'Route 2 - Downtown & Legion Loop',
        color = '#30d158',
        headwaySeconds = 180,
        maxBuses = 2,
        nodes = {
            { id = 1,  stopId = 1,   name = 'Bus Depot',            coords = vector4(261.86267089844, -1217.6439208984, 29.434476852417, 269.24642944336), unloadAll = true,  isWaypoint = false },
            { id = 2,  stopId = 2,   name = 'Strawberry TOD',       coords = vector4(265.42486572266, -1187.0051269531, 29.482809066772, 89.877502441406), unloadAll = false, isWaypoint = false },
            { id = 3,  stopId = 3,   name = 'Vespucci Blvd',        coords = vector4(359.0325012207, -1064.2998046875, 29.371976852417, 269.32781982422),  unloadAll = false, isWaypoint = false },
            { id = 4,  stopId = nil, name = 'WP Perempatan Sinner', coords = vector4(380.50936889648, -1055.0034179688, 29.234436035156, 0.0),             unloadAll = false, isWaypoint = true  },
            { id = 5,  stopId = nil, name = 'WP Masuk Sinner St',   coords = vector4(399.88677978516, -1033.7852783203, 29.436128616333, 0.0),             unloadAll = false, isWaypoint = true  },
            { id = 6,  stopId = 5,   name = 'Sinner St / MRPD',     coords = vector4(403.40435791016, -1005.8744506836, 29.314323425293, 358.88122558594), unloadAll = false, isWaypoint = false },
            { id = 7,  stopId = 6,   name = 'Sinner St North',      coords = vector4(410.40921020508, -774.57196044922, 29.185949325562, 359.95953369141), unloadAll = false, isWaypoint = false },
            { id = 8,  stopId = 7,   name = 'Dashound Terminal',    coords = vector4(409.44445800781, -698.26525878906, 29.199073791504, 359.42965698242), unloadAll = false, isWaypoint = false },
            { id = 9,  stopId = 8,   name = 'Pillbox Hill East',    coords = vector4(307.47039794922, -766.38092041016, 29.245018005371, 162.24298095703), unloadAll = false, isWaypoint = false },
            { id = 10, stopId = 9,   name = 'Legion Square North',  coords = vector4(236.56069946289, -829.05926513672, 30.011199951172, 69.423187255859), unloadAll = false, isWaypoint = false },
            { id = 11, stopId = 10,  name = 'Legion Square West',   coords = vector4(132.43704223633, -892.6025390625, 30.240404129028, 159.72193908691),  unloadAll = false, isWaypoint = false },
            { id = 12, stopId = nil, name = 'WP Perempatan Legion', coords = vector4(108.04764556885, -995.30279541016, 29.402669906616, 0.0),             unloadAll = false, isWaypoint = true  },
            { id = 13, stopId = nil, name = 'WP Masuk Legion',      coords = vector4(128.58917236328, -1019.3918457031, 29.315055847168, 0.0),             unloadAll = false, isWaypoint = true  },
            { id = 14, stopId = 11,  name = 'Vespucci & Elgin',     coords = vector4(145.64776611328, -1026.21875, 29.268972396851, 250.48806762695),      unloadAll = false, isWaypoint = false }
        }
    }
}

Config.BusStops = {
    { id = 1,  code = 'HLT-01', name = 'Bus Depot',           zone = 'Strawberry / Central Depot',     routes = { 1, 2 }, routeLabel = 'Rute 1 & Rute 2', coords = vector4(261.86267089844, -1217.6439208984, 29.434476852417, 269.24642944336), unloadAll = true,  transfer = 'Titik Transit Rute 1 (Strawberry) & Rute 2 (Downtown)' },
    { id = 2,  code = 'HLT-02', name = 'Strawberry TOD',      zone = 'Strawberry Ave',                 routes = { 1, 2 }, routeLabel = 'Rute 1 & Rute 2', coords = vector4(265.42486572266, -1187.0051269531, 29.482809066772, 89.877502441406),  unloadAll = false, transfer = 'Integrasi Stasiun Metro Strawberry (#4) + Rute 1 & 2' },
    { id = 3,  code = 'HLT-03', name = 'Vespucci Blvd',       zone = 'Pillbox / Vespucci',             routes = { 1, 2 }, routeLabel = 'Rute 1 & Rute 2', coords = vector4(359.0325012207, -1064.2998046875, 29.371976852417, 269.32781982422),   unloadAll = false, transfer = 'Percabangan Rute 1 (Crusade) & Rute 2 (MRPD / Legion)' },
    { id = 4,  code = 'HLT-04', name = 'Crusade Rd',          zone = 'Strawberry East / Crusade',     routes = { 1 },    routeLabel = 'Rute 1 - Strawberry Loop', coords = vector4(448.01779174805, -1251.4504394531, 30.2868309021, 91.012718200684), unloadAll = false, transfer = nil },
    { id = 5,  code = 'HLT-05', name = 'Sinner St / MRPD',     zone = 'Mission Row Police Dept',       routes = { 2 },    routeLabel = 'Rute 2 - Downtown & Legion Loop', coords = vector4(403.40435791016, -1005.8744506836, 29.314323425293, 358.88122558594), unloadAll = false, transfer = nil },
    { id = 6,  code = 'HLT-06', name = 'Sinner St North',      zone = 'Mission Row / Textile City',    routes = { 2 },    routeLabel = 'Rute 2 - Downtown & Legion Loop', coords = vector4(410.40921020508, -774.57196044922, 29.185949325562, 359.95953369141),  unloadAll = false, transfer = nil },
    { id = 7,  code = 'HLT-07', name = 'Dashound Terminal',    zone = 'Dashound Bus Center',           routes = { 2 },    routeLabel = 'Rute 2 - Downtown & Legion Loop', coords = vector4(409.44445800781, -698.26525878906, 29.199073791504, 359.42965698242),  unloadAll = false, transfer = 'Terminal Bus Antarkota Dashound' },
    { id = 8,  code = 'HLT-08', name = 'Pillbox Hill East',    zone = 'Pillbox Hill / Swiss St',       routes = { 2 },    routeLabel = 'Rute 2 - Downtown & Legion Loop', coords = vector4(307.47039794922, -766.38092041016, 29.245018005371, 162.24298095703), unloadAll = false, transfer = nil },
    { id = 9,  code = 'HLT-09', name = 'Legion Square North',  zone = 'Legion Square / Elgin Ave',     routes = { 2 },    routeLabel = 'Rute 2 - Downtown & Legion Loop', coords = vector4(236.56069946289, -829.05926513672, 30.011199951172, 69.423187255859),  unloadAll = false, transfer = nil },
    { id = 10, code = 'HLT-10', name = 'Legion Square West',   zone = 'Legion Square / Strawberry Ave', routes = { 2 },   routeLabel = 'Rute 2 - Downtown & Legion Loop', coords = vector4(132.43704223633, -892.6025390625, 30.240404129028, 159.72193908691),  unloadAll = false, transfer = nil },
    { id = 11, code = 'HLT-11', name = 'Vespucci & Elgin',     zone = 'Pillbox South / Vespucci Blvd', routes = { 2 },    routeLabel = 'Rute 2 - Downtown & Legion Loop', coords = vector4(145.64776611328, -1026.21875, 29.268972396851, 250.48806762695),      unloadAll = false, transfer = 'Dekat Stasiun Metro Pillbox South (#9)' }
}

Config.SubwayTransit = {
    LineName = 'Los Santos Transit Metro Loop',
    HeadwaySeconds = 240,
    MaxTrainsPerRoute = 2,
    FarePrice = 10,
    TicketItem = 'metro_ticket',
    CruiseSpeed = 20.0,
    WaitAtStationSeconds = 15
}

Config.MetroStations = {
    { id = 1,  code = 'STN-01', name = 'LSIA Terminal 4',      zone = 'Los Santos International Airport', coords = vector3(-1088.62, -2709.35, -7.41),  transfer = 'Akses Bandara Internasional LSIA' },
    { id = 2,  code = 'STN-02', name = 'LSIA Parking',         zone = 'LSIA Main Parking Plaza',          coords = vector3(-889.27, -2311.83, -11.73), transfer = nil },
    { id = 3,  code = 'STN-03', name = 'Puerto Del Sol',       zone = 'La Puerta / Marina',               coords = vector3(-536.81, -1286.07, 26.90),  transfer = nil },
    { id = 4,  code = 'STN-04', name = 'Strawberry Station',   zone = 'Strawberry Transit Hub',           coords = vector3(270.64, -1210.22, 38.90),   transfer = 'Integrasi Halte EcoBus Strawberry TOD (#2)' },
    { id = 5,  code = 'STN-05', name = 'Burton Station',       zone = 'Burton / Rockford Plaza',          coords = vector3(-294.75, -326.90, 10.06),   transfer = nil },
    { id = 6,  code = 'STN-06', name = 'Portola Drive',        zone = 'Rockford Hills',                   coords = vector3(-816.71, -137.65, 19.95),   transfer = nil },
    { id = 7,  code = 'STN-07', name = 'Del Perro Station',    zone = 'Del Perro Promenade',              coords = vector3(-1351.28, -467.89, 15.05),  transfer = nil },
    { id = 8,  code = 'STN-08', name = 'Little Seoul Station', zone = 'Little Seoul Central',             coords = vector3(-502.66, -673.41, 11.81),   transfer = nil },
    { id = 9,  code = 'STN-09', name = 'Pillbox South',        zone = 'Downtown / Pillbox Hill',          coords = vector3(-213.48, -1031.59, 30.14),  transfer = 'Dekat Halte EcoBus Vespucci & Elgin (#11)' },
    { id = 10, code = 'STN-10', name = 'Davis Station',        zone = 'Davis South',                      coords = vector3(112.31, -1724.63, 30.11),   transfer = nil }
}

-- =========================================================================
-- KONFIGURASI LAYANAN ECOCAB (UBER-STYLE 3 TIER)
-- Disinkronkan dengan eco_taxi/config.lua Config.Services
-- =========================================================================
Config.EcoCabServices = {
    ['ecoluxe'] = {
        id            = 'ecoluxe',
        name          = 'EcoLuxe',
        subtitle      = 'Autonomous Electric Sedan',
        model         = 'vivanite2',
        isAutonomous  = true,
        maxPassengers = 3,
        speedKmh      = 120,
        baseFare      = 30,
        pricePerKm    = 18,
        minFare       = 50,
        badge         = 'AI Driverless',
        icon          = 'sparkles'
    },
    ['ecocab'] = {
        id            = 'ecocab',
        name          = 'EcoCab',
        subtitle      = 'City Standard Taxi',
        model         = 'taxi',
        isAutonomous  = false,
        maxPassengers = 3,
        speedKmh      = 80,
        baseFare      = 25,
        pricePerKm    = 14,
        minFare       = 30,
        badge         = 'Driver Berpengalaman',
        icon          = 'taxi'
    },
    ['ecoride'] = {
        id            = 'ecoride',
        name          = 'EcoRide',
        subtitle      = 'Ojek Motor Hemat',
        model         = 'faggio',
        isAutonomous  = false,
        maxPassengers = 1,
        speedKmh      = 60,
        baseFare      = 0,
        pricePerKm    = 8,
        minFare       = 15,
        badge         = 'Cepat & Lincah',
        icon          = 'motorcycle'
    }
}

-- 50 Nama Orang Indonesia Acak untuk Driver EcoCab & EcoRide
Config.IndonesianDriverNames = {
    "Budi Santoso", "Agus Setiawan", "Rian Hidayat", "Eko Prasetyo", "Bambang Pamungkas",
    "Dedi Kurniawan", "Ahmad Fauzi", "Rizky Ramadhan", "Hendra Gunawan", "Fajar Pratama",
    "Doni Saputra", "Wahyu Nugroho", "Indra Wijaya", "Tri Handoko", "Bayu Wicaksono",
    "Ilham Firmansyah", "Asep Sunandar", "Yanto Sukirno", "Joko Susilo", "Aris Munandar",
    "Dimas Anggara", "Teguh Wibowo", "Nanang Suherman", "Surya Saputra", "Ade Iskandar",
    "Gilang Ramadhan", "Rudi Hartono", "Mulyadi", "Danang Priyanto", "Taufik Hidayat",
    "Andi Permana", "Cecep Supriatna", "Ujang Suhendar", "Iman Sulaeman", "Guntur Pratama",
    "Bagus Setiadi", "Yoga Pratama", "Panji Kusuma", "Galih Rakasiwi", "Lukman Hakim",
    "Rahmat Hidayat", "Samsul Bahri", "Zulham Efendi", "Herman Darmawan", "Irfan Maulana",
    "Kurnia Sandi", "Faisal Basri", "Tomi Suwandi", "Hadi Prayitno", "Wawan Ridwan"
}

-- =========================================================================
-- KONFIGURASI DYNAMIC SURGE PRICING (ECOCAB)
-- =========================================================================
Config.SurgePricing = {
    Enabled = true,
    Multiplier = 1.25, -- Pengali reguler 1.25x saat cuaca buruk / malam hari
    NightHours = {
        Start = 22,    -- Mulai pukul 22:00 malam
        Finish = 5     -- Berakhir pukul 05:00 pagi
    },
    BadWeatherTypes = {
        [`RAIN`] = "Hujan Lebat",
        [`THUNDER`] = "Badai Petir",
        [`CLEARING`] = "Hujan Gerimis",
        [`BLIZZARD`] = "Badai Salju",
        [`SNOWLIGHT`] = "Hujan Salju"
    }
}

-- =========================================================================
-- KONFIGURASI PAKET LANGGANAN ECOVIP
-- =========================================================================
Config.EcoVIP = {
    Price           = 350,   -- Biaya langganan ($350)
    TripCount       = 30,    -- 30 voucher perjalanan diskon
    DurationDays    = 10,    -- Masa aktif voucher 10 hari sejak pembelian / perpanjangan
    DiscountPercent = 20,    -- Diskon 20% untuk semua layanan (EcoLuxe, EcoCab, EcoRide)
    SurgeMultiplier = 1.05   -- Proteksi surge pricing hemat x1.05 (normal x1.25)
}
