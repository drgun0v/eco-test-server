-- mt-restaurants/restaurants/wigwam.lua

local restaurantConfig = {
    enabled = true,
    label = 'Wigwam Burger',
    job = 'wigwam',
    ingredients = Config.ingredients.globalIngredients,
    maxIngredients = 6,
    maxRecipes = 10,
    maxRecipePrice = 30,
    blip = { enabled = true, coords = vec3(-853.36, -1140.7, 6.27), sprite = 106, color = 17, scale = 0.6, display = 4 },
    zone = {
        points = {
            vec3(-830.6, -1137.47, 7.70),
            vec3(-865.01, -1157.13, 7.70),
            vec3(-881.07, -1128.27, 7.70),
            vec3(-846.61, -1109.27, 7.70)
        },
        thickness = 15,
    },
    management = {
        { coords = vec3(-865.4, -1126.7, 7.05), radius = 0.6 },
    },
    stashes = {
        -- [1] Pass / Tray (For finished orders)
        { coords = vec3(-854.8, -1128.45, 7.8), radius = 0.6, label = 'Pass', slots = 50, weight = 500 },
        
        -- [2] Fridge (For RAW ingredients from market: Meat, Whole Lettuce, etc.)
        { coords = vec3(-853.2, -1119.85, 7.0), radius = 0.6, label = 'Fridge', slots = 50, weight = 500000 },
        
        -- [3] NEW: Prepped Ingredients (For Cut Lettuce, Sliced Tomato, etc.)
        -- I placed this near the Prep Station coords, feel free to move it!
        { coords = vec3(-852.1, -1126.3, 7.2), radius = 0.4, label = 'Prepped Ingredients', slots = 50, weight = 500000 },
    },
    trays = {
        { coords = vec3(-854.95, -1131.5, 7.3), radius = 0.5, label = 'Tray', slots = 10, weight = 100 },
        { coords = vec3(-854.8, -1126.5, 7.1), radius = 0.5, label = 'Tray', slots = 10, weight = 100 },
    },
    prepare = {
        -- PREP STATION: Takes from Fridge -> Puts in Prepped Stash
        { 
            coords = vec3(-853.75, -1122.85, 7.0), 
            radius = 0.5, 
            label = 'Prepare', 
            ingredients = Config.ingredients.globalIngredients, 
            anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer' },
            
            -- NEW ROUTING CONFIG
            drawsFrom = 'Fridge',            -- Takes raw items from here
            outputsTo = 'Prepped Ingredients' -- Puts cut items here
        },
    },
    stations = {
        -- DRINKS: Takes from Prepped Stash -> Puts in Order Box
        { 
            coords = vec3(-853.2, -1127.2, 7.3), 
            radius = 0.4, 
            label = 'Drinks Machine', 
            type = 'drink', 
            anim = { dict = 'anim@amb@nightclub@mini@drinking@drinking_shots@ped_a@normal', clip = 'pour_one' },
            
            -- NEW ROUTING CONFIG
            drawsFrom = 'Prepped Ingredients',   -- Takes lemons/ice from fridge
            outputsTo = 'SmartBox'  -- Puts finished drinks in Order Box
        },

        -- GRILL: Takes from Prepped -> Puts in Order Box
        { 
            coords = vec3(-857.95, -1125.95, 7.2), 
            radius = 0.4, 
            label = 'Grill', 
            type = 'food', 
            anim = { dict = 'amb@prop_human_bbq@male@idle_a', clip = 'idle_b' }, 
            prop = { bone = 28422, model = 'prop_fish_slice_01', pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
            
            -- NEW ROUTING CONFIG
            drawsFrom = 'Prepped Ingredients', -- Takes cut lettuce/tomato/patties
            outputsTo = 'SmartBox'             -- Puts finished burger in Order Box
        },
                { 
            coords = vec3(-853.7, -1129.3, 7.5), 
            radius = 0.4, 
            label = 'Drinks Machine', 
            type = 'drink', 
            anim = { dict = 'anim@amb@nightclub@mini@drinking@drinking_shots@ped_a@normal', clip = 'pour_one' },
            
            -- NEW ROUTING CONFIG
            drawsFrom = 'Prepped Ingredients',   -- Takes lemons/ice from fridge
            outputsTo = 'SmartBox'  -- Puts finished drinks in Order Box
        },
                -- DEEP FRY: Takes from Prepped -> Puts in Order Box
        { 
            coords = vector3(-856.53961181641, -1125.9609375, 7.2), 
            radius = 0.4, 
            label = 'Deep Fryer', 
            type = 'food', 
            anim = { dict = 'amb@prop_human_bbq@male@idle_a', clip = 'idle_b' }, 
            prop = { bone = 28422, model = 'prop_fish_slice_01', pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
            
            -- NEW ROUTING CONFIG
            drawsFrom = 'Prepped Ingredients', -- Takes cut lettuce/tomato/patties
            outputsTo = 'SmartBox'             -- Puts finished burger in Order Box
        },
    },
    registers = {
        { coords = vec3(-855.6, -1131.5, 7.25), radius = 0.4, label = 'Register', playersRadius = 5.0, comission = 5 }
    },
    menus = {
        { coords = vec3(-853.6, -1130.85, 7.35), radius = 0.35, label = 'Beanmachine Menu' },
    },
    offlineShop = {
        { coords = vec4(-857.85321044922, -1131.8392333984, 6.0, 173.24256896973), label = 'Shop', model = 's_f_y_sweatshop_01', scenario = 'WORLD_HUMAN_AA_COFFEE' },
    },
    boxes = {
        { coords = vec3(-854.45, -1130.5, 6.75), radius = 0.3 },
    },
    delivery = {
        { coords = vec3(-855.2, -1125.85, 7.2), radius = 0.25, priceLost = 0, comission = 8, cooldown = 8 },
    },
    music = {
        { coords = vec3(-859.53991699219, -1122.9346923828, 7.2743859291077), radius = 0.4, maxMusicRadius = 50.0, maxMusicVolume = 50},
    },
    chairs = {        
    },
    garage = { -- The restaurant garage
        {
            coords = vec4(-847.687927, -1128.131836, 5.987549, 300.472443+180), -- Garage prop spawn coords
            spawnCoords = vec4(-845.340637, -1126.800049, 7.038086, 300.472443), -- Vehicle spawn coords
            vehicles = {
                { icon = 'fas fa-car', label = 'Faggio', id = 'faggio' },
            },
        },
    },
}

AddRestaurant(restaurantConfig)