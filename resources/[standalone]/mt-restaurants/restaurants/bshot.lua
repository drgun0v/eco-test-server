-- mt-restaurants/restaurants/lplucker.lua

local restaurantConfig = {
    enabled = true,
    label = 'Burger Shot Murrieta',
    job = 'bshot',
    ingredients = Config.ingredients.globalIngredients,
    maxIngredients = 6,
    maxRecipes = 10,
    maxRecipePrice = 30,
    blip = { enabled = true, coords = vec3(1119.9072265625, -868.20538330078, 52.29955291748), sprite = 106, color = 3, scale = 0.6, display = 4 },
    zone = {
        points = {
            vec3(1099.4102783203, -853.9365234375, 51.633270263672),
            vec3(1152.5964355469, -856.06536865234, 54.05451965332),
            vec3(1148.3582763672, -902.71313476562, 51.672241210938),
            vec3(1100.2485351562, -902.4267578125, 52.348514556885)
        },
        thickness = 15,
    },
    management = {
        { coords = vec3(1124.9967041016, -893.58624267578, 52.2), radius = 0.6 },
    },
    stashes = {
        -- [1] Pass / Tray (For finished orders)
        { coords = vec3(1114.6, -880.7, 52.5), radius = 0.4, label = 'Pass', slots = 50, weight = 500 },
        
        -- [2] Fridge (For RAW ingredients from market: Meat, Whole Lettuce, etc.)
        { coords = vec3(1112.3, -888.4, 52.3), radius = 0.6, label = 'Fridge', slots = 50, weight = 500000 },
        
        -- [3] NEW: Prepped Ingredients (For Cut Lettuce, Sliced Tomato, etc.)
        -- I placed this near the Prep Station coords, feel free to move it!
        { coords = vec3(1109.2, -878.7, 52.3), radius = 0.5, label = 'Prepped Ingredients', slots = 50, weight = 500000 },
    },
    trays = {
        { coords = vec3(1117.58, -884.40, 52.28), radius = 0.5, label = 'Tray', slots = 10, weight = 100 },
        { coords = vec3(1117.72, -880.82, 52.28), radius = 0.5, label = 'Tray', slots = 10, weight = 100 },
    },
    prepare = {
        -- PREP STATION: Takes from Fridge -> Puts in Prepped Stash
        { 
            coords = vec3(1109.2, -878.7, 52.3), 
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
            coords = vec3(1117.054, -878.09918212891, 52.61092376709), 
            radius = 0.6, 
            label = 'Drinks Machine', 
            type = 'drink', 
            anim = { dict = 'anim@amb@nightclub@mini@drinking@drinking_shots@ped_a@normal', clip = 'pour_one' },
            
            -- NEW ROUTING CONFIG
            drawsFrom = 'Prepped Ingredients',   -- Takes lemons/ice from fridge
            outputsTo = 'SmartBox'  -- Puts finished drinks in Order Box
        },

        -- GRILL: Takes from Prepped -> Puts in Order Box
        { 
            coords = vec3(1109.2, -881.8, 52.3), 
            radius = 0.5, 
            label = 'Grill', 
            type = 'food', 
            anim = { dict = 'amb@prop_human_bbq@male@idle_a', clip = 'idle_b' }, 
            prop = { bone = 28422, model = 'prop_fish_slice_01', pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
            
            -- NEW ROUTING CONFIG
            drawsFrom = 'Prepped Ingredients', -- Takes cut lettuce/tomato/patties
            outputsTo = 'SmartBox'             -- Puts finished burger in Order Box
        },
    },
    registers = {
        { coords = vec3(1117.3, -881.4, 52.5), radius = 0.4, label = 'Register', playersRadius = 5.0, comission = 5 },
        { coords = vec3(1117.3, -879.4, 52.5), radius = 0.4, label = 'Register', playersRadius = 5.0, comission = 5 },
    },
    offlineShop = {
        { coords = vec4(1117.0, -883.55169677734, 51.4, 273.8), label = 'Shop', model = 's_f_y_sweatshop_01', scenario = 'WORLD_HUMAN_AA_COFFEE' },
    },

    delivery = {
        { coords = vec3(1117.3, -881.4, 52.5), radius = 0.25, priceLost = 0, comission = 8, cooldown = 8 },
        { coords = vec3(117.3, -879.4, 52.5), radius = 0.25, priceLost = 0, comission = 8, cooldown = 8 },
    },
    music = {
        { coords = vec3(1117.3, -879.4, 52.5), radius = 0.4, maxMusicRadius = 50.0, maxMusicVolume = 50},
    },
    chairs = {

    },
    garage = {
        {
            coords = vec4(1133.920898, -856.167053, 51.30, 181.417328+180), -- Garage prop spawn coords
            spawnCoords = vec4(1137.6303710938, -858.12670898438, 52.31477355957, 171.50625610352), -- Vehicle spawn coords
            vehicles = {
                { icon = 'fas fa-car', label = 'Faggio', id = 'faggio' },
            },
        },
    },
}

AddRestaurant(restaurantConfig)