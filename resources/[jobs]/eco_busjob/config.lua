Config = {}

Config.BusModel = 'bus'
Config.SpawnPoint = vector4(297.94, -1200.9, 29.19, 179.3)

Config.Deposit = 500
Config.Reward = 2720
Config.AbandonTimeout = 180 -- 3 Menit

UnloadType = {
    All = 1,
    Some = 2
}

Config.PassengerModels = {
    'a_m_m_business_01',
    'a_m_y_business_01',
    'a_f_y_business_01',
    'a_f_m_downtown_01',
    'a_m_y_skater_01',
    'a_f_y_tourist_01',
    'a_m_y_hipster_01',
    'a_f_y_gencaspat_01'
}

Config.MetroStops = {
    [1]  = {x = 265.52, y = -1217.26, z = 29.40, unloadType = UnloadType.All,  name = 'Terminal Keberangkatan', announceText = 'Departure Terminal'},
    [2]  = {x = 403.48, y = -974.07, z = 29.36, unloadType = UnloadType.Some, name = 'Kantor Polisi MRPD', announceText = 'Mission Row Police Station'},
    [3]  = {x = 429.94, y = -641.53, z = 28.50, unloadType = UnloadType.Some, name = 'Terminal Dashound', announceText = 'Dashound Bus Terminal'},
    [4]  = {x = 99.97, y = -317.38, z = 45.90, unloadType = UnloadType.Some, name = 'Occupation Avenue', announceText = 'Occupation Avenue'},
    [5]  = {x = 309.81, y = -263.62, z = 53.86, unloadType = UnloadType.Some, name = 'City Hall', announceText = 'City Hall'},
    [6]  = {x = 486.06, y = -4.93, z = 85.26, unloadType = UnloadType.Some, name = 'Meteor Street', announceText = 'Meteor Street'},
    [7]  = {x = 439.61, y = 122.99, z = 99.81, unloadType = UnloadType.Some, name = 'Vinewood Boulevard', announceText = 'Vinewood Boulevard'},
    [8]  = {x = 177.73, y = 218.72, z = 105.83, unloadType = UnloadType.Some, name = 'Downtown Vinewood', announceText = 'Downtown Vinewood'},
    [9]  = {x = -158.15, y = 263.53, z = 93.80, unloadType = UnloadType.Some, name = 'Eclipse Boulevard', announceText = 'Eclipse Boulevard'},
    [10] = {x = -315.89, y = 131.43, z = 67.46, unloadType = UnloadType.Some, name = 'Spanish Avenue', announceText = 'Spanish Avenue'},
    [11] = {x = -394.55, y = 33.74, z = 48.44, unloadType = UnloadType.Some, name = 'Eastbourne Way', announceText = 'Eastbourne Way'},
    [12] = {x = -565.08, y = -33.53, z = 43.15, unloadType = UnloadType.Some, name = 'Milton Road', announceText = 'Milton Road'},
    [13] = {x = -486.64, y = -198.83, z = 36.98, unloadType = UnloadType.Some, name = 'Abe Milton Parkway', announceText = 'Abe Milton Parkway'},
    [14] = {x = -245.96, y = -590.23, z = 34.13, unloadType = UnloadType.Some, name = 'Rumah Sakit LSMC', announceText = 'Los Santos Medical Center'},
    [15] = {x = -512.48, y = -648.54, z = 33.06, unloadType = UnloadType.Some, name = 'San Andreas Avenue', announceText = 'San Andreas Avenue'},
    [16] = {x = -656.62, y = -276.95, z = 35.66, unloadType = UnloadType.Some, name = 'Portola Drive', announceText = 'Portola Drive'},
    [17] = {x = -933.81, y = -127.83, z = 37.58, unloadType = UnloadType.Some, name = 'Boulevard Del Perro', announceText = 'Boulevard Del Perro'},
    [18] = {x = -1287.44, y = -52.79, z = 46.68, unloadType = UnloadType.Some, name = 'Dorset Drive', announceText = 'Dorset Drive'},
    [19] = {x = -1618.60, y = -234.42, z = 54.17, unloadType = UnloadType.Some, name = 'West Eclipse', announceText = 'West Eclipse'},
    [20] = {x = -1508.42, y = -405.11, z = 39.28, unloadType = UnloadType.Some, name = 'Prosperity Street', announceText = 'Prosperity Street'},
    [21] = {x = -1406.13, y = -566.79, z = 30.21, unloadType = UnloadType.Some, name = 'Marathon Avenue', announceText = 'Marathon Avenue'},
    [22] = {x = -1615.43, y = -975.80, z = 13.01, unloadType = UnloadType.Some, name = 'Red Desert Avenue', announceText = 'Red Desert Avenue'},
    [23] = {x = -1294.25, y = -933.35, z = 11.27, unloadType = UnloadType.Some, name = 'Los Santos Motel', announceText = 'Los Santos Motel'},
    [24] = {x = -1305.21, y = -1160.19, z = 5.09, unloadType = UnloadType.Some, name = 'Magellan Avenue', announceText = 'Magellan Avenue'},
    [25] = {x = -1167.66, y = -1471.11, z = 4.32, unloadType = UnloadType.Some, name = 'Aguja Street', announceText = 'Aguja Street'},
    [26] = {x = -1014.99, y = -1637.98, z = 4.51, unloadType = UnloadType.Some, name = 'Bay City Avenue', announceText = 'Bay City Avenue'},
    [27] = {x = -1082.24, y = -1408.48, z = 5.02, unloadType = UnloadType.Some, name = 'La Spada', announceText = 'La Spada'},
    [28] = {x = -917.06, y = -1217.31, z = 5.01, unloadType = UnloadType.Some, name = 'Palomino Avenue', announceText = 'Palomino Avenue'},
    [29] = {x = -713.93, y = -1213.96, z = 10.54, unloadType = UnloadType.Some, name = 'South Rockford', announceText = 'South Rockford Drive'},
    [30] = {x = -288.58, y = -1191.85, z = 23.58, unloadType = UnloadType.Some, name = 'Los Santos Depot', announceText = 'Los Santos Transit Depot'},
    [31] = {x = -291.16, y = -1298.05, z = 31.10, unloadType = UnloadType.Some, name = 'Alta Street', announceText = 'Alta Street'},
    [32] = {x = -156.64, y = -1515.49, z = 33.73, unloadType = UnloadType.Some, name = 'Carson Avenue', announceText = 'Carson Avenue'},
    [33] = {
        x = 268.63, y = -1187.53, z = 29.45, 
        unloadType = UnloadType.All,  
        name = 'Terminal Kedatangan Akhir', 
        announceText = 'Central Arrival Terminal, End of the Line. Please check your belongings and make sure nothing is left behind. Thank you for riding with us.'
    }
}