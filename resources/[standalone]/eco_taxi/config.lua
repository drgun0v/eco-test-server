Config = {}

-- =========================================================================
-- KONFIGURASI 3 KELAS LAYANAN ECOCAB (SINKRON DENGAN ECO_TABLET)
-- =========================================================================
Config.Services = {
    ['ecoluxe'] = {
        id            = 'ecoluxe',
        name          = 'EcoLuxe',
        subtitle      = 'Autonomous Electric Sedan',
        model         = `vivanite2`,
        isAutonomous  = true,
        driverModel   = `s_m_m_autoshop_01`, -- Ghost AI ped invisible
        maxPassengers = 3,
        maxSpeedKmh   = 120.0,
        cruiseSpeed   = 33.33, -- 120 km/h dalam m/s
        pickupSpeed   = 25.0,  -- ~90 km/h saat menjemput
        baseFare      = 30,    -- Biaya buka pintu $30
        pricePerKm    = 18,    -- Tarif $18/km
        minFare       = 50,    -- Tarif minimum $50
        plate         = 'LST-AI', -- Plat nomor khusus otonom sesuai UI eco_tablet
        isBike        = false,
        drivingStyle  = 524475
    },
    ['ecocab'] = {
        id            = 'ecocab',
        name          = 'EcoCab',
        subtitle      = 'City Standard Taxi',
        model         = `taxi`,
        isAutonomous  = false,
        driverModel   = `s_m_m_trucker_01`,
        maxPassengers = 3,
        maxSpeedKmh   = 80.0,
        cruiseSpeed   = 22.22, -- 80 km/h dalam m/s
        pickupSpeed   = 20.0,  -- ~72 km/h saat menjemput
        baseFare      = 25,    -- Biaya buka pintu $25
        pricePerKm    = 14,    -- Tarif $14/km
        minFare       = 30,    -- Tarif minimum $30
        plate         = 'B1945ECO', -- Sesuai dengan tampilan 'B 1945 ECO' di eco_tablet
        isBike        = false,
        drivingStyle  = 524475
    },
    ['ecoride'] = {
        id              = 'ecoride',
        name            = 'EcoRide',
        subtitle        = 'Ojek Motor Hemat',
        model           = `faggio`,
        isAutonomous    = false,
        driverModelPool = { `s_m_y_ammucity_01`, `ig_josef`, `ig_mp_agent14` }, -- Random ped sesuai spesifikasi
        maxPassengers   = 1,
        maxSpeedKmh     = 60.0,
        cruiseSpeed     = 16.67, -- 60 km/h dalam m/s
        pickupSpeed     = 16.67, -- 60 km/h saat menjemput
        baseFare        = 0,     -- Tidak ada biaya buka pintu ($0)
        pricePerKm      = 8,     -- Tarif $8/km
        minFare         = 15,    -- Tarif minimum $15
        plate           = 'B1945ECO', -- Sesuai dengan tampilan 'B 1945 ECO' di eco_tablet
        isBike          = true,
        drivingStyle    = 524475,
        gasEventChance  = 25,    -- 25% peluang mampir isi bensin di SPBU terdekat
        gasStopDuration = 8000   -- Durasi isi bensin (8 detik)
    }
}

-- Alias agar kompatibel jika dipanggil sebagai Config.EcoCabServices
Config.EcoCabServices = Config.Services

-- Fallback Pricing Default
Config.Pricing = {
    BaseFare = 25,
    PricePerKm = 14,
    MinimumFare = 30,
    WaitTimePricePerMin = 5
}

-- Pengaturan Navigasi Kendali Otonom & AI
Config.Drive = {
    CruiseSpeed = 22.22,
    PickupSpeed = 20.0,
    ApproachSpeed = 6.0,
    MaxSpeedKmh = 120.0,
    DrivingStyle = 524475,
    SpawnDistanceMin = 70.0,
    SpawnDistanceMax = 120.0,
    PickupRadius = 6.0,
    DestinationRadius = 8.0,
    WaitAtPickupSeconds = 60
}

-- Daftar Pom Bensin (SPBU) di Los Santos untuk Random Event EcoRide
Config.GasStations = {
    { name = "SPBU Strawberry / Innocence Blvd", coords = vector3(265.05, -1262.65, 29.3) },
    { name = "SPBU Grove St / Davis",            coords = vector3(-70.94, -1761.88, 29.53) },
    { name = "SPBU Clinton Ave / Vinewood",      coords = vector3(620.83, 268.53, 103.09) },
    { name = "SPBU Mirror Park Blvd",            coords = vector3(1181.38, -330.85, 69.32) },
    { name = "SPBU El Rancho Blvd / Murrieta",   coords = vector3(1208.61, -1402.57, 35.22) },
    { name = "SPBU Lindsay Circus / Little Seoul", coords = vector3(-724.56, -935.97, 19.21) },
    { name = "SPBU Korean Plaza / Little Seoul", coords = vector3(-525.68, -1211.23, 18.18) },
    { name = "SPBU Del Perro Blvd / Rockford",   coords = vector3(-1437.04, -276.74, 46.21) },
    { name = "SPBU Great Ocean Hwy / Del Perro", coords = vector3(-2096.34, -320.24, 13.17) },
    { name = "SPBU Spanish Ave / West Vinewood", coords = vector3(179.85, -1558.12, 29.3) }
}

-- Daftar 50 Nama Driver Indonesia (Sinkron dengan eco_tablet) & Pemetaan Plat Nomor Unik
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

-- Fungsi Helper Menghasilkan Plat Nomor Sesuai Database Driver eco_tablet
-- Default UI eco_tablet menampilkan 'LST-AI' untuk EcoLuxe dan 'B 1945 ECO' (GTA Plate: B1945ECO) untuk Driver
Config.UseTabletExactPlate = true -- Jika true, menggunakan 'LST-AI' & 'B1945ECO' persis seperti kartu UI eco_tablet

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
