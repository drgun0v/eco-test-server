local PlantStates = {} -- [fieldId][index] = { stage=0, plantedAt=0 }

local function getFieldConfig(fieldId)
    for _, f in ipairs(Config.Fields or {}) do
        if f.id == fieldId then return f end
    end
end

local function initPlants()
    -- Load all plants from DB
    local rows = MySQL.query.await('SELECT field_id, plant_index, stage, planted_at FROM agriculture_plants', {}) or {}
    
    -- Initialize cache
    for _, field in ipairs(Config.Fields) do
        PlantStates[field.id] = {}
        for i = 1, #field.offsets do
            PlantStates[field.id][i] = { stage = 0, plantedAt = 0 }
        end
    end

    -- Apply DB data
    for _, row in ipairs(rows) do
        if PlantStates[row.field_id] and PlantStates[row.field_id][row.plant_index] then
            PlantStates[row.field_id][row.plant_index] = {
                stage     = tonumber(row.stage),
                plantedAt = tonumber(row.planted_at)
            }
        end
    end
end

CreateThread(initPlants)

-- Get all plants for a field (sent to client)
lib.callback.register('mt-agriculture:server:getPlants', function(source, fieldId)
    return PlantStates[fieldId] or {}
end)

-- Step 1: NPC Interaction "Prepare Field"
lib.callback.register('mt-agriculture:server:prepareField', function(source, fieldId)
    local src = source
    local field = getFieldConfig(fieldId)
    if not field then return false end
    
    local cropData = Config.Crops[field.crop]
    
    -- Check if player has the right seeds
    local seedCount = exports.ox_inventory:Search(src, 'count', cropData.seedItem)
    if seedCount < 1 then
        return false, 'no_seeds'
    end

    -- Set all EMPTY spots to Stage 1 (Bucket)
    local changed = false
    for i, state in pairs(PlantStates[fieldId]) do
        if state.stage == 0 then
            state.stage = 1
            MySQL.insert('INSERT INTO agriculture_plants (field_id, plant_index, stage, planted_at) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE stage = ?', 
                { fieldId, i, 1, 0, 1 })
            changed = true
        end
    end

    if changed then
        TriggerClientEvent('mt-agriculture:client:syncPlants', -1, fieldId, PlantStates[fieldId])
        return true
    else
        return false, 'field_full'
    end
end)

-- Step 2: Player clicks Bucket "Plant Seed"
lib.callback.register('mt-agriculture:server:plantSeed', function(source, fieldId, index)
    local src = source
    local field = getFieldConfig(fieldId)
    local state = PlantStates[fieldId][index]
    
    if not state or state.stage ~= 1 then return false, 'invalid_plant' end -- Must be a bucket

    local cropData = Config.Crops[field.crop]
    
    -- Remove 1 Seed
    if exports.ox_inventory:RemoveItem(src, cropData.seedItem, 1) then
        state.stage = 2 -- Growing
        state.plantedAt = os.time()
        
        MySQL.update.await('UPDATE agriculture_plants SET stage = ?, planted_at = ? WHERE field_id = ? AND plant_index = ?', 
            { 2, state.plantedAt, fieldId, index })
            
        TriggerClientEvent('mt-agriculture:client:syncPlants', -1, fieldId, PlantStates[fieldId])
        return true
    else
        return false, 'no_seeds'
    end
end)

-- Step 3: Harvest
lib.callback.register('mt-agriculture:server:harvestPlant', function(source, fieldId, index)
    local src = source
    local field = getFieldConfig(fieldId)
    local state = PlantStates[fieldId][index]

    if not state or state.stage ~= 3 then return false, 'not_ready' end

    local cropData = Config.Crops[field.crop]
    local qty = math.random(cropData.minYield, cropData.maxYield)

    if exports.ox_inventory:AddItem(src, cropData.harvestItem, qty) then
        state.stage = 0 -- Reset to empty
        state.plantedAt = 0
        
        MySQL.update.await('UPDATE agriculture_plants SET stage = 0, planted_at = 0 WHERE field_id = ? AND plant_index = ?', 
            { fieldId, index })
            
        TriggerClientEvent('mt-agriculture:client:syncPlants', -1, fieldId, PlantStates[fieldId])
        return true, qty
    else
        return false, 'inv_full'
    end
end)

-- Growth Loop
CreateThread(function()
    while true do
        Wait(60000) -- Check every 1 min
        local now = os.time()
        local updated = {}

        for fieldId, plants in pairs(PlantStates) do
            local field = getFieldConfig(fieldId)
            local crop = Config.Crops[field.crop]
            local changed = false

            for i, state in pairs(plants) do
                if state.stage == 2 and (now - state.plantedAt >= crop.growthTime) then
                    state.stage = 3 -- Ready
                    MySQL.update('UPDATE agriculture_plants SET stage = 3 WHERE field_id = ? AND plant_index = ?', { fieldId, i })
                    changed = true
                end
            end
            
            if changed then
                TriggerClientEvent('mt-agriculture:client:syncPlants', -1, fieldId, plants)
            end
        end
    end
end)