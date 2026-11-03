Config = {}

Config.HeadwaySeconds = 180 -- Interval antar bus per rute (detik)
Config.MaxBusesPerRoute = 2 -- Maksimal armada aktif untuk MASING-MASING rute

Config.TicketRequired = true
Config.TicketItem = 'bus_ticket'
Config.TicketAmount = 1
Config.FarePrice = 15
Config.UseCashIfNoItem = true

-- Konfigurasi Visual Halte (Box Highlight dinonaktifkan)
Config.DrawStopBox = false
Config.DrawStopText = false
Config.StopBoxSize = vector3(3.4, 13.5, 0.4)
Config.StopBoxColor = { r = 255, g = 195, b = 0, a = 110 }

Config.Bus = {
    Model = `bus`,
    DriverModel = `s_m_m_trucker_01`,
    Speed = 10.0,               -- Kecepatan jelajah stabil di dalam kota (~36 km/jam)
    CornerSpeed = 7.5,          -- Kecepatan saat berbelok di persimpangan
    DockingSpeed = 3.5,         -- Kecepatan merayap masuk ke dalam titik halte (m/s)
    DrivingStyle = 524475,      -- Disiplin Lajur Ketat: Patuh arah jalan, tidak menyalip ke jalur lawan arah
    CornerDrivingStyle = 524475,-- Tetap patuh lajur saat berbelok
    ApproachOffset = 2.0,       -- Jarak offset di depan halte
    QueueStopDistance = 21.0,   -- Jarak bus ke-2 berhenti mengantri di belakang halte
    ClearanceDistance = 17.5,   -- Bus ke-1 harus sudah keluar sejauh 17.5m sebelum bus ke-2 boleh masuk halte
    ArrivalDistance = 14.5,     -- Jarak bus mulai ditarik masuk secara presisi ke titik halte
    WaypointRadius = 14.0,      -- Radius lolos waypoint
    PrecisionDistance = 0.5,    -- Presisi akhir di titik tengah halte (0.5 meter)
    WaitAtStopSeconds = 12,     -- Jeda tunggu halte
    StuckTimeoutSeconds = 15
}

-- =========================================================================
-- DAFTAR RUTE TERPISAH (MULTI-ROUTE SYSTEM)
-- =========================================================================
Config.Routes = {
    -- Rute 1: Rute Eksisting (Strawberry - Crusade Loop)
    [1] = {
        id = 1,
        name = 'Route 1 - Strawberry Loop',
        blipColor = 38,
        headwaySeconds = 180,
        maxBuses = 2,
        stops = {
            { id = 1, name = 'Bus Depot',       coords = vector4(261.86267089844, -1217.6439208984, 29.434476852417, 269.24642944336), unloadAll = true },
            { id = 2, name = 'Strawberry TOD',  coords = vector4(265.42486572266, -1187.0051269531, 29.482809066772, 89.877502441406), unloadAll = false },
            { id = 3, name = 'Vespucci Blvd',   coords = vector4(359.0325012207, -1064.2998046875, 29.371976852417, 269.32781982422), unloadAll = false },
            { id = 4, name = 'Crusade Rd',      coords = vector4(448.01779174805, -1251.4504394531, 30.2868309021, 91.012718200684),   unloadAll = false }
        }
    },

    -- Rute 2: Rute Baru (Downtown / Legion Square Corridor)
    [2] = {
        id = 2,
        name = 'Route 2 - Downtown & Legion Loop',
        blipColor = 46,
        headwaySeconds = 180,
        maxBuses = 2,
        stops = {
            { id = 1,  name = 'Bus Depot',                 coords = vector4(261.86267089844, -1217.6439208984, 29.434476852417, 269.24642944336), unloadAll = true },
            { id = 2,  name = 'Strawberry TOD',            coords = vector4(265.42486572266, -1187.0051269531, 29.482809066772, 89.877502441406), unloadAll = false },
            { id = 3,  name = 'Vespucci Blvd',             coords = vector4(359.0325012207, -1064.2998046875, 29.371976852417, 269.32781982422), unloadAll = false },
            -- Perbaikan Waypoint Belokan Sinner St (tetap di lajur selatan agar bus tidak U-turn!)
            { id = 4,  name = 'WP Menjelang Perempatan',   coords = vector4(390.45, -1063.20, 29.25, 270.0), isWaypoint = true },
            { id = 5,  name = 'WP Belok Kiri Sinner',      coords = vector4(401.85, -1050.50, 29.28, 355.0), isWaypoint = true },
            { id = 6,  name = 'WP Masuk Sinner St',        coords = vector4(402.50, -1030.00, 29.40, 360.0), isWaypoint = true },
            { id = 7,  name = 'Sinner St / MRPD',          coords = vector4(403.40435791016, -1005.8744506836, 29.314323425293, 358.88122558594), unloadAll = false },
            { id = 8,  name = 'Sinner St North',           coords = vector4(410.40921020508, -774.57196044922, 29.185949325562, 359.95953369141), unloadAll = false },
            { id = 9,  name = 'Dashound Terminal',         coords = vector4(409.44445800781, -698.26525878906, 29.199073791504, 359.42965698242), unloadAll = false },
            { id = 10, name = 'Pillbox Hill East',         coords = vector4(307.47039794922, -766.38092041016, 29.245018005371, 162.24298095703), unloadAll = false },
            { id = 11, name = 'Legion Square North',       coords = vector4(236.56069946289, -829.05926513672, 30.011199951172, 69.423187255859), unloadAll = false },
            { id = 12, name = 'Legion Square West',        coords = vector4(132.43704223633, -892.6025390625, 30.240404129028, 159.72193908691), unloadAll = false },
            { id = 13, name = 'WP Perempatan Legion',      coords = vector4(108.04764556885, -995.30279541016, 29.402669906616, 0.0), isWaypoint = true },
            { id = 14, name = 'WP Masuk Legion',           coords = vector4(128.58917236328, -1019.3918457031, 29.315055847168, 0.0), isWaypoint = true },
            { id = 15, name = 'Vespucci & Elgin',          coords = vector4(145.64776611328, -1026.21875, 29.268972396851, 250.48806762695),     unloadAll = false },
            -- Perbaikan Waypoint Belokan Elgin Ave Selatan (pandu bus masuk lajur barat yang sah, bukan lajur lawan arah!)
            { id = 16, name = 'WP Belok Elgin Selatan',    coords = vector4(118.50, -1045.20, 29.15, 180.0), isWaypoint = true },
            { id = 17, name = 'WP Lurus Elgin Selatan',    coords = vector4(118.20, -1085.00, 29.05, 180.0), isWaypoint = true }
        }
    }
}

Config.RouteLoop = Config.Routes[1].stops
