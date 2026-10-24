local Interiors = {
    vector3(293.911, -1257.827, 29.412),
    vector3(-533.918762, -1227.76965, 19.5815754),
    vector3(-2065.81348, -325.3963, 14.44404),
    vector3(-73.36257, 6425.72, 32.5940628)
}

local EntitySets = {
    CounterGlassBarrier = "int_xero_counter_glass_barrier",
    Counter = "int_xero_counter"
}

CreateThread(function()
    local setName = Config.EnableGlassBarrier and EntitySets.CounterGlassBarrier or EntitySets.Counter
    for i = 1, #Interiors do
        local interiorID = GetInteriorAtCoords(Interiors[i])
        if interiorID and interiorID ~= 0 then
            LoadInterior(interiorID)
            while not IsInteriorReady(interiorID) do
                Wait(50)
            end
            if not IsInteriorEntitySetActive(interiorID, setName) then
                ActivateInteriorEntitySet(interiorID, setName)
            end
            RefreshInterior(interiorID)
        end
    end
end)