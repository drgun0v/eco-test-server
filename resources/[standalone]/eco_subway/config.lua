Config = {}

Config.HeadwaySeconds = 240 -- Interval antar kereta metro (4 menit)
Config.MaxTrainsPerRoute = 2 -- Maksimal rangkaian kereta aktif di jalur LST

-- Sistem Tiket / Tarif
Config.TicketRequired = true
Config.TicketItem = 'metro_ticket'
Config.TicketAmount = 1
Config.FarePrice = 10
Config.UseCashIfNoItem = true

-- Konfigurasi Kereta Metro (LST)
Config.Train = {
    Variation = 25,            -- Prioritas utama index variasi Metro (dilengkapi Auto-Purge gerbong kargo/tanker)
    Direction = true,          -- Arah sirkulasi rel
    CruiseSpeed = 20.0,        -- Kecepatan jelajah antar stasiun (~72 km/h)
    ApproachSpeed = 8.0,       -- Kecepatan saat memasuki area peron (~28 km/h)
    CrawlSpeed = 3.0,          -- Kecepatan merayap sebelum berhenti di peron
    ApproachRadius = 75.0,     -- Jarak mulai deselerasi masuk stasiun
    CrawlRadius = 28.0,        -- Jarak mulai merayap di peron
    StopRadius = 11.5,         -- Radius deteksi berhenti di peron
    WaitAtStationSeconds = 15, -- Durasi berhenti & buka pintu di stasiun (detik)
    DoorCloseWaitSeconds = 3,  -- Durasi penutupan pintu (tunggu sampai pintu rapat tertutup baru berangkat)
}

-- PENGATURAN BLIP & PAPAN INFORMASI ELEKTRONIK (PIDS)
Config.ShowStationBlips = false -- Sembunyikan semua ikon blip stasiun di map
Config.ShowTrainBlips = false   -- Sembunyikan blip posisi kereta bergerak di map
Config.DrawPlatformMarker = true -- Tampilkan PIDS (Layar LED Jadwal Real-Time) di atas peron stasiun
Config.PIDSDrawDistance = 28.0   -- Jarak maksimal pemain melihat layar PIDS di peron
Config.PIDSHeightOffset = 2.15   -- Ketinggian layar PIDS dari lantai peron (bisa disesuaikan)

-- Ketinggian duduk di bangku kabin
Config.DefaultSeatZ = 0.68

-- Daftar Offset Kursi Penumpang di Dalam Gerbong `metrotrain`
Config.SeatOffsets = {
    { offset = vector3(-0.85,  1.85, 0.68), heading = -90.0 },
    { offset = vector3(-0.85,  0.45, 0.68), heading = -90.0 },
    { offset = vector3(-0.85, -1.85, 0.68), heading = -90.0 },
    { offset = vector3(-0.85, -3.25, 0.68), heading = -90.0 },
    { offset = vector3( 0.85,  1.85, 0.68), heading =  90.0 },
    { offset = vector3( 0.85,  0.45, 0.68), heading =  90.0 },
    { offset = vector3( 0.85, -1.85, 0.68), heading =  90.0 },
    { offset = vector3( 0.85, -3.25, 0.68), heading =  90.0 },
}

-- Daftar 10 Stasiun Resmi Los Santos Transit (LST Metro Loop)
-- Anda dapat menambahkan `pidsCoords = vector3(x, y, z)` pada stasiun tertentu jika ingin menggeser posisi layar PIDS
Config.Stations = {
    { id = 1,  name = 'LSIA Terminal 4',      coords = vector3(-1088.62, -2709.35, -7.41) },
    { id = 2,  name = 'LSIA Parking',         coords = vector3(-889.27, -2311.83, -11.73) },
    { id = 3,  name = 'Puerto Del Sol',       coords = vector3(-536.81, -1286.07, 26.90) },
    { id = 4,  name = 'Strawberry Station',   coords = vector3(270.64, -1210.22, 38.90) },
    { id = 5,  name = 'Burton Station',       coords = vector3(-294.75, -326.90, 10.06) },
    { id = 6,  name = 'Portola Drive',        coords = vector3(-816.71, -137.65, 19.95) },
    { id = 7,  name = 'Del Perro Station',    coords = vector3(-1351.28, -467.89, 15.05) },
    { id = 8,  name = 'Little Seoul Station', coords = vector3(-502.66, -673.41, 11.81) },
    { id = 9,  name = 'Pillbox South',        coords = vector3(-213.48, -1031.59, 30.14) },
    { id = 10, name = 'Davis Station',        coords = vector3(112.31, -1724.63, 30.11) }
}
