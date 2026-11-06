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

local resourceName = GetCurrentResourceName()
local resourcePath = GetResourcePath(resourceName)

Citizen.CreateThread(function()
    bridge.fw.registerCommand("pw_opencreator", locale("COMMAND_OPEN_CREATOR_HELP"), nil, "group.admin", function(src, args, rawCommand)
        TriggerClientEvent("prp-pressurewash:client:newCreatorStart", src)
    end)
end)

local function round(value, numDecimalPlaces)
	if numDecimalPlaces then
		local power = 10 ^ numDecimalPlaces
		return math.floor((value * power) + 0.5) / (power)
	else
		return math.floor(value + 0.5)
	end
end

local function spaces(num)
    local str = ""
    if num == 0 then return str end
    for i=1, num do
        str = str .. " "
    end
    return str
end

local function zoneToStr(pos, walls, flats, indentNum, zone, zoneLabel, zoneScumminess)
    local fileData = ""
    fileData = fileData .. ("%s{\n%spos = vec3(%s, %s, %s),\n"):format(spaces(0 + indentNum), spaces(4 + indentNum), round(pos.x, 3), round(pos.y, 3), round(pos.z, 3))
    fileData = fileData .. ("%szone = \"%s\",\n"):format(spaces(4 + indentNum), zone)
    fileData = fileData .. ("%szoneLabel = \"%s\",\n"):format(spaces(4 + indentNum), zoneLabel)
    fileData = fileData .. ("%szoneScumminess = %s,\n"):format(spaces(4 + indentNum), zoneScumminess)
    fileData = fileData .. ("%swalls = {\n"):format(spaces(4 + indentNum))

    for i=1, #walls do
        local wallPoints = walls[i]
        fileData = fileData .. ("%s{\n"):format(spaces(8 + indentNum))
        for j=1, #wallPoints do
            local points = wallPoints[j]
            fileData = fileData .. ("%s{\n"):format(spaces(12 + indentNum))
            for k=1, #points do
                fileData = fileData .. ("%svec3(%s, %s, %s),\n"):format(spaces(16 + indentNum), round(points[k].x, 3), round(points[k].y, 3), round(points[k].z, 3))
            end
            fileData = fileData .. ("%s},\n"):format(spaces(12 + indentNum))
        end
        fileData = fileData .. ("%s},\n"):format(spaces(8 + indentNum))
    end

    fileData = fileData .. ("%s},\n"):format(spaces(4 + indentNum))
    fileData = fileData .. ("%sflats = {\n"):format(spaces(4 + indentNum))

    for i=1, #flats do
        local plane = flats[i]
        fileData = fileData .. ("%s{\n"):format(spaces(8 + indentNum))
        for j=1, #plane do
            local points = plane[j]
            fileData = fileData .. ("%s{\n"):format(spaces(12 + indentNum))
            for k=1, #points do
                fileData = fileData .. ("%svec3(%s, %s, %s),\n"):format(spaces(16 + indentNum), round(points[k].x, 3), round(points[k].y, 3), round(points[k].z, 3))
            end
            fileData = fileData .. ("%s},\n"):format(spaces(12 + indentNum))
        end
        fileData = fileData .. ("%s},\n"):format(spaces(8 + indentNum))
    end

    fileData = fileData .. ("%s}\n"):format(spaces(4 + indentNum))
    fileData = fileData .. ("%s},\n"):format(spaces(0 + indentNum))

    return fileData
end

local function removeLastCharacter(_filename)
    local resourceName = GetCurrentResourceName()
    local content = LoadResourceFile(resourceName, "//server//" .. _filename) or ""

    if content and #content > 0 then
        content = content:sub(1, -2)
    end

    SaveResourceFile(resourceName, "//server//" .. _filename, content, -1)
end

local function appendToFile(_filename, data)
    local resourceName = GetCurrentResourceName()
    local content = LoadResourceFile(resourceName, "//server//" .. _filename) or ""

    content = content .. data

    SaveResourceFile(resourceName, "//server//" .. _filename, content, -1)
end

RegisterNetEvent("prp-pressurewash:server:saveZone", function(pos, walls, flats, zone, zoneLabel, zoneScumminess)
    local src = source
    if not bridge.fw.isAdmin(src) then
        return
    end

    PressureWashZones[#PressureWashZones + 1] = {
        pos = vec3(round(pos.x, 3), round(pos.y, 3), round(pos.z, 3)),
        zone = zone,
        walls = walls,
        flats = flats,
        subscribers = {},
        zoneLabel = zoneLabel,
        zoneScumminess = zoneScumminess,
    }

    local str = zoneToStr(pos, walls, flats, 4, zone, zoneLabel, zoneScumminess)
    str = str .. "}"
    removeLastCharacter("zones.lua")
    appendToFile("zones.lua", str)
end)
