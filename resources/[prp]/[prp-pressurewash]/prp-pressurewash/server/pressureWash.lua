--[[
========================================================================================
 ██████╗ ██╗     ███████╗ █████╗ ███╗   ██╗███████╗██████╗ 
██╔════╝ ██║     ██╔════╝██╔══██╗████╗  ██║██╔════╝██╔══██╗
██║      ██║     █████╗  ███████║██╔██╗ ██║█████╗  ██║  ██║
██║      ██║     ██╔══╝  ██╔══██║██║╚██╗██║██╔══╝  ██║  ██║
╚██████╗ ███████╗███████╗██║  ██║██║ ╚████║███████╗██████╔╝
 ╚═════╝ ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚═════╝ 

                 ██████╗ ██╗   ██╗
                 ██╔══██╗╚██╗ ██╔╝
                 ██████╔╝ ╚████╔╝ 
                 ██╔══██╗  ╚██╔╝  
                 ██████╔╝   ██║   
                 ╚═════╝    ╚═╝   

██╗  ██╗ █████╗ ███████╗██╗███╗   ███╗
██║  ██║██╔══██╗╚══███╔╝██║████╗ ████║
███████║███████║  ███╔╝ ██║██╔████╔██║
██╔══██║██╔══██║ ███╔╝  ██║██║╚██╔╝██║
██║  ██║██║  ██║███████╗██║██║ ╚═╝ ██║
╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═╝     ╚═╝

██╗  ██╗███████╗██████╗ ██████╗ ███████╗██████╗  █████╗ 
██║  ██║██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔══██╗
███████║█████╗  ██████╔╝██████╔╝█████╗  ██████╔╝███████║
██╔══██║██╔══╝  ██╔══██╗██╔══██╗██╔══╝  ██╔══██╗██╔══██║
██║  ██║███████╗██║  ██║██║  ██║███████╗██║  ██║██║  ██║
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
========================================================================================
--]]

---@enum
local stages = {
    get_to_depot = 1,
    clean_zone = 2,
    return_vehicle = 3,
}

local decalTypes = {
    1040,
    1050,
    9000,
    1015,
}

local getZoneCount = function(charId)
    return 1
end

local getRandomZone = function()
    local zones = {}
    for k, v in pairs(PressureWashZones) do
        if not v.active then
            zones[#zones+1] = k
        end
    end
    if #zones == 0 then return end
    if #zones == 1 then
        return zones[1]
    end
    return zones[math.random(1, #zones)]
end

local getZoneObject = function(job)
    return PressureWashZones[job.zones[job.currentZone]]
end

local generateZoneDecals = function(job)
    local zone = getZoneObject(job)
    local points = {}
    local maxPoints = 10
    for i=1, #zone.walls do
        if #points >= maxPoints then break end
        local usedId = {}

        for j=1, 2 do
            if #zone.walls[i] < 2 then break end
            local id = math.random(1, #zone.walls[i])
            while usedId[id] do
                id = math.random(1, #zone.walls[i])
                Wait(0)
            end
            if not usedId[id] then
                usedId[id] = true
            end
            points[#points+1] = zone.walls[i][id]
            points[#points][4] = decalTypes[math.random(1, #decalTypes)]
            points[#points][5] = { math.random(1, 100)/100, math.random(1, 100)/100, math.random(1, 100)/100, 1.0 }
        end
    end

    for i=1, #zone.flats do
        if #points >= maxPoints then break end
        local usedId = {}
        for j=1, 2 do
            if #zone.flats[i] < 2 then break end
            local id = math.random(1, #zone.flats[i])
            while usedId[id] do
                id = math.random(1, #zone.flats[i])
                Wait(0)
            end
            if not usedId[id] then
                usedId[id] = true
            end
            points[#points+1] = zone.flats[i][id]
            points[#points][4] = decalTypes[math.random(1, #decalTypes)]
            points[#points][5] = { math.random(1, 100)/100, math.random(1, 100)/100, math.random(1, 100)/100, 1.0 }
        end
    end
    zone.points = points
    OnZoneChange(job.zones[job.currentZone])
    return points
end

---@param job Job
---@param stageId number
local setStage = function(job, stageId)
    job.syncData.stage = stageId
    if stageId == stages.get_to_depot then
        if not job.syncData.depot then
            job.syncData.depot = math.random(#Config.Job.PW.depots)
        end
        job:Notification("info", locale("GET_VEHICLE_AND_EQUIPMENT_FROM_DEPOT"))
    elseif stageId == stages.clean_zone then
        job.syncData.zoneLocation = getZoneObject(job).pos
        job.points = generateZoneDecals(job)
        job.syncData.zone = job.zones[job.currentZone]
        job.decalCount = #job.points
        job.pointsDone = {}
        job:Notification("info", locale("CLEAN_THE_ZONE"))
    elseif stageId == stages.return_vehicle then
        job:Notification("info", locale("RETURN_YOUR_VEHICLE_TO_THE_DEPOT"))
    end
    job:SyncData()
end

RegisterNetEvent("prp-pressurewash:washedPoints", function(points)
    local source = source
    local job = Job:GetByMember(source)
    if job and job.syncData.stage == stages.clean_zone then
        local playerPed = GetPlayerPed(source)
        local playerCoords = GetEntityCoords(playerPed)
        if #(playerCoords - job.syncData.zoneLocation) > 100 then
            return
        end
        if not job.vehicle or not DoesEntityExist(job.vehicle) then
            return
        end
        if #(playerCoords - GetEntityCoords(job.vehicle)) > 150 then
            TriggerClientEvent("prp-hud:notify", source, "Error", locale("VEHICLE_TOO_FAR_AWAY"), 10000)
            return
        end
        local changedPoints = {}
        local changedPointsCount = 0
        for k, v in pairs(points) do
            job.points[k][5][4] -= (v or 0.0)
            changedPoints[k] = job.points[k]
            if job.points[k][5][4] <= 0.0 and not job.pointsDone[k] then
                job.pointsDone[k] = true
                changedPointsCount = changedPointsCount + 1
            end
        end
        if job:UpdateTaskProgress(changedPointsCount) then
            if job:GetVariable("gotPayout") then return end
            job:SetVariable("gotPayout", true)

            local zoneLocation = job.syncData.zoneLocation
            if not job.zones or not job.currentZone or not job.zones[job.currentZone] then
                return
            end

            local zone = nil

            pcall(function()
                PressureWashZones[job.zones[job.currentZone]].active = nil

                OnZoneChange(job.zones[job.currentZone], source)
                job.currentZone = 1
                job.zones = {}
                zone = getRandomZone()
                local totalSalary = Config.Job.PW.salaryPerZone
                for k, v in pairs(job.members) do
                    bridge.fw.addMoney(v.source, "bank", totalSalary)
                    local charId = bridge.fw.getIdentifier(v.source)
                    bridge.log.send(
                        Config.Webhook,
                        "Pressure Wash Job",
                        ("%s has completed a pressure wash zone and earned $%s"):format(bridge.fw.getCharacterName(charId), totalSalary)
                    )
                end
            end)

            job:SetVariable("gotPayout", nil)

            if not zone then
                return setStage(job, stages.return_vehicle)
            end
            job:Notification("info", locale("ZONE_CLEANED_GET_TO_NEXT_ZONE"))
            PressureWashZones[zone].active = job.id
            job.zones[#job.zones+1] = zone
            setStage(job, stages.clean_zone)
        else
            if changedPointsCount > 0 then
                local totalPointsDone = 0
                for k,v in pairs(job.pointsDone) do
                    totalPointsDone = totalPointsDone + 1
                end
                job:Notification("info", locale("POINTS_CLEANED_PROGRESS", totalPointsDone, job.decalCount))
            end
            OnZoneChange(job.zones[job.currentZone], source, changedPoints)
        end
    end
end)

function SquaredLength(v)
    return v.x*v.x + v.y*v.y + v.z*v.z;
end

local onStart = function(job)
    if job:GetMemberCount() > Config.Job.PW.maxMembers then
        job:Finish(false, false)
        job:Notification(locale("POWER_WASH_JOB"), locale("MAX_MEMBERS_EXCEEDED", Config.Job.PW.maxMembers))
        return
    end
    job.zoneCount = getZoneCount(job.owner)
    job.zones = {}
    for i=1, job.zoneCount do
        local zone = getRandomZone()
        if not zone then
            job:Finish(false, false)
            job:Notification(locale("POWER_WASH_JOB"), locale("NO_FREE_SPOTS"))
            return
        end
        PressureWashZones[zone].active = job.id
        job.zones[#job.zones+1] = zone
    end
    job.currentZone = 1
    setStage(job, stages.get_to_depot)
end

local onDestroy = function(job)
    if job.vehicle then
        if DoesEntityExist(job.vehicle) then
            for _, member in pairs(job.members) do
                if member.source then
                    bridge.vkeys.remove(member.source, job.vehicle)
                end
            end
            RemoveVehicle(job.vehicle)
        end
        job.vehicle = nil
    end
    if job.zones then
        for i=1, #job.zones do
            local zone = PressureWashZones[job.zones[i]]
            if zone and zone.active == job.id then
                zone.active = nil
                OnZoneChange(job.zones[i])
            end
        end
    end
    job.syncData = nil
    job:SyncData()
end

local onPlayerAdd = function(job, source, characterId)
    job:SyncData(source)
end

local onPlayerRemove = function(job, source, characterId)
    if DoesEntityExist(GetPlayerPed(source)) then
        TriggerClientEvent(("prp-pressurewash:syncData"), source, nil)
    end
end

Job:RegisterType(Config.Job.PW, onStart, onDestroy, onPlayerAdd, onPlayerRemove)

RegisterNetEvent(("prp-pressurewash:getVan"), function()
    local source = source
    ---@type Job|nil
    local job = Job:GetByMember(source)
    if not job then return end
    local charId = bridge.fw.getIdentifier(source)
    if job.owner ~= tostring(charId) then
        TriggerClientEvent("prp-hud:notify", source, "Error", locale("GROUP_OWNER_REQUIRED"))
        return
    end
    if job.syncData.stage ~= stages.get_to_depot then
        return
    end
    if job.vehicle then
        TriggerClientEvent("prp-hud:notify", source, "Error", locale("VEHICLE_ALREADY_EXISTS"))
        return
    end
    -- Guard against a second request while the first one is still spawning the vehicle.
    if job.spawningVehicle then
        TriggerClientEvent("prp-hud:notify", source, "Error", locale("VEHICLE_ALREADY_EXISTS"))
        return
    end
    job.spawningVehicle = true
    local depotId = job.syncData.depot
    -- A callback timeout raises an error, so pcall keeps the job from being left with a stale spawn lock.
    local ok, spotId = pcall(lib.callback.await, "prp-pressurewash:getFreeSpot", source, depotId)
    if not ok then
        job.spawningVehicle = nil
        TriggerClientEvent("prp-hud:notify", source, "Error", locale("COULD_NOT_SPAWN_VEHICLE"))
        return
    end
    if not spotId then
        job.spawningVehicle = nil
        TriggerClientEvent("prp-hud:notify", source, "Error", locale("NO_FREE_SPOTS"))
        return
    end
    -- The job may have been ended or the player may have disconnected while awaiting the callback.
    if job.destroyed or not job.syncData then
        job.spawningVehicle = nil
        return
    end
    local vehTries = 0
    local function spawnVehicle()
        if vehTries > 3 or job.destroyed or not job.syncData then return end
        local coords = Config.Job.PW.depots[depotId].vehSpawns[spotId]
        local vehObj = SpawnVehicle(`burrito`, coords)
        if not vehObj then
            TriggerClientEvent("prp-hud:notify", source, "Error", locale("COULD_NOT_SPAWN_VEHICLE"))
            return
        end
        local timeout = 0
        while NetworkGetEntityOwner(vehObj.veh) == -1 and timeout < 15 do
            timeout += 1
            Citizen.Wait(100)
        end
        if timeout >= 15 or not vehObj.veh or not DoesEntityExist(vehObj.veh) then
            if vehObj.veh then
                RemoveVehicle(vehObj.veh)
            end
            vehTries += 1
            Citizen.Wait(100)
            return spawnVehicle()
        end
        return vehObj.veh
    end
    local veh = spawnVehicle()
    job.spawningVehicle = nil
    if job.destroyed or not job.syncData then
        if veh then RemoveVehicle(veh) end
        return
    end
    if not veh then
        TriggerClientEvent("prp-hud:notify", source, "Error", locale("COULD_NOT_SPAWN_VEHICLE"))
        return
    end
    bridge.vkeys.give(source, veh)

    job.vehicle = veh
    job.syncData.vehNetId = NetworkGetNetworkIdFromEntity(veh)
    TriggerClientEvent(("prp-pressurewash:setVehMod"), NetworkGetEntityOwner(job.vehicle), job.syncData.vehNetId, "livery", 3)
    setStage(job, stages.clean_zone)
end)

RegisterNetEvent(("prp-pressurewash:returnVan"), function()
    local source = source
    ---@type Job|nil
    local job = Job:GetByMember(source)
    if not job then return end
    if job.syncData.stage ~= stages.return_vehicle then return end
    local charId = bridge.fw.getIdentifier(source)
    if job.owner ~= tostring(charId) then
        TriggerClientEvent("prp-hud:notify", source, "Error", locale("GROUP_OWNER_REQUIRED"))
        return
    end
    if not job.vehicle then
        TriggerClientEvent("prp-hud:notify", source, "Error", locale("VEHICLE_NOT_FOUND"))
        return
    end
    if not DoesEntityExist(job.vehicle) or #(GetEntityCoords(GetPlayerPed(source)) - GetEntityCoords(job.vehicle)) > 50 then
        TriggerClientEvent("prp-hud:notify", source, "Error", locale("VEHICLE_TOO_FAR_AWAY"))
        return
    end

    -- Job:Finish destroys the job, which removes the vehicle and clears the zone through onDestroy.
    job:Finish(true, false)
end)

