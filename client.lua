
local polygon = {}
local checkpointPositions = {}
local polygonOutlinePoints = {}

Print = function(text)
	TriggerServerEvent('Print', GetPlayerName(GetPlayerId()), text)
end

function AddPolygonPoint()
    local ped = GetPlayerChar(-1)
    local x, y, z = GetCharCoordinates(ped)
    table.insert(polygon, {x, y, z})
    table.insert(checkpointPositions, {x, y, z - 1.0})
    Print("Added point: " .. x .. "," .. y .. "," .. z)
    UpdatePolygonOutline()
end

function ExportPolygon()
    Print("[EXPORTED] Polygon Coords:")
    for _, v in ipairs(polygon) do
        Print(string.format("{ %.5f, %.5f, %.5f },", v[1], v[2], v[3]))
    end
end

function UpdatePolygonOutline()
    polygonOutlinePoints = {}
    for i = 1, #polygon do
        local p1 = polygon[i]
        local p2 = polygon[(i % #polygon) + 1]
        local linePoints = InterpolatePoints(p1, p2, 10)
        for _, pos in ipairs(linePoints) do
            table.insert(polygonOutlinePoints, pos)
        end
    end
end

function InterpolatePoints(p1, p2, segments)
    local points = {}
    for i = 0, segments do
        local t = i / segments
        local x = p1[1] + (p2[1] - p1[1]) * t
        local y = p1[2] + (p2[2] - p1[2]) * t
        local z = p1[3] + (p2[3] - p1[3]) * t
        table.insert(points, {x, y, z})
    end
    return points
end

function StripZ(polygon3D)
    local poly2D = {}
    for _, coord in ipairs(polygon3D) do
        table.insert(poly2D, {coord[1], coord[2]})
    end
    return poly2D
end

function IsPointInPolygon(point, polygon)
    local x, y = point[1], point[2]
    local inside = false

    local j = #polygon
    for i = 1, #polygon do
        local xi, yi = polygon[i][1], polygon[i][2]
        local xj, yj = polygon[j][1], polygon[j][2]

        if ((yi > y) ~= (yj > y)) and
            (x < (xj - xi) * (y - yi) / ((yj - yi) + 0.00001) + xi) then
            inside = not inside
        end
        j = i
    end

    return inside
end

--  Sample polygon for testing (replace with yours)
local polygon3D = {
  { -1824.95947, 374.69708, 25.42347 },
  { -1833.96899, 372.23199, 25.41044 },
  { -1855.81555, 320.34717, 24.97746 },
  { -1824.96655, 374.69742, 25.42145 },
  { -1825.10889, 374.69360, 25.42290 },
  { -1824.34753, 374.42590, 25.42686 },
  { -1833.83557, 371.91864, 25.41043 },
  { -1867.95178, 329.35089, 23.17966 },
  { -1856.02454, 322.44193, 24.76027 },
  { -1824.18860, 374.41882, 25.42791 },
}

polygon = polygon3D
UpdatePolygonOutline()

--  Main loop
CreateThread(function()
    while true do
        Wait(0)

        -- Draw added points
        for _, pos in ipairs(checkpointPositions) do
            DrawCheckpoint(pos[1], pos[2], pos[3], 0.8, 0, 255, 0, 200)
        end

        --[[Draw outline optional
        for _, pos in ipairs(polygonOutlinePoints) do
            DrawCheckpoint(pos[1], pos[2], pos[3], 0.3, 255, 255, 0, 200)
        end]]

        -- Check player inside polygon
        local x, y, z = GetCharCoordinates(GetPlayerChar(-1))
        local polygon2D = StripZ(polygon)
        if IsPointInPolygon({x, y}, polygon2D) then
            DisplayTextWithLiteralString(0.5, 0.9, "STRING", "In Zone") -- remove if you dont want
        else
            DisplayTextWithLiteralString(0.5, 0.9, "STRING", "Out Zone") -- remove if you dont want
        end

        -- Controls
        if IsGameKeyboardKeyJustPressed(18) then -- E
            AddPolygonPoint()
        end
        if IsGameKeyboardKeyJustPressed(33) then -- F
            ExportPolygon()
        end
    end
end)
