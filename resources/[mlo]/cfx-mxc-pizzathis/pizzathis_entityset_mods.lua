local interiors = {

    ["mxc_pizzathis_vinewoodboulevard"] = {
        coords = vec3(542.0942, 104.0647, 96.5544),
        sets = {
            ["mxc_pizzathis_windows_off"] = false,
            ["mxc_pizzathis_windows_on"] = true,
            ["mxc_pizzathis_kitchendetails"] = true,
        }
    },
    ["mxc_pizzathis_atleestreet"] = {
        coords = vec3(292.2665, -967.3187, 29.435),
        sets = {
            ["mxc_pizzathis_windows_off"] = true,
            ["mxc_pizzathis_windows_on"] = false,
            ["mxc_pizzathis_kitchendetails"] = true,
        }
    },
    ["mxc_pizzathis_delperro"] = {
        coords = vec3(-1524.5308, -908.3739, 10.1822),
        sets = {
            ["mxc_pizzathis_windows_off"] = true,
            ["mxc_pizzathis_windows_on"] = false,
            ["mxc_pizzathis_kitchendetails"] = true,
        }
    },
}


for name, v in pairs(interiors) do
    RequestIpl(name)
    local interior = GetInteriorAtCoordsWithType(v.coords, "mxc_pizzathis_col")
 print(name, interior)
    if IsValidInterior(interior) then
        print(name, "valid")
        for name2, enable in pairs(v.sets) do
            print(name, name2, enable)
            if enable then
                ActivateInteriorEntitySet(interior, name2)
            else
                DeactivateInteriorEntitySet(interior, name2)
            end
        end

        RefreshInterior(interior)
    end
end