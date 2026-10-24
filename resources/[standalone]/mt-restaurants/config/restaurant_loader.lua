Config = Config or {}
Config.restaurants = {}

-- This file will be loaded after all restaurant files
-- It will collect all the returned restaurant configurations and add them to Config.restaurants

AddRestaurant = function(restaurantConfig)
    if restaurantConfig and type(restaurantConfig) == 'table' then
        if Config.restaurants[restaurantConfig.job] then
            print('^3[MT-Restaurants]^7 Warning: Restaurant with job ' .. restaurantConfig.job .. ' already exists')
            return
        end

        Config.restaurants[restaurantConfig.job] = restaurantConfig
    end
end
