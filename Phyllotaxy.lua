local Phyllotaxy = {
    ["GoldenAngle"] = math.pi * (1 + math.sqrt(5))
}

local floor     =   math.floor
local ceil      =   math.ceil
local sqrt      =   math.sqrt
local min       =   math.min
local max       =   math.max
local sin       =   math.sin
local asin      =   math.asin
local cos       =   math.cos
local tan       =   math.tan
local pi        =   math.pi

local tcreate   =   table.create
local tremove   =   table.remove
local tinsert   =   table.insert

type point2d = {
    x   :(number),
    y   :(number)
}

type point3d = {
    x   :(number),
    y   :(number),
    z   :(number)
}

function Phyllotaxy.SpiralInCircle(
    pointSeparationDistance :(number),
    maxDistanceFromCenter   :(number),
    maxPointCount           :(number),
    baseAngle               :(number),
    pointVisualizer         :(any)
)   :({point2d})

    local points :({point2d}) = tcreate(maxPointCount)

    for pointIndex = 1, maxPointCount do
        local radius = sqrt(pointIndex)
        if (radius > maxDistanceFromCenter) then break end
        local theta = pointIndex * baseAngle
        local x = radius * cos(theta)
        local y = radius * sin(theta)
        points[pointIndex] = {x = x, y = y}
        if (pointVisualizer) then pointVisualizer(x, y) end
    end

    return points

end

-- Two phyllotaxic spiral point distributions starting on each pole, meeting at the equator.
function Phyllotaxy.PolarSpiralsOnSphere(
    sphereRadius            :(number),
    pointSeparationDistance :(number),
    maxPointCount           :(number),
    baseAngle               :(number),
    pointVisualizer         :(any)
)   :({point3d})

    local points :({point3d}) = tcreate(maxPointCount)

    for pointIndex = 1, floor(maxPointCount/2) do
        local radius = sqrt(pointIndex * pointSeparationDistance)
        if (radius > sphereRadius) then break end
        local theta = pointIndex * baseAngle
        local x = radius * cos(theta)
        local y = radius * sin(theta)
        local z = sqrt(sphereRadius * sphereRadius - x * x - y * y)
        points[pointIndex] = {x = x, y = y, z = z}
        points[pointIndex+1] = {x = x, y = y, z = -z}
        if (pointVisualizer) then pointVisualizer(x, y, z) pointVisualizer(x, y, -z) end
    end

    return points
end

-- 3d analog of a phyllotaxic spiral.
function Phyllotaxy.Helix(
    pointSeparationDistance :(number),
    maxDistanceFromCenter   :(number),
    maxPointCount           :(number),
    baseAngle               :(number),
    pointVisualizer         :(any)
)   :({point3d})

    local points :({point3d}) = tcreate(maxPointCount)

    for pointIndex = 1, floor(maxPointCount/2) do
        local radius = sqrt(pointIndex * pointSeparationDistance)

        if (radius > maxDistanceFromCenter) then break end

        local theta = pointIndex * baseAngle
        local phi = theta/radius

        local sinTheta = sin(theta)
        local cosTheta = cos(theta)

        local cosPhi = cos(phi)
        local sinPhi = sin(phi)

        local x :(number)   =   radius * sinTheta * cosPhi
        local y :(number)   =   radius * sinTheta * sinPhi
        local z :(number)   =   radius * cosTheta

        points[pointIndex] = {x = x, y = y, z = z}

        if (pointVisualizer) then pointVisualizer(x, y, z) end
    end

    return points
end

return Phyllotaxy
