-- ## Interior Configurations
Config = {
    Debug = false, -- Set to true to enable debug prints
    ElevatorsEnabled = true, -- Set to false to disable all elevator logic (no markers, no blips, no menus)
    Locale = "en", -- Default locale for elevator menus and prompts (e.g., "en", "de")
    
    -- Custom Help Notify Function (optional)
    -- If set to nil, the default help notify will be used
    -- Example custom function:
    -- CustomHelpNotify = function(text)
    --     exports['your_notification']:ShowHelp(text)
    -- end
    CustomHelpNotify = nil, -- Set to your custom help notify function or nil for default

    -- EntitySets define the interior configurations for various locations
    EntitySets = {
        {
            name = "Laundromat Dollar Pills Paleto Bay",
            coords = vector3(-44.39701, 6453.24756, 32.15056),
            ipl = "tstudio_laundromat_paleto",
            entitySets = {
                {name = "door_open", enable = true}, -- Enable the door_open entity set
                {name = "door_closed", enable = false} -- Disable the door_closed entity set
            }
        }, {
            name = "Laundromat Dollar Pills Davis",
            coords = vector3(62.1981468, -1604.00537, 30.2375851),
            ipl = "tstudio_laundromat_dollar_pills",
            entitySets = {
                {name = "door_open", enable = false}, -- Disable the door_open entity set
                {name = "door_closed", enable = true} -- Enable the door_closed entity set
            }
        }, {
            name = "Laundromat Dollar Pills Banyon Canyon",
            coords = vector3(-3062.18, 630.528, 8.03883),
            ipl = "tstudio_laundromat_bc",
            entitySets = {
                {name = "door_open", enable = true}, -- Enable the door_open entity set
                {name = "door_closed", enable = false} -- Disable the door_closed entity set
            }
        }, {
            name = "Jurassic Jackpot",
            coords = vector3(-247.246368, -919.344238, 40.5292854),
            ipl = "johanni_jurassic_jackpot_milo",
            entitySets = {
                {name = "casino_table_yes_w_car_podium", enable = true}, -- Enable the casino_table_yes_w_car_podium entity set
                {name = "casino_table_no_w_car_podium", enable = false}, -- Enable the casino_table_no_w_car_podium entity set
                {name = "casino_table_yes", enable = false}, -- Enable the casino_table_yes entity set
                {name = "casino_table_no", enable = false} -- Disable the casino_table_no entity set
            }
        }, {
            name = "VHotel Estate",
            coords = vector3(-1354.21887, -1071.3999, 9.128438),
            ipl = "johanni_vhotel_milo_",
            entitySets = {
                {name = "r16_casino_slots_on", enable = true}, -- Enable the casino slots entity set
                {name = "r2_r3_pool_tables_on", enable = true} -- Enable the pool tables entity set
            }
        }, {
            name = "Fleeca Bank Vinewood",
            coords = vector3(-355.435852, -48.5326, 48.1063843),
            ipl = "uniqx_flecca_l1_milo_",
            entitySets = {
                {name = "fleeca_vaultprops", enable = true}, -- Enable the casino slots entity set
            }
        }, {
            name = "Fleeca Bank Vinewood (Lower Level)",
            coords = vector3(309.74646, -277.644165, 53.2345963),
            ipl = "uniqx_flecca_l2_milo_",
            entitySets = {
                {name = "fleeca_vaultprops", enable = true}, -- Enable the casino slots entity set
            }
        }, {
            name = "Fleeca Bank Legion Square",
            coords = vector3(145.416824, -1039.277, 28.4378834),
            ipl = "uniqx_flecca_l3_milo_",
            entitySets = {
                {name = "fleeca_vaultprops", enable = true}, -- Enable the casino slots entity set
            }
        }, {
            name = "Fleeca Bank Movie Studio",
            coords = vector3(-1216.7616, -333.000763, 36.85084),
            ipl = "uniqx_flecca_l4_milo_",
            entitySets = {
                {name = "fleeca_vaultprops", enable = true}, -- Enable the casino slots entity set
            }
        }, {
            name = "Fleeca Bank East Highway",
            coords = vector3(-2962.59131, 478.238037, 14.7668953),
            ipl = "uniqx_flecca_l5_milo_",
            entitySets = {
                {name = "fleeca_vaultprops", enable = true}, -- Enable the casino slots entity set
            }
        }, {
            name = "Fleeca Bank Sandy Shores",
            coords = vector3(1179.74475, 2706.985, 37.15784),
            ipl = "uniqx_flecca_l6_milo_",
            entitySets = {
                {name = "fleeca_vaultprops", enable = true}, -- Enable the casino slots entity set
            }
        },
        -- #########################################
        -- Pearls Resort Entity Set Configuration
        -- #########################################
        {
            name = "Villa Small Interior 01",
            coords = vector3(-1919.861694, -1461.563599, 2.169187),
            ipl = "tstudio_jhn_resort_int_villa_s_01_milo_",
            entitySets = {
                {name = "villa_s_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 02",
            coords = vector3(-1938.779663, -1500.747437, 2.169187),
            ipl = "tstudio_jhn_resort_int_villa_s_02_milo_",
            entitySets = {
                {name = "villa_s_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 03",
            coords = vector3(-1964.696533, -1518.412964, 2.169187),
            ipl = "tstudio_jhn_resort_int_villa_s_03_milo_",
            entitySets = {
                {name = "villa_s_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 04",
            coords = vector3(-1994.894653, -1474.635742, 2.169187),
            ipl = "tstudio_jhn_resort_int_villa_s_04_milo_",
            entitySets = {
                {name = "villa_s_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 05",
            coords = vector3(-1969.661743, -1458.650879, 2.169187),
            ipl = "tstudio_jhn_resort_int_villa_s_05_milo_",
            entitySets = {
                {name = "villa_s_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 06",
            coords = vector3(-2050.360840, -1427.984985, 2.169187),
            ipl = "tstudio_jhn_resort_int_villa_s_06_milo_",
            entitySets = {
                {name = "villa_s_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 07",
            coords = vector3(-2038.969727, -1400.422729, 2.169187),
            ipl = "tstudio_jhn_resort_int_villa_s_07_milo_",
            entitySets = {
                {name = "villa_s_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 08",
            coords = vector3(-2098.611572, -1406.019897, 2.169187),
            ipl = "tstudio_jhn_resort_int_villa_s_08_milo_",
            entitySets = {
                {name = "villa_s_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 09",
            coords = vector3(-2085.950684, -1377.324097, 2.169187),
            ipl = "tstudio_jhn_resort_int_villa_s_09_milo_",
            entitySets = {
                {name = "villa_s_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 10",
            coords = vector3(-2050.601318, -1351.971924, 2.169187),
            ipl = "tstudio_jhn_resort_int_villa_s_10_milo_",
            entitySets = {
                {name = "villa_s_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Large Interior 01",
            coords = vector3(-2062.492920, -1498.251099, 2.171660),
            ipl = "tstudio_jhn_resort_int_villa_l_01_milo_",
            entitySets = {
                {name = "villa_l_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Large Interior 02",
            coords = vector3(-2013.281982, -1518.893188, 2.171660),
            ipl = "tstudio_jhn_resort_int_villa_l_02_milo_",
            entitySets = {
                {name = "villa_l_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Villa Large Interior 03",
            coords = vector3(-2090.989990, -1453.017822, 2.171660),
            ipl = "tstudio_jhn_resort_int_villa_l_03_milo_",
            entitySets = {
                {name = "villa_l_props_yes", enable = true}, -- Enable this entity set
                {name = "villa_s_props_no", enable = false} -- Disable this entity set
            }
        },
        {
            name = "Pearls Restaurant",
            coords = vector3(-1934.319580, -1334.520142, 2.050076),
            ipl = "tstudio_jhn_resort_int_pearls_milo_",
            entitySets = {
                {name = "casino_table_slots_wheel_yes", enable = true}, -- Enable this entity set
                {name = "enable_3d_logos", enable = true}, -- Enable this entity set
            }
        },

        -- #########################################
        -- Cayo Perico Lagoon Entity Set Configuration
        -- #########################################
        {
            name = "Villa Small Interior 01",
            coords = vector3(4719.517090, -4835.916016, 2.169187),
            ipl = "tstudio_jhn_cayo_party_int_villa_s_01_milo_",
            entitySets = {
                {name = "decorations_villa_s_yes", enable = true}, -- Enable/Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 02",
            coords = vector3(4762.354980, -4821.987793, 2.169187),
            ipl = "tstudio_jhn_cayo_party_int_villa_s_02_milo_",
            entitySets = {
                {name = "decorations_villa_s_yes", enable = true}, -- Enable/Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 03",
            coords = vector3(4728.758301, -4863.995117, 2.169187),
            ipl = "tstudio_jhn_cayo_party_int_villa_s_03_milo_",
            entitySets = {
                {name = "decorations_villa_s_yes", enable = true}, -- Enable/Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 04",
            coords = vector3(4771.432129, -4849.894531, 2.169187),
            ipl = "tstudio_jhn_cayo_party_int_villa_s_04_milo_",
            entitySets = {
                {name = "decorations_villa_s_yes", enable = true}, -- Enable/Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 05",
            coords = vector3(4738.696289, -4897.474609, 2.169187),
            ipl = "tstudio_jhn_cayo_party_int_villa_s_05_milo_",
            entitySets = {
                {name = "decorations_villa_s_yes", enable = true}, -- Enable/Disable this entity set
            }
        },
        {
            name = "Villa Small Interior 06",
            coords = vector3(4783.766113, -4882.660156, 2.169187),
            ipl = "tstudio_jhn_cayo_party_int_villa_s_06_milo_",
            entitySets = {
                {name = "decorations_villa_s_yes", enable = true}, -- Enable/Disable this entity set
            }
        },
        {
            name = "Villa Large Interior 01",
            coords = vector3(4664.574707, -5023.058594, 2.171660),
            ipl = "tstudio_jhn_cayo_party_int_villa_l_01_milo_",
            entitySets = {
                {name = "decorations_villa_l_yes", enable = true}, -- Enable/Disable this entity set
            }
        },
        {
            name = "Villa Large Interior 02",
            coords = vector3(4697.878906, -5032.681152, 2.171660),
            ipl = "tstudio_jhn_cayo_party_int_villa_l_02_milo_",
            entitySets = {
                {name = "decorations_villa_l_yes", enable = true}, -- Enable/Disable this entity set
            }
        },
        {
            name = "Villa Large Interior 03",
            coords = vector3(4665.482910, -4961.603516, 2.171660),
            ipl = "tstudio_jhn_cayo_party_int_villa_l_03_milo_",
            entitySets = {
                {name = "decorations_villa_l_yes", enable = true}, -- Enable/Disable this entity set
            }
        },
        {
            name = "Villa Large Interior 04",
            coords = vector3(4689.266113, -4930.037598, 2.171660),
            ipl = "tstudio_jhn_cayo_party_int_villa_l_04_milo_",
            entitySets = {
                {name = "decorations_villa_l_yes", enable = true}, -- Enable/Disable this entity set
            }
        },

        -- #########################################
        -- MRPD Entity Set Configuration
        -- #########################################
        {
            name = "MRPD Main Interior",
            coords = vector3(459.153778, -991.8762, 34.5723877),
            ipl = "tstudio_mrpd_int_milo_",
            entitySets = {
                {name = "mrpd_int_logo_3d", enable = true}, -- Enable/Disable this entity set
                {name = "mrpd_int_logo_2d", enable = false} -- Enable/Disable this entity set
            }
        },
        {
            name = "MRPD Garage Interior",
            coords = vector3(459.153931, -991.876648, 22.57239),
            ipl = "tstudio_mrpd_garage_milo_",
            entitySets = {
                {name = "mrpd_garage_logo_3d", enable = true}, -- Enable/Disable this entity set
                {name = "mrpd_garage_logo_2d", enable = false} -- Enable/Disable this entity set
            }
        },
    },

    PrivacySwitch = {
        positions = {
            vector3(306.003, -568.511, 63.181), -- Office 1
            vector3(305.963, -568.432, 67.184), -- Office 2
            vector3(306.056, -568.902, 59.229) -- etc.
        },
        entitySetA = "r7_privacy_off",
        entitySetB = "r7_privacy_on",
        marker = {type = 6, r = 19, g = 87, b = 66, alpha = 100},
        range = 2
    },

    -- CompatibilityPatches define fixes for specific combinations of maps
    CompatibilityPatches = {
        -- ===========================================
        -- TStudio Maps Compatibility Patches
        -- ===========================================
        {
            name = "Fix for Opium Nights & LSI Square",
            requiredMaps = {"tstudio_opium_nights", "tstudio_lsi_square"},
            fixResource = "tstudio_zpatch_opium_lsis" -- Resource to apply the fix
        }, {
            name = "Fix for Opium Nights & Bennys Racetrack",
            requiredMaps = {"tstudio_opium_nights", "tstudio_bennys_racetrack"},
            fixResource = "tstudio_zpatch_opium_racetrack" -- Resource to apply the fix
        }, {
            name = "Fix for Opium Nights, Bennys Racetrack & LSI Square",
            requiredMaps = {
                "tstudio_opium_nights", "tstudio_lsi_square",
                "tstudio_bennys_racetrack"
            },
            fixResource = "tstudio_zpatch_opium_racetrack_lsis" -- Resource to apply the fix
        }, {
            name = "Fix for Missionrowpark, Kebabking, Tropical Heights & Legion",
            requiredMaps = {
                "tstudio_missionrow_park", "tstudio_legionsquare",
                "tstudio_tropical_heights", "tstudio_kebabking"
            },
            fixResource = "tstudio_zpatch_mrpark_kebab_th_ls" -- Resource to apply the fix
        }, {
            name = "Fix for Missionrowpark, Kebabking & Tropical Heights",
            requiredMaps = {
                "tstudio_missionrow_park", "tstudio_kebabking",
                "tstudio_tropical_heights"
            },
            fixResource = "tstudio_zpatch_mrpark_kebab_th" -- Resource to apply the fix
        }, {
            name = "Fix for Missionrowpark & Tropical Heights",
            requiredMaps = {
                "tstudio_missionrow_park", "tstudio_tropical_heights"
            },
            fixResource = "tstudio_zpatch_mrpark_th" -- Resource to apply the fix
        }, {
            name = "Fix for Missionrowpark, Legion & Tropical Heights",
            requiredMaps = {
                "tstudio_missionrow_park", "tstudio_tropical_heights",
                "tstudio_legionsquare"
            },
            fixResource = "tstudio_zpatch_mrpark_th_ls" -- Resource to apply the fix
        }, {
            name = "Fix for Missionrowpark, Kebabking & Legion",
            requiredMaps = {
                "tstudio_missionrow_park", "tstudio_kebabking",
                "tstudio_legionsquare"
            },
            fixResource = "tstudio_zpatch_mrpark_kebab_ls" -- Resource to apply the fix
        }, {
            name = "Fix for Missionrowpark & Legion",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_legionsquare"},
            fixResource = "tstudio_zpatch_mrpark_ls" -- Resource to apply the fix
        }, {
            name = "Fix for Missionrowpark & Reds Tuner",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_redstuner"},
            fixResource = "tstudio_zpatch_mrpark_reds" -- Resource to apply the fix
        }, {
            name = "Fix for Missionrowpark, Kebabking",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_kebabking"},
            fixResource = "tstudio_zpatch_mrpark_kebab" -- Resource to apply the fix
        }, {
            name = "Fix for Impound & Carrent",
            requiredMaps = {"tstudio_impound", "tstudio_carrent"},
            fixResource = "tstudio_zpatch_impound_carrent" -- Resource to apply the fix
        }, {
            name = "Fix for Missionrowpark & Impound",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_impound"},
            fixResource = "tstudio_zpatch_mrpark_impound" -- Resource to apply the fix
        }, {
            name = "Fix for Missionrowpark, Legionsquare, Tropical Heights & Mission Row PD ",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_legionsquare", "tstudio_tropical_heights", "tstudio_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_th_ls_mrpd" -- Resource to apply the fix
        }, {
            name = "Fix for Missionrowpark, Legionsquare, Tropical Heights, Kebab King & Mission Row PD ",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_legionsquare", "tstudio_tropical_heights", "tstudio_kebabking", "tstudio_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_th_kebab_ls_mrpd" -- Resource to apply the fix
        }, {
            name = "Fix for Legion Garage & Kebab",
            requiredMaps = {"tstudio_legionsquare_garage", "tstudio_kebabking"},
            fixResource = "tstudio_zpatch_garage_kebab" -- Resource to apply the fix
        }, {
            name = "Fix for Pillbox, Legion Garage & Kebab",
            requiredMaps = {
                "tstudio_pillbox_md", "tstudio_legionsquare_garage",
                "tstudio_kebabking"
            },
            fixResource = "tstudio_zpatch_pillbox_garage_kebab" -- Resource to apply the fix
        }, {
            name = "Fix for Pillbox & Legion Garage",
            requiredMaps = {"tstudio_pillbox_md", "tstudio_legionsquare_garage"},
            fixResource = "tstudio_zpatch_pillbox_garage" -- Resource to apply the fix
        }, {
            name = "Fix for Pillbox & Kebab",
            requiredMaps = {"tstudio_pillbox_md", "tstudio_kebabking"},
            fixResource = "tstudio_zpatch_pillbox_kebab" -- Resource to apply the fix
        }, {
            name = "Fix for Pillbox & Kebab",
            requiredMaps = {"tstudio_pillbox_md", "tstudio_kebabking"},
            fixResource = "tstudio_zpatch_pillbox_kebab" -- Resource to apply the fix
        },
        {
            name = "Fix for Mission Row Park & Jurassic Jackpot",
            requiredMaps = {"tstudio_jurassic_jackpot", "tstudio_missionrow_park"},
            fixResource = "tstudio_zpatch_mrpark_jj",
        },
        {
            name = "Fix for Aldente's & VHotel",
            requiredMaps = {"tstudio_aldentes", "tstudio_vhotel_estate"},
            fixResource = "tstudio_zpatch_aldentes_vhotel"
        },
        {
            name = "Fix for Paleto Bewo & Paleto Cardealer & Taxi",
            requiredMaps = {"tstudio_paleto_bewo", "tstudio_paleto_cardealer", "tstudio_taxi"},
            fixResource = "tstudio_zpatch_bw_cardealer_taxi",
        },
        {
            name = "Fix for Ammunation & Gabz PDM",
            requiredMaps = {"tstudio_ammunation", "cfx-gabz-pdm"},
            fixResource = "tstudio_zpatch_ammunation_gabz_pdm",
        },

        {
            name = "Fix for Legion Square & MRPD",
            requiredMaps = {"tstudio_legionsquare", "tstudio_mrpd"},
            fixResource = "tstudio_zpatch_ls_mrpd",
        },
        {
            name = "Fix for Mission Row Park & MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_mrpd",
        },
        {
            name = "Fix for Mission Row Park, Kebab, Legion Square & MRPD",
            requiredMaps = {"tstudio_legionsquare", "tstudio_kebabking", "tstudio_missionrow_park", "tstudio_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_kebab_ls_mrpd",
        },
        {
            name = "Fix for Mission Row Park, Kebab, Tropical Heights & MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_kebabking", "tstudio_tropical_heights", "tstudio_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_kebab_th_mrpd",
        },
        {
            name = "Fix for Mission Row Park, Legion Square & MRPD",
            requiredMaps = {"tstudio_legionsquare", "tstudio_missionrow_park", "tstudio_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_ls_mrpd",
        },
        {
            name = "Fix for Mission Row Park, Tropical Heights, Kebab, Legion Square & MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_tropical_heights", "tstudio_kebabking", "tstudio_legionsquare", "tstudio_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_th_kebab_ls_mrpd",
        },
        {
            name = "Fix for Mission Row Park, Tropical Height, Legion Square & MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_tropical_heights", "tstudio_legionsquare", "tstudio_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_th_ls_mrpd",
        },
        {
            name = "Fix for Mission Row Park, Tropical Height & MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_tropical_heights", "tstudio_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_th_mrpd",
        },
        {
            name = "Fix for Tropical Height & MRPD",
            requiredMaps = {"tstudio_tropical_heights", "tstudio_mrpd"},
            fixResource = "tstudio_zpatch_th_mrpd",
        },

        -- ===========================================
        -- Fiv3Devs Maps Compatibility Patches
        -- ===========================================
        {
            name = "Fix for Mission Row Park, Legion Square & Fiv3Devs Pillbox",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_legionsquare", "fiv3devs_pillbox"},
            fixResource = "tstudio_zpatch_mrpark_ls_fiv3dev_pillbox"
        },
        {
            name = "Fix for Kebab & Fiv3Devs Pillbox",
            requiredMaps = {"tstudio_kebabking", "fiv3devs_pillbox"},
            fixResource = "tstudio_zpatch_kebab_fiv3devs_pillbox"
        },
        {
            name = "Fix for Water XML of Pearls Resort & Fiv3Devs Pacific Bluffs",
            requiredMaps = {"tstudio_pearls_resort", "fiv3devs_pacificbluffs"},
            fixResource = "tstudio_zpatch_pearls_fiv3dev_bluffs_water"
        },

        -- ===========================================
        -- Kiiya Maps Compatibility Patches
        -- ===========================================

        { -- This patch is for the Mission Row Park, Legion Square, Tropical Heights & Kiiya MRPD
            name = "Fix for Mission Row Park, Legion Square, Tropical Heights & Kiiya MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_legionsquare", "tstudio_tropical_heights", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_ls_th_kiiya_mrpd"
        },
        { -- This patch is for the Mission Row Park & Kiiya MRPD
            name = "Fix for Mission Row Park & Kiiya MRPD",
            requiredMaps = {"tstudio_missionrow_park", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_kiiya_mrpd"
        },
        { -- This patch is for the Mission Row Park, Tropical Heights & Kiiya MRPD
            name = "Fix for Mission Row Park, Tropical Heights & Kiiya MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_tropical_heights", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_th_kiiya_mrpd"
        },
        { -- This patch is for the Kebabking & Kiiya MRPD
            name = "Fix for Kebabking & Kiiya MRPD",
            requiredMaps = {"tstudio_kebabking", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_kebab_kiiya_mrpd"
        },
        { -- This patch is for the Legion Square, Kebabking & Kiiya MRPD
            name = "Fix for Legion Square, Kebabking & Kiiya MRPD",
            requiredMaps = {"tstudio_legionsquare", "tstudio_kebabking", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_ls_kebab_kiiya_mrpd"
        },
        { -- This patch is for the Legion Square, Tropical Heights, Kebabking & Kiiya MRPD
            name = "Fix for Legion Square, Tropical Heights & Kebabking & Kiiya MRPD",
            requiredMaps = {"tstudio_legionsquare", "tstudio_tropical_heights", "tstudio_kebabking", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_ls_th_kebab_kiiya_mrpd"
        },
        { -- This patch is for the Kebabking, Tropical Heights & Kiiya MRPD
            name = "Fix for Kebabking, Tropical Heights & Kiiya MRPD",
            requiredMaps = {"tstudio_kebabking", "tstudio_tropical_heights", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_kebab_th_kiiya_mrpd"
        },
        { -- This patch is for the Legion Square & Kiiya MRPD
            name = "Fix for Legion Square & Kiiya MRPD",
            requiredMaps = {"tstudio_legionsquare", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_ls_kiiya_mrpd"
        },
        { -- This patch is for the Legion Square, Tropical Heights & Kiiya MRPD
            name = "Fix for Legion Square, Tropical Heights & Kiiya MRPD",
            requiredMaps = {"tstudio_legionsquare", "tstudio_tropical_heights", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_ls_th_kiiya_mrpd"
        },
        { -- This patch is for the Tropical Heights & Kiiya MRPD
            name = "Fix for Tropical Heights & Kiiya MRPD",
            requiredMaps = {"tstudio_tropical_heights", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_th_kiiya_mrpd"
        },
        { -- This patch is for the Mission Row Park, Legionsquare, Kebabking & Kiiya MRPD
            name = "Fix for Mission Row Park, Legionsquare, Kebabking & Kiiya MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_legionsquare", "tstudio_kebabking", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_ls_kebab_kiiya_mrpd"
        },
        { -- This patch is for the Mission Row Park, Legionsquare, Tropical Heights, Kebabking & Kiiya MRPD
            name = "Fix for Mission Row Park, Legionsquare, Tropical Heights, Kebabking & Kiiya MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_legionsquare", "tstudio_kebabking", "tstudio_tropical_heights", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_ls_kebab_th_kiiya_mrpd"
        },
        { -- This patch is for the Mission Row Park, Kebabking & Kiiya MRPD
            name = "Fix for Mission Row Park, Kebabking & Kiiya MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_kebabking", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_kebab_kiiya_mrpd"
        },
        { -- This patch is for the Mission Row Park, Kebabking, Tropical Heights & Kiiya MRPD
            name = "Fix for Mission Row Park, Kebabking, Tropical Heights & Kiiya MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_kebabking", "tstudio_tropical_heights", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_kebab_th_kiiya_mrpd"
        },
        { -- This patch is for the Mission Row Park, Legionsquare & Kiiya MRPD
            name = "Fix for Mission Row Park, Legionsquare & Kiiya MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_legionsquare", "kiiya_mrpd"},
            fixResource = "tstudio_zpatch_mrpark_ls_kiiya_mrpd"
        },

        -- ===========================================
        -- FM Maps Compatibility Patches
        -- ===========================================
        {
            name = "Fix for Legion Square & FM MRPD",
            requiredMaps = {"tstudio_legionsquare", "cfx-fm-mrpd"},
            fixResource = "tstudio_zpatch_ls_fm_mrpd"
        },
        {
            name = "Fix for Mission Row Park & FM MRPD",
            requiredMaps = {"tstudio_missionrow_park", "cfx-fm-mrpd"},
            fixResource = "tstudio_zpatch_mrpark_fm_mrpd"
        },
        {
            name = "Fix for Mission Row Park, Legion Square & FM MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_legionsquare", "cfx-fm-mrpd"},
            fixResource = "tstudio_zpatch_mrpark_ls_fm_mrpd"
        },
        {
            name = "Fix for Mission Row Park, Legion Square, Tropical Heights & FM MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_legionsquare", "tstudio_tropical_heights", "cfx-fm-mrpd"},
            fixResource = "tstudio_zpatch_mrpark_ls_th_fm_mrpd"
        },
        {
            name = "Fix for Mission Row Park, Tropical Heights & FM MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_tropical_heights", "cfx-fm-mrpd"},
            fixResource = "tstudio_zpatch_mrpark_th_fm_mrpd"
        },
        {
            name = "Fix for Tropical Heights & FM MRPD",
            requiredMaps = {"tstudio_tropical_heights", "cfx-fm-mrpd"},
            fixResource = "tstudio_zpatch_th_fm_mrpd"
        },
        {
            name = "Fix for Mission Row Park, Legion Square, Tropical Heights & Kebab & FM MRPD",
            requiredMaps = {"tstudio_missionrow_park", "tstudio_legionsquare", "tstudio_tropical_heights", "tstudio_kebabking", "cfx-fm-mrpd"},
            fixResource = "tstudio_zpatch_mrpark_ls_th_kebab_fm_mrpd"
        },

        -- ===========================================
        -- RTX Compatibility Patches
        -- ===========================================
        {
            name = "Fix for Pearls Resort & RTX Themepark DLC",
            requiredMaps = {"tstudio_pearls_resort", "rtx_themepark_dlc_objects"},
            fixResource = "tstudio_zpatch_pearls_rtx_themepark_dlc"
        },
        {
            name = "Fix for Pearls Resort & RTX Themepark",
            requiredMaps = {"tstudio_pearls_resort", "rtx_themepark_objects"},
            fixResource = "tstudio_zpatch_pearls_rtx_themepark"
        },

        -- ===========================================
        -- Ambitioneers Compatibility Patches
        -- ===========================================
        {
            name = "Fix for Water XML of Pearls Resort & Ambitioneers Roxwood",
            requiredMaps = {"tstudio_pearls_resort", "amb-roxwood-map"},
            fixResource = "tstudio_zpatch_pearls_ambitioneers_roxwood_water"
        },
        {
            name = 'Fix for Mission Row Park & Ambitioneers Rags&Riches',
            requiredMaps = { 'amb-lslive-main-patches', 'tstudio_missionrow_park' },
            fixResource = 'tstudio_zpatch_rr_amb_mrpark',
        },
        {
            name = 'Fix for Legion Square & Mission Row Park & Ambitioneers Rags&Riches',
            requiredMaps = { 'amb-lslive-main-patches', 'tstudio_legionsquare', 'tstudio_missionrow_park' },
            fixResource = 'tstudio_zpatch_rr_amb_ls_mrpark',
        },
        {
            name = 'Fix for Legion Square & Ambitioneers Rags&Riches',
            requiredMaps = { 'amb-lslive-main-patches', 'tstudio_legionsquare' },
            fixResource = 'tstudio_zpatch_rr_amb_ls',
        },
    },

    -- Section for automatic floor ipl loading configurations
    FloorConfigs = {
        pillbox = {
            resourceName = "tstudio_pillbox_md", -- Added name for debug purposes
            center = vector3(306.003, -568.511, 63.181), -- Center of the area for checking player position
            floors = {
                [0] = {height = 64.159, ipls = {"johanni_pillbox_e03_01_milo_"}},
                [1] = {height = 68.162, ipls = {"johanni_pillbox_e03_02_milo_"}},
                [2] = {height = 60.025, ipls = {"johanni_pillbox_e03_03_milo_"}}
            }
        },
        opium = {
            resourceName = "tstudio_opium_nights", -- Added name for debug purposes
            center = vector3(-720.0305, -2268.00635, 16.2695923), -- Center of the area for checking player position
            floors = {
                [0] = {
                    height = 28.00,
                    ipls = {
                        "johanni_opium_penthouse_e01_milo_",
                        "johanni_opium_hallway_e01_milo_",
                        "johanni_opium_hotel_e01_r01_milo_",
                        "johanni_opium_hotel_e01_r02_milo_",
                        "johanni_opium_hotel_e01_r03_milo_",
                        "johanni_opium_hotel_e01_r04_milo_",
                        "johanni_opium_hotel_e01_r05_milo_",
                        "johanni_opium_hotel_e01_r06_milo_",
                        "johanni_opium_hotel_e01_r07_milo_",
                        "johanni_opium_hotel_e01_r08_milo_",
                        "johanni_opium_hotel_e01_r09_milo_",
                        "johanni_opium_hotel_e01_r10_milo_",
                        "johanni_opium_hotel_e01_r11_milo_",
                        "johanni_opium_hotel_e01_r12_milo_"
                    }
                },
                [1] = {
                    height = 38.14,
                    ipls = {
                        "johanni_opium_penthouse_e02_milo_",
                        "johanni_opium_hallway_e02_milo_",
                        "johanni_opium_hotel_e02_r01_milo_",
                        "johanni_opium_hotel_e02_r02_milo_",
                        "johanni_opium_hotel_e02_r03_milo_",
                        "johanni_opium_hotel_e02_r04_milo_",
                        "johanni_opium_hotel_e02_r05_milo_",
                        "johanni_opium_hotel_e02_r06_milo_",
                        "johanni_opium_hotel_e02_r07_milo_",
                        "johanni_opium_hotel_e02_r08_milo_",
                        "johanni_opium_hotel_e02_r09_milo_",
                        "johanni_opium_hotel_e02_r10_milo_",
                        "johanni_opium_hotel_e02_r11_milo_",
                        "johanni_opium_hotel_e02_r12_milo_"
                    }
                },
                [2] = {
                    height = 47.04,
                    ipls = {
                        "johanni_opium_penthouse_e03_milo_",
                        "johanni_opium_hallway_e03_milo_",
                        "johanni_opium_hotel_e03_r01_milo_",
                        "johanni_opium_hotel_e03_r02_milo_",
                        "johanni_opium_hotel_e03_r03_milo_",
                        "johanni_opium_hotel_e03_r04_milo_",
                        "johanni_opium_hotel_e03_r05_milo_",
                        "johanni_opium_hotel_e03_r06_milo_",
                        "johanni_opium_hotel_e03_r07_milo_",
                        "johanni_opium_hotel_e03_r08_milo_",
                        "johanni_opium_hotel_e03_r09_milo_",
                        "johanni_opium_hotel_e03_r10_milo_",
                        "johanni_opium_hotel_e03_r11_milo_",
                        "johanni_opium_hotel_e03_r12_milo_"
                    }
                },
                [3] = {
                    height = 55.88,
                    ipls = {
                        "johanni_opium_penthouse_e04_milo_",
                        "johanni_opium_hallway_e04_milo_",
                        "johanni_opium_hotel_e04_r01_milo_",
                        "johanni_opium_hotel_e04_r02_milo_",
                        "johanni_opium_hotel_e04_r03_milo_",
                        "johanni_opium_hotel_e04_r04_milo_",
                        "johanni_opium_hotel_e04_r05_milo_",
                        "johanni_opium_hotel_e04_r06_milo_",
                        "johanni_opium_hotel_e04_r07_milo_",
                        "johanni_opium_hotel_e04_r08_milo_",
                        "johanni_opium_hotel_e04_r09_milo_",
                        "johanni_opium_hotel_e04_r10_milo_",
                        "johanni_opium_hotel_e04_r11_milo_",
                        "johanni_opium_hotel_e04_r12_milo_"
                    }
                },
                [4] = {
                    height = 64.55,
                    ipls = {
                        "johanni_opium_penthouse_e05_milo_",
                        "johanni_opium_hallway_e05_milo_",
                        "johanni_opium_hotel_e05_r01_milo_",
                        "johanni_opium_hotel_e05_r02_milo_",
                        "johanni_opium_hotel_e05_r03_milo_",
                        "johanni_opium_hotel_e05_r04_milo_",
                        "johanni_opium_hotel_e05_r05_milo_",
                        "johanni_opium_hotel_e05_r06_milo_",
                        "johanni_opium_hotel_e05_r07_milo_",
                        "johanni_opium_hotel_e05_r08_milo_",
                        "johanni_opium_hotel_e05_r09_milo_",
                        "johanni_opium_hotel_e05_r10_milo_",
                        "johanni_opium_hotel_e05_r11_milo_",
                        "johanni_opium_hotel_e05_r12_milo_"
                    }
                },
                [5] = {
                    height = 73.35,
                    ipls = {
                        "johanni_opium_penthouse_e06_milo_",
                        "johanni_opium_hallway_e06_milo_",
                        "johanni_opium_hotel_e06_r01_milo_",
                        "johanni_opium_hotel_e06_r02_milo_",
                        "johanni_opium_hotel_e06_r03_milo_",
                        "johanni_opium_hotel_e06_r04_milo_",
                        "johanni_opium_hotel_e06_r05_milo_",
                        "johanni_opium_hotel_e06_r06_milo_",
                        "johanni_opium_hotel_e06_r07_milo_",
                        "johanni_opium_hotel_e06_r08_milo_",
                        "johanni_opium_hotel_e06_r09_milo_",
                        "johanni_opium_hotel_e06_r10_milo_",
                        "johanni_opium_hotel_e06_r11_milo_",
                        "johanni_opium_hotel_e06_r12_milo_"
                    }
                }
            }
        }
    },

    -- Interior blocking configurations
    -- Each interior can be configured with the following properties:
    -- coords: The coordinates of the interior
    -- interiorName: The name of the interior to disable
    -- enabled: Whether this interior blocking is enabled
    -- resourceDependency: (Optional) Only disable this interior if the specified resource is started
    --                     This prevents breaking default interiors when custom resources aren't loaded
    Interiors = {
        ["tstudio_tattoo_studio"] = {
            [1] = { enabled = true, name = "v_tattoo", coords = vec3(-3171.2937, 1076.24451, 19.8303947) },
            [2] = { enabled = true, name = "v_tattoo", coords = vec3(322.967865, 181.942917, 102.587761) },
            [3] = { enabled = true, name = "v_tattoo", coords = vec3(1323.765, -1653.43164, 51.27684) },
            [4] = { enabled = true, name = "v_tattoo", coords = vec3(-1153.18408, -1427.0127, 3.955685) },
        },
        ["tstudio_ammunation"] = {
            [1] = { enabled = true, name = "v_gun", coords = vec3(821.144043, -2154.8916, 28.61892) },      -- Cypress
            [2] = { enabled = true, name = "v_gun2", coords = vec3(843.2987, -1028.10669, 27.1947746) },    -- LaMesa
            [3] = { enabled = true, name = "v_gun", coords = vec3(10.9070005, -1105.65833, 28.7969322) },   -- Legion
            [4] = { enabled = true, name = "v_gun2", coords = vec3(247.371582, -47.245163, 68.9409943) },   -- Hawick
            [5] = { enabled = true, name = "v_gun2", coords = vec3(-1310.87659, -392.009644, 35.6957169) }, -- MorningWood
            [6] = { enabled = true, name = "v_gun2", coords = vec3(-663.1717, -940.758057, 20.8291473) },   -- Little Seoul
            [7] = { enabled = true, name = "v_gun2", coords = vec3(-3167.29614, 1084.70984, 19.8386574) },  -- Chumash
            [8] = { enabled = true, name = "v_gun2", coords = vec3(2568.834, 299.788116, 107.734818) },     -- East Highway
            [9] = { enabled = true, name = "v_gun2", coords = vec3(1696.95251, 3755.445, 33.7052574) },     -- Sandy Shores
            [10] = { enabled = true, name = "v_gun2", coords = vec3(-327.1706, 6079.257, 30.4546967) },     -- Paleto Bay
            [11] = { enabled = true, name = "v_gun2", coords = vec3(-1114.84509, 2693.80957, 17.55406) }    -- Route 68
        },
        ["tstudio_fleeca"] = {
            [1] = { enabled = true, name = "v_genbank", coords = vec3(-355.435852, -48.5326, 48.1063843) },    -- Vinewood
            [2] = { enabled = true, name = "v_genbank", coords = vec3(309.74646, -277.644165, 53.2345963) },   -- Vinewood (Lower Level)
            [3] = { enabled = true, name = "v_genbank", coords = vec3(145.416824, -1039.277, 28.4378834) },    -- Legion Square
            [4] = { enabled = true, name = "v_genbank", coords = vec3(-1216.7616, -333.000763, 36.85084) },    -- Movie Studio
            [5] = { enabled = true, name = "hei_generic_bank_dlc", coords = vec3(-2962.59131, 478.238037, 14.7668953) },  -- West Highway
            [6] = { enabled = true, name = "v_genbank", coords = vec3(1179.74475, 2706.985, 37.15784) }        -- Sandy Shores
        },
        ["tstudio_pillbox_md"] = {
            [1] = { enabled = true, name = "rc12b_default", ipl = "rc12b_default", coords = vec3(307.1680, -590.807, 43.280) },    -- Pillbox Hill
        },
        ["tstudio_mrpd"] = {
            [1] = { enabled = true, name = "hei_heist_police_dlc", ipl = "hei_heist_police_dlc", coords = vec3(442.429565, -985.067, 29.8852863) },    -- preparation for MRPD
            [2] = { enabled = true, name = "v_policehub", ipl = "v_policehub", coords = vec3(442.429565, -985.0669, 29.8852863) },    -- preparation for MRPD        },
        },
    },

    -- Dry Volume configurations
    -- Dry volumes prevent water from rendering in specific areas
    -- Each project can have multiple dry volumes defined by min/max coordinates
    DryVolumes = {
        ["tstudio_missionrow_park"] = {
            {
                name = "Mission Row Park IPL Patch Fix 1",
                minX = 337.012115,
                minY = -1013.49805,
                minZ = -100.221939,
                maxX = 353.21637,
                maxY = -992.301636,
                maxZ = -97.20087
            },
            {
                name = "Mission Row Park IPL Patch Fix 2",
                minX = 281.538,
                minY = -1002.9624,
                minZ = -100.007484,
                maxX = 313.910767,
                maxY = -984.104553,
                maxZ = -90.30185
            }
        },
        -- Example for multiple dry volumes in one project:
        -- ["project_name"] = {
        --     {
        --         name = "Area 1",
        --         minX = x1, minY = y1, minZ = z1,
        --         maxX = x2, maxY = y2, maxZ = z2
        --     },
        --     {
        --         name = "Area 2",
        --         minX = x1, minY = y1, minZ = z1,
        --         maxX = x2, maxY = y2, maxZ = z2
        --     }
        -- }
    }
}
