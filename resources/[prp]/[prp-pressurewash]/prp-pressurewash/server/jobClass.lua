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

---@type table<JobOptions>
JobTypes = {}
JobId = 0

---@class Job
---@field id string jobId
---@field members table<JobMember>
---@field variables table
---@field owner string Character id of the owner
---@field jobType string
---@field groupId number|nil
---@field destroyCb function
---@field addPlayerCb function
---@field removePlayerCb function
---@field syncData table Synced data
Job = {}
Job.__index = Job

---@type table<Job>
JobTable = {}

---@type table<number> Key: characterId, Value: jobId
JobMembers = {}

---@class JobOptions
---@field id string
---@field name string
---@field restrictions table|nil
---@field customRep table|nil
---@field timeout number|nil
---@field cooldown number|nil

---@class JobMember
---@field source number
---@field charId string

---@param jobType string
---@param joiner number Player id
---@param members table<table>|nil Players (without the owner)
---@param groupId number|nil
---@param destroyCb function
---@param addPlayerCb function
---@param removePlayerCb function
---@return Job
function CreateJob(jobType, joiner, members, groupId, destroyCb, addPlayerCb, removePlayerCb)
    JobId += 1
    local self = {
        id = tostring(JobId),
        syncData = {},
        members = {},
        variables = {}
    }

    JobTable[self.id] = setmetatable(self, Job)
    ---@type Job
    local job = JobTable[self.id]
    job.jobType = jobType

    if members then
        for k, v in pairs(members) do
            job:AddMember(v.source)
        end
    end

    job:AddMember(joiner)

    job.owner = tostring(bridge.fw.getIdentifier(joiner))
    job.destroyCb = destroyCb
    job.addPlayerCb = addPlayerCb
    job.removePlayerCb = removePlayerCb

    job.groupId = groupId

    return JobTable[self.id]
end

function Job:Notification(type, message, time)
    for k, v in pairs(self.members) do
        bridge.fw.notify(v.source, type, message, nil, time)
    end
end

---@param count number Progress count
---@return boolean complete Is task finished
function Job:UpdateTaskProgress(count)
    ---@type JobMember
    local owner = self.members[self.owner]
    if not count or count == 0 then
        return false
    end
    local isComplete = false
    local pointsDone = 0
    for k,v in pairs(self.pointsDone) do
        pointsDone = pointsDone + 1
    end
    if pointsDone >= self.decalCount then
        isComplete = true
    end
    return isComplete
end

---@param success boolean
---@param skipDistanceCheck boolean
function Job:Finish(success, skipDistanceCheck)
    if self.finished then
        return
    end
    self.finished = true
    self.success = success == true
    self:Destroy()
end

---@param eventName string
---@param ... any Args
function Job:SendEventToMembers(eventName, ...)
    local args = msgpack.pack_args(...)
    local argLength = args:len()
    for k, v in pairs(self.members) do
        if GetPlayerPing(v.source) > 0 then
            TriggerClientEventInternal(eventName, v.source, args, argLength)
        end
    end
end

function Job:Destroy()
    if self.destroyed then
        return
    end
    self.destroyed = true
    if self.destroyCb then
        self.destroyCb(self)
    end
    for _, member in pairs(self.members) do
        if JobMembers[member.charId] == self.id then
            JobMembers[member.charId] = nil
        end
    end
    JobTable[self.id] = nil
end

---@param source number
function Job:AddMember(source)
    local identifier = bridge.fw.getIdentifier(source)
    if not identifier then
        return
    end
    local characterId = tostring(identifier)
    self.members[characterId] = {
        source = tonumber(source),
        charId = characterId
    }
    JobMembers[characterId] = self.id
    if self.addPlayerCb then
        self.addPlayerCb(self, source, characterId)
    end
end

---@param source number | string
function Job:RemoveMember(source)
    local playerSource = tonumber(source) or source
    for k, v in pairs(self.members) do
        if v.source == playerSource then
            if self.removePlayerCb then
                self.removePlayerCb(self, v.source, v.charId)
            end
            JobMembers[v.charId] = nil
            self.members[k] = nil
        end
    end
end

---@param source number
---@return Job|nil job
function Job:GetByMember(source)
    local identifier = bridge.fw.getIdentifier(source)
    if not identifier then
        return nil
    end
    local characterId = tostring(identifier)

    if JobMembers[characterId] then
        return JobTable[JobMembers[characterId]]
    end
end

---@param charId number
---@return Job|nil job
function Job:GetByCharId(charId)
    local characterId = tostring(charId)
    
    if JobMembers[characterId] then
        return JobTable[JobMembers[characterId]]
    end
end

function Job:GetMemberCount()
    local count = 0
    for _, _ in pairs(self.members) do
        count += 1
    end
    return count
end

---@param groupId number
---@return Job|nil job 
function Job:GetByGroupId(groupId)
    for k, v in pairs(JobTable) do
        if v.groupId and v.groupId == groupId then
            return v
        end
    end
end

function Job:SyncData(source)
    if source then
        TriggerClientEvent(("prp-pressurewash:syncData"), source, self.syncData)
        return
    end
    for _, member in pairs(self.members) do
        if GetPlayerPing(member.source) > 0 then
            TriggerClientEvent(("prp-pressurewash:syncData"), member.source, self.syncData)
        end
    end
end

---@param key string
---@param value any
function Job:SetVariable(key, value)
    self.variables[key] = value
end

---@param key string
---@return any
function Job:GetVariable(key)
    return self.variables[key]
end

AddEventHandler("prp-bridge:server:groupMemberAdded", function(src, groupId)
    local job = Job:GetByGroupId(groupId)
    if not job then return end
    job:AddMember(src)
end)

AddEventHandler("prp-bridge:server:groupMemberRemoved", function(src, groupId)
    local job = Job:GetByGroupId(groupId)
    if not job then return end
    job:RemoveMember(src)
end)

AddEventHandler("prp-bridge:server:groupDisbanded", function(groupId)
    local job = Job:GetByGroupId(groupId)
    if not job then return end
    job:Destroy()
end)

---Registers a job type
---@param jobOptions JobOptions
---@param startCb function
---@param destroyCb function
function Job:RegisterType(jobOptions, startCb, destroyCb, addPlayerCb, removePlayerCb)
    JobTypes[jobOptions.id] = jobOptions

    if Config.StartByNPC then
        RegisterServerEvent("prp-pressurewash:startJob", function(depotId)
            local src = source
            if not Config.Job.PW.depots[depotId] then return end
            if Job:GetByMember(src) then return end

            local group = exports["prp-bridge"]:GetGroupFromMember(src)
            if not group then
                local result = exports["prp-bridge"]:CreateGroup(src)
                if not result.success or not result.group then return end
                group = result.group
            end
            if not group then return end

            local groupMembers = group.getMembers()
            local _groupMembers = {}
            for k,v in pairs(groupMembers) do
                table.insert(_groupMembers, { source = v.src, stateId = v.identifier })
            end
            local uuid = group.getUuid()
            local job = CreateJob(jobOptions.id, src, _groupMembers, uuid, destroyCb, addPlayerCb, removePlayerCb)
            -- Set the chosen depot before onStart syncs the job so the client is routed to the
            -- depot the player actually interacted with.
            job.syncData.depot = depotId
            startCb(job)
        end)

        RegisterServerEvent("prp-pressurewash:endJob", function()
            local job = Job:GetByMember(source)
            if not job then return end
            job:Destroy()
        end)
    else
        AddEventHandler(jobOptions.id..":Server:OnDuty", function(joiner, members, isWorkgroup)
            local job = CreateJob(jobOptions.id, joiner, members, isWorkgroup, destroyCb, addPlayerCb, removePlayerCb)
            startCb(job)
        end)

        AddEventHandler(jobOptions.id..":Server:OffDuty", function(playerId, joiner)
            local job = Job:GetByMember(joiner)
            if not job then return end
            job:Destroy()
        end)
    end
end