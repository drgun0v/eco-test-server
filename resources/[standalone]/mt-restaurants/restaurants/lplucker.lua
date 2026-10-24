-- mt-restaurants/restaurants/lplucker.lua

local restaurantConfig = {
    enabled = true,
    label = 'Lucky Plucker',
    job = 'lplucker',
    ingredients = Config.ingredients.globalIngredients,
    maxIngredients = 6,
    maxRecipes = 10,
    maxRecipePrice = 30,
    blip = { enabled = true, coords = vec3(-584.84552001953, -870.98248291016, 25.731380462646), sprite = 77, color = 5, scale = 0.6, display = 4 },
    zone = {
        points = {
            vec3(-570.82501220703, -861.53961181641, 26.370317459106),
            vec3(-615.94409179688, -857.4990234375, 25.088174819946),
            vec3(-620.3994140625, -903.34204101562, 24.40763092041),
            vec3(-571.42541503906, -905.26257324219, 25.700483322144)
        },
        thickness = 15,
    },
    management = {
        { coords = vec3(-587.49, -882.92, 26.30), radius = 0.6 },
    },
    stashes = {
        -- [1] Pass / Tray (For finished orders)
        { coords = vec3(-588.9, -878.9, 26.5), radius = 0.6, label = 'Pass', slots = 50, weight = 500 },
        
        -- [2] Fridge (For RAW ingredients from market: Meat, Whole Lettuce, etc.)
        { coords = vec3(-589.4, -880.6, 25.4), radius = 0.6, label = 'Fridge', slots = 50, weight = 500000 },
        
        -- [3] NEW: Prepped Ingredients (For Cut Lettuce, Sliced Tomato, etc.)
        -- I placed this near the Prep Station coords, feel free to move it!
        { coords = vec3(-589.7, -880.6, 26.2), radius = 0.4, label = 'Prepped Ingredients', slots = 50, weight = 500000 },
    },
    trays = {
        { coords = vec3(-584.9, -879.3, 26.0), radius = 0.5, label = 'Tray', slots = 10, weight = 100 },
        { coords = vec3(-588.2, -876.6, 26.0), radius = 0.5, label = 'Tray', slots = 10, weight = 100 },
    },
    prepare = {
        -- PREP STATION: Takes from Fridge -> Puts in Prepped Stash
        { 
            coords = vec3(-589.4, -880.6, 26.0), 
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
            coords = vec3(-589.6, -878.0, 26.2), 
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
            coords = vec3(-586.8, -881.7, 26.2), 
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
        { coords = vec3(-585.0, -879.9, 26.2), radius = 0.4, label = 'Register', playersRadius = 5.0, comission = 5 },
        { coords = vec3(-586.84478759766, -876.68634033203, 26.200073242188), radius = 0.4, label = 'Register', playersRadius = 5.0, comission = 5 },
    },
    offlineShop = {
        { coords = vec4(-585.78332519531, -877.57116699219, 25.0, 317.3603515625), label = 'Shop', model = 's_f_y_sweatshop_01', scenario = 'WORLD_HUMAN_AA_COFFEE' },
    },

    delivery = {
        { coords = vec3(-585.0, -879.9, 26.2), radius = 0.25, priceLost = 0, comission = 8, cooldown = 8 },
        { coords = vec3(-586.84478759766, -876.68634033203, 26.200073242188), radius = 0.25, priceLost = 0, comission = 8, cooldown = 8 },
    },
    music = {
        { coords = vec3(-589.8, -877.33355712891, 27.0), radius = 0.4, maxMusicRadius = 50.0, maxMusicVolume = 50},
    },
    chairs = {

    },
    garage = { -- The restaurant garage
        {
            coords = vec4(-593.037354, -885.824158, 25.0, 87.874016+180), -- Garage prop spawn coords
            spawnCoords = vec4(-596.861511, -885.916504, 25.522339, 83.874016), -- Vehicle spawn coords
            vehicles = {
                { icon = 'fas fa-car', label = 'Faggio', id = 'faggio' },
            },
        },
    },
}

AddRestaurant(restaurantConfig)