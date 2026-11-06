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

Citizen.CreateThread(function()
    bridge.fw.registerItemUse('pressurewash', function(src, itemData)
        local pos = nil
        local _, err = pcall(function()
            pos = lib.callback.await("prp-pressurewash:placeGenerator", src)
        end)
        if err then return end
        if not pos then return end
        PlaceGenerator(src, pos, itemData.metaData, itemData.slot)
    end)
end)

function HasValue(tbl, value)
	for k, v in ipairs(tbl) do
		if v == value or (type(v) == "table" and HasValue(v, value)) then
			return true
		end
	end
	return false
end

function SpawnVehicle(model, coords)
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
    local timeout = 0
    while not DoesEntityExist(vehicle) and timeout < 50 do
        timeout += 1
        Citizen.Wait(0)
    end
    if timeout >= 50 then
        return
    end
    local vehState = Entity(vehicle).state
    local plate = GetVehicleNumberPlateText(vehicle)
    vehState.Owned = false
    vehState.Locked = false
    vehState.PlayerDriven = true
    vehState.NoCriminalActivities = true
    vehState.Fuel = math.random(80, 100)
    vehState.Plate = plate
    timeout = 0
    while NetworkGetEntityOwner(vehicle) == -1 and timeout < 15 do
        timeout += 1
        Citizen.Wait(100)
    end
    if timeout >= 15 then
        RemoveVehicle(vehicle)
        return
    end

    return { veh = vehicle, vin = vehState.VIN }
end

--- Remove the vehicle.
--- @param entity number EntityID
--- @return boolean
function RemoveVehicle(entity)
    Entity(entity).state.Deleted = true
    DeleteEntity(entity)

    return true
end