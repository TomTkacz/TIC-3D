--
-- Bundle file
-- Code changes will be overwritten
--

-- title: 3D
-- author:  Tom Tkacz, github.com/TomTkacz
-- desc:    3D rendering
-- site:    https://www.thomastkacz.com
-- license: MIT License
-- script:  lua

-- [TQ-Bundler: include.Lookup]

SIN = {
    0.0, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1, 0.11, 0.12, 0.129, 0.139, 0.149, 0.159, 0.169, 0.179, 0.189, 0.198, 0.208, 0.218, 0.228, 0.237, 0.247, 0.257, 0.266, 0.276, 0.286, 0.295, 0.305, 0.314, 0.324, 0.333, 0.343, 0.352, 0.361, 0.371, 0.38, 0.389, 0.398, 0.407, 0.416, 0.426, 0.435, 0.444, 0.452, 0.461, 0.47, 0.479, 0.488, 0.496, 0.505, 0.514, 0.522, 0.531, 0.539, 0.547, 0.556, 0.564, 0.572, 0.58, 0.589, 0.597, 0.605, 0.613, 0.62, 0.628, 0.636, 0.644, 0.651, 0.659, 0.666, 0.674, 0.681, 0.688, 0.696, 0.703, 0.71, 0.717, 0.724, 0.731, 0.737, 0.744, 0.751, 0.757, 0.764, 0.77, 0.776, 0.783, 0.789, 0.795, 0.801, 0.807, 0.813, 0.819, 0.824, 0.83, 0.835, 0.841, 0.846, 0.852, 0.857, 0.862, 0.867, 0.872, 0.877, 0.881, 0.886, 0.891, 0.895, 0.9, 0.904, 0.908, 0.912, 0.916, 0.92, 0.924, 0.928, 0.932, 0.935, 0.939, 0.942, 0.945, 0.949, 0.952, 0.955, 0.958, 0.96, 0.963, 0.966, 0.968, 0.971, 0.973, 0.975, 0.978, 0.98, 0.982, 0.983, 0.985, 0.987, 0.988, 0.99, 0.991, 0.993, 0.994, 0.995, 0.996, 0.997, 0.997, 0.998, 0.999, 0.999, 0.999, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.999, 0.999, 0.998, 0.998, 0.997, 0.996, 0.995, 0.994, 0.993, 0.992, 0.991, 0.989, 0.988, 0.986, 0.984, 0.983, 0.981, 0.979, 0.976, 0.974, 0.972, 0.97, 0.967, 0.965, 0.962, 0.959, 0.956, 0.953, 0.95, 0.947, 0.944, 0.94, 0.937, 0.933, 0.93, 0.926, 0.922, 0.918, 0.914, 0.91, 0.906, 0.902, 0.897, 0.893, 0.888, 0.884, 0.879, 0.874, 0.869, 0.864, 0.859, 0.854, 0.849, 0.844, 0.838, 0.833, 0.827, 0.821, 0.816, 0.81, 0.804, 0.798, 0.792, 0.786, 0.78, 0.773, 0.767, 0.76, 0.754, 0.747, 0.741, 0.734, 0.727, 0.72, 0.713, 0.706, 0.699, 0.692, 0.685, 0.677, 0.67, 0.663, 0.655, 0.647, 0.64, 0.632, 0.624, 0.616, 0.609, 0.601, 0.593, 0.585, 0.576, 0.568, 0.56, 0.552, 0.543, 0.535, 0.526, 0.518, 0.509, 0.501, 0.492, 0.483, 0.475, 0.466, 0.457, 0.448, 0.439, 0.43, 0.421, 0.412, 0.403, 0.394, 0.384, 0.375, 0.366, 0.357, 0.347, 0.338, 0.328, 0.319, 0.309, 0.3, 0.29, 0.281, 0.271, 0.262, 0.252, 0.242, 0.233, 0.223, 0.213, 0.203, 0.194, 0.184, 0.174, 0.164, 0.154, 0.144, 0.134, 0.125, 0.115, 0.105, 0.095, 0.085, 0.075, 0.065, 0.055, 0.045, 0.035, 0.025, 0.015, 0.005, -0.005, -0.015, -0.025, -0.035, -0.045, -0.055, -0.065, -0.075, -0.085, -0.095, -0.105, -0.115, -0.125, -0.134, -0.144, -0.154, -0.164, -0.174, -0.184, -0.194, -0.203, -0.213, -0.223, -0.233, -0.242, -0.252, -0.262, -0.271, -0.281, -0.29, -0.3, -0.309, -0.319, -0.328, -0.338, -0.347, -0.357, -0.366, -0.375, -0.384, -0.394, -0.403, -0.412, -0.421, -0.43, -0.439, -0.448, -0.457, -0.466, -0.475, -0.483, -0.492, -0.501, -0.509, -0.518, -0.526, -0.535, -0.543, -0.552, -0.56, -0.568, -0.576, -0.585, -0.593, -0.601, -0.609, -0.616, -0.624, -0.632, -0.64, -0.647, -0.655, -0.663, -0.67, -0.677, -0.685, -0.692, -0.699, -0.706, -0.713, -0.72, -0.727, -0.734, -0.741, -0.747, -0.754, -0.76, -0.767, -0.773, -0.78, -0.786, -0.792, -0.798, -0.804, -0.81, -0.816, -0.821, -0.827, -0.833, -0.838, -0.844, -0.849, -0.854, -0.859, -0.864, -0.869, -0.874, -0.879, -0.884, -0.888, -0.893, -0.897, -0.902, -0.906, -0.91, -0.914, -0.918, -0.922, -0.926, -0.93, -0.933, -0.937, -0.94, -0.944, -0.947, -0.95, -0.953, -0.956, -0.959, -0.962, -0.965, -0.967, -0.97, -0.972, -0.974, -0.976, -0.979, -0.981, -0.983, -0.984, -0.986, -0.988, -0.989, -0.991, -0.992, -0.993, -0.994, -0.995, -0.996, -0.997, -0.998, -0.998, -0.999, -0.999, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -0.999, -0.999, -0.999, -0.998, -0.997, -0.997, -0.996, -0.995, -0.994, -0.993, -0.991, -0.99, -0.988, -0.987, -0.985, -0.983, -0.982, -0.98, -0.978, -0.975, -0.973, -0.971, -0.968, -0.966, -0.963, -0.96, -0.958, -0.955, -0.952, -0.949, -0.945, -0.942, -0.939, -0.935, -0.932, -0.928, -0.924, -0.92, -0.916, -0.912, -0.908, -0.904, -0.9, -0.895, -0.891, -0.886, -0.881, -0.877, -0.872, -0.867, -0.862, -0.857, -0.852, -0.846, -0.841, -0.835, -0.83, -0.824, -0.819, -0.813, -0.807, -0.801, -0.795, -0.789, -0.783, -0.776, -0.77, -0.764, -0.757, -0.751, -0.744, -0.737, -0.731, -0.724, -0.717, -0.71, -0.703, -0.696, -0.688, -0.681, -0.674, -0.666, -0.659, -0.651, -0.644, -0.636, -0.628, -0.62, -0.613, -0.605, -0.597, -0.589, -0.58, -0.572, -0.564, -0.556, -0.547, -0.539, -0.531, -0.522, -0.514, -0.505, -0.496, -0.488, -0.479, -0.47, -0.461, -0.452, -0.444, -0.435, -0.426, -0.416, -0.407, -0.398, -0.389, -0.38, -0.371, -0.361, -0.352, -0.343, -0.333, -0.324, -0.314, -0.305, -0.295, -0.286, -0.276, -0.266, -0.257, -0.247, -0.237, -0.228, -0.218, -0.208, -0.198, -0.189, -0.179, -0.169, -0.159, -0.149, -0.139, -0.129, -0.12, -0.11, -0.1, -0.09, -0.08, -0.07, -0.06, -0.05, -0.04, -0.03, -0.02, -0.01
}

COS = {
    1.0, 1.0, 1.0, 1.0, 0.999, 0.999, 0.998, 0.998, 0.997, 0.996, 0.995, 0.994, 0.993, 0.992, 0.99, 0.989, 0.987, 0.986, 0.984, 0.982, 0.98, 0.978, 0.976, 0.974, 0.971, 0.969, 0.966, 0.964, 0.961, 0.958, 0.955, 0.952, 0.949, 0.946, 0.943, 0.94, 0.936, 0.932, 0.929, 0.925, 0.921, 0.917, 0.913, 0.909, 0.905, 0.901, 0.896, 0.892, 0.887, 0.883, 0.878, 0.873, 0.868, 0.863, 0.858, 0.853, 0.848, 0.842, 0.837, 0.831, 0.826, 0.82, 0.814, 0.808, 0.803, 0.797, 0.79, 0.784, 0.778, 0.772, 0.765, 0.759, 0.752, 0.746, 0.739, 0.732, 0.725, 0.718, 0.712, 0.704, 0.697, 0.69, 0.683, 0.676, 0.668, 0.661, 0.653, 0.646, 0.638, 0.63, 0.622, 0.615, 0.607, 0.599, 0.591, 0.583, 0.574, 0.566, 0.558, 0.55, 0.541, 0.533, 0.524, 0.516, 0.507, 0.499, 0.49, 0.481, 0.472, 0.464, 0.455, 0.446, 0.437, 0.428, 0.419, 0.41, 0.4, 0.391, 0.382, 0.373, 0.364, 0.354, 0.345, 0.335, 0.326, 0.317, 0.307, 0.298, 0.288, 0.278, 0.269, 0.259, 0.25, 0.24, 0.23, 0.22, 0.211, 0.201, 0.191, 0.181, 0.171, 0.162, 0.152, 0.142, 0.132, 0.122, 0.112, 0.102, 0.092, 0.082, 0.072, 0.062, 0.052, 0.042, 0.032, 0.022, 0.012, 0.002, -0.007, -0.017, -0.027, -0.037, -0.047, -0.057, -0.067, -0.077, -0.087, -0.097, -0.107, -0.117, -0.127, -0.137, -0.147, -0.157, -0.167, -0.176, -0.186, -0.196, -0.206, -0.216, -0.225, -0.235, -0.245, -0.254, -0.264, -0.274, -0.283, -0.293, -0.302, -0.312, -0.321, -0.331, -0.34, -0.35, -0.359, -0.368, -0.377, -0.387, -0.396, -0.405, -0.414, -0.423, -0.432, -0.441, -0.45, -0.459, -0.468, -0.477, -0.486, -0.494, -0.503, -0.511, -0.52, -0.529, -0.537, -0.545, -0.554, -0.562, -0.57, -0.578, -0.587, -0.595, -0.603, -0.611, -0.618, -0.626, -0.634, -0.642, -0.649, -0.657, -0.664, -0.672, -0.679, -0.687, -0.694, -0.701, -0.708, -0.715, -0.722, -0.729, -0.736, -0.742, -0.749, -0.756, -0.762, -0.769, -0.775, -0.781, -0.787, -0.793, -0.8, -0.805, -0.811, -0.817, -0.823, -0.829, -0.834, -0.84, -0.845, -0.85, -0.855, -0.861, -0.866, -0.871, -0.875, -0.88, -0.885, -0.89, -0.894, -0.898, -0.903, -0.907, -0.911, -0.915, -0.919, -0.923, -0.927, -0.931, -0.934, -0.938, -0.941, -0.945, -0.948, -0.951, -0.954, -0.957, -0.96, -0.963, -0.965, -0.968, -0.97, -0.973, -0.975, -0.977, -0.979, -0.981, -0.983, -0.985, -0.986, -0.988, -0.99, -0.991, -0.992, -0.993, -0.995, -0.996, -0.996, -0.997, -0.998, -0.998, -0.999, -0.999, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -0.999, -0.999, -0.998, -0.998, -0.997, -0.996, -0.996, -0.995, -0.993, -0.992, -0.991, -0.99, -0.988, -0.986, -0.985, -0.983, -0.981, -0.979, -0.977, -0.975, -0.973, -0.97, -0.968, -0.965, -0.963, -0.96, -0.957, -0.954, -0.951, -0.948, -0.945, -0.941, -0.938, -0.934, -0.931, -0.927, -0.923, -0.919, -0.915, -0.911, -0.907, -0.903, -0.898, -0.894, -0.89, -0.885, -0.88, -0.875, -0.871, -0.866, -0.861, -0.855, -0.85, -0.845, -0.84, -0.834, -0.829, -0.823, -0.817, -0.811, -0.805, -0.8, -0.793, -0.787, -0.781, -0.775, -0.769, -0.762, -0.756, -0.749, -0.742, -0.736, -0.729, -0.722, -0.715, -0.708, -0.701, -0.694, -0.687, -0.679, -0.672, -0.664, -0.657, -0.649, -0.642, -0.634, -0.626, -0.618, -0.611, -0.603, -0.595, -0.587, -0.578, -0.57, -0.562, -0.554, -0.545, -0.537, -0.529, -0.52, -0.511, -0.503, -0.494, -0.486, -0.477, -0.468, -0.459, -0.45, -0.441, -0.432, -0.423, -0.414, -0.405, -0.396, -0.387, -0.377, -0.368, -0.359, -0.35, -0.34, -0.331, -0.321, -0.312, -0.302, -0.293, -0.283, -0.274, -0.264, -0.254, -0.245, -0.235, -0.225, -0.216, -0.206, -0.196, -0.186, -0.176, -0.167, -0.157, -0.147, -0.137, -0.127, -0.117, -0.107, -0.097, -0.087, -0.077, -0.067, -0.057, -0.047, -0.037, -0.027, -0.017, -0.007, 0.002, 0.012, 0.022, 0.032, 0.042, 0.052, 0.062, 0.072, 0.082, 0.092, 0.102, 0.112, 0.122, 0.132, 0.142, 0.152, 0.162, 0.171, 0.181, 0.191, 0.201, 0.211, 0.22, 0.23, 0.24, 0.25, 0.259, 0.269, 0.278, 0.288, 0.298, 0.307, 0.317, 0.326, 0.335, 0.345, 0.354, 0.364, 0.373, 0.382, 0.391, 0.4, 0.41, 0.419, 0.428, 0.437, 0.446, 0.455, 0.464, 0.472, 0.481, 0.49, 0.499, 0.507, 0.516, 0.524, 0.533, 0.541, 0.55, 0.558, 0.566, 0.574, 0.583, 0.591, 0.599, 0.607, 0.615, 0.622, 0.63, 0.638, 0.646, 0.653, 0.661, 0.668, 0.676, 0.683, 0.69, 0.697, 0.704, 0.712, 0.718, 0.725, 0.732, 0.739, 0.746, 0.752, 0.759, 0.765, 0.772, 0.778, 0.784, 0.79, 0.797, 0.803, 0.808, 0.814, 0.82, 0.826, 0.831, 0.837, 0.842, 0.848, 0.853, 0.858, 0.863, 0.868, 0.873, 0.878, 0.883, 0.887, 0.892, 0.896, 0.901, 0.905, 0.909, 0.913, 0.917, 0.921, 0.925, 0.929, 0.932, 0.936, 0.94, 0.943, 0.946, 0.949, 0.952, 0.955, 0.958, 0.961, 0.964, 0.966, 0.969, 0.971, 0.974, 0.976, 0.978, 0.98, 0.982, 0.984, 0.986, 0.987, 0.989, 0.99, 0.992, 0.993, 0.994, 0.995, 0.996, 0.997, 0.998, 0.998, 0.999, 0.999, 1.0, 1.0, 1.0
}

function sinq(x)
    return SIN[ 1 + math.floor( ( x%TWO_PI ) * 100 ) ]
end

function cosq(x)
    return COS[ 1 + math.floor( ( x%TWO_PI ) * 100 ) ]
end

-- [/TQ-Bundler: include.Lookup]

-- [TQ-Bundler: include.Utils]

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
    local areaABC = math.abs( (x1*(y2-y3)) + (x2*(y3-y1)) + (x3*(y1-y2)) ) / 2

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
    local FDX12, FDY12 = DX12 << 4, DY12 << 4
    local FDX23, FDY23 = DX23 << 4, DY23 << 4
    local FDX31, FDY31 = DX31 << 4, DY31 << 4

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
    local CY1 = C1 + DX12 * (miny << 4) - DY12 * (minx << 4)
    local CY2 = C2 + DX23 * (miny << 4) - DY23 * (minx << 4)
    local CY3 = C3 + DX31 * (miny << 4) - DY31 * (minx << 4)

    -- Loop over bounding box
    for y = miny, maxy - 1 do
        local CX1, CX2, CX3 = CY1, CY2, CY3

        for x = minx, maxx - 1 do
            if CX1 < 0 and CX2 < 0 and CX3 < 0 then -- CCW winding
                callback(x,y,color,{
                    pA={x=x1,y=y1},
                    pB={x=x2,y=y2},
                    pC={x=x3,y=y3},
                    areaABC=areaABC
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

-- [/TQ-Bundler: include.Utils]

-- [TQ-Bundler: include.LoadObjects]

function loadObjects()
	objects={}

	bytesOffset = 0

	-- get current byte address from byte offset
	local function curByteAddr()
		return MAP_BASE_ADDRESS+bytesOffset
	end

	-- get current nibble address from byte offset
	local function curNibbleAddr()
		return (MAP_BASE_ADDRESS+bytesOffset)*2
	end

	-- get current bit address from byte offset
	local function curBitAddr()
		return (MAP_BASE_ADDRESS+bytesOffset)*8
	end

	while bytesOffset < MAP_SIZE_BYTES do

		meshID = ""

		for i=1,12 do
			if peek(curByteAddr()) ~= 0 then
				meshID = meshID..byteToUTF8(peek(curByteAddr()))
			end
			bytesOffset = bytesOffset + 1
		end

		numberOfTriangles = peek(curByteAddr())
		if numberOfTriangles == 0 then break end

		mesh = {meshID=meshID,numberOfTriangles=numberOfTriangles,triangles={}}

		bytesOffset = bytesOffset + 2 -- skip over flags for now

		for a=1,numberOfTriangles do

			triangle={vertices={}}

			for b=1,3 do

				vertex={}

				for c=1,3 do

					-- reads first bit
					if peek(curBitAddr()+7,1) == 0 then sign=1 else sign=-1 end
					
					-- reads byte, removes leftmost bit, shifts left once, ORs with first bit of next byte
					b1 = peek(curByteAddr())
					if b1 >= 128 then b1 = b1 - 128 end
					b1 = b1 << 1
					b1 = b1 | (peek(curByteAddr()+1) >> 7)
					bytesOffset = bytesOffset + 1

					b2 = peek(curByteAddr())
					if b2 >= 128 then b2 = b2 - 128 end
					b2 = b2 << 1
					b2 = b2 | (peek(curByteAddr()+1) >> 7)
					bytesOffset = bytesOffset + 1

					-- reads byte, shifts right 3, removes bit 4
					b3 = peek(curByteAddr())
					b3 = b3 >> 3
					if b3 >= 16 then b3 = b3 - 16 end
					
					-- reads last 4 bits of byte and removes leftmost bit
					exp = peek(curNibbleAddr(),4)
					if exp >= 8 then exp = exp - 8 end

					-- ORs together all parts of base num
					b1 = b1 << 12
					b2 = b2 << 4
					base = b1 | b2 | b3

					-- calculates the final float value
					float = base*math.pow(10,-exp)*sign

					table.insert(vertex,float)
					
					bytesOffset = bytesOffset + 1
				end

				table.insert(triangle.vertices,Pos3D(table.unpack(vertex)))
				
			end

			triangle.center = getTriangleCircumcenter(triangle.vertices[1],triangle.vertices[2],triangle.vertices[3])

			table.insert(mesh.triangles,triangle)

		end

		origin=calculateMeshOrigin(mesh)
		mesh=getMeshRelativeToOrigin(mesh,origin)
		mesh.origin=origin
		objects[meshID] = mesh

	end

	scene.loadedObjects = objects
	for k,_ in pairs(scene.loadedObjects) do trace(k) end

end


-- [/TQ-Bundler: include.LoadObjects]

-- [TQ-Bundler: class.Camera]

Camera={}
Camera.mt={}
Camera.mti={}

function Camera.mt.__call(self,pos,rot,dir)

    local s={
        pos=pos,
        rot=rot,
        dir=dir,
    }

    function s:initalizeClippingPlanes()

        self.clippingPlanes = {

            near={
                origin=WORLD_ORIGIN,
                normalTheta=0,
            },
    
            left={
                origin=WORLD_ORIGIN,
                normalTheta=-(viewport.fov/2)+(PI_OVER_TWO),
            },
    
            right={
                origin=WORLD_ORIGIN,
                normalTheta=(viewport.fov/2)-(PI_OVER_TWO),
            },
    
            top={
                origin=WORLD_ORIGIN,
                normalTheta=(viewport._vfov/2)-(PI_OVER_TWO),
            },
    
            bottom={
                origin=WORLD_ORIGIN,
                normalTheta=-(viewport._vfov/2)+(PI_OVER_TWO)
            },
    
        }

    end

    function s:rotate(r)
        self.rot=self.rot+r
        self.dir:rotate(r.x,r.y,r.z)
    end

    function s:updateClippingPlanes()

        for k,p in pairs(self.clippingPlanes) do
            local rotationAxis = (k=="left" or k=="right") and self.verticalVector or self.horizontalVector
            local normal = self.dir:getCopy()
            normal:rotateAboutAxis(rotationAxis,p.normalTheta)
            self.clippingPlanes[k].normal = normal
            self.clippingPlanes[k].origin = self.pos
        end

    end

    function s:updateVectors()
        local horizontalX,horizontalZ = cosq(PI-self.rot.y),sinq(PI-self.rot.y)
        local hv,vv = self.horizontalVector,self.verticalVector
        if not hv then self.horizontalVector = Dir3D(); hv = self.horizontalVector end
        if not vv then self.verticalVector = Y_AXIS end
        hv.x,hv.y,hv.z = horizontalX,0,horizontalZ
    end

    function s:isPointInView(p,r)
        
        if r==nil then r=0 end
        local errorMargin = 0.005

        for _,plane in pairs(self.clippingPlanes) do
            if getSignedDistToPlane(p,plane) < -r - errorMargin then return false
        end

        return true end

    end

    setmetatable(s,Camera.mti)

    s:rotate(s.rot)
    s:updateVectors()

    return s

end

setmetatable(Camera,Camera.mt)

-- [/TQ-Bundler: class.Camera]

-- [TQ-Bundler: class.Pos3D]

Pos3D={}
Pos3D.mt={}
Pos3D.mti={}

function Pos3D.mt.__call(self,x,y,z,w)
	local s={x=x,y=y,z=z,w=(w or 1)}
	s.matrix=Matrix4D.fromVector3D(s)

	function s:updateMatrix()
		self.matrix.values={{self.x},{self.y},{self.z},{self.w}}
	end

	function s:getCopy()
		return Pos3D(self.x,self.y,self.z,self.w)
	end

	function s:getDotProduct(p2)
		return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)+(self.w*p2.w)
	end

	function s:scale(sx,sy,sz)
		local m=self.matrix
		m:applyScaleFactor(sx,sy,sz)
		self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
		self:updateMatrix()
	end

	function s:translate(tx,ty,tz)
		local m=self.matrix
		m:applyTranslation(tx,ty,tz)
		self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
		self:updateMatrix()
	end

	function s:rotateAboutAxis(dir,angle)
		local m=self.matrix
		m:applyAxisAngleRotation(dir,angle)
		self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
		self:updateMatrix()
	end

	function s:getCrossProduct(v)
		local x = ( self.y * v.z ) - ( v.y * self.z )
		local y = ( self.z * v.x ) - ( v.z * self.x )
		local z = ( self.x * v.y ) - ( v.x * self.y )
		return Pos3D(x,y,z,self.w)
	end

	function s:toLocalTransform(origin,rot,scale)
		return self.matrix:toLocalTransform(origin,rot,scale)
	end

	function s:toScreenSpace()
		return self.matrix:toScreenSpace()
	end
	
	function s:getMagnitude()
		if s.w == 0 then
			return math.sqrt(self:getDotProduct(self))
		end
		return math.sqrt(math.abs(self:getDotProduct(self)-1))
	end

	function s:toCameraTransform()

		local m = self.matrix:getCopy()
		local pos = camera.pos
		local rot = camera.rot
		local posx,posy,posz=pos.x,pos.y,pos.z
		local rotx,roty,rotz=rot.x,rot.y,rot.z

		-- translate/rotate about the camera
		m:applyTranslation(-posx,-posy,-posz)
		m:applyAxisAngleRotation(X_AXIS,-rotx)
		m:applyAxisAngleRotation(Y_AXIS,PI-roty)
		m:applyAxisAngleRotation(Z_AXIS,-rotz)

		return Pos3D.fromMatrix4D(m)

	end

	function s:canonical()
		local div = 1
		if self.w ~= 0 then div=self.w end
		return Pos3D(self.x/div,self.y/div,self.z/div,1)
	end

	setmetatable(s,Pos3D.mti)
	return s
end

function Pos3D.fromMatrix4D(m)
	return Pos3D(m[1][1],m[2][1],m[3][1],m[4][1])
end

function Pos3D.mti.__add(self,v)
	if not type(v) == "table" then return end
	return Pos3D(self.x+v.x,self.y+v.y,self.z+v.z,self.w+v.w)
end

function Pos3D.mti.__sub(self,v)
	if not type(v) == "table" then return end
	return Pos3D(self.x-v.x,self.y-v.y,self.z-v.z,self.w-v.w)
end

function Pos3D.mti.__mul(self,v)
	if type(v) == "number" then
		return Pos3D(self.x*v,self.y*v,self.z*v,self.w*v)
	elseif type(v) == "table" then
		return Pos3D(self.x*v.x,self.y*v.y,self.z*v.z,self.w*v.w)
	end
end

function Pos3D.mti.__div(self,v)
	if type(v) == "number" then
		return Pos3D(self.x/v,self.y/v,self.z/v,self.w/v)
	elseif type(v) == "table" then
		return Pos3D(self.x/v.x,self.y/v.y,self.z/v.z,self.w/v.w)
	end
end

setmetatable(Pos3D,Pos3D.mt)

-- [/TQ-Bundler: class.Pos3D]

-- [TQ-Bundler: class.Pos2D]

Pos2D={}
Pos2D.mt={}
Pos2D.mti={}

function Pos2D.mt.__call(self,x,y)
	local s={x=x,y=y}
	setmetatable(s,Pos2D.mti)
	return s
end

function Pos2D.fromMatrix(m)
	local rows = #m
	local p = Pos2D(m[1][1],m[2][1])
	if rows > 2 then
		p.x = p.x/m[3][1]
		p.y = p.y/m[3][1]
	end
	return p
end

setmetatable(Pos2D,Pos2D.mt)

-- [/TQ-Bundler: class.Pos2D]

-- [TQ-Bundler: class.Rot3D]

Rot3D={}
Rot3D.mt={}
Rot3D.mti={}

function Rot3D.mt.__call(self,x,y,z)
	local s={x=x,y=y,z=z}

	function s:rotate(x,y,z)
		self.x=self.x+x
		self.y=self.y+y
		self.z=self.z+z
	end

	function s:rotateAboutAxis(dir,angle)
		local m=Matrix.fromVector(self)
		m:applyAxisAngleRotation(dir,angle)
		self.x,self.y,self.z = table.unpack(m[1])
	end

	setmetatable(s,Rot3D.mti)
	return s
end

function Rot3D.mti.__add(self,v)
	if not type(v) == "table" then return end
	return Rot3D(inRads(self.x+v.x),inRads(self.y+v.y),inRads(self.z+v.z))
end

function Rot3D.mti.__sub(self,v)
	if not type(v) == "table" then return end
	return Rot3D(inRads(self.x-v.x),inRads(self.y-v.y),inRads(self.z-v.z))
end

function Rot3D.mti.__mul(self,v)
	if type(v) == "table" then
		return Rot3D(inRads(self.x*v.x),inRads(self.y*v.y),inRads(self.z*v.z))
	elseif type(v) == "number" then
		return Rot3D(inRads(self.x*v),inRads(self.y*v),inRads(self.z*v))
	else return end
end

function Rot3D.mti.__unm(self)
	return Rot3D(-self.x,-self.y,-self.z)
end

function Rot3D.fromMatrix(m)
	if m.rows~=1 or m.cols~=3 then return end
	return Rot3D(m[1][1],m[1][2],m[1][3])
end

setmetatable(Rot3D,Rot3D.mt)

-- [/TQ-Bundler: class.Rot3D]

-- [TQ-Bundler: class.Dir3D]

Dir3D={}
Dir3D.mt={}
Dir3D.mti={}

function Dir3D.mt.__call(self,x,y,z,w)
	local s={x=x,y=y,z=z,w=(w or 0)}
	s.matrix=Matrix4D.fromVector3D(s)
	return setmetatable(s,Dir3D.mti)
end

function Dir3D:getCopy()
	return Dir3D(self.x,self.y,self.z,self.w)
end

function Dir3D:updateMatrix()
	self.matrix.values={{self.x},{self.y},{self.z},{self.w}}
end

function Dir3D:getDotProduct(p2)
	return (self.x*p2.x)+(self.y*p2.y)+(self.z*p2.z)
end

function Dir3D:getCrossProduct(v)
	local x = ( self.y * v.z ) - ( v.y * self.z )
	local y = ( self.z * v.x ) - ( v.z * self.x )
	local z = ( self.x * v.y ) - ( v.x * self.y )
	return Dir3D(x,y,z,self.w)
end

function Dir3D:rotate(x,y,z)
	local m=self.matrix
	m:applyRotation(x,y,z)
	self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
	self:updateMatrix()
end

function Dir3D:rotateAboutAxis(dir,angle)
	local m=self.matrix
	m:applyAxisAngleRotation(dir,angle)
	self.x,self.y,self.z,self.w = m[1][1],m[2][1],m[3][1],m[4][1]
	self:updateMatrix()
end

function Dir3D:getCanonical()
	local div=self.w
	if self.w == 0 then div = 1 end
	return Dir3D(self.x/div,self.y/div,self.z/div,0)
end

function Dir3D:getMagnitude()
	local v = self:getCanonical()
	if v.w == 0 then
		return math.sqrt(math.abs(v:getDotProduct(v)))
	end
	return math.sqrt(math.abs(v:getDotProduct(v))-1)
end

function Dir3D.mti.__index(self,i)
	return Dir3D[i]
end

function Dir3D.mti.__add(self,v)
	if not type(v) == "table" then return end
	return Dir3D(self.x+v.x,self.y+v.y,self.z+v.z,self.w+v.w)
end

function Dir3D.mti.__sub(self,v)
	if not type(v) == "table" then return end
	return Dir3D(self.x-v.x,self.y-v.y,self.z-v.z,self.w-v.w)
end

function Dir3D.mti.__mul(self,v)
	if type(v) == "table" then
		return Dir3D(self.x*v.x,self.y*v.y,self.z*v.z,self.w*v.w)
	elseif type(v) == "number" then
		return Dir3D(self.x*v,self.y*v,self.z*v,self.w*v)
	else return end
end

function Dir3D.mti.__unm(self)
	return Dir3D(-self.x,-self.y,-self.z,-self.w)
end

function Dir3D.fromMatrix4D(m)
	return Dir3D(m[1][1],m[2][1],m[3][1],m[4][1])
end

setmetatable(Dir3D,Dir3D.mt)

-- [/TQ-Bundler: class.Dir3D]

-- [TQ-Bundler: class.Size2D]

Size2D={}
Size2D.mt={}
Size2D.mti={}

function Size2D.mt.__call(self,w,h)
	local s={w=w,h=h}
	setmetatable(s,Size2D.mti)
	return s
end

setmetatable(Size2D,Size2D.mt)

-- [/TQ-Bundler: class.Size2D]

-- [TQ-Bundler: class.Ray]

Ray={}
Ray.mt={}
Ray.mti={}

function Ray.mt.__call(self,pos,dir)
	local s={pos=pos,dir=dir}
	setmetatable(s,Ray.mti)
	return s
end

function Ray.fromPoints(pos1,pos2)
	return Ray(Pos3D(pos1.x,pos1.y,pos1.z),dirBetween3DPoints(pos1,pos2))
end

setmetatable(Ray,Ray.mt)

-- [/TQ-Bundler: class.Ray]

-- [TQ-Bundler: class.Matrix]

Matrix={}
Matrix.mt={}
Matrix.mti={}

function Matrix.mt.__call(self,rows,cols)
    local values = {}
    for row = 1, rows do
        local rowValues = {}
        for col = 1, cols do
            rowValues[col] = 0
        end
        values[row] = rowValues
    end
    local s = { rows = rows, cols = cols, values = values }
    return setmetatable(s, Matrix.mti)
end

function Matrix.mti.__index(self,i)
	return self.values[i]
end

function Matrix.mti.__add(self,m)
	n=Matrix(self.rows,self.cols)
	for row=1,self.rows do
		for col=1,self.cols do
			n[row][col] = self[row][col]+m[row][col]
		end
	end
	return n
end

function Matrix.mti.__sub(self,m)
	n=Matrix(self.rows,self.cols)
	for row=1,self.rows do
		for col=1,self.cols do
			n[row][col] = self[row][col]-m[row][col]
		end
	end
	return n
end

function Matrix.mti.__mul(self,m2)
	-- multiply rows with columns
	local m1=self
	local mtx = Matrix(m1.rows,m2.cols)
	for i = 1,m1.rows do
		for j = 1,m2.cols do
			local num = m1.values[i][1] * m2.values[1][j]
			for n = 2,m1.cols do
				num = num + m1.values[i][n] * m2.values[n][j]
			end
			mtx.values[i][j] = num
		end
	end
	return mtx
end

setmetatable(Matrix,Matrix.mt)

Matrix.M44 = Matrix(4,4)
Matrix.M41 = Matrix(4,1)

function Matrix.bindLocalMatrixToFunction(func,rows,cols,initialValuesTable)
	local m = Matrix(rows,cols)
	local unpack = table.unpack
	function transform(...)
		local params={...}
		if initialValuesTable then m.values = initialValuesTable end
		return func(m,unpack(params))
	end
	return transform
end

-- [/TQ-Bundler: class.Matrix]

-- [TQ-Bundler: class.Matrix4D]

Matrix4D={}
Matrix4D.mt={}
Matrix4D.mti={}

Matrix4D.rotationMatrixX,Matrix4D.rotationMatrixY,Matrix4D.rotationMatrixZ,Matrix4D.screenProjectionMatrix = Matrix(4,4),Matrix(4,4),Matrix(4,4),Matrix(4,4)

Matrix4D.rotationMatrixX.values = {
	{ 1, 0, 0, 0},
	{ 0, "cosx", "-sinx", 0 },
	{ 0, "sinx", "cosx", 0 },
	{ 0, 0, 0, 1}
}
Matrix4D.rotationMatrixY.values = {
	{ "cosy", 0, "siny", 0},
	{ 0, 1, 0, 0 },
	{ "-siny", 0, "cosy", 0 },
	{ 0, 0, 0, 1}
}
Matrix4D.rotationMatrixZ.values = {
	{ "cosz", "-sinz", 0, 0},
	{ "sinz", "cosz", 0, 0},
	{ 0, 0, 1, 0},
	{ 0, 0, 0, 1}
}

function Matrix4D.mt.__call(self,x,y,z,w)
	local s=Matrix(4,1)
	s.values = {{x},{y},{z},{w}}
	return setmetatable(s,Matrix4D.mti)
end

function Matrix4D:getCopy()
	return Matrix4D(self[1][1],self[2][1],self[3][1],self[4][1])
end

do
	local function applyRotation(m,self,x,y,z)
		local sin = sinq
		local cos = cosq
		local sinx,cosx = sin(x),cos(x)
		local siny,cosy = sin(y),cos(y)
		local sinz,cosz = sin(z),cos(z)
		local rx,ry,rz=Matrix4D.rotationMatrixX,Matrix4D.rotationMatrixY,Matrix4D.rotationMatrixZ
	
		if x ~= 0 then
			rx[2][2] = cosx
			rx[2][3] = -sinx
			rx[3][2] = sinx
			rx[3][3] = cosx
			m.values = (m*rx).values
		end
	
		if y ~= 0 then
			ry[1][1] = cosy
			ry[1][3] = siny
			ry[3][1] = -siny
			ry[3][3] = cosy
			m.values = (m*ry).values
		end
	
		if z ~= 0 then
			rz[1][1] = cosz
			rz[1][2] = -sinz
			rz[2][1] = sinz
			rz[2][2] = cosz
			m.values = (m*rz).values
		end
	
		self.values = (m*self).values
	end
	Matrix4D.applyRotation = Matrix.bindLocalMatrixToFunction(applyRotation,4,4,{
		{1,0,0,0},
		{0,1,0,0},
		{0,0,1,0},
		{0,0,0,1}
	})

	local function applyAxisAngleRotation(m,self,dir,angle)
		local c=cosq(angle)
		local s=sinq(angle)
		local C=1-c
		local x,y,z = dir.x,dir.y,dir.z
		local xC,yC,zC,xs,ys,zs = x*C,y*C,z*C,x*s,y*s,z*s
		local values = m.values

		values[1][1] = x*xC+c
		values[1][2] = y*xC-zs
		values[1][3] = z*xC+ys
		values[2][1] = y*xC+zs
		values[2][2] = y*yC+c
		values[2][3] = z*yC-xs
		values[3][1] = z*xC-ys
		values[3][2] = z*yC+xs
		values[3][3] = z*zC+c
		
		self.values = (m*self).values
	end
	Matrix4D.applyAxisAngleRotation = Matrix.bindLocalMatrixToFunction(applyAxisAngleRotation,4,4,{
		{0,0,0,0},
		{0,0,0,0},
		{0,0,0,0},
		{0,0,0,1}
	})

	local function applyScaleFactor(m,self,sx,sy,sz)
		local values = m.values
		values[1][1] = sx
		values[2][2] = sy
		values[3][3] = sz
		self.values = (m*self).values
	end
	Matrix4D.applyScaleFactor = Matrix.bindLocalMatrixToFunction(applyScaleFactor,4,4,{
		{0,0,0,0},
		{0,0,0,0},
		{0,0,0,0},
		{0,0,0,1}
	})

	local function applyTranslation(m,self,tx,ty,tz)
		local values = m.values
		values[1][4] = tx
		values[2][4] = ty
		values[3][4] = tz
		self.values = (m*self).values
	end
	Matrix4D.applyTranslation = Matrix.bindLocalMatrixToFunction(applyTranslation,4,4,{
		{1,0,0,0},
		{0,1,0,0},
		{0,0,1,0},
		{0,0,0,1}
	})

	local function toScreenSpace(m,self)
	
		local viewportWidth,viewportHeight,viewportFocalDist = viewport.size.w,viewport.size.h,viewport._focalDist
		local values = m.values
		values[1][1] = viewportFocalDist
		values[2][2] = viewportFocalDist

		local result = Matrix4D.fromMatrix(m*self):getCanonical().values
	
		result[1][1] = ((result[1][1]+viewportWidth/2)*SCREEN_WIDTH)/viewportWidth
		result[2][1] = ((result[2][1]+viewportHeight/2)*SCREEN_HEIGHT)/viewportHeight
	
		return Pos2D(result[1][1],result[2][1])
	
	end
	Matrix4D.toScreenSpace = Matrix.bindLocalMatrixToFunction(toScreenSpace,4,4,{
		{0,0,0,0},
		{0,0,0,0},
		{0,0,1,0},
		{0,0,1,0}
	})

end

function Matrix4D:getCanonical()
	local w = self[4][1]
	return Matrix4D(self[1][1]/w,self[2][1]/w,self[3][1]/w,1)
end

function Matrix4D:toLocalTransform(origin,rot,scale)
	local m=self:getCopy()
	m:applyScaleFactor(scale,scale,scale)
	m:applyRotation(rot.x,rot.y,rot.z)
	m:applyTranslation(origin.x,origin.y,origin.z)
	return Pos3D(m[1][1],m[2][1],m[3][1],m[4][1])
end

function Matrix4D.fromVector3D(v)
	return Matrix4D(v.x,v.y,v.z,v.w)
end

function Matrix4D.fromMatrix(m)
	return Matrix4D(m[1][1],m[2][1],m[3][1],m[4][1])
end

function Matrix4D.mti.__index(self,i)
	return self.values[i] ~= nil and self.values[i] or Matrix4D[i]
end

Matrix4D.mti.__add = Matrix.mti.__add
Matrix4D.mti.__sub = Matrix.mti.__sub
Matrix4D.mti.__mul = Matrix.mti.__mul

setmetatable(Matrix4D,Matrix4D.mt)

-- [/TQ-Bundler: class.Matrix4D]

-- [TQ-Bundler: class.Object3D]

Object3D={}
Object3D.mt={}
Object3D.mti={}
Object3D._inits={}
Object3D._hitChecks={}
Object3D._renderRoutines={}

function Object3D.mt.__call(self,type,...)

    local s={}
    s=Object3D._inits[type](...)
    s.type=type
    s.hasCustomRenderRoutine = Object3D._renderRoutines[type] ~= nil
    if s.hasCustomRenderRoutine then s.renderRoutine = Object3D._renderRoutines[s.type] end

    function s:render()
        self.renderRoutine(self)
    end

    setmetatable(s,Object3D.mti)
    table.insert(scene.activeObjects,s)
    return #scene.activeObjects

end
setmetatable(Object3D,Object3D.mt)

-- MESH --

function Object3D._inits.mesh(meshID,pos,rot,dir,scale)
    local mesh = scene.loadedObjects[meshID]
    return {
        meshID=mesh.meshID,
        pos=pos,
        rot=rot,
        dir=dir,
        scale=scale,
        origin=mesh.origin,
        numberOfTriangles=mesh.numberOfTriangles
    }
end

function Object3D._renderRoutines.mesh(self)

    local mesh = scene.loadedObjects[self.meshID]
    self.origin = self.pos

    local function getResultantTriangles(verticesTable)

        local resultantTriangles,newBorderVertices = {},{}
        local borderVertices = verticesTable
        local move,abs = table.move,math.abs

        for planeIndex=1,#camera.clippingPlanes do

            local plane = camera.clippingPlanes[planeIndex]
            local insertIndex = 1

            for i=1,#borderVertices do

                local v1 = borderVertices[i]
                local v2 = i~=#borderVertices and borderVertices[i+1] or borderVertices[1]

                local closerPointToPlane,furtherPointToPlane = v1,v2
                local signedDistv1ToPlane,signedDistv2ToPlane =  getSignedDistToPlane(v1,plane),getSignedDistToPlane(v2,plane)
                if abs(signedDistv2ToPlane) < abs(signedDistv1ToPlane) then
                    closerPointToPlane = v2
                    furtherPointToPlane = v1
                end

                local intersectionPoint = getVectorPlaneIntersection(furtherPointToPlane,dirBetween3DPoints(furtherPointToPlane,closerPointToPlane),plane)

                if signedDistv2ToPlane >= 0 then
                    if signedDistv1ToPlane < 0 then
                        newBorderVertices[insertIndex] = intersectionPoint
                        insertIndex=insertIndex+1
                    end
                    newBorderVertices[insertIndex] = v2
                    insertIndex=insertIndex+1
                elseif signedDistv1ToPlane >= 0 then
                    newBorderVertices[insertIndex] = intersectionPoint
                    insertIndex=insertIndex+1
                end

            end

            move(newBorderVertices,1,insertIndex-1,1,borderVertices)

        end

        local anchorPoint = borderVertices[1]
        for i=2,#borderVertices-1 do
            table.insert(resultantTriangles,{vertices={ anchorPoint,borderVertices[i],borderVertices[i+1] }})
        end

        return resultantTriangles

    end

    for triangleIndex=1,#mesh.triangles do

        local triangle = mesh.triangles[triangleIndex]
        local triangleVertices = triangle.vertices
        local triangleCenter = triangle.center:toLocalTransform(self.origin,self.rot,self.scale)
        local triangleVertexLocalTransform = triangleVertices[1]:toLocalTransform(self.origin,self.rot,self.scale)
        local triangleBoundingSphereRadius = distBetween3DPoints( triangleCenter, triangleVertexLocalTransform )

        if camera:isPointInView(triangleCenter,triangleBoundingSphereRadius) then

            local resultantTriangles = {}
            resultantTriangles = getResultantTriangles({
                triangleVertexLocalTransform,
                triangleVertices[2]:toLocalTransform(self.origin,self.rot,self.scale),
                triangleVertices[3]:toLocalTransform(self.origin,self.rot,self.scale)
            })

            local triangleScreenValues = {}
            local unpack = table.unpack
            for i=1,#resultantTriangles do

                local t = resultantTriangles[i]
                local insertIndex = 1

                local depths = {}

                for j=1,3 do
                    local vertex = t.vertices[j]
                    local inCameraPos = vertex:toCameraTransform()
                    local screenPos = inCameraPos:toScreenSpace()
                    triangleScreenValues[insertIndex] = screenPos.x
                    triangleScreenValues[insertIndex+1] = screenPos.y
                    insertIndex=insertIndex+2

                    table.insert(depths,math.abs(inCameraPos.z))
                end

                triangleScreenValues[insertIndex] = 1+(triangleIndex%7)

                local function depthBufferCallback(x,y,color,info)

                    if not ( x>=1 and x<=SCREEN_WIDTH and y>=1 and y<=SCREEN_HEIGHT ) then return end

                    local pA,pB,pC = info.pA,info.pB,info.pC
                    local abs = math.abs

                    local deltayBC = pB.y-pC.y
                    local deltayCA = pC.y-pA.y
                    local deltayAB = pA.y-pB.y

                    local areaABC = info.areaABC
                    local areaPBC = abs( (x*(deltayBC)) + (pB.x*(pC.y-y)) + (pC.x*(y-pB.y)) ) / 2
                    local areaPCA = abs( (pA.x*(y-pC.y)) + (x*(deltayCA)) + (pC.x*(pA.y-y)) ) / 2
                    local areaPAB = abs( (pA.x*(pB.y-y)) + (pB.x*(y-pA.y)) + (x*(deltayAB)) ) / 2

                    local alpha = areaPBC / areaABC
                    local beta = areaPCA / areaABC
                    local gamma = areaPAB / areaABC

                    local depth = (alpha*depths[1]) + (beta*depths[2]) + (gamma*depths[3])

                    if depth < Z_BUFFER[x][y] then

                        Z_BUFFER[x][y] = depth
                        pix(x,y,color)

                    end

                end

                table.insert(triangleScreenValues,depthBufferCallback)

                triCulled(unpack(triangleScreenValues))

            end

        end
    end
end

-- [/TQ-Bundler: class.Object3D]

-- [TQ-Bundler: debug.Profiler]

-- SOURCED FROM https://github.com/2dengine/profile.lua
-- MODIFIED TO WORK WITH TIC-80

profiler = {}

profiler.clock = time

-- function labels
profiler._labeled = {}
-- function definitions
profiler._defined = {}
-- time of last call
profiler._tcalled = {}
-- total execution time
profiler._telapsed = {}
-- number of calls
profiler._ncalls = {}
-- list of internal profiler functions
profiler._internal = {}

--- This is an internal function.
-- @tparam string event Event type
-- @tparam number line Line number
-- @tparam[opt] table info Debug info table
function profiler.hooker(event, line, info)
  info = info or debug.getinfo(2, 'fnS')
  local f = info.func
  -- ignore the profiler itself
  if profiler._internal[f] or info.what ~= "Lua" then
    return
  end
  -- get the function name if available
  if info.name then
    profiler._labeled[f] = info.name
  end
  -- find the line definition
  if not profiler._defined[f] then
    profiler._defined[f] = info.short_src..":"..info.linedefined
    profiler._ncalls[f] = 0
    profiler._telapsed[f] = 0
  end
  if profiler._tcalled[f] then
    local dt = profiler.clock() - profiler._tcalled[f]
    profiler._telapsed[f] = profiler._telapsed[f] + dt
    profiler._tcalled[f] = nil
  end
  if event == "tail call" then
    local prev = debug.getinfo(3, 'fnS')
    profiler.hooker("return", line, prev)
    profiler.hooker("call", line, info)
  elseif event == 'call' then
    profiler._tcalled[f] = profiler.clock()
  else
    profiler._ncalls[f] = profiler._ncalls[f] + 1
  end
end

--- Sets a clock function to be used by the profiler.
-- @tparam function func Clock function that returns a number
function profiler.setclock(f)
  assert(type(f) == "function", "clock must be a function")
  clock = f
end

--- Starts collecting data.
function profiler.start()
  if rawget(_G, 'jit') then
    jit.off()
    jit.flush()
  end
  debug.sethook(profiler.hooker, "cr")
end

--- Stops collecting data.
function profiler.stop()
  debug.sethook()
  for f in pairs(profiler._tcalled) do
    local dt = profiler.clock() - profiler._tcalled[f]
    profiler._telapsed[f] = profiler._telapsed[f] + dt
    profiler._tcalled[f] = nil
  end
  -- merge closures
  local lookup = {}
  for f, d in pairs(profiler._defined) do
    local id = (profiler._labeled[f] or '?')..d
    local f2 = lookup[id]
    if f2 then
      profiler._ncalls[f2] = profiler._ncalls[f2] + (profiler._ncalls[f] or 0)
      profiler._telapsed[f2] = profiler._telapsed[f2] + (profiler._telapsed[f] or 0)
      profiler._defined[f], profiler._labeled[f] = nil, nil
      profiler._ncalls[f], profiler._telapsed[f] = nil, nil
    else
      lookup[id] = f
    end
  end
  collectgarbage('collect')
end

--- Resets all collected data.
function profiler.reset()
  for f in pairs(profiler._ncalls) do
    profiler._ncalls[f] = 0
  end
  for f in pairs(profiler._telapsed) do
    profiler._telapsed[f] = 0
  end
  for f in pairs(profiler._tcalled) do
    profiler._tcalled[f] = nil
  end
  collectgarbage('collect')
end

--- This is an internal function.
-- @tparam function a First function
-- @tparam function b Second function
-- @treturn boolean True if "a" should rank higher than "b"
function profiler.comp(a, b)
  local dt = profiler._telapsed[b] - profiler._telapsed[a]
  if dt == 0 then
    return profiler._ncalls[b] < profiler._ncalls[a]
  end
  return dt < 0
end

--- Generates a report of functions that have been called since the profile was started.
-- Returns the report as a numeric table of rows containing the rank, function label, number of calls, total execution time and source code line number.
-- @tparam[opt] number limit Maximum number of rows
-- @treturn table Table of rows
function profiler.query(limit)
  local t = {}
  for f, n in pairs(profiler._ncalls) do
    if n > 0 then
      t[#t + 1] = f
    end
  end
  table.sort(t, profiler.comp)
  if limit then
    while #t > limit do
      table.remove(t)
    end
  end
  for i, f in ipairs(t) do
    local dt = 0
    if profiler._tcalled[f] then
      dt = profiler.clock() - profiler._tcalled[f]
    end
    t[i] = { i, profiler._labeled[f] or '?', profiler._ncalls[f], (profiler._telapsed[f] + dt).." - "..(round( (profiler._telapsed[f] + dt)/profiler._ncalls[f],3)*1000).."mcs", profiler._defined[f] }
  end
  return t
end

profiler.cols = { 3, 29, 11, 24, 32 }

--- Generates a text report of functions that have been called since the profile was started.
-- Returns the report as a string that can be printed to the console.
-- @tparam[opt] number limit Maximum number of rows
-- @treturn string Text-based profiling report
function profiler.report(n)
  local out = {}
  local report = profiler.query(n)
  for i, row in ipairs(report) do
    for j = 1, 5 do
      local s = row[j]
      local l2 = profiler.cols[j]
      s = tostring(s)
      local l1 = s:len()
      if l1 < l2 then
        s = s..(' '):rep(l2-l1)
      elseif l1 > l2 then
        s = s:sub(l1 - l2 + 1, l1)
      end
      row[j] = s
    end
    out[i] = table.concat(row, ' | ')
  end

  local row = " +-----+-------------------------------+-------------+--------------------------+----------------------------------+ \n"
  local col = " | #   | Function                      | Calls       | Time                     | Code                             | \n"
  local sz = row..col..row
  if #out > 0 then
    sz = sz..' | '..table.concat(out, ' | \n | ')..' | \n'
  end
  return '\n'..sz..row
end

-- store all internal profiler functions
for _, v in pairs(profiler) do
  if type(v) == "function" then
    profiler._internal[v] = true
  end
end



-- [/TQ-Bundler: debug.Profiler]

-- GLOBAL VALUES --

SCREEN_WIDTH=240
SCREEN_HEIGHT=136
MAP_BASE_ADDRESS=0x8000
MAP_SIZE_BYTES=32640
PI=3.1415927
TWO_PI=6.2831854
PI_OVER_TWO=1.57079635
WORLD_ORIGIN=Pos3D(0,0,0)
Z_BUFFER={}
DEBUG=false
X_AXIS,Y_AXIS,Z_AXIS = Dir3D(1,0,0),Dir3D(0,1,0),Dir3D(0,0,1)

-- SCENE COMPONENTS --

camera=Camera( Pos3D(0,0,0), Rot3D(0,0,0), Dir3D(0,0,1) )

viewport={
	size=Size2D(SCREEN_WIDTH,SCREEN_HEIGHT),
	fov=90,
}
function viewport:updateFocalDist()
	self._focalDist = self.size.w / ( 2*math.tan(math.rad(self.fov)/2) )
	self._vfov = 2 * math.atan( self.size.h, (2*self._focalDist) ) -- in radians
	Matrix4D.screenProjectionMatrix[1][1],Matrix4D.screenProjectionMatrix[2][2]=self._focalDist,self._focalDist
end
viewport:updateFocalDist()

HalfViewportWidth,HalfViewportHeight = viewport.size.w/2,viewport.size.h/2
ScreenWidthScale,ScreenHeightScale = SCREEN_WIDTH/viewport.size.w,SCREEN_HEIGHT/viewport.size.h

light={
	pos=Pos3D(-5,6,5)
}

gmouse={
	sensitivity=70,
}

scene={
	lights={},
	loadedObjects={},
	activeObjects={},
	get = function(id)
		return scene.activeObjects[id]
	end
}

-- METHODS --

function initializeZBuffer()
	local huge = math.huge
	for col=1,SCREEN_WIDTH do
		if not Z_BUFFER[col] then Z_BUFFER[col] = {} end
		local zcol = Z_BUFFER[col]
		for row=1,SCREEN_HEIGHT do
			zcol[row] = huge
		end
	end
end

function calculateMeshOrigin(mesh)
	local xAvg,yAvg,zAvg=0,0,0
	for _,triangle in pairs(mesh.triangles) do
		for _,vertex in pairs(triangle.vertices) do
			xAvg=xAvg+vertex.x
			yAvg=yAvg+vertex.y
			zAvg=zAvg+vertex.z
		end
	end
	xAvg=xAvg/mesh.numberOfTriangles
	yAvg=yAvg/mesh.numberOfTriangles
	zAvg=zAvg/mesh.numberOfTriangles
	return Pos3D(xAvg,yAvg,zAvg)
end

function getMeshRelativeToOrigin(mesh,origin)
	newmesh=mesh
	for t,triangle in ipairs(newmesh.triangles) do
		for v,vertex in ipairs(triangle) do
			vPos=Pos3D(table.unpack(vertex))
			vPos=vPos-origin
			newmesh.triangles[t][v]={vPos.x,vPos.y,vPos.z}
		end
	end
	return newmesh
end

function translate3D(pos,dir,dist)
	local newX = pos.x+(dir.x*dist)
	local newY = pos.y+(dir.y*dist)
	local newZ = pos.z+(dir.z*dist)
	return Pos3D(newX,newY,newZ)
end

function distBetween3DPoints(p1,p2)
	local delta = p1-p2
	return math.sqrt(delta:getDotProduct(delta))
end

function dirBetween3DPoints(p1,p2)
	local dist = distBetween3DPoints(p1,p2)
	local dx = p2.x-p1.x
	local dy = p2.y-p1.y
	local dz = p2.z-p1.z
	return Dir3D(dx/dist,dy/dist,dz/dist)
end

function getSurfaceNormal(p1,p2,p3)
	local a = p2 - p1
	local b = p3 - p1
	local nX = a.y * b.z - a.z * b.y
	local nY = a.z * b.x - a.x * b.z
	local nZ = a.x * b.y - a.y * b.x
	return Dir3D(nX,nY,nZ)
end

function getTriangleCircumcenter(pA,pB,pC)
	local faceNormal = getSurfaceNormal(pA,pB,pC)

	local abMidpoint = (pA+pB)/2
	local abPerpDir = dirBetween3DPoints(pA,pB)
	abPerpDir:rotateAboutAxis(faceNormal,PI_OVER_TWO)

	local bcMidpoint = (pB+pC)/2
	local bcPerpDir = dirBetween3DPoints(pB,pC)
	bcPerpDir:rotateAboutAxis(faceNormal,PI_OVER_TWO)

	local a = 0
	local lastDifference = math.huge
	while a < 5 do
		local left = ( abPerpDir:getCrossProduct(bcPerpDir) ) * a
		local right = ( bcMidpoint - abMidpoint ):getCrossProduct(bcPerpDir)
		local difference = (left-right):getMagnitude()
		if difference > lastDifference then break end
		lastDifference = difference
		a=a+0.01
	end

	return translate3D(abMidpoint,abPerpDir,a)
end

function updateMouseInfo()
	if not gmouse.x then gmouse.x=0 end
	if not gmouse.y then gmouse.y=0 end
	if not gmouse.previous then gmouse.previous={} end
	gmouse.previous.x=gmouse.x
	gmouse.previous.y=gmouse.y
	gmouse.previous.down=mouseDown
	gmouse.x,gmouse.y,gmouse.down=mouse()
	gmouse.deltaX=gmouse.x-gmouse.previous.x
	gmouse.deltaY=gmouse.previous.y-gmouse.y
end

function renderScreen()
	initializeZBuffer()
	for _,obj in pairs(scene.activeObjects) do
		obj:render()
	end
end

-- MAIN LOOP --

t=0
frameStartTimeMilliseconds=0
frameEndTimeMilliseconds=0
fpsInterval=5
currentFPS=0

function TIC()

	updateMouseInfo()

	if t==0 then
		camera:updateVectors()
		camera:initalizeClippingPlanes()
		camera:updateClippingPlanes()
		loadObjects()
		cube=Object3D("mesh","mips",Pos3D(0,-1.4,5),Rot3D(0,0,0),Dir3D(0,0,1),0.2)
		if DEBUG then profiler.start() end
	end

	cls(0)

	if btn(0) then camera.pos=translate3D(camera.pos,camera.dir,0.1) end --forward
	if btn(1) then camera.pos=translate3D(camera.pos,camera.dir,-0.1) end --backward
	if btn(2) then camera.pos=translate3D(camera.pos,camera.horizontalVector,0.1) end --right
	if btn(3) then camera.pos=translate3D(camera.pos,camera.horizontalVector,-0.1) end --left

	if btn(4) then
		scene.get(cube).rot:rotate(0,0.1,0)
	end

	if gmouse.down then
		physicalSpace = (gmouse.deltaX/SCREEN_WIDTH)*viewport.size.w*(gmouse.sensitivity/100)
		camera:rotate( Rot3D(0,2*PI*(physicalSpace/viewport.size.w),0) )
	end

	camera:updateVectors()
	camera:updateClippingPlanes()

	renderScreen()

	if DEBUG and t==10 then
		profiler.stop()
		trace(profiler.report(20))
		exit()
	end

	if t%fpsInterval==0 then
		frameEndTimeMilliseconds=time()
		currentFPS=fpsInterval/((frameEndTimeMilliseconds-frameStartTimeMilliseconds)/1000)
		frameStartTimeMilliseconds=time()
	end

	print("FPS:"..round(currentFPS,2))

	t=t+1
end
-- <MAP>
-- 000:365726560000000000000000c00008008000008000008008008008008008008008008008008000008008008000008008008000008008008008008008008008008008008000008000008008008000008008008000008000008008008008008000008000008000008008008008008000008000008008008000008000008008008008008008008008008000008008008008008008008008008000008008008000008000008000008000008000008008008008008000008000008008008000008008008008008008008008008008008000008008008000008000008008008000008008008008008000008000008008008000
-- 001:0080000080000080000080080080000080000080000080000080080080000080000080080080080080000080000080080080080080000080080080000080080080080080000080080080000080080080080080000080000080000080000080000080b6e696665600000000000000820000f0dfa052d420f95d0060c65017d70074db00f0df50df5108da5600d04028b6d20098db0060c628b6d220f95d00845578555420f95d0060c61017de18745e0060c65017d70074db0060c628b6d220f95d08f0dfa052d420f95d08f0df50df5108da560860c65017d70074db00e0592041d52844db00f0df50df5108da560060
-- 002:c65017d70074db00204028d6d238f15f00e0592041d52844db0060c61017de18745e08d04028b6d20098db0860c68872d40098db08845578555420f95d0860c65017d70074db0860c628b6d220f95d08f0dfa052d420f95d0860c65017d70074db08f0df50df5108da5608e0592041d52844db0860c61017de18745e08e0592041d52844db08204028d6d238f15f00f0df50df5108da5600e0592041d52844db08e0592041d52844db00d04028b6d20098db0060c68872d40098db0860c68872d40098db00f0dfa052d420f95d00f0df50df5108da5608f0df50df5108da560060c628b6d220f95d00f0dfa052d420f9
-- 003:5d08f0dfa052d420f95d00204028d6d238f15f0060c628b6d2180e5b0860c628b6d2180e5b00845578555420f95d08845578555420f95d0860c68872d40098db00e0592041d52844db00204028d6d238f15f08204028d6d238f15f00845578555420f95d0060c628b6d220f95d0860c628b6d220f95d0060c628b6d2180e5b00d04028b6d20098db08d04028b6d20098db00d04028b6d20098db00845578555420f95d0060c68872d40098db0060c61017de18745e0060c628b6d220f95d0060c628b6d2180e5b0060c628b6d2180e5b0060c628b6d220f95d00d04028b6d20098db0060c628b6d220f95d0060c65017
-- 004:d70074db00f0dfa052d420f95d00e0592041d52844db0060c65017d70074db0060c61017de18745e00204028d6d238f15f0060c61017de18745e0060c628b6d2180e5b08d04028b6d20098db08845578555420f95d0860c628b6d220f95d08d04028b6d20098db0860c628b6d220f95d0860c628b6d2180e5b0860c628b6d2180e5b0860c628b6d220f95d0860c61017de18745e0860c61017de18745e0860c628b6d220f95d0860c65017d70074db0860c65017d70074db08e0592041d52844db0860c61017de18745e0860c61017de18745e08204028d6d238f15f0860c628b6d2180e5b00f0df50df5108da5608e0
-- 005:592041d52844db08f0df50df5108da5600d04028b6d20098db0860c68872d40098db08d04028b6d20098db00f0dfa052d420f95d08f0df50df5108da5608f0dfa052d420f95d0060c628b6d220f95d08f0dfa052d420f95d0860c628b6d220f95d00204028d6d238f15f0860c628b6d2180e5b08204028d6d238f15f00845578555420f95d0860c68872d40098db0060c68872d40098db00e0592041d52844db08204028d6d238f15f08e0592041d52844db00845578555420f95d0860c628b6d220f95d08845578555420f95d0060c628b6d2180e5b08d04028b6d20098db0860c628b6d2180e5bd696073700000000
-- 006:000000003c00491b512121dac1bb5e289b4200114982d1d58846d9004d5702dcde9a0f563142d6707cd1491b512121dac1bb5e49805c31f4d5089b538846d9004d5702dcde49805c31f4d5089b53491b512121dac1bb5e2a0c52f0955068f35a49805c31f4d5089b53e806581041d73846dd49805c31f4d5089b532a0c52f0955068f35a9a0f563142d6707cd149805c31f4d5089b538846d9004d5702dcdee806581041d73846dd9a0f563142d6707cd12a0c52f0955068f35afacad4003dd39068dc289b4200114982d1d59a0f563142d6707cd1facad4003dd39068dc9a0f563142d6707cd1289b4200114982d1d5
-- 007:491b512121dac1bb5e2a0c52f0955068f35ae806581041d73846ddfacad4003dd39068dc8846d9004d5702dcdefacad4003dd39068dce806581041d73846ddfacad4003dd39068dc8846d9004d5702dcde289b4200114982d1d56889d625a0d038b05d109c54842cdc080fd25042dc25a0d028395e38065f842cdc1842de109c54842cdc080fd26889d625a0d038b05d109c54842cdc080fd238065f842cdc1842de6889d625a0d038b05d109c54842cdc080fd26889d625a0d038b05d5042dc25a0d028395e91a157d2f95500764d910d5fb2e25c1245d150f7dcf1585332ea5990b0daf1d157508bd750f7dcf15853
-- 008:32ea59b852d5f1d15740aed250f7dcf1585332ea59910d5fb2e25c1245d12888d162b7d10355d4b852d5f1d15740aed250f7dcf1585332ea59a87757f1585332b05791a157d2f95500764d50f7dcf1585332ea5990b0daf1d157508bd72888d162b7d10355d401595b215fdc829bd950f7dcf1585332ea5901595b215fdc829bd9a87757f1585332b05750f7dcf1585332ea59e9f05eb2e25cf191d8b940dcd2f955109f5da87757f1585332b057a87757f1585332b0572888d162b7d10355d4e9f05eb2e25cf191d8a87757f1585332b057b940dcd2f955109f5db852d5f1d15740aed2a87757f1585332b05701595b
-- 009:215fdc829bd959bed4215fdc72035659bed4215fdc7203562888d162b7d10355d4a87757f1585332b057b852d5f1d15740aed2b940dcd2f955109f5d08d55fd25dd0588ed4b852d5f1d15740aed208d55fd25dd0588ed490b0daf1d157508bd789dfd7b35bd0124a59e9f05eb2e25cf191d82888d162b7d10355d49979d4605249d0555ab940dcd2f955109f5de9f05eb2e25cf191d89979d4605249d0555ae9f05eb2e25cf191d889dfd7b35bd0124a5990b0daf1d157508bd708d55fd25dd0588ed491a157d2f95500764d9979d4605249d0555a89dfd7b35bd0124a598834df452151f0f358180bdf351f57b17450
-- 010:89dfd7b35bd0124a5928235054cbd5728ed189dfd7b35bd0124a592888d162b7d10355d428235054cbd5728ed18834df452151f0f35889dfd7b35bd0124a59180bdf351f57b174509979d4605249d0555a8834df452151f0f35898bbd4348c5b407d5898bbd4348c5b407d58b940dcd2f955109f5d9979d4605249d0555a009840452151f0acd951fd58d38edfe064d070f95a34ccd160105551fd58d38edfe064d0910d5fb2e25c1245d191a157d2f95500764d91a157d2f95500764d70f95a34ccd160105551fd58d38edfe064d0910d5fb2e25c1245d151fd58d38edfe064d041e8dbb35bd03257da009840452151
-- 011:f0acd941e8dbb35bd03257da51fd58d38edfe064d02888d162b7d10355d441e8dbb35bd03257da28235054cbd5728ed141e8dbb35bd03257da009840452151f0acd9180bdf351f57b1745041e8dbb35bd03257da2888d162b7d10355d4910d5fb2e25c1245d141e8dbb35bd03257da180bdf351f57b1745028235054cbd5728ed198bbd4348c5b407d58009840452151f0acd970f95a34ccd1601055009840452151f0acd998bbd4348c5b407d588834df452151f0f358180bdf351f57b17450009840452151f0acd98834df452151f0f358b940dcd2f955109f5d98bbd4348c5b407d5808d55fd25dd0588ed470f95a
-- 012:34ccd160105591a157d2f95500764d08d55fd25dd0588ed401595b215fdc829bd92888d162b7d10355d438c051d1ced800c9bd2888d162b7d10355d459bed4215fdc72035638c051d1ced800c9bd70f95a34ccd160105508d55fd25dd0588ed498bbd4348c5b407d5859bed4215fdc72035601595b215fdc829bd928bd5801625983085001595b215fdc829bd938c051d1ced800c9bd28bd5801625983085038c051d1ced800c9bd59bed4215fdc72035628bd58016259830850091cdd6219d6e0895b1947dee067d5d073d7c9c8dc10894ab06dd7091cdd6219d6e0895bc9c8dc10894ab06dd779a35a72175a101641
-- 013:091cdd6219d6e0895b891c5a1067cfd19dda1947dee067d5d073d7891c5a1067cfd19dda091cdd6219d6e0895b495cde72235d2037c879a35a72175a101641891c5a1067cfd19dda495cde72235d2037c879a35a72175a101641c9c8dc10894ab06dd7891c5a1067cfd19ddac0c6d9d0ddd8d133d16105d57223d1112b54e05ddc62cede91d8d791a1daf0145b0121576105d57223d1112b54c0c6d9d0ddd8d133d1c0c6d9d0ddd8d133d10156d97285dde03d51e05fdef0385fb052dd0156d97285dde03d51c0c6d9d0ddd8d133d1e05ddc62cede91d8d7e05fdef0385fb052dd0156d97285dde03d5191a1daf0145b
-- 014:01215791a1daf0145b0121570156d97285dde03d516105d57223d1112b54fa52ddd0c844d13950b8d9dc179dd891c2d569dedda0abc4713c509955d0e00dcc02b45ab8d9dc179dd891c2d5fa52ddd0c844d139507af954e0994e6258d69955d0e00dcc02b45afa52ddd0c844d13950089022d0bdcad2f95909d257b69c511230d29955d0e00dcc02b45afa52ddd0c844d1395009d257b69c511230d2089022d0bdcad2f9597af954e0994e6258d6fa52ddd0c844d13950089022d0bdcad2f9597af954e0994e6258d6089022d0bdcad2f9599955d0e00dcc02b45a9955d0e00dcc02b45a09d257b69c511230d2b8d9dc
-- 015:179dd891c2d509d257b69c511230d2fa52ddd0c844d1395069dedda0abc4713c505997db1009d8ba0cdf685d4d1043d999f85f58124f10b4d23b4dd2685d4d1043d999f85f5997db1009d8ba0cdffad6d71057d9a0c252fad6d71057d9a0c2525997db1009d8ba0cdfe812db106bdd28fbdc99005310a1cea0efddfad6d71057d9a0c252e812db106bdd28fbdcfad6d71057d9a0c25299005310a1cea0efdd9a2ed231c5d570ceda99005310a1cea0efdd39af593178580839da9a2ed231c5d570ceda39af593178580839da99005310a1cea0efdde812db106bdd28fbdc9a2ed231c5d570ceda4a0e5b51e2de6a4e55
-- 016:5b6f5f51d0d80a24dd4a0e5b51e2de6a4e559a2ed231c5d570ceda39af593178580839da5b6f5f51d0d80a24ddfad6d71057d9a0c2529a2ed231c5d570cedafad6d71057d9a0c2525b6f5f51d0d80a24dd685d4d1043d999f85fe812db106bdd28fbdc4a0e5b51e2de6a4e5539af593178580839da4a0e5b51e2de6a4e55e812db106bdd28fbdc5997db1009d8ba0cdf4a0e5b51e2de6a4e555997db1009d8ba0cdf58124f10b4d23b4dd24a0e5b51e2de6a4e5558124f10b4d23b4dd25b6f5f51d0d80a24dd5b6f5f51d0d80a24dd58124f10b4d23b4dd2685d4d1043d999f85fd99f5511f5c370865f9971dbe06cca
-- 017:0273d0ebb4d1f0e7c70065c7d99f5511f5c370865febb4d1f0e7c70065c71b88da11834338af54ebb4d1f0e7c70065c79971dbe06cca0273d0ea8ed8d028c2d1e7d62a9a55d0fccd720e54ea8ed8d028c2d1e7d69971dbe06cca0273d0d99f5511f5c370865f8ae15de07acbc2c5589971dbe06cca0273d02a9a55d0fccd720e549971dbe06cca0273d08ae15de07acbc2c5586baed0117bc241d6d58ae15de07acbc2c558d99f5511f5c370865f8ae15de07acbc2c558ebb4d1f0e7c70065c7ea8ed8d028c2d1e7d62a9a55d0fccd720e548ae15de07acbc2c558ea8ed8d028c2d1e7d6ebb4d1f0e7c70065c78ae15d
-- 018:e07acbc2c5586baed0117bc241d6d56baed0117bc241d6d5d99f5511f5c370865f1b88da11834338af546baed0117bc241d6d51b88da11834338af54ebb4d1f0e7c70065c7128e5410d6be3287d16166def0d0ceb2905c2020cbe003ca00e73a2020cbe003ca00e73a6166def0d0ceb2905c90d35be02ec122595fc096d2a0db4d22a0d590d35be02ec122595f7022d00706d4916852c096d2a0db4d22a0d52020cbe003ca00e73a90d35be02ec122595fc096d2a0db4d22a0d5128e5410d6be3287d12020cbe003ca00e73a128e5410d6be3287d1c096d2a0db4d22a0d531ce51d6155191bf5290d35be02ec122595f
-- 019:6166def0d0ceb2905c128e5410d6be3287d17022d00706d491685290d35be02ec122595f128e5410d6be3287d17022d00706d4916852128e5410d6be3287d131ce51d6155191bf52c096d2a0db4d22a0d57022d00706d491685231ce51d6155191bf52109f44104756baf857045fd800c4d459b9519233501050dfc0d4de109f44104756baf8579233501050dfc0d4de904150108dd338a4529233501050dfc0d4de215f55b050d3b0845f904150108dd338a452045fd800c4d459b951109f44104756baf8575030c700f0cf1bc2d6337856412655d9a7d79233501050dfc0d4de045fd800c4d459b951215f55b050d3
-- 020:b0845f9233501050dfc0d4de42e2dd3140d09079d39233501050dfc0d4de337856412655d9a7d742e2dd3140d09079d332b05b20414a38fb4842e2dd3140d09079d3337856412655d9a7d7f0d0d331e85a08aadf215f55b050d3b0845f42e2dd3140d09079d342e2dd3140d09079d332b05b20414a38fb48f0d0d331e85a08aadf215f55b050d3b0845ff0d0d331e85a08aadf904150108dd338a45232b05b20414a38fb48904150108dd338a452f0d0d331e85a08aadf904150108dd338a45232b05b20414a38fb48109f44104756baf857109f44104756baf85732b05b20414a38fb485030c700f0cf1bc2d65030c7
-- 021:00f0cf1bc2d632b05b20414a38fb48337856412655d9a7d75030c700f0cf1bc2d6337856412655d9a7d7045fd800c4d459b95110cd480005db82d758d024df110ed5c12c5c0007d90031cff1aa5cf080553165da083a5ee181571058c548afd990e55110535d38bed4e181571058c548afd9f080553165da083a5e42925f21ccd590e9d5e181571058c548afd942925f21ccd590e9d592c7dd0036d910a24e0007d90031cff1aa5cf080553165da083a5e90e55110535d38bed4d024df110ed5c12c5c42925f21ccd590e9d5f080553165da083a5ef080553165da083a5e0007d90031cff1aa5cd024df110ed5c12c5c
-- 022:42925f21ccd590e9d510cd480005db82d75892c7dd0036d910a24e10cd480005db82d75842925f21ccd590e9d5d024df110ed5c12c5c90e55110535d38bed4e181571058c548afd992c7dd0036d910a24e92c7dd0036d910a24e0007d90031cff1aa5c90e55110535d38bed40007d90031cff1aa5c92c7dd0036d910a24e10cd480005db82d758904253e06d4d228754a0375411da46b0bf5ce2df5e01dccad0a4dde2df5e01dccad0a4dda0375411da46b0bf5cf1d3d521b2c500b0b2904253e06d4d228754e2df5e01dccad0a4dd12ec5ce0f3cb32a55312ec5ce0f3cb32a55341b15ee091cbb2a6d6904253e06d4d
-- 023:228754904253e06d4d22875441b15ee091cbb2a6d66191d6f040ca1352556191d6f040ca13525541b15ee091cbb2a6d612ec5ce0f3cb32a5536191d6f040ca135255f194592109cdd158d4a0375411da46b0bf5ce2df5e01dccad0a4dd6191d6f040ca13525512ec5ce0f3cb32a5536191d6f040ca135255a0375411da46b0bf5c904253e06d4d2287546191d6f040ca135255e2df5e01dccad0a4ddf194592109cdd158d4a0375411da46b0bf5cf194592109cdd158d4f1d3d521b2c500b0b2f1d3d521b2c500b0b2f194592109cdd158d4e2df5e01dccad0a4dd00145c66175c5959de00c2dad5fb5e39f7da7852d3
-- 024:96d15ec8cd5f00145c66175c5959de0099ca96d15e18b34e00c2dad5fb5e39f7da7852d396d15ec8cd5f0099ca96d15e18b34e00145c66175c5959de31d452074a58b2a5dac1e6ddb657d23011dbe0365bc05c491066d231d452074a58b2a5da01bdd5c58cddd28bd1c1e6ddb657d23011db18475ad0844751355331d452074a58b2a5dae0365bc05c491066d201bdd5c58cddd28bd131d452074a58b2a5da69e151c58cddc2925f69e151c58cddc2925f31d452074a58b2a5da896dd7074a58928951896dd7074a5892895131d452074a58b2a5da18475ad08447513553e9bb59b657d2005bd869e151c58cddc2925f
-- 025:896dd7074a5892895169e151c58cddc2925f18235ae49754e08ed601bdd5c58cddd28bd118235ae49754e08ed669e151c58cddc2925f0a1cd23589de01d055e9bb59b657d2005bd80a1cd23589de01d05569e151c58cddc2925fc1e6ddb657d23011db01bdd5c58cddd28bd1d12bda3589de21b8d101bdd5c58cddd28bd118235ae49754e08ed6d12bda3589de21b8d1e9bb59b657d2005bd8896dd7074a589289510912dec05c4900e2d9896dd7074a5892895118475ad084475135530912dec05c4900e2d918475ad0844751355308a9d8d026c508004e0912dec05c4900e2d908a9d8d026c508004e18475ad08447
-- 026:513553e0365bc05c491066d2694a588028c6186ad618235ae49754e08ed60a1cd23589de01d05518235ae49754e08ed641e8df8028c60021ded12bda3589de21b8d141e8df8028c60021de18235ae49754e08ed60825d6f4dcd378905818235ae49754e08ed6694a588028c6186ad60825d6f4dcd37890587852d396d15ec8cd5f08a9d8d026c508004e0099ca96d15e18b34e08a9d8d026c508004ee0365bc05c491066d20099ca96d15e18b34e08a9d8d026c508004e7852d396d15ec8cd5f0912dec05c4900e2d90099ca96d15e18b34e41e8df8028c60021de00c2dad5fb5e39f7dac1e6ddb657d23011db41e8df
-- 027:8028c60021de0099ca96d15e18b34ee0365bc05c491066d2c1e6ddb657d23011db0099ca96d15e18b34e00c2dad5fb5e39f7da41e8df8028c60021de0825d6f4dcd37890587852d396d15ec8cd5f00c2dad5fb5e39f7da694a588028c6186ad6e9bb59b657d2005bd87852d396d15ec8cd5f694a588028c6186ad60912dec05c4900e2d97852d396d15ec8cd5fe9bb59b657d2005bd8c1e6ddb657d23011dbd12bda3589de21b8d141e8df8028c60021dee9bb59b657d2005bd8694a588028c6186ad60a1cd23589de01d055694a588028c6186ad600c2dad5fb5e39f7da0825d6f4dcd3789058475637474727960000
-- 028:00000010000000003054472861d300000088145d511bdd0000005947d54903d700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <PALETTE>
-- 000:1a1c2c001c00002c00003c04004c0000590000690000790029366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

