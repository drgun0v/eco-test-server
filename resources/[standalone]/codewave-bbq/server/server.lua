

-- Framework Detection
ESX = nil
QBCore = nil

if Config.Framework == "ESX" then
    ESX = exports.es_extended:getSharedObject()
elseif Config.Framework == "QBCore" then
    QBCore = exports["qb-core"]:GetCoreObject()
end

-- Helper Functions
function GetPlayerObject(playerId)
    if Config.Framework == "ESX" then
        return ESX.GetPlayerFromId(playerId)
    elseif Config.Framework == "QBCore" then
        return QBCore.Functions.GetPlayer(playerId)
    end
    return nil
end

function GetPlayerMoney(playerObject)
    if Config.Framework == "ESX" then
        return playerObject.getMoney()
    elseif Config.Framework == "QBCore" then
        return playerObject.PlayerData.money.cash
    end
    return 0
end

function RemovePlayerMoney(playerObject, amount)
    if Config.Framework == "ESX" then
        playerObject.removeMoney(amount)
    elseif Config.Framework == "QBCore" then
        playerObject.Functions.RemoveMoney("cash", amount)
    end
end

function AddPlayerItem(playerObject, itemId, quantity)
    if Config.Framework == "ESX" then
        playerObject.addInventoryItem(itemId, quantity)
    elseif Config.Framework == "QBCore" then
        playerObject.Functions.AddItem(itemId, quantity)
    end
end

function RemovePlayerItem(playerObject, itemId, quantity)
    if Config.Framework == "ESX" then
        playerObject.removeInventoryItem(itemId, quantity)
    elseif Config.Framework == "QBCore" then
        playerObject.Functions.RemoveItem(itemId, quantity)
    end
end

function GetPlayerItemCount(playerObject, itemId)
    if Config.Framework == "ESX" then
        local item = playerObject.getInventoryItem(itemId)
        return item and item.count or 0
    elseif Config.Framework == "QBCore" then
        local item = playerObject.Functions.GetItemByName(itemId)
        return item and item.amount or 0
    end
    return 0
end

function FindItemById(itemList, itemId)
    for _, item in pairs(itemList) do
        if item.id == itemId then
            return item
        end
    end
    return nil
end

-- Purchase Item Handler
RegisterNetEvent("store:purchaseItemfoodbbq")
AddEventHandler("store:purchaseItemfoodbbq", function(itemId, quantity)
    local playerId = source
    local playerObject = GetPlayerObject(playerId)
    
    if not playerObject then return end
    
    local item = FindItemById(Config.Items, itemId)
    
    if not item then return end
    
    local totalPrice = item.price * quantity
    local playerMoney = GetPlayerMoney(playerObject)
    
    if playerMoney >= totalPrice then
        RemovePlayerMoney(playerObject, totalPrice)
        AddPlayerItem(playerObject, item.id, quantity)
        
        TriggerClientEvent("store:notifyfoodbbq", playerId, 
            "You bought " .. quantity .. " " .. item.name, "success")
    else
        TriggerClientEvent("store:notifyfoodbbq", playerId, 
            "You do not have enough money", "error")
    end
end)

-- BBQ Crafting Handler
RegisterNetEvent("store:attemptCraftItemfoodbbq")
AddEventHandler("store:attemptCraftItemfoodbbq", function(recipeId, craftQuantity)
    local playerId = source
    local playerObject = GetPlayerObject(playerId)
    
    if not playerObject then return end
    
    local recipe = FindItemById(Config.CraftingRecipes, recipeId)
    
    if not recipe then return end
    
    craftQuantity = math.max(1, craftQuantity or 1)
    
    local hasAllMaterials = true
    
    for _, requiredItem in pairs(recipe.requiredItems) do
        local neededQuantity = requiredItem.quantity * craftQuantity
        local playerItemCount = GetPlayerItemCount(playerObject, requiredItem.id)
        
        if playerItemCount < neededQuantity then
            hasAllMaterials = false
            break
        end
    end
    
    if hasAllMaterials then
        TriggerClientEvent("store:playBBqCraftingAnimation", playerId)
        
        for _, requiredItem in pairs(recipe.requiredItems) do
            local neededQuantity = requiredItem.quantity * craftQuantity
            RemovePlayerItem(playerObject, requiredItem.id, neededQuantity)
        end
        
        Citizen.Wait(Config.TimeToCraft)
        
        local yieldAmount = (recipe.yield or 1) * craftQuantity
        AddPlayerItem(playerObject, recipe.id, yieldAmount)
    else
        TriggerClientEvent("store:keepCraftingUIOpen", playerId)
        TriggerClientEvent("store:notifyfoodbbq", playerId, 
            "Not enough materials to craft " .. recipe.name, "error")
    end
end)

-- Drink Crafting Handler
RegisterNetEvent("store:attemptCraftItemdrink")
AddEventHandler("store:attemptCraftItemdrink", function(recipeId, craftQuantity)
    local playerId = source
    local playerObject = GetPlayerObject(playerId)
    
    if not playerObject then return end
    
    local recipe = FindItemById(Config.CraftingRecipesDrinks, recipeId)
    
    if not recipe then return end
    
    craftQuantity = math.max(1, craftQuantity or 1)
    
    local hasAllMaterials = true
    
    for _, requiredItem in pairs(recipe.requiredItems) do
        local neededQuantity = requiredItem.quantity * craftQuantity
        local playerItemCount = GetPlayerItemCount(playerObject, requiredItem.id)
        
        if playerItemCount < neededQuantity then
            hasAllMaterials = false
            break
        end
    end
    
    if hasAllMaterials then
        TriggerClientEvent("store:playDrinkCraftingAnimation", playerId)
        
        for _, requiredItem in pairs(recipe.requiredItems) do
            local neededQuantity = requiredItem.quantity * craftQuantity
            RemovePlayerItem(playerObject, requiredItem.id, neededQuantity)
        end
        
        Citizen.Wait(Config.TimeToCraft)
        
        local yieldAmount = (recipe.yield or 1) * craftQuantity
        AddPlayerItem(playerObject, recipe.id, yieldAmount)
    else
        TriggerClientEvent("store:keepCraftingUIOpen", playerId)
        TriggerClientEvent("store:notifyDrinkCrafting", playerId, 
            "Not enough materials to craft " .. recipe.name, "error")
    end
end)

-- Placeable Props System
local placeableProps = Config.PlaceableProps or {}

function RegisterPlaceableProp(itemName)
    if Config.Framework == "ESX" then
        ESX.RegisterUsableItem(itemName, function(playerId)
            local playerObject = ESX.GetPlayerFromId(playerId)
            local itemCount = playerObject.getInventoryItem(itemName).count
            
            if itemCount > 0 then
                TriggerClientEvent("placeProp:useItem", playerId, itemName)
                playerObject.removeInventoryItem(itemName, 1)
            else
                TriggerClientEvent("esx:showNotification", playerId, "You do not have this item.")
            end
        end)
    elseif Config.Framework == "QBCore" then
        QBCore.Functions.CreateUseableItem(itemName, function(playerId)
            local playerObject = QBCore.Functions.GetPlayer(playerId)
            local hasItem = playerObject.Functions.GetItemByName(itemName)
            
            if hasItem then
                TriggerClientEvent("placeProp:useItem", playerId, itemName)
                playerObject.Functions.RemoveItem(itemName, 1)
                TriggerClientEvent("QBCore:Notify", playerId, 
                    "You have used the " .. itemName, "success")
            else
                TriggerClientEvent("QBCore:Notify", playerId, 
                    "You do not have this item.", "error")
            end
        end)
    end
end

for itemName, _ in pairs(placeableProps) do
    RegisterPlaceableProp(itemName)
end

-- Prop Return Handler
RegisterNetEvent("placeProp:returnItem")
AddEventHandler("placeProp:returnItem", function(itemName)
    local playerId = source
    
    if not placeableProps[itemName] then
        print(string.format("CHEAT DETECTED: player %s requested invalid prop '%s'", 
            playerId, tostring(itemName)))
        DropPlayer(playerId, "Cheating detected: Kicked By CodeWave")
        return
    end
    
    local playerObject = GetPlayerObject(playerId)
    
    if not playerObject then return end
    
    AddPlayerItem(playerObject, itemName, 1)
    
    if Config.Framework == "ESX" then
        TriggerClientEvent("esx:showNotification", playerId, 
            "You received your " .. itemName .. ".")
    elseif Config.Framework == "QBCore" then
        TriggerClientEvent("QBCore:Notify", playerId, 
            "You received your " .. itemName .. ".", "success")
    end
end)


