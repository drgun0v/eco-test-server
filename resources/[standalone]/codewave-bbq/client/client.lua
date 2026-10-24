

-- Framework Detection
ESX = nil
QBCore = nil

if Config.Framework == "ESX" then
    ESX = exports.es_extended:getSharedObject()
elseif Config.Framework == "QBCore" then
    QBCore = exports["qb-core"]:GetCoreObject()
end

-- State Variables
local isStoreMenuOpen = false
local isCraftingMenuOpen = false
local isCrafting = false
local storeItems = Config.Items
local craftingRecipes = Config.CraftingRecipes
local isPlacingProp = false
local currentPlacedProp = nil
local placedProps = {}
local isCraftingUIOpen = false

-- Resource Start Handler
AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    SetNuiFocus(false, false)
    SendNUIMessage({action = "closeMenu"})
    SendNUIMessage({action = "closeCrafting"})
end)

-- Notification System
RegisterNetEvent("showNotification")
AddEventHandler("showNotification", function(message)
    ShowNotification(message)
end)

function ShowNotification(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end

-- NUI Callbacks
RegisterNUICallback("close", function(data, cb)
    isStoreMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({action = "closeMenu"})
    cb("ok")
end)

RegisterNUICallback("closeCrafting", function(data, cb)
    isCraftingMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({action = "closeCrafting"})
    cb("ok")
end)

RegisterNUICallback("purchase", function(data, cb)
    local itemId = data.id
    local quantity = tonumber(data.quantity)
    TriggerServerEvent("store:purchaseItemfoodbbq", itemId, quantity)
    cb("ok")
end)

RegisterNUICallback("craft", function(data, cb)
    if not isCrafting then
        local recipeId = data.id
        TriggerServerEvent("store:attemptCraftItemfoodbbq", recipeId)
    else
        ShowNotification("You are already crafting, Please wait")
    end
end)

RegisterNUICallback("craft-drink", function(data, cb)
    if not isCrafting then
        local recipeId = data.id
        TriggerServerEvent("store:attemptCraftItemdrink", recipeId)
    else
        ShowNotification("You are already crafting, Please wait")
    end
end)

-- Crafting Animation Handlers
RegisterNetEvent("store:playBBqCraftingAnimation")
AddEventHandler("store:playBBqCraftingAnimation", function()
    isCraftingMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({action = "closeCrafting"})
    
    isCrafting = true
    local playerPed = PlayerPedId()
    
    TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BBQ", 0, true)
    
    Citizen.CreateThread(function()
        Citizen.Wait(Config.TimeToCraft)
        ClearPedTasks(playerPed)
        isCrafting = false
    end)
end)

RegisterNetEvent("store:playDrinkCraftingAnimation")
AddEventHandler("store:playDrinkCraftingAnimation", function()
    isCraftingMenuOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({action = "closeCrafting"})
    
    isCrafting = true
    local playerPed = PlayerPedId()
    
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(100)
    end
    
    TaskPlayAnim(playerPed, "mini@repair", "fixing_a_player", 8.0, -8.0, -1, 1, 0, false, false, false)
    
    Citizen.CreateThread(function()
        Citizen.Wait(Config.TimeToCraft)
        ClearPedTasks(playerPed)
        isCrafting = false
    end)
end)

-- Crafting UI Notifications
RegisterNetEvent("store:keepCraftingUIOpen")
AddEventHandler("store:keepCraftingUIOpen", function()
    SendNUIMessage({
        action = "notify",
        message = "You do not have the required items to craft this.",
        type = "error"
    })
end)

RegisterNetEvent("store:notifyfoodbbq")
AddEventHandler("store:notifyfoodbbq", function(message, notificationType)
    SendNUIMessage({
        action = "notify",
        message = message,
        type = notificationType
    })
end)

-- NPC Spawning
function SpawnStoreNPC()
    local npcModel = GetHashKey(Config.NPC.Model)
    local npcCoords = Config.NPC.Coords
    
    RequestModel(npcModel)
    while not HasModelLoaded(npcModel) do
        Citizen.Wait(100)
    end
    
    local npc = CreatePed(4, npcModel, npcCoords.x, npcCoords.y, npcCoords.z, Config.NPC.Heading, false, true)
    
    SetEntityHeading(npc, Config.NPC.Heading)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    -- Create Blip
    local blip = AddBlipForCoord(npcCoords.x, npcCoords.y, npcCoords.z)
    SetBlipSprite(blip, Config.NPC.BlipSprite or 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.NPC.BlipScale or 1.0)
    SetBlipColour(blip, Config.NPC.BlipColour or 1)
    SetBlipAsShortRange(blip, true)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.NPC.BlipName or "NPC")
    EndTextCommandSetBlipName(blip)
end

-- Store Menu Functions
function OpenStoreMenu()
    local playerPed = PlayerPedId()
    local playerModel = GetEntityModel(playerPed)
    local canOpen = false
    
    if Config.OnlyFemales then
        for _, femaleModel in ipairs(Config.FemalePedModels) do
            if playerModel == femaleModel then
                canOpen = true
                break
            end
        end
    else
        canOpen = true
    end
    
    if canOpen then
        if not isCraftingUIOpen then
            isCraftingUIOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "openMenu",
                items = storeItems,
                playMusic = Config.PlayMusicWhileUIIsOpen,
                volume = Config.MusicVolume
            })
        else
            isCraftingUIOpen = false
            SetNuiFocus(false, false)
            SendNUIMessage({action = "closeMenu"})
        end
    else
        ShowNotification("This menu is only available to specified female characters.")
    end
end

-- Interaction System
Citizen.CreateThread(function()
    SpawnStoreNPC()
    
    if Config.InteractionType == "ox_target" then
        local npcCoords = Config.NPC.Coords
        exports.ox_target:addSphereZone({
            name = "bbq_store",
            coords = {npcCoords.x, npcCoords.y, npcCoords.z + 1.0},
            radius = 0.45,
            debug = drawZones,
            options = {
                {
                    name = "open_bbq",
                    label = "Open BBQ Store",
                    icon = "fa-solid fa-store",
                    onSelect = function()
                        OpenStoreMenu()
                    end
                }
            }
        })
    end
    
    while true do
        Citizen.Wait(0)
        
        if Config.InteractionType == "3dtext" then
            local playerPed = PlayerPedId()
            local npcCoords = Config.NPC.Coords
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - npcCoords)
            
            if distance < 2.0 then
                drawText("Press [E] to interact")
                
                if IsControlJustReleased(0, 38) then
                    OpenStoreMenu()
                end
            end
        end
    end
end)

-- 3D Text Drawing
function drawText(text)
    SetTextFont(0)
    SetTextProportional(1)
    SetTextScale(0.35, 0.35)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(0.5, 0.93)
end

-- Placeable Props System
local placeableProps = Config.PlaceableProps

function NotifyPlayer(message, notifyType)
    if Config.Framework == "ESX" then
        ESX.ShowNotification(message)
    elseif Config.Framework == "QBCore" then
        QBCore.Functions.Notify(message, notifyType or "primary")
    else
        print(message)
    end
end

function PlaceProp(itemName)
    local propConfig = placeableProps[itemName]
    
    if not propConfig then
        print("Invalid item: no corresponding prop found.")
        return
    end
    
    local propModel = propConfig.model
    local isInteractable = propConfig.interactable or false
    local playerPed = PlayerPedId()
    
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(10)
    end
    
    currentPlacedProp = CreateObject(GetHashKey(propModel), 0, 0, 0, true, true, true)
    local propNetId = NetworkGetNetworkIdFromEntity(currentPlacedProp)
    
    SetEntityHeading(currentPlacedProp, GetEntityHeading(playerPed))
    FreezeEntityPosition(currentPlacedProp, true)
    SetEntityCollision(currentPlacedProp, false, true)
    
    local propHeading = GetEntityHeading(currentPlacedProp)
    local heightOffset = 0.0
    isPlacingProp = true
    
    Citizen.CreateThread(function()
        while isPlacingProp do
            Wait(0)
            
            drawText("Aim to position | Page Up/Down: Adjust Height | U: Rotate | Enter: Place | Backspace: Cancel")
            
            local camCoord = GetGameplayCamCoord()
            local camRot = GetGameplayCamRot(2)
            local direction = RotationToDirection(camRot)
            local destination = camCoord + vector3(direction.x * 10.0, direction.y * 10.0, direction.z * 10.0)
            
            local rayHandle = StartShapeTestRay(camCoord.x, camCoord.y, camCoord.z, destination.x, destination.y, destination.z, -1, playerPed, 0)
            local _, hit, hitCoords = GetShapeTestResult(rayHandle)
            
            if hit == 1 then
                SetEntityCoords(currentPlacedProp, hitCoords.x, hitCoords.y, hitCoords.z + heightOffset)
                DrawMarker(1, hitCoords.x, hitCoords.y, hitCoords.z + heightOffset, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 0.1, 255, 255, 255, 100, false, false, 2, nil, nil, false)
            end
            
            if IsControlPressed(0, 10) then
                heightOffset = heightOffset + 0.02
            elseif IsControlPressed(0, 11) then
                heightOffset = heightOffset - 0.02
            end
            
            if IsControlPressed(0, 303) then
                propHeading = propHeading + 1.0
                SetEntityHeading(currentPlacedProp, propHeading)
            end
            
            if IsControlJustReleased(0, 191) then
                SetEntityInvincible(currentPlacedProp, true)
                FreezeEntityPosition(currentPlacedProp, true)
                SetEntityCollision(currentPlacedProp, true, true)
                PlaceObjectOnGroundProperly(currentPlacedProp)
                isPlacingProp = false
                
                table.insert(placedProps, {
                    propNetId = propNetId,
                    item = itemName,
                    interactable = isInteractable
                })
                
                Citizen.CreateThread(function()
                    while DoesEntityExist(currentPlacedProp) do
                        Citizen.Wait(1000)
                        PlaceObjectOnGroundProperly(currentPlacedProp)
                    end
                end)
                
                NotifyPlayer("Prop has been placed.", "success")
                Citizen.Wait(1500)
                NotifyPlayer("Use /packup to pickup your items!!!.", "inform")
            end
            
            if IsControlJustReleased(0, 194) then
                DeleteEntity(currentPlacedProp)
                currentPlacedProp = nil
                isPlacingProp = false
                NotifyPlayer("Prop placement canceled.", "error")
            end
        end
    end)
end

function RotationToDirection(rotation)
    local adjustedRotation = vector3(math.rad(rotation.x), math.rad(rotation.y), math.rad(rotation.z))
    local direction = vector3(
        -math.sin(adjustedRotation.z) * math.cos(adjustedRotation.x),
        math.cos(adjustedRotation.z) * math.cos(adjustedRotation.x),
        math.sin(adjustedRotation.x)
    )
    return direction
end

-- Prop Placement Event
RegisterNetEvent("placeProp:useItem")
AddEventHandler("placeProp:useItem", function(itemName)
    PlaceProp(itemName)
end)

-- Packup Command
RegisterCommand("packup", function()
    if #placedProps == 0 then
        NotifyPlayer("You have no props to pick up!", "error")
        return
    end
    
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestProp = nil
    local closestDistance = 2.0
    
    for index, propData in ipairs(placedProps) do
        local propEntity = NetworkGetEntityFromNetworkId(propData.propNetId)
        
        if DoesEntityExist(propEntity) then
            local propCoords = GetEntityCoords(propEntity)
            local distance = #(playerCoords - propCoords)
            
            if distance <= closestDistance then
                closestProp = {
                    entity = propEntity,
                    index = index,
                    item = propData.item
                }
                closestDistance = distance
            end
        end
    end
    
    if closestProp then
        TaskStartScenarioInPlace(playerPed, "PROP_HUMAN_BUM_BIN", 0, true)
        Citizen.Wait(2000)
        ClearPedTasks(playerPed)
        
        DeleteEntity(closestProp.entity)
        handlePropPickup(closestProp.item)
        table.remove(placedProps, closestProp.index)
        
        NotifyPlayer("Nearest prop picked up.", "success")
        
        if #placedProps == 0 then
            NotifyPlayer("No more props left to pick up.", "inform")
        end
    else
        NotifyPlayer("No nearby props to pick up.", "inform")
    end
end, false)

-- Prop Interaction Loop
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local foundInteraction = false
        
        for _, propData in ipairs(placedProps) do
            local propEntity = NetworkGetEntityFromNetworkId(propData.propNetId)
            
            if DoesEntityExist(propEntity) then
                local propCoords = GetEntityCoords(propEntity)
                local distance = #(playerCoords - propCoords)
                
                if distance <= 2.0 and propData.interactable then
                    foundInteraction = true
                    drawText("[E] To open the machine")
                    
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent("placeProp:interact", propData.item, propEntity)
                        break
                    end
                end
            end
        end
        
        if not foundInteraction then
            Citizen.Wait(500)
        end
    end
end)

-- Prop Pickup Handler
function handlePropPickup(itemName)
    TriggerServerEvent("placeProp:returnItem", itemName)
end

-- Prop Interaction Handler
RegisterNetEvent("placeProp:interact")
AddEventHandler("placeProp:interact", function(itemName, propEntity)
    if itemName == "soda_machine" then
        if not isCraftingUIOpen then
            isCraftingUIOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "openCrafting",
                recipes = Config.CraftingRecipesDrinks,
                menuType = "drink",
                playMusic = Config.PlayMusicWhileUIIsOpen,
                volume = Config.MusicVolume
            })
            isCraftingMenuOpen = true
        else
            isCraftingUIOpen = false
            SetNuiFocus(false, false)
            SendNUIMessage({action = "closeCrafting"})
            isCraftingMenuOpen = false
        end
    elseif itemName == "bbq_grill" then
        if not isCraftingUIOpen then
            isCraftingUIOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = "openCrafting",
                recipes = craftingRecipes,
                playMusic = Config.PlayMusicWhileUIIsOpen,
                volume = Config.MusicVolume
            })
            isCraftingMenuOpen = true
        else
            isCraftingUIOpen = false
            SetNuiFocus(false, false)
            SendNUIMessage({action = "closeCrafting"})
            isCraftingMenuOpen = false
        end
    end
end)

-- Cleanup on Resource Stop
AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, propData in ipairs(placedProps) do
            local propEntity = NetworkGetEntityFromNetworkId(propData.propNetId)
            if DoesEntityExist(propEntity) then
                DeleteEntity(propEntity)
            end
        end
        placedProps = {}
    end
end)


