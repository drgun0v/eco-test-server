Citizen.CreateThread(function()
    for _, data in pairs(Config.Entitysets) do
        local interiorId = GetInteriorAtCoords(data.coords.x, data.coords.y, data.coords.z)
        
        if interiorId ~= 0 then
            if data.active then
                ActivateInteriorEntitySet(interiorId, data.entityset)
                print("Entity set '" .. data.entityset .. "' has been activated (Interior ID: " .. interiorId .. ")")
            else
                DeactivateInteriorEntitySet(interiorId, data.entityset)
                print("Entity set '" .. data.entityset .. "' has been deactivated (Interior ID: " .. interiorId .. ")")
            end
            
            RefreshInterior(interiorId)
        end
    end
end)