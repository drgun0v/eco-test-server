-- Weapon hash to name mapping table
local weaponHashes = {}

-- Populate weapon hash table from config
for weaponName in pairs(Config.WeaponNames or {}) do
    local hash = joaat(weaponName)
    weaponHashes[hash] = weaponName
end

-- Get weapon data for display
function GetWeaponData(weaponHash)
    -- Check if weapon display is enabled in config
    if not Config.ShowComponents or not Config.ShowComponents.weapon then
        return false
    end
    
    -- Use cached weapon if no hash provided
    if weaponHash == nil then
        weaponHash = cache.weapon
    end
    
    -- Return false if no weapon
    if not weaponHash then
        return false
    end
    
    -- Get weapon name from hash
    local weaponName = weaponHashes[weaponHash]
    if Config.WeaponNames and Config.WeaponNames[weaponName] then
        weaponName = Config.WeaponNames[weaponName]
    end
    
    -- Check if this is a vehicle weapon
    local isVehicleWeapon, vehicleWeaponIndex = GetCurrentPedVehicleWeapon(cache.ped)
    if isVehicleWeapon then
        weaponName = "Vehicle Weapon"
    end
    
    -- Get ammo count
    local totalAmmo
    if isVehicleWeapon then
        totalAmmo = GetVehicleWeaponRestrictedAmmo(cache.vehicle, vehicleWeaponIndex) or 
                    GetAmmoInPedWeapon(cache.ped, weaponHash)
    else
        totalAmmo = GetAmmoInPedWeapon(cache.ped, weaponHash)
    end
    
    -- Get clip ammo
    local clipAmmo = GetAmmoInClip(cache.ped, weaponHash)
    
    -- Calculate reserve ammo
    local reserveAmmo = totalAmmo - clipAmmo
    
    -- Return weapon data table
    return {
        weaponHash = weaponName,
        weaponName = weaponName,
        reserveAmmo = reserveAmmo,
        clipAmmo = clipAmmo
    }
end

-- Send weapon data to NUI
local function SendWeaponDataToNUI(weaponHash)
    SendNUIMessage({
        type = "weaponData",
        weaponData = GetWeaponData(weaponHash)
    })
end

-- Flag to track if weapon monitoring thread is running
local isMonitoringWeapon = false

-- Create thread to monitor weapon ammo updates
local function StartWeaponMonitoring()
    CreateThread(function()
        Wait(10)
        
        -- Check if weapon display is enabled
        if not Config.ShowComponents or not Config.ShowComponents.weapon then
            return
        end
        
        -- Check if player has a weapon
        if not cache.ped or not cache.weapon then
            return
        end
        
        -- Prevent multiple monitoring threads
        if isMonitoringWeapon then
            return
        end
        
        isMonitoringWeapon = true
        
        -- Monitor weapon while player has it equipped
        while cache.ped and cache.weapon and IsHudRunning do
            Wait(1000)
            SendWeaponDataToNUI(cache.weapon)
        end
        
        isMonitoringWeapon = false
    end)
end

-- Check and display weapon data on player load
function CheckWeaponOnLoad()
    if Config.ShowComponents and Config.ShowComponents.weapon then
        if cache.weapon then
            SendWeaponDataToNUI(cache.weapon)
            StartWeaponMonitoring()
        end
    end
end

-- Register weapon change listener
if Config.ShowComponents and Config.ShowComponents.weapon then
    -- Listen for weapon cache changes
    lib.onCache("weapon", function(newWeapon)
        SendWeaponDataToNUI(newWeapon)
        StartWeaponMonitoring()
    end)
    
    -- Listen for gunshot events to update ammo display
    AddEventHandler("CEventGunShot", function(entities, shooter)
        -- Only update if the shooter is the player
        if shooter ~= cache.ped then
            return
        end
        
        SendWeaponDataToNUI(cache.weapon)
        StartWeaponMonitoring()
    end)
end