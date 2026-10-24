

--- ######################### ---
--- ## DISCORD.GG/CODEWAVE ## ---
--- ######################### ---


--- ### BBQ SCRIPT BY DISCORD.GG/CODEWAVE ### ---

Config = {}
Config.Framework = 'ESX' -- 'ESX' or 'QBCore' (case sensitive)
Config.InteractionType = 'ox_target' -- ox_target | 3dtext
Config.UseOxTargetForNpc = true -- Set to true to enable ox_target, false to use key press interaction
Config.TimeToCraft = 8000
Config.DebugMode = true  -- Set to true to enable debug messages


Config.OnlyFemales = false  -- Enable or disable the restriction to only allow male peds
Config.FemalePedModels = {
    GetHashKey("mp_m_freemode_01"),  -- Male freemode character
    GetHashKey("mp_f_freemode_01")  -- Female freemode character
}

Config.NPC = {
    Model = "a_f_m_soucentmc_01", -- Change to your desired NPC model
    Coords = vector3(53.1397, -1478.7578, 28.2871), -- Change to your desired NPC spawn location
    Heading = 182.0, -- Adjust the heading as needed
    BlipSprite = 52,        -- Example blip icon, see https://wiki.rage.mp/index.php?title=Blips for blip IDs
    BlipScale = 1.0,
    BlipColour = 81,
    BlipName = "BBQ Cook Up Store"
}


    -- Add anything you want here (For example if you want a new required item you can add it here for them to purchase!)
    Config.Items = {
        { name = "BBQ Grill", id = "bbq_grill", img = "image/bbq_grill.png", price = 100 }, -- You don't really need too touch anything apart from PRICE
        { name = "Gazebo", id = "gazebo", img = "image/gazebo.png", price = 200 },
        { name = "Outside Chair", id = "chair", img = "image/chair.png", price = 100 },
        { name = "Flood Light", id = "flood_light", img = "image/flood_light.png", price = 100 },
        { name = "Table", id = "table", img = "image/table.png", price = 100 },
        { name = "Soda Machine Maker", id = "soda_machine", img = "image/soda_machine.png", price = 100 },

        { name = "Raw Ribs", id = "raw_ribs", img = "image/raw_ribs.png", price = 300 },
        { name = "Raw Beef Brisket", id = "raw_beef_brisket", img = "image/raw_beef_brisket.png", price = 100 },
        { name = "Pork Joint", id = "pork_joint", img = "image/pork_joint.png", price = 100 },
        { name = "Raw Pork Sausages", id = "raw_sausages", img = "image/raw_sausages.png", price = 100 },
        { name = "Raw Short Ribs", id = "raw_short_ribs", img = "image/raw_short_ribs.png", price = 100 },
        { name = "Raw Lamb Chops", id = "lamb_chops", img = "image/lamb_chops.png", price = 100 },
        { name = "Raw Ribeye Steak", id = "ribeye_steak", img = "image/ribeye_steak.png", price = 100 },
        { name = "Raw Chicken Thigh", id = "chicken_thigh", img = "image/chicken_thigh.png", price = 100 },
        { name = "Raw Turkey Drum Sticks", id = "raw_turkey_drums", img = "image/raw_turkey_drums.png", price = 100 },
        { name = "Corn Cob", id = "corn_cob", img = "image/corn_cob.png", price = 100 },
        { name = "Raw Kebab", id = "raw_kebab", img = "image/raw_kebab.png", price = 100 },
        { name = "Raw Chicken Wings", id = "raw_wings", img = "image/raw_wings.png", price = 300 },
        { name = "BBQ Seasoning", id = "bbq_seasoning", img = "image/bbq_seasoning.png", price = 100 },
        { name = "Empty Plastic Cup", id = "empty_cup", img = "image/empty_cup.png", price = 100 },
        { name = "Big Bottle Of Cola", id = "big_bottle_cola", img = "image/big_bottle_cola.png", price = 100 },
        { name = "Big Bottle Of Lemonade", id = "big_bottle_lemonade", img = "image/big_bottle_lemonade.png", price = 100 },
        { name = "Big Bottle Of Tide", id = "big_bottle_tide", img = "image/big_bottle_tide.png", price = 100 }

    }
--####################################################################--
--### THE FIELD "YIELD" IS HOW MANY COOKED ITEMS THEY WILL RECEIVE ###--
--####################################################################--

    Config.CraftingRecipes = {
        { name = "Cooked BBQ Ribs", id = "cooked_ribs", img = "image/cooked_ribs.png", requiredItems = { { id = "raw_ribs", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 },
        { name = "Cooked BBQ Brisket", id = "cooked_brisket", img = "image/cooked_brisket.png", requiredItems = { { id = "raw_beef_brisket", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 },
        { name = "Cooked Pork Joint", id = "cooked_pork_joint", img = "image/cooked_pork_joint.png", requiredItems = { { id = "pork_joint", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 },
        { name = "Cooked BBQ Sausages", id = "cooked_bbq_sausages", img = "image/cooked_bbq_sausages.png", requiredItems = { { id = "raw_sausages", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 },
        { name = "Cooked Short Ribs", id = "cooked_short_ribs", img = "image/cooked_short_ribs.png", requiredItems = { { id = "raw_short_ribs", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 },
        { name = "Cooked Lamb Chops", id = "cooked_lamb_chops", img = "image/cooked_lamb_chops.png", requiredItems = { { id = "lamb_chops", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 },
        { name = "Cooked BBQ Ribeye", id = "cooked_bbq_ribeye", img = "image/cooked_bbq_ribeye.png", requiredItems = { { id = "ribeye_steak", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 },
        { name = "Cooked BBQ Thigh", id = "cooked_bbq_thigh", img = "image/cooked_bbq_thigh.png", requiredItems = { { id = "chicken_thigh", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 },
        { name = "Cooked Turkey Drum Stick", id = "cooked_turkey_drum", img = "image/cooked_turkey_drum.png", requiredItems = { { id = "raw_turkey_drums", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 },
        { name = "Cooked Corn Cob", id = "cooked_corn_cob", img = "image/cooked_corn_cob.png", requiredItems = { { id = "corn_cob", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 },
        { name = "Cooked Kebab", id = "cooked_kebab", img = "image/cooked_kebab.png", requiredItems = { { id = "raw_kebab", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 },
        { name = "Cooked BBQ Wings", id = "cooked_bbq_wings", img = "image/cooked_bbq_wings.png", requiredItems = { { id = "raw_wings", quantity = 1 }, { id = "bbq_seasoning", quantity = 1 } }, yield = 1 }
    }

    -- This is for DRINKS, Teas/Coffees/Sodas/Ect
    Config.CraftingRecipesDrinks = {
        { name = "Cup Of Cola", id = "cup_cola", img = "image/cup_cola.png", requiredItems = { { id = "empty_cup", quantity = 5 }, { id = "big_bottle_cola", quantity = 1 } }, yield = 5 },
        { name = "Cup Of Lemonade", id = "cup_lemonade", img = "image/cup_lemonade.png", requiredItems = { { id = "empty_cup", quantity = 5 }, { id = "big_bottle_lemonade", quantity = 1 } }, yield = 5 },
        { name = "Cup Of Tide", id = "cup_tide", img = "image/cup_tide.png", requiredItems = { { id = "empty_cup", quantity = 5 }, { id = "big_bottle_tide", quantity = 1 } }, yield = 5 }

    }
    

Config.PlayMusicWhileUIIsOpen = false --- True = music plays, False = music doesn't. (YOU CAN CHANGE MUSIC IN SOUNDS FILE)
Config.MusicVolume = 0.05 --- Music volume in the menu, Only applies if above is set to True


--- ALL THESE ITEMS ARE FOR COSMETIC EFFECTS ONLY (YOU CAN ADD AS MANY AS YOU WISH) --
-- Install instructions - the first field "gazebo" would be the item you would add to your inventory, the other field is the prop it will use --

---  VERY IMPORTANT. THE INTERACTABLE FIELD SHOUD ALL REMAIN FALSE APART FROM THE DEFAULT TRUE ONE (WHICH IS SODA MACHINE & BBQ GRILL) ---
Config.PlaceableProps = {
    ["gazebo"] = {model = "benjifilmz_codewave_bbq", interactable = false},               -- Gazebo
    ["flood_light"] = {model = "prop_worklight_03b", interactable = false},    -- Portable floodlight for night events
    ["bbq_grill"] = {model = "benjifilmz_codewave_grill", interactable = true},    -- Portable floodlight for night events
    ["chair"] = {model = "prop_chair_01b", interactable = false},              -- Chair
    ["table"] = {model = "prop_ven_market_table1", interactable = false},     -- Table
    ["soda_machine"] = {model = "prop_food_bs_soda_02", interactable = true},     -- Table

}


