Config = Config or {}

-- Helper to generate a grid of offsets so you don't have to type them manually
local function generateGrid(rows, cols, spacing)
    local offsets = {}
    for x = 1, rows do
        for y = 1, cols do
            offsets[#offsets+1] = vec3((x-rows/2)*spacing, (y-cols/2)*spacing, 0.0)
        end
    end
    return offsets
end

Config.Fields = {
    {
        id        = 'wheat_field_1',
        label     = 'Wheat Field',
        crop      = 'wheat',
        center    = vec3(2638.140625, 4698.026367, 35.463745),
        npcCoords = vec4(2624.360352, 4687.991211, 33.677612, 317.480316), -- Where the NPC stands
        npcModel  = `a_m_m_farmer_01`,
        propHeading = 223.1,
        -- Generate 10 spots (2 rows of 5, 2.5m apart)
        offsets   = generateGrid(2, 5, 6.5) 
    },
}