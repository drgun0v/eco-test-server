-- Function to get all recipes for a restaurant
local function getRecipes(source, restaurantId)
  return MySQL.query.await("SELECT * FROM `restaurants_recipes` WHERE job = ?", {restaurantId})
end

-- Register callback for getting recipes
lib.callback.register("mt-restaurants:server:getRecipes", getRecipes)

-- =========================================================
--  TABLET BOSS MENU (FINAL SAFE VERSION)
-- =========================================================

-- Callback to get available job grades for the popup
lib.callback.register('mt-restaurants:server:getJobGrades', function(source, jobName)
    local grades = {}
    if Config.framework == 'esx' then
        if Config.core.GetJobs then
            -- NEW ESX
            local job = Config.core.GetJobs()[jobName]
            if job and job.grades then
                for grade, data in pairs(job.grades) do
                    table.insert(grades, { grade = grade, label = data.label })
                end
            end
        elseif ESX.GetJob then
             -- OLD ESX
             local job = ESX.GetJob(jobName)
             if job and job.grades then
                for grade, data in pairs(job.grades) do
                    table.insert(grades, { grade = tonumber(grade), label = data.label })
                end
            end
        end
    elseif Config.framework == 'qb' then
        local job = Config.core.Shared.Jobs[jobName]
        if job and job.grades then
            for grade, data in pairs(job.grades) do
                table.insert(grades, { grade = tonumber(grade), label = data.name })
            end
        end
    end
    return grades
end)


-- Callback to get Society Money & Employees & SALES STATS
lib.callback.register('mt-restaurants:server:getBossData', function(source, restaurantId)
    local src = source
    local xPlayer = nil
    
    -- Detect Framework
    if Config.framework == 'esx' then
        xPlayer = Config.core.GetPlayerFromId(src)
    elseif Config.framework == 'qb' then
        xPlayer = Config.core.Functions.GetPlayer(src)
    end

    if not xPlayer then return nil end

    -- 1. Get Money
    local money = 0
    local p = promise.new()

    if Config.framework == 'esx' then
        -- ESX Addon Account
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..restaurantId, function(account)
            if account then 
                money = account.money 
            else
                money = 0
            end
            p:resolve(money)
        end)
    elseif Config.framework == 'qb' then
        -- QB Management
        if exports['qb-management'] then
            money = exports['qb-management']:GetAccount(restaurantId)
            p:resolve(money)
        else
            p:resolve(0) 
        end
    end
    
    Citizen.Await(p)

    -- 2. FETCH EMPLOYEE STATS (Safe Mode)
    local statsMap = {}
    local success, stats = pcall(function()
        return MySQL.query.await('SELECT * FROM restaurants_employee_stats WHERE job = ?', {restaurantId})
    end)

    if success and stats then
        for _, s in pairs(stats) do
            statsMap[s.identifier] = s
        end
    else
        print("^1[MT-Restaurants] Warning: Could not fetch 'restaurants_employee_stats'. Did you run the SQL file? Sales data will be 0.^0")
    end

    -- 3. Get Online Employees
    local employees = {}
    
    -- Helper to safely get name
    local function SafeGetName(p)
        if p.getName then return p.getName() end
        if p.get then return (p.get('firstName') or '') .. ' ' .. (p.get('lastName') or '') end
        return "Unknown"
    end

    if Config.framework == 'esx' then
        if Config.core.GetExtendedPlayers then
            local xPlayers = Config.core.GetExtendedPlayers('job', restaurantId)
            for _, xTarget in pairs(xPlayers) do
                local s = statsMap[xTarget.identifier] or {sales_count = 0, total_earnings = 0}
                table.insert(employees, {
                    name = xTarget.getName(),
                    gradeLabel = xTarget.getJob().grade_label,
                    grade = xTarget.getJob().grade,
                    identifier = xTarget.identifier,
                    sales = s.sales_count,
                    earnings = s.total_earnings
                })
            end
        else
            local xPlayers = Config.core.GetPlayers()
            for _, sourceID in ipairs(xPlayers) do
                local xTarget = Config.core.GetPlayerFromId(sourceID)
                if xTarget and xTarget.job.name == restaurantId then
                    local s = statsMap[xTarget.identifier] or {sales_count = 0, total_earnings = 0}
                    table.insert(employees, {
                        name = SafeGetName(xTarget),
                        gradeLabel = xTarget.job.grade_label,
                        grade = xTarget.job.grade,
                        identifier = xTarget.identifier,
                        sales = s.sales_count,
                        earnings = s.total_earnings
                    })
                end
            end
        end
    elseif Config.framework == 'qb' then
        local players = Config.core.Functions.GetPlayers()
        for _, v in pairs(players) do
            local tPlayer = Config.core.Functions.GetPlayer(v)
            if tPlayer and tPlayer.PlayerData.job.name == restaurantId then
                local s = statsMap[tPlayer.PlayerData.citizenid] or {sales_count = 0, total_earnings = 0}
                table.insert(employees, {
                    name = tPlayer.PlayerData.charinfo.firstname .. ' ' .. tPlayer.PlayerData.charinfo.lastname,
                    gradeLabel = tPlayer.PlayerData.job.grade.name,
                    grade = tPlayer.PlayerData.job.grade.level,
                    identifier = tPlayer.PlayerData.citizenid,
                    sales = s.sales_count,
                    earnings = s.total_earnings
                })
            end
        end
    end

    local currencySym = "$"

    return {
        money = currencySym .. money,
        employees = employees
    }
end)

-- Event to REGISTER A SALE (Call this from your Registers script!)
RegisterNetEvent('mt-restaurants:server:registerSale', function(amount)
    local src = source
    local xPlayer = nil
    if Config.framework == 'esx' then xPlayer = Config.core.GetPlayerFromId(src)
    elseif Config.framework == 'qb' then xPlayer = Config.core.Functions.GetPlayer(src) end

    if xPlayer then
        local job = ""
        local id = ""
        
        if Config.framework == 'esx' then
            job = xPlayer.getJob().name
            id = xPlayer.identifier
        elseif Config.framework == 'qb' then
            job = xPlayer.PlayerData.job.name
            id = xPlayer.PlayerData.citizenid
        end

        if job and id then
            pcall(function()
                MySQL.insert('INSERT INTO restaurants_employee_stats (identifier, job, sales_count, total_earnings) VALUES (?, ?, 1, ?) ON DUPLICATE KEY UPDATE sales_count = sales_count + 1, total_earnings = total_earnings + ?', {id, job, amount, amount})
            end)
        end
    end
end)

-- Event to handle Boss Actions
RegisterNetEvent('mt-restaurants:server:performBossAction', function(action, data)
    local src = source
    local xPlayer = nil
    if Config.framework == 'esx' then xPlayer = Config.core.GetPlayerFromId(src)
    elseif Config.framework == 'qb' then xPlayer = Config.core.Functions.GetPlayer(src) end
    
    if not xPlayer then return end

    local job = data.restaurantId

    -- Security: Check if sender is boss
    local isBoss = false
    if Config.framework == 'esx' then
        if xPlayer.getJob().name == job and xPlayer.getJob().grade_name == 'boss' then isBoss = true end
    elseif Config.framework == 'qb' then
        if xPlayer.PlayerData.job.name == job and xPlayer.PlayerData.job.isboss then isBoss = true end
    end
    
    if not isBoss then return end

    -- Determine money source/destination
    local moneyType = data.moneyType or 'cash' -- Default to cash if not specified

    if action == 'deposit' then
        local amount = tonumber(data.amount)
        if amount and amount > 0 then
            if Config.framework == 'esx' then
                local hasMoney = false
                if moneyType == 'cash' then
                    if xPlayer.getMoney() >= amount then
                        xPlayer.removeMoney(amount)
                        hasMoney = true
                    end
                elseif moneyType == 'bank' then
                    -- Older ESX uses getAccount('bank').money, check newer docs if needed
                    local bankMoney = 0
                    if xPlayer.getAccount then
                         bankMoney = xPlayer.getAccount('bank').money
                    else
                         -- Very old ESX fallback
                         local account = xPlayer.getAccount('bank')
                         if account then bankMoney = account.money end
                    end
                    
                    if bankMoney >= amount then
                        xPlayer.removeAccountMoney('bank', amount)
                        hasMoney = true
                    end
                end

                if hasMoney then
                    TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..job, function(account)
                        if account then account.addMoney(amount) end
                    end)
                    createLog(LogsConfig.bossAction, "Money Deposited ("..moneyType..")", string.format("**Boss:** %s\n**Amount:** $%s\n**Restaurant:** %s", xPlayer.getName(), amount, job))
                else
                    xPlayer.showNotification("Not enough money in " .. moneyType)
                end

            elseif Config.framework == 'qb' then
                if xPlayer.Functions.RemoveMoney(moneyType, amount) then
                    exports['qb-management']:AddMoney(job, amount)
                    createLog(LogsConfig.bossAction, "Money Deposited ("..moneyType..")", string.format("**Boss:** %s\n**Amount:** $%s\n**Restaurant:** %s", xPlayer.PlayerData.charinfo.firstname, amount, job))
                else
                    TriggerClientEvent('QBCore:Notify', src, "Not enough money in " .. moneyType, "error")
                end
            end
        end

    elseif action == 'withdraw' then
        local amount = tonumber(data.amount)
        if amount and amount > 0 then
            if Config.framework == 'esx' then
                TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..job, function(account)
                    if account and account.money >= amount then
                        account.removeMoney(amount)
                        
                        if moneyType == 'cash' then
                            xPlayer.addMoney(amount)
                        else
                            xPlayer.addAccountMoney('bank', amount)
                        end
                        
                        createLog(LogsConfig.bossAction, "Money Withdrawn ("..moneyType..")", string.format("**Boss:** %s\n**Amount:** $%s\n**Restaurant:** %s", xPlayer.getName(), amount, job))
                    else
                         xPlayer.showNotification("Not enough money in society account")
                    end
                end)
            elseif Config.framework == 'qb' then
                if exports['qb-management']:RemoveMoney(job, amount) then
                    xPlayer.Functions.AddMoney(moneyType, amount)
                    createLog(LogsConfig.bossAction, "Money Withdrawn ("..moneyType..")", string.format("**Boss:** %s\n**Amount:** $%s\n**Restaurant:** %s", xPlayer.PlayerData.charinfo.firstname, amount, job))
                else
                    TriggerClientEvent('QBCore:Notify', src, "Not enough money in society account", "error")
                end
            end
        end

    elseif action == 'hire' then
        -- ... existing hire logic ...
        local targetId = tonumber(data.targetId)
        if targetId then
            if Config.framework == 'esx' then
                local xTarget = Config.core.GetPlayerFromId(targetId)
                if xTarget then 
                    xTarget.setJob(job, 0)
                    createLog(LogsConfig.bossAction, "Employee Hired", string.format("**Boss:** %s\n**Hired:** %s", xPlayer.getName(), xTarget.getName()))
                end
            elseif Config.framework == 'qb' then
                local tPlayer = Config.core.Functions.GetPlayer(targetId)
                if tPlayer then 
                    tPlayer.Functions.SetJob(job, 0) 
                    createLog(LogsConfig.bossAction, "Employee Hired", string.format("**Boss:** %s\n**Hired:** %s", xPlayer.PlayerData.charinfo.firstname, tPlayer.PlayerData.charinfo.firstname))
                end
            end
        end

    elseif action == 'fire' then
        -- ... existing fire logic ...
        if Config.framework == 'esx' then
            local xTarget = Config.core.GetPlayerFromIdentifier(data.target)
            if xTarget then 
                xTarget.setJob('unemployed', 0) 
            end
            createLog(LogsConfig.bossAction, "Employee Fired", string.format("**Boss:** %s\n**Fired ID:** %s", xPlayer.getName(), data.target))
        elseif Config.framework == 'qb' then
            local tPlayer = Config.core.Functions.GetPlayerByCitizenId(data.target)
            if tPlayer then tPlayer.Functions.SetJob('unemployed', 0) end
            createLog(LogsConfig.bossAction, "Employee Fired", string.format("**Boss:** %s\n**Fired ID:** %s", xPlayer.PlayerData.charinfo.firstname, data.target))
        end
        
    elseif action == 'grade' then
         -- ... existing grade logic ...
         local newGrade = tonumber(data.newGrade)
         if newGrade then
            if Config.framework == 'esx' then
                local xTarget = Config.core.GetPlayerFromIdentifier(data.target)
                if xTarget then
                    xTarget.setJob(job, newGrade)
                end
            elseif Config.framework == 'qb' then
                local tPlayer = Config.core.Functions.GetPlayerByCitizenId(data.target)
                if tPlayer then
                    tPlayer.Functions.SetJob(job, newGrade)
                end
            end
            createLog(LogsConfig.bossAction, "Employee Promoted/Demoted", string.format("**Boss:** %s\n**Target ID:** %s\n**New Grade:** %s", xPlayer.getName(), data.target, data.newGrade))
         end

    elseif action == 'bonus' then
        -- ... existing bonus logic ...
        local amount = tonumber(data.amount)
        if amount and amount > 0 then
             local success = false
             if Config.framework == 'esx' then
                TriggerEvent('esx_addonaccount:getSharedAccount', 'society_'..job, function(account)
                    if account and account.money >= amount then
                        account.removeMoney(amount)
                        success = true
                    end
                end)
                
                if success then
                    local xTarget = Config.core.GetPlayerFromIdentifier(data.target)
                    if xTarget then
                        xTarget.addAccountMoney('bank', amount)
                        xTarget.showNotification("You received a bonus of $"..amount)
                    end
                    createLog(LogsConfig.bossAction, "Bonus Given", string.format("**Boss:** %s\n**Target ID:** %s\n**Amount:** $%s", xPlayer.getName(), data.target, amount))
                end

             elseif Config.framework == 'qb' then
                if exports['qb-management']:RemoveMoney(job, amount) then
                    local tPlayer = Config.core.Functions.GetPlayerByCitizenId(data.target)
                    if tPlayer then
                        tPlayer.Functions.AddMoney('bank', amount)
                        TriggerClientEvent('QBCore:Notify', tPlayer.PlayerData.source, "You received a bonus of $"..amount)
                    end
                    createLog(LogsConfig.bossAction, "Bonus Given", string.format("**Boss:** %s\n**Target ID:** %s\n**Amount:** $%s", xPlayer.PlayerData.charinfo.firstname, data.target, amount))
                end
             end
        end
    end
end)

-- =========================================================
--  RECIPES LOGIC (EXISTING)
-- =========================================================

local function createNewRecipe(source, recipeData)
  local result = MySQL.insert.await(
    "INSERT INTO `restaurants_recipes` (label, description, image_url, ingredients, animation, type, stations, active, price, job) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
    {
      recipeData.label, recipeData.description or "", recipeData.image_url, json.encode(recipeData.ingredients),
      recipeData.animation, recipeData.type, json.encode(recipeData.station), recipeData.active, recipeData.price, recipeData.job
    }
  )
  if result then
    createLog(LogsConfig.createRecipe, locale("logs_created_new_recipe"), locale("logs_created_new_recipe_desc", GetPlayerName(source), source, recipeData.label, recipeData.type, recipeData.price, recipeData.job, recipeData.image_url), recipeData.image_url)
    registerStation(recipeData.job)
    return true
  end
  return false
end
lib.callback.register("mt-restaurants:server:createNewRecipe", createNewRecipe)

local function editRecipe(source, recipeData)
  local result = MySQL.update.await(
    "UPDATE `restaurants_recipes` SET label = ?, description = ?, image_url = ?, ingredients = ?, animation = ?, type = ?, stations = ?, active = ?, price = ?, job = ? WHERE id LIKE ?",
    {
      recipeData.label, recipeData.description or "", recipeData.image_url, json.encode(recipeData.ingredients),
      recipeData.animation, recipeData.type, json.encode(recipeData.station), recipeData.active, recipeData.price, recipeData.job, recipeData.recipeId
    }
  )
  if result then
    createLog(LogsConfig.editRecipe, locale("logs_recipe_edited"), locale("logs_recipe_edited_desc", GetPlayerName(source), source, recipeData.label, recipeData.type, recipeData.price, recipeData.job, recipeData.recipeId, recipeData.image_url), recipeData.image_url)
    registerStation(recipeData.job)
    return true
  end
  return false
end
lib.callback.register("mt-restaurants:server:editRecipe", editRecipe)

local function deleteRecipe(source, recipeId, restaurantId)
  local result = MySQL.query.await("DELETE FROM `restaurants_recipes` WHERE id LIKE ?", {recipeId})
  if result then
    createLog(LogsConfig.deleteRecipe, locale("logs_recipe_deleted"), locale("logs_recipe_deleted_desc", GetPlayerName(source), source, recipeId))
    registerStation(restaurantId)
    return true
  end
  return false
end
lib.callback.register("mt-restaurants:server:deleteRecipe", deleteRecipe)

local function getMenus(source, restaurantId)
  return MySQL.query.await("SELECT * FROM `restaurants_menus` WHERE job = ?", {restaurantId})
end
lib.callback.register("mt-restaurants:server:getMenus", getMenus)

local function editMenuImage(source, imageUrl, restaurantId)
  local existingMenu = MySQL.query.await("SELECT * FROM `restaurants_menus` WHERE job = ?", {restaurantId})
  createLog(LogsConfig.menuImageEdited, locale("logs_menu_image_edited"), locale("logs_menu_image_edited_desc", GetPlayerName(source), source, restaurantId, imageUrl), imageUrl)
  if existingMenu and #existingMenu >= 1 then
    return MySQL.update.await("UPDATE `restaurants_menus` SET image_url = ? WHERE id LIKE ?", {imageUrl, existingMenu[1].id})
  else
    return MySQL.insert.await("INSERT INTO `restaurants_menus` (image_url, job) VALUES (?, ?)", {imageUrl, restaurantId})
  end
end
lib.callback.register("mt-restaurants:server:editMenuImage", editMenuImage)

CreateThread(function()
  for restaurantId, restaurant in pairs(Config.restaurants) do
    TriggerEvent("esx_society:registerSociety", restaurant.job, restaurant.job, "society_" .. restaurant.job, "society_" .. restaurant.job, "society_" .. restaurant.job, {type = "public"})
  end
end)