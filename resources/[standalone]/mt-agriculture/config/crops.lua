Config = Config or {} -- <--- YOU MUST ADD THIS LINE AT THE TOP

Config.Crops = {
    wheat = {
        label       = 'Wheat',
        seedItem    = 'wheat_seed',
        harvestItem = 'wheat_raw',
        minYield    = 3,
        maxYield    = 7,
        growthTime  = 2 * 60, -- Remember to change this back to 15 * 60 after testing!
        
        -- Visuals
        stages = {
            [1] = `prop_bucket_01b`,   -- Stage 1: Preparation (The Bucket)
            [2] = `prop_veg_crop_05`,  -- Stage 2: Growing (Green Crop)
            [3] = `prop_bush_med_06`,  -- Stage 3: Ready (Your new bush prop)
        }
    },
}