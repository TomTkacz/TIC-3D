function byteToUTF8(codepoint)
    local utf8 = ""
    if codepoint <= 0x7F then
        utf8 = string.char(codepoint)
    elseif codepoint <= 0x7FF then
        utf8 = string.char(
            0xC0 + math.floor(codepoint / 0x40),
            0x80 + (codepoint % 0x40)
        )
    elseif codepoint <= 0xFFFF then
        utf8 = string.char(
            0xE0 + math.floor(codepoint / 0x1000),
            0x80 + (math.floor(codepoint / 0x40) % 0x40),
            0x80 + (codepoint % 0x40)
        )
    elseif codepoint <= 0x10FFFF then
        utf8 = string.char(
            0xF0 + math.floor(codepoint / 0x40000),
            0x80 + (math.floor(codepoint / 0x1000) % 0x40),
            0x80 + (math.floor(codepoint / 0x40) % 0x40),
            0x80 + (codepoint % 0x40)
        )
    else
        error("Code point out of range")
    end
    return utf8
end

function round(n,d)
    if d == 0 then return math.floor(n+0.5) end
	return math.floor(n*math.pow(10,d))/math.pow(10,d)
end

function printTable(t, indent)
    indent = indent or ""
    for key, value in pairs(t) do
        if type(value) == "table" then
            trace(indent .. tostring(key) .. ": ")
            printTable(value, indent .. "  ")
        elseif type(value) ~= "function" then
            trace(indent .. tostring(key) .. ": " .. tostring(value))
        end
    end
end

function copyTable(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[copyTable(k, s)] = copyTable(v, s) end
    return res
end

function getVectorPlaneIntersection(pos,dir,plane)
    local normal = plane.normal
    local planeDotDir = normal:getDotProduct(dir)
    if planeDotDir == 0 then return end
    local t = normal:getDotProduct(plane.origin - pos) / planeDotDir
    return pos + ( dir * t )
end

function getSignedDistToPlane(pos,plane)
    return plane.normal:getDotProduct(pos-plane.origin)
end

function inRads(v)
    return v%(TWO_PI)
end

function triCulled(x1, y1, x2, y2, x3, y3, color, callback)

    if not callback then callback=pix end
    local floor,min,max = math.floor,math.min,math.max

    -- 28.4 fixed-point coordinates
    local Y1 = floor(16.0 * y1 + 0.5)
    local Y2 = floor(16.0 * y2 + 0.5)
    local Y3 = floor(16.0 * y3 + 0.5)

    local X1 = floor(16.0 * x1 + 0.5)
    local X2 = floor(16.0 * x2 + 0.5)
    local X3 = floor(16.0 * x3 + 0.5)

    -- Deltas
    local DX12, DY12 = X1 - X2, Y1 - Y2
    local DX23, DY23 = X2 - X3, Y2 - Y3
    local DX31, DY31 = X3 - X1, Y3 - Y1

    -- Fixed-point deltas
    local FDX12, FDY12 = DX12 * 16, DY12 * 16
    local FDX23, FDY23 = DX23 * 16, DY23 * 16
    local FDX31, FDY31 = DX31 * 16, DY31 * 16

    -- Bounding rectangle
    local minx = floor((min(X1, X2, X3) + 15) / 16)
    local maxx = floor((max(X1, X2, X3) + 15) / 16)
    local miny = floor((min(Y1, Y2, Y3) + 15) / 16)
    local maxy = floor((max(Y1, Y2, Y3) + 15) / 16)

    -- Half-edge constants
    local C1 = DY12 * X1 - DX12 * Y1
    local C2 = DY23 * X2 - DX23 * Y2
    local C3 = DY31 * X3 - DX31 * Y3

    -- Correct for fill convention (CCW winding)
    if DY12 > 0 or (DY12 == 0 and DX12 < 0) then C1 = C1 + 1 end
    if DY23 > 0 or (DY23 == 0 and DX23 < 0) then C2 = C2 + 1 end
    if DY31 > 0 or (DY31 == 0 and DX31 < 0) then C3 = C3 + 1 end

    -- Initialize edge values at top-left corner of bounding box
    local CY1 = C1 + DX12 * (miny * 16) - DY12 * (minx * 16)
    local CY2 = C2 + DX23 * (miny * 16) - DY23 * (minx * 16)
    local CY3 = C3 + DX31 * (miny * 16) - DY31 * (minx * 16)

    -- Loop over bounding box
    for y = miny, maxy - 1 do
        local CX1, CX2, CX3 = CY1, CY2, CY3

        for x = minx, maxx - 1 do
            if CX1 < 0 and CX2 < 0 and CX3 < 0 then -- CCW winding
                callback(x,y,color,{
                    pA={x=x1,y=y1},
                    pB={x=x2,y=y2},
                    pC={x=x3,y=y3}
                })
            end

            CX1 = CX1 - FDY12
            CX2 = CX2 - FDY23
            CX3 = CX3 - FDY31
        end

        CY1 = CY1 + FDX12
        CY2 = CY2 + FDX23
        CY3 = CY3 + FDX31
    end
end