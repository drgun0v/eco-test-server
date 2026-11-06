Config = Config or {}

Config.Debug = false
Config.PassportPrice = 250
Config.PassportItem = 'summit_passport'
Config.GrandBadgeItem = 'badge_four_summit'

-- Batas kecepatan maksimal wajar jalan kaki/lari (m/s) untuk deteksi anti-teleport
Config.MaxFootSpeed = 14.5
-- Toleransi tidak sengaja masuk kendaraan (detik)
Config.VehicleGraceSeconds = 3

-- Pos Utama Ranger (Pembelian Paspor & Klaim Grand Reward)
Config.RangerStation = {
    coords = vector4(383.82, 794.52, 187.46, 180.0), -- Park Ranger Station (Beaver Bush / Chiliad Base)
    pedModel = `s_m_y_ranger_01`,
    blip = {
        enabled = true,
        sprite = 141,
        color = 25,
        scale = 0.85,
        label = 'San Andreas Ranger Station (Four Summit HQ)'
    }
}

-- Konfigurasi 4 Etape Puncak Gunung
Config.Summits = {
    ['josiah'] = {
        id = 'josiah',
        name = 'Mt. Josiah',
        elevation = '402m',
        badgeItem = 'badge_josiah',
        badgeLabel = 'Josiah Mountaineer',
        trailhead = {
            coords = vector4(-1501.45, 2975.12, 34.62, 20.0), -- Kaki bukit dekat Jembatan Zancudo / Route 68
            prop = `prop_sign_road_09d`,
            label = 'Trailhead: Mt. Josiah'
        },
        summit = {
            coords = vector4(-1226.40, 3849.85, 489.10, 115.0), -- Puncak Tertinggi Mt. Josiah
            prop = `prop_Box_wood05a`,
            label = 'Summit Box: Mt. Josiah'
        }
    },
    ['chiliad'] = {
        id = 'chiliad',
        name = 'Mt. Chiliad',
        elevation = '798m',
        badgeItem = 'badge_chiliad',
        badgeLabel = 'Chilliad Explorer',
        trailhead = {
            coords = vector4(413.10, 5572.40, 779.10, 165.0),
            trailheadBase = vector4(-477.92251586914, 5563.8305664062, 72.950317382812, 132.92263793945), -- Parkir Kaki Gunung Paleto
            prop = `prop_sign_road_09d`,
            label = 'Trailhead: Mt. Chiliad'
        },
        summit = {
            coords = vector4(501.76, 5604.50, 797.91, 175.0), -- Dek Observasi Puncak Chiliad
            prop = `prop_Box_wood05a`,
            label = 'Summit Box: Mt. Chiliad'
        }
    },
    ['gordo'] = {
        id = 'gordo',
        name = 'Mt. Gordo',
        elevation = '585m',
        badgeItem = 'badge_gordo',
        badgeLabel = 'Gordo Pioneer',
        trailhead = {
            coords = vector4(3310.15, 5176.40, 18.45, 65.0), -- Area El Gordo Lighthouse / Kaki Jalur Timur
            prop = `prop_sign_road_09d`,
            label = 'Trailhead: Mt. Gordo'
        },
        summit = {
            coords = vector4(2877.12, 5911.05, 369.60, 290.0), -- Puncak Pemancar Radio Mt. Gordo
            prop = `prop_Box_wood05a`,
            label = 'Summit Box: Mt. Gordo'
        }
    },
    ['chianski'] = {
        id = 'chianski',
        name = 'Mt. Chianski',
        elevation = '345m',
        badgeItem = 'badge_chianski',
        badgeLabel = 'Chianski Trekker',
        trailhead = {
            coords = vector4(2690.50, 2765.20, 37.80, 120.0), -- Area Bahu Jalan Dekat Palmer-Taylor / Davis Quartz
            prop = `prop_sign_road_09d`,
            label = 'Trailhead: Mt. Chianski'
        },
        summit = {
            coords = vector4(2996.45, 2979.10, 195.80, 45.0), -- Punggung Bukit Tertinggi Chianski Range
            prop = `prop_Box_wood05a`,
            label = 'Summit Box: Mt. Chianski'
        }
    }
}
