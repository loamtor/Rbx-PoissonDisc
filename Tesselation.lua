--!strict

local Tesselation = {}

local abs       =   math.abs
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
local tfreeze   =   table.freeze
local tclone    =   table.clone

local CornerVectors :({number}) = table.freeze({
    1, -1,
    -1, -1,
    -1, 1,
    1, 1
})

local SideDirections:({number}) = table.freeze({
    -1, 0,
    0, 1,
    1, 0,
    0, -1
})

local ThreeThreeFourThreeFourCandidates :({number}) = table.freeze({
    0, 1, -- [xx, yy + halfUnit]
    2, 1, -- [xx + 2 * halfUnit, yy + halfUnit]
    1, -1, -- [xx + halfUnit, yy - halfUnit]
    1, -3, -- [xx + halfUnit, yy - halfUnit * 3]
    -1, -2, -- [xx - halfUnit, yy - 2 * halfUnit]
    -3, -2, -- [xx - halfUnit * 3, yy - halfUnit * 2]
    -2, 0, -- [xx - halfUnit * 2, yy]
    -2, 2 -- [xx - halfUnit * 2, yy + halfUnit * 2]
})

-- ulam spiral for growing a grid from the center
function Tesselation.Ulam(
    index   :(number),
    unitSize:(number)
)   :((number), (number))

    if (index == 0) then return 0, 0 end
    
    local cycleNumber = ceil(floor(sqrt(index))/2)
    local distFromStart = index - (4 * cycleNumber * (cycleNumber - 1) + 1);
    local sideLength = 2 * cycleNumber
    
    local indexOffset = floor(distFromStart / sideLength)*2;
    local distAlongSide = 1 + distFromStart % sideLength;
    
    return (CornerVectors[indexOffset+1] * cycleNumber + distAlongSide * SideDirections[indexOffset+1]) * unitSize,
        (CornerVectors[indexOffset+2] * cycleNumber + distAlongSide * SideDirections[indexOffset+2]) * unitSize;
end

function Tesselation.GenerateUlamPointsInCircle(
    unitSize            :(number),
    circleRadius        :(number),
    maxPointCount       :(number),
    maxSampleFailures   :(number),
    visualizer          :(any?)
)   :({number})
    
    local points    :({number}) = tcreate(maxPointCount*2)
    
    local radiusSquared :(number) = circleRadius * circleRadius
    
    local failures = 0
    for pointIndex = 0, maxPointCount-1 do
        local x, y = Tesselation.Ulam(pointIndex, unitSize)
        if (x * x + y * y > radiusSquared) then
            failures = failures + 1
            if (failures > maxSampleFailures) then break end
            continue
        end
        
        failures = 0
        points[pointIndex*2 + 1] = x
        points[pointIndex*2 + 2] = y
        if (visualizer) then visualizer(x, y) end
    end
    
    return points
end

function Tesselation.ThreeThreeFourThreeFourInCircle(
    unitSize                :(number),
    maxDistanceFromCenter   :(number),
    maxPointCount           :(number),
    maxSampleFailures       :(number),
    visualizer              :(any?)
)   :({number})
    
    local points :({number}) = tcreate(maxPointCount)

    local maxDistanceSquared = maxDistanceFromCenter * maxDistanceFromCenter
    local halfUnit = unitSize / 2
    
    local ulamIndex = 0
    local failCount = 0
    local pointIndexOffset = 0
   
    while (pointIndexOffset / 2 < maxPointCount) do
        
        local offsetX, offsetY = Tesselation.Ulam(ulamIndex, 1)
        
        local x = offsetX * halfUnit * 6
        local y = offsetY * halfUnit * 6
        
        for candidateIndexOffset = 0, #ThreeThreeFourThreeFourCandidates-1, 2 do
            local cx = ThreeThreeFourThreeFourCandidates[candidateIndexOffset + 1] * halfUnit + x
            local cy = ThreeThreeFourThreeFourCandidates[candidateIndexOffset + 2] * halfUnit + y
            if (cx * cx + cy * cy > maxDistanceSquared) then
                failCount = failCount + 1
                continue
            end
            failCount = 0
            points[pointIndexOffset + 1] = cx
            points[pointIndexOffset + 2] = cy
            pointIndexOffset = pointIndexOffset + 2
            if (visualizer) then visualizer(cx, cy) end
        end
        
        ulamIndex = ulamIndex + 1
        
        if (unitSize * min(abs(offsetX), abs(offsetY)) - 3 * halfUnit > maxDistanceFromCenter) then break end
        if failCount > 999 then break end
        
    end
        
    return points
end

function Tesselation.GeneratePointsOnGridSquareCorners(
    
    offsetX :(number),
    offsetY :(number),
    width   :(number),
    length  :(number),
    spacing :(number)
    
)   :({number})
    
    local numPoints = width*length
    
    local points    :({number}) = tcreate(numPoints*2)
    
    local hW, hL = width/2*spacing, length/2*spacing
    local iW = 1/width

    for pointIndex = 0, numPoints do
        local pointIndexOffset = pointIndex * 2
        points[pointIndexOffset+1] = offsetX + (pointIndex%width) * spacing - hW
        points[pointIndexOffset+2] = offsetY + floor(pointIndex*iW) * spacing - hL
    end
    
    return points
end

--[[

function Tesselation.GeneratePointsOnHexagonalTileCorners(offset, width, length, spacing, pointytop)
    local points = tcreate(width*length, table)
    local X, Y, Z = offset.X, offset.Y, offset.Z
    local h_spacing = sqrt(3) * spacing
    local v_spacing = 3/2 * spacing -- == 3/4 * height
    if not pointytop then
        -- flat top:
        -- horizontal distance is horiz = 3/4 * width = 3/2 * size
        -- vertical distance is vert = height = sqrt(3) * size
    end
    -- pointy top:
    -- horizontal distance is horiz = width = sqrt(3) * size
    -- vertical distance is vert == 3/4 * height == 3/2 * size
    for P = 0, #points-1 do
        local z = floor(P/width)
        points[P+1] = {
            X + ( P%width+1 - (width+z%2)/2 ) * h_spacing,
            Y,
            Z + ( z - (length/2)) * v_spacing
        }
    end
    return points
end

function Points.GeneratePointsOnHexagonCenters(offset, width, length, size, pointytop)
    local points = tcreate(width*length, table)
    local X, Y, Z = offset.X, offset.Y, offset.Z
    local h_spacing = sqrt(3) * size
    local v_spacing = 3/2 * size -- == 3/4 * height
    if not pointytop then
        -- flat top:
        -- horizontal distance is horiz = 3/4 * width = 3/2 * size
        -- vertical distance is vert = height = sqrt(3) * size
    end
    -- pointy top:
    -- horizontal distance is horiz = width = sqrt(3) * size
    -- vertical distance is vert == 3/4 * height == 3/2 * size
    for P = 0, #points-1 do
        local z = floor(P/width)
        points[P+1] = {
            X + ( P%width+1 - (width+z%2)/2 ) * h_spacing,
            Y,
            Z + ( z - (length/2)) * v_spacing
        }
    end
    return points
end

]]


return Tesselation
