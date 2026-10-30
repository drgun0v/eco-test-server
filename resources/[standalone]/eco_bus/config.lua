Config = {}

Config.HeadwaySeconds = 180 -- Interval antar bus (ubah ke 420 untuk 7 menit)
Config.MaxBusesPerRoute = 3 -- Maksimal armada aktif

Config.TicketRequired = true
Config.TicketItem = 'bus_ticket'
Config.TicketAmount = 1
Config.FarePrice = 15
Config.UseCashIfNoItem = true

-- Konfigurasi Box Highlight (Zona Berhenti Bus di Aspal)
Config.DrawStopBox = true
Config.StopBoxSize = vector3(3.4, 13.5, 0.4) -- Lebar 3.4m, Panjang 13.5m
Config.StopBoxColor = { r = 255, g = 195, b = 0, a = 110 } -- Warna kuning/amber transit

Config.Bus = {
    Model = `bus`,
    DriverModel = `s_m_m_trucker_01`,
    Speed = 13.0,            -- Kecepatan jelajah stabil di dalam kota
    DockingSpeed = 4.5,      -- Kecepatan merayap masuk ke dalam box halte (m/s)
    DrivingStyle = 786603,   -- Taat lajur jalan & rambu selama jelajah
    ArrivalDistance = 15.0,  -- Jarak bus mulai ditarik masuk secara presisi ke dalam box
    PrecisionDistance = 0.5, -- Presisi akhir di titik tengah box (0.5 meter)
    WaitAtStopSeconds = 12,  -- Jeda tunggu halte
    StuckTimeoutSeconds = 15
}

-- Rute Halte (Menggunakan vector4: x, y, z, heading)
Config.RouteLoop = {
    { id = 1, name = 'Bus Depot',       coords = vector4(261.86267089844, -1217.6439208984, 29.434476852417, 269.24642944336), unloadAll = true },
    { id = 2, name = 'Strawberry TOD',  coords = vector4(265.42486572266, -1187.0051269531, 29.482809066772, 89.877502441406), unloadAll = false },
    { id = 3, name = 'Vespucci Blvd',   coords = vector4(359.0325012207, -1064.2998046875, 29.371976852417, 269.32781982422), unloadAll = false },
    { id = 4, name = 'Crusade Rd',      coords = vector4(448.01779174805, -1251.4504394531, 30.2868309021, 91.012718200684),   unloadAll = false }
}
