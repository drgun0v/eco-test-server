Config = {}

-- =========================================================================
-- 3 KELAS LAYANAN ECOCAB (UBER-STYLE)
-- =========================================================================
Config.Services = {
    ['ecoluxe'] = {
        name = 'EcoLuxe',
        model = `vivanite2`,
        isAutonomous = true,
        driverModel = `s_m_m_autoshop_01`, -- Ghost AI ped invisible
        maxPassengers = 3,
        speedKmh = 120.0,
        cruiseSpeed = 33.3, -- ~120 km/h (m/s)
        baseFare = 30,
        pricePerKm = 18,
        minFare = 50,
        isBike = false,
        drivingStyle = 524475
    },
    ['ecocab'] = {
        name = 'EcoCab',
        model = `taxi`,
        isAutonomous = false,
        driverModel = `s_m_m_trucker_01`,
        maxPassengers = 3,
        speedKmh = 80.0,
        cruiseSpeed = 22.2, -- ~80 km/h (m/s)
        baseFare = 25,
        pricePerKm = 14,
        minFare = 30,
        isBike = false,
        drivingStyle = 524475
    },
    ['ecoride'] = {
        name = 'EcoRide',
        model = `faggio`,
        isAutonomous = false,
        driverModelPool = { `s_m_y_ammucity_01`, `ig_josef`, `ig_mp_agent14` },
        maxPassengers = 1,
        speedKmh = 60.0,
        cruiseSpeed = 16.6, -- ~60 km/h (m/s)
        baseFare = 0,
        pricePerKm = 8,
        minFare = 15,
        isBike = true,
        drivingStyle = 524475,
        -- Event Random: Mampir Pom Bensin (18% chance)
        gasEventChance = 18,
        gasStopDuration = 8000 -- 8 detik di dispenser SPBU
    }
}

-- Pengaturan Navigasi Kendali Otonom & AI Driver
Config.Drive = {
    ApproachSpeed = 6.0,
    SpawnDistanceMin = 70.0,
    SpawnDistanceMax = 120.0,
    PickupRadius = 6.0,
    DestinationRadius = 8.0,
    WaitAtPickupSeconds = 60
}

-- Lokasi SPBU di Los Santos untuk Random Event EcoRide
Config.GasStations = {
    { name = "SPBU Strawberry / Innocence Blvd", coords = vector3(265.05, -1262.65, 29.3) },
    { name = "SPBU Grove St / Davis",           coords = vector3(-70.94, -1761.88, 29.53) },
    { name = "SPBU Clinton Ave / Vinewood",     coords = vector3(620.83, 268.53, 103.09) },
    { name = "SPBU Mirror Park",                coords = vector3(1181.38, -330.85, 69.32) },
    { name = "SPBU El Rancho Blvd / Murrieta",  coords = vector3(1208.61, -1402.57, 35.22) },
    { name = "SPBU Lindsay Circus / Little Seoul", coords = vector3(-724.56, -935.97, 19.21) },
    { name = "SPBU Korean Plaza / Little Seoul", coords = vector3(-525.68, -1211.23, 18.18) },
    { name = "SPBU Del Perro Blvd / Rockford",  coords = vector3(-1437.04, -276.74, 46.21) },
    { name = "SPBU Great Ocean Hwy / Del Perro", coords = vector3(-2096.34, -320.24, 13.17) },
    { name = "SPBU Spanish Ave / Vinewood",     coords = vector3(179.85, -1558.12, 29.3) }
}

-- Daftar Destinasi Cepat Populer untuk Aplikasi EcoCab di Tablet
Config.QuickDestinations = {
    { id = 1,  name = 'Pillbox Hill Medical Center', coords = vector3(308.20, -595.34, 43.28) },
    { id = 2,  name = 'Mission Row Police Station',  coords = vector3(426.97, -979.88, 30.71) },
    { id = 3,  name = 'Legion Square Central',       coords = vector3(195.42, -934.12, 30.69) },
    { id = 4,  name = 'Strawberry TOD Transit Hub',  coords = vector3(265.42, -1187.01, 29.48) },
    { id = 5,  name = 'LSIA Terminal 4 Airport',     coords = vector3(-1037.28, -2737.89, 20.17) },
    { id = 6,  name = 'Del Perro Pier Entrance',     coords = vector3(-1635.85, -1004.22, 13.02) },
    { id = 7,  name = 'Vinewood Boulevard Cinema',   coords = vector3(302.91, 155.88, 103.85) },
    { id = 8,  name = 'Diamond Casino & Resort',     coords = vector3(924.96, 47.12, 81.10) },
    { id = 9,  name = 'Sandy Shores City Hall',      coords = vector3(1853.12, 3687.21, 34.27) },
    { id = 10, name = 'Paleto Bay Bank & Square',    coords = vector3(-110.82, 6467.45, 31.63) }
}