local FieldProps = {} -- [fieldId] = { npc = entity, plants = { [index] = entity } }
local FieldData = {} -- Synced data from server

-- 1. Sync Logic
RegisterNetEvent('mt-agriculture:client:syncPlants', function(fieldId, plants)
    FieldData[fieldId] = plants
    UpdateVisuals(fieldId)
end)

-- 2. NPC Spawner
local function SpawnNPC(field)
    local model = field.npcModel
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local npc = CreatePed(4, model, field.npcCoords.x, field.npcCoords.y, field.npcCoords.z - 1.0, field.npcCoords.w, false, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetModelAsNoLongerNeeded(model)

    -- NPC Target: "Prepare Seeds"
    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'agri_prep_'..field.id,
            label = 'Prepare Seeds',
            icon = 'fa-solid fa-seedling',
            onSelect = function()
                local success, reason = lib.callback.await('mt-agriculture:server:prepareField', false, field.id)
                if success then
                    lib.notify({description = 'You prepared the planting spots!', type = 'success'})
                else
                    if reason == 'no_seeds' then
                        lib.notify({description = 'You do not have the right seeds.', type = 'error'})
                    end
                end
            end
        }
    })
    
    return npc
end

-- 3. Update Visuals (The Buckets & Crops)
function UpdateVisuals(fieldId)
    local field = nil
    for _, f in ipairs(Config.Fields) do 
        if f.id == fieldId then field = f break end 
    end
    if not field then return end
    
    -- Initialize table if needed
    if not FieldProps[fieldId] then FieldProps[fieldId] = { plants = {} } end
    
    local plants = FieldData[fieldId] or {}
    
    for i, offset in ipairs(field.offsets) do
        local state = plants[i] or { stage = 0 }
        local existingProp = FieldProps[fieldId].plants[i]
        
        -- Calculate absolute coords
        local coords = field.center + offset
        
        -- Determine correct model
        local requiredModel = nil
        local stage = state.stage
        
        if stage == 1 then requiredModel = Config.Crops[field.crop].stages[1] end
        if stage == 2 then requiredModel = Config.Crops[field.crop].stages[2] end
        if stage == 3 then requiredModel = Config.Crops[field.crop].stages[3] end -- This will now use prop_bush_med_06
        
        -- If prop exists but shouldn't (or wrong model), delete it
        if existingProp and (not requiredModel or GetEntityModel(existingProp) ~= requiredModel) then
            if exports.ox_target then exports.ox_target:removeLocalEntity(existingProp) end
            DeleteEntity(existingProp)
            FieldProps[fieldId].plants[i] = nil
            existingProp = nil
        end
        
        -- If we need a prop and don't have one, create it
        if requiredModel and not existingProp then
            RequestModel(requiredModel)
            while not HasModelLoaded(requiredModel) do Wait(0) end
            
            local obj = CreateObject(requiredModel, coords.x, coords.y, coords.z, false, false, false)

            SetEntityHeading(obj, field.propHeading or 0.0)
            
            FreezeEntityPosition(obj, true)
            PlaceObjectOnGroundProperly(obj)
            FieldProps[fieldId].plants[i] = obj
            existingProp = obj -- Update reference for the next step
            
            SetModelAsNoLongerNeeded(requiredModel)
        end

        -- Update Options (Runs every time, ensuring options change from None -> Harvest)
        if existingProp and DoesEntityExist(existingProp) then
            -- Clear old options first (optional, but safer to prevent duplicates)
            exports.ox_target:removeLocalEntity(existingProp)

            local options = {}
            
            -- If Stage 1 (Bucket) -> Plant Seed
            if stage == 1 then
                table.insert(options, {
                    label = 'Plant Seed',
                    icon = 'fa-solid fa-hand-holding-seedling',
                    onSelect = function()
                        if lib.progressCircle({duration = 2000, label = 'Planting...', position = 'bottom', useWhileDead=false, canCancel=true, disable={move=true}}) then
                            local ok = lib.callback.await('mt-agriculture:server:plantSeed', false, fieldId, i)
                            if ok then lib.notify({type='success', description='Planted!'}) 
                            else lib.notify({type='error', description='Missing seeds!'}) end
                        end
                    end
                })
            -- If Stage 3 (Ready) -> Harvest
            elseif stage == 3 then
                table.insert(options, {
                    label = 'Harvest',
                    icon = 'fa-solid fa-sickle',
                    onSelect = function()
                         if lib.progressCircle({duration = 2000, label = 'Harvesting...', position = 'bottom', useWhileDead=false, canCancel=true, disable={move=true}}) then
                            local ok, qty = lib.callback.await('mt-agriculture:server:harvestPlant', false, fieldId, i)
                            if ok then lib.notify({type='success', description='Harvested '..qty}) end
                        end
                    end
                })
            end
            
            if #options > 0 then
                exports.ox_target:addLocalEntity(existingProp, options)
            end
        end
    end
end

-- Initialize Logic
CreateThread(function()
    for _, field in ipairs(Config.Fields) do
        -- Spawn NPC
        FieldProps[field.id] = { npc = SpawnNPC(field), plants = {} }
        
        -- Fetch Initial State
        local plants = lib.callback.await('mt-agriculture:server:getPlants', false, field.id)
        FieldData[field.id] = plants
        UpdateVisuals(field.id)
    end
end)

-- Cleanup on Resource Stop
AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for id, data in pairs(FieldProps) do
        if DoesEntityExist(data.npc) then DeleteEntity(data.npc) end
        for _, obj in pairs(data.plants) do
            if DoesEntityExist(obj) then DeleteEntity(obj) end
        end
    end
end)