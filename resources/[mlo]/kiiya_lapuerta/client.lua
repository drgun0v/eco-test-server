local interiors = {
    {
        boxMin = vector3(-472, -946.27, 46.65),
        boxMax = vector3(-442.44, -888.59, 51.06),
        ymapName = "kiiya_puerta_apt1_floor1_milo_",
        isLoaded = true
    },
    {
        boxMin = vector3(-471.95, -945.64, 57.69),
        boxMax = vector3(-442.25, -888.66, 62.86),
        ymapName = "kiiya_puerta_apt1_floor2_milo_",
        isLoaded = true
    },
    {
        boxMin = vector3(-471.95, -945.64, 68.69),
        boxMax = vector3(-442.25, -888.66, 73.21),
        ymapName = "kiiya_puerta_apt1_floor3_milo_",
        isLoaded = true
    },
    {
        boxMin = vector3(-471.95, -945.64, 79.69),
        boxMax = vector3(-442.25, -888.66, 84.86),
        ymapName = "kiiya_puerta_apt1_floor4_milo_",
        isLoaded = true
    },
    {
        boxMin = vector3(-471.95, -945.64, 90.69),
        boxMax = vector3(-442.25, -888.66, 95.86),
        ymapName = "kiiya_puerta_apt1_floor5_milo_",
        isLoaded = true
    },
    {
        boxMin = vector3(-471.95, -945.64, 101.69),
        boxMax = vector3(-442.25, -888.66, 105.86),
        ymapName = "kiiya_puerta_apt1_floor6_milo_",
        isLoaded = true
    },
    {
        boxMin = vector3(-471.95, -945.64, 107.69),
        boxMax = vector3(-442.25, -888.66, 111.86),
        ymapName = "kiiya_puerta_apt1_floor7_milo_",
        isLoaded = true
    },
   {
        boxMin = vector3(-500.483124, -1088.91272, 42.36617),
        boxMax = vector3(-442.024, -1010.929, 47.47124),
        ymapName = "kiiya_puerta_apt2_floor1_milo_",
        isLoaded = true
    },
   {
        boxMin = vector3(-500.483124, -1088.91272, 53.3662071),
        boxMax = vector3(-442.024, -1010.929, 58.47128),
        ymapName = "kiiya_puerta_apt2_floor2_milo_",
        isLoaded = true
    },
   {
        boxMin = vector3(-500.483124, -1088.91272, 64.36621),
        boxMax = vector3(-442.024, -1010.929, 69.47128),
        ymapName = "kiiya_puerta_apt2_floor3_milo_",
        isLoaded = true
    },
   {
        boxMin = vector3(-500.483124, -1088.91272, 75.36623),
        boxMax = vector3(-442.024, -1010.929, 80.4713),
        ymapName = "kiiya_puerta_apt2_floor4_milo_",
        isLoaded = true
    },
   {
        boxMin = vector3(-500.483124, -1088.91272, 86.36623),
        boxMax = vector3(-442.024, -1010.929, 91.4713),
        ymapName = "kiiya_puerta_apt2_floor5_milo_",
        isLoaded = true
    },
   {
        boxMin = vector3(-500.483124, -1088.91272, 97.36623),
        boxMax = vector3(-442.024, -1010.929, 102.4713),
        ymapName = "kiiya_puerta_apt2_floor6_milo_",
        isLoaded = true
    },
   {
        boxMin = vector3(-500.483124, -1088.91272, 102.866241),
        boxMax = vector3(-442.024, -1010.929, 107.971313),
        ymapName = "kiiya_puerta_apt2_floor7_milo_",
        isLoaded = true
    },  
}

Citizen.CreateThread(function()
  SetAmbientZoneStatePersistent("az_los_santos_construction_site_03", false, true)
end)

local function isPlayerOutsideBox(interior)
    local playerCoords = GetEntityCoords(PlayerPedId())
    return playerCoords.x < interior.boxMin.x or playerCoords.x > interior.boxMax.x or
           playerCoords.y < interior.boxMin.y or playerCoords.y > interior.boxMax.y or
           playerCoords.z < interior.boxMin.z or playerCoords.z > interior.boxMax.z
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) 
        for i=1, #interiors do
            local interior = interiors[i]
            if isPlayerOutsideBox(interior) and interior.isLoaded then
                RemoveIpl(interior.ymapName) 
                interior.isLoaded = false
            elseif not isPlayerOutsideBox(interior) and not interior.isLoaded then
                RequestIpl(interior.ymapName) 
                interior.isLoaded = true
            end
        end
    end
end)
