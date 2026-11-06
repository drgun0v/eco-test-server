CreateThread(function()
    while true do
        Wait(500)
        RemoveIpl("gasstation_ipl_group1")
        RemoveIpl("gasstation_ipl_group1_lod")
        RemoveIpl("gasstation_ipl_group2")
        RemoveIpl("gasstation_ipl_group2_lod")
    end
end)