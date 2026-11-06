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

function RefuellingProgress(id, data, weaponSlot)
    local progressbarResult = bridge.fw.progressBar({
        duration = 10 * 1000,
        label = locale("REFUELING_GENERATOR_PROGRESS_LABEL"),
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "weapons@misc@jerrycan@",
            animClip = "fire",
            animFlag = 49,
        },
    })
    if not progressbarResult then
        return
    end
    TriggerServerEvent("prp-pressurewash:refillFuel", id, data, weaponSlot)
end

function RefillWaterProgress(id, data, itemSlot)
    local progressbarResult = bridge.fw.progressBar({
        duration = 10 * 1000,
        label = locale("REFILLING_GENERATOR_PROGRESS_LABEL"),
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "weapons@misc@jerrycan@",
            animClip = "fire",
            animFlag = 49,
        },
    })
    if not progressbarResult then
        return
    end
    TriggerServerEvent("prp-pressurewash:refillWater", id, data, itemSlot)
end

function OpenJobShop()
    bridge.inv.openShop("Pressurewash")
end

Citizen.CreateThread(function()
    if Config.DefaultBlip then
        for i=1, #Config.Job.PW.depots do
            local blip = AddBlipForCoord(Config.Job.PW.depots[i].pedCoords.x, Config.Job.PW.depots[i].pedCoords.y, Config.Job.PW.depots[i].pedCoords.z)
            SetBlipSprite(blip, Config.BlipOptions.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.BlipOptions.scale)
            SetBlipColour(blip, Config.BlipOptions.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentSubstringPlayerName(locale("PRESSURE_WASH_JOB_LABEL"))
            EndTextCommandSetBlipName(blip)
        end
    end
end)