--!strict

-- Implementation of Poisson Disc Generation based on Martin Roberts' improvement on Bridson's 2007 Algorithm (found on 'Observable HQ').
-- Two dimensional sample sets lie within the X-Z plane.

local PoissonDisc = {}

local floor     =   math.floor
local ceil      =   math.ceil
local sqrt      =   math.sqrt
local min       =   math.min
local max       =   math.max
local sin       =   math.sin
local asin      =   math.asin
local cos       =   math.cos
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

PoissonDisc.DefaultSettings = {
    ["RandomSource"] = Random.new(tick()),
    ["Epsilon"] = 0.0001,
    ["MaxSampleAttempts"] = 10,
}

function PoissonDisc.GeneratePointsInRectangle(
    
    width               :(number),
    height              :(number),
    maxPoints           :(number),
    cullRadius          :(number),
    maxSampleAttempts   :(number),
    randomSource        :(Random),
    epsilon             :(number),
    visualizer          :(any?),
    invalidVisualizer   :(any?),
    pathVisualizer      :(any?),
    invalidPathVisualizer:(any?)
    
)   :{(point2d)}
    
    local radiusEpsiloned   :(number)   =   cullRadius + epsilon
    local radiusSquared     :(number)   =   cullRadius * cullRadius -- radius2
    local radiusSquareRoot  :(number)   =   cullRadius * sqrt(0.5) -- cellSize
    local oneOverRadiusSqrt :(number)   =   1 / radiusSquareRoot
    
    local gridWidth     :(number)   =   ceil(width / radiusSquareRoot) 
    local gridHeight    :(number)   =   ceil(height / radiusSquareRoot)
    local numCells      :(number)   =   gridWidth * gridHeight
    
    local grid  :{(point2d)}    =   tcreate(numCells)
    
    -- TODO JOHN: make sure that the table.create count is correct:
    local xQueue    :{(number)} =   tcreate(width * 2 + height * 2)
    local yQueue    :{(number)} =   tcreate(width * 2 + height * 2)
    
    local pointCount:(number)   =   0
    local queueCount:(number)   =   0
    
    local function sample(x:number, y:number): ()
        pointCount = pointCount + 1
        grid[gridWidth * floor(y * oneOverRadiusSqrt) + floor(x * oneOverRadiusSqrt)] = {x = x, y = y}
        tinsert(xQueue, x)
        tinsert(yQueue, y)
        queueCount = queueCount + 1
        if (visualizer ~= nil) then
            visualizer(x, y)
        end
    end
    
    sample(width / 2 , height / 2)
    
    -- Pick a random existing sample from the queue:
    while (queueCount > 0) do
        local currentIndex :(number)    =   randomSource:NextInteger(1, queueCount)
        
        local seed  :(number)           =   randomSource:NextNumber()

        local xParent   :(number) = xQueue[currentIndex] or 0
        local yParent   :(number) = yQueue[currentIndex] or 0

        local accepted = false
        
        for attempt = 0, maxSampleAttempts-1 do
            local angle = 2 * pi * (seed + 1.0*attempt/maxSampleAttempts)
            
            local x :(number) =   xParent + radiusEpsiloned * cos(angle)
            local y :(number) =   yParent + radiusEpsiloned * sin(angle)
            
            -- Accept candidates that are inside the allowed extent:
            if (
                x < 0
                or x >= width
                or y < 0
                or y >= height
            ) then continue end
            
            local i = floor(x/radiusSquareRoot)
            local j = floor(y/radiusSquareRoot)
            local i0 = max(i - 2, 0)
            local j0 = max(j - 2, 0)
            local i1 = min(i + 3, gridWidth)
            local j1 = min(j + 3, gridHeight)

            local invalid = false
            for j = j0, j1-1, 1 do
                local o = j * gridWidth
                for i = i0, i1-1, 1 do
                    local s = grid[o + i]
                    if (s) then
                        local dx = s.x - x
                        local dy = s.y - y
                        -- Only accept candidates farther than 2*radius from other samples:
                        if (dx * dx + dy * dy < radiusSquared) then
                            invalid = true
                            if (invalidVisualizer ~= nil) then
                                invalidVisualizer(x, y)
                            end
                            if (invalidPathVisualizer ~= nil) then
                                invalidPathVisualizer(x, xParent, y, yParent)
                            end
                            break
                        end
                    end
                end
                if invalid then break end
            end
            
            -- If invalid, move on to the next sample:
            if (invalid) then continue end
            
            -- Go ahead and add the sample if it is good:
            accepted = true
            sample(x, y)
            
            if (pathVisualizer ~= nil) then
                pathVisualizer(x, xParent, y, yParent)
            end
           
            if (pointCount >= maxPoints) then return grid end
            
            --task.wait()
            
            -------------------------------------------------------
            -- TODO: Here, break? or continue?
            -------------------------------------------------------

            continue

        end

        if (accepted) then continue end

        -- If none of the candidates were accepted, remove it from the queue:
        
        local poppedX :(number) = tremove(xQueue) or 0 -- supposed to be a pop here.
        local poppedY :(number) = tremove(yQueue) or 0
        
        queueCount = queueCount - 1
        
        if currentIndex <= queueCount then
            --if (CURRENT_INDEX ~= 1) then
            xQueue[currentIndex] = poppedX
            yQueue[currentIndex] = poppedY
        end

    end
    
    return grid
end

function PoissonDisc.GeneratePointsInRectangularPrism(

    width               :(number),
    height              :(number),
    length              :(number),
    maxPoints           :(number),
    cullRadius          :(number),
    maxSampleAttempts   :(number),
    randomSource        :(Random),
    epsilon             :(number),
    visualizer          :(any?),
    invalidVisualizer   :(any?),
    pathVisualizer      :(any?),
    invalidPathVisualizer:(any?)

)   :{(point3d)}

    local radiusEpsiloned   :(number)   =   cullRadius + epsilon
    local radiusSquared     :(number)   =   cullRadius * cullRadius -- radius2
    local radiusSquareRoot  :(number)   =   cullRadius * sqrt(0.5) -- cellSize
    local oneOverRadiusSqrt :(number)   =   1 / radiusSquareRoot

    local gridWidth     :(number)   =   ceil(width / radiusSquareRoot) 
    local gridHeight    :(number)   =   ceil(height / radiusSquareRoot)
    local gridLength    :(number)   =   ceil(length / radiusSquareRoot)
    local gridArea      :(number)   =   gridWidth * gridHeight
    
    local numCells      :(number)   =   gridWidth * gridHeight * gridLength

    local grid  :{(point3d)}    =   tcreate(numCells)

    -- TODO JOHN: make sure that the table.create count is correct:
    local xQueue    :{(number)} =   tcreate(width * 2 + height * 2)
    local yQueue    :{(number)} =   tcreate(width * 2 + height * 2)
    local zQueue    :{(number)} =   tcreate(width * 2 + height * 2)
    
    local pointCount:(number)   =   0
    local queueCount:(number)   =   0

    local function sample(x:number, y:number, z:number): ()
        pointCount = pointCount + 1
        local xN = floor(x * oneOverRadiusSqrt)
        local yN = floor(y * oneOverRadiusSqrt)
        local zN = floor(z * oneOverRadiusSqrt)
        grid[
            gridArea * zN + gridWidth * yN + xN
        ] = {x = x, y = y, z = z}
        tinsert(xQueue, x)
        tinsert(yQueue, y)
        tinsert(zQueue, z)
        queueCount = queueCount + 1
        if (visualizer ~= nil) then
            visualizer(x, y, z)
        end
    end

    sample(width / 2 , height / 2, length / 2)

    -- Pick a random existing sample from the queue.
    while (queueCount > 0) do
        local currentIndex :(number)    =   randomSource:NextInteger(1, queueCount)

        local seed  :(number)           =   randomSource:NextNumber()
        local seed2 :(number)           =   randomSource:NextNumber()

        local xParent   :(number) = xQueue[currentIndex] or 0
        local yParent   :(number) = yQueue[currentIndex] or 0
        local zParent   :(number) = zQueue[currentIndex] or 0

        local accepted = false
        
        for attempt = 0, maxSampleAttempts-1 do
            local angle = 2 * pi * (seed + attempt/maxSampleAttempts)
            local angle2 = 2 * pi * (seed2 + attempt/maxSampleAttempts)
            
            local x :(number)   =   xParent + radiusEpsiloned * sin(angle) * cos(angle2)
            local y :(number)   =   yParent + radiusEpsiloned * sin(angle) * sin(angle2)
            local z :(number)   =   zParent + radiusEpsiloned * cos(angle)
            
            -- Accept candidates that are inside the allowed extent:
            if (
                x < 0
                or x >= width
                or y < 0
                or y >= height
                or z < 0
                or z >= length
            ) then continue end

            -- And only candidates that are farther than 2*radius to all existing samples:

            local xIndex = floor(x/radiusSquareRoot)
            local preX = max(xIndex - 2, 0)
            local postX = min(xIndex + 3, gridWidth)
            
            local yIndex = floor(y/radiusSquareRoot)
            local preY = max(yIndex - 2, 0)
            local postY = min(yIndex + 3, gridHeight)
            
            local zIndex = floor(z/radiusSquareRoot)
            local preZ = max(zIndex - 2, 0)
            local postZ = min(zIndex + 3, gridLength)
            
            local invalid = false
            
            for zValue = preZ, postZ - 1, 1 do
                local zCellsOffset = zValue * gridArea
                for yValue = preY, postY - 1, 1 do
                    local yCellsOffset = yValue * gridWidth
                    for xValue = preX, postX - 1, 1 do
                        local cell = grid[zCellsOffset + yCellsOffset + xValue]
                        if (cell) then
                            local dx = cell.x - x
                            local dy = cell.y - y
                            local dz = cell.z - z
                            if (dx * dx + dy * dy + dz * dz < radiusSquared) then
                                invalid = true
                                if (invalidVisualizer ~= nil) then
                                    invalidVisualizer(x, y, z)
                                end
                                if (invalidPathVisualizer ~= nil) then
                                    invalidPathVisualizer(x, xParent, y, yParent, z, zParent)
                                end
                                break
                            end
                        end
                    end
                    if invalid then break end
                end
                if invalid then break end
            end
            
            -- If invalid, move on to the next sample:
            if (invalid) then continue end

            -- Go ahead and add the sample if it's good:
            accepted = true
            sample(x, y, z)
            
            if (pathVisualizer ~= nil) then
                pathVisualizer(x, xParent, y, yParent, z, zParent)
            end
            
            if (pointCount >= maxPoints) then return grid end
            
            --task.wait()

            -------------------------------------------------------
            -- TODO: Here, break? or continue?
            -------------------------------------------------------

            continue

        end

        if (accepted) then continue end

        -- If none of the candidates were accepted, remove it from the queue.

        local poppedX :(number) = tremove(xQueue) or 0 -- supposed to be a pop here.
        local poppedY :(number) = tremove(yQueue) or 0
        local poppedZ :(number) = tremove(zQueue) or 0
        
        queueCount = queueCount - 1

        if currentIndex <= queueCount then
            --if (CURRENT_INDEX ~= 1) then
            xQueue[currentIndex] = poppedX
            yQueue[currentIndex] = poppedY
            zQueue[currentIndex] = poppedZ
        end

    end

    return grid
end

function PoissonDisc.SphereSurfacePointFrom2d(
    point           :(point2d),
    sphereRadius    :(number)
)   :(point3d)
    return {x = point.x, y = point.x, z = point.x}
end

function PoissonDisc.GeneratePointsOnSphereSurfaceWithPolarAnomalies(

    sphereRadius        :(number),
    maxPoints           :(number),
    cullRadius          :(number),
    maxSampleAttempts   :(number),
    randomSource        :(Random),
    epsilon             :(number),
    visualizer          :(any?),
    invalidVisualizer   :(any?),
    pathVisualizer      :(any?),
    invalidPathVisualizer:(any?)
)   :{(point3d)}

    local radiusEpsiloned   :(number)   =   cullRadius + epsilon
    local radiusSquared     :(number)   =   cullRadius * cullRadius -- radius2
    local radiusSquareRoot  :(number)   =   cullRadius * sqrt(0.5) -- cellSize
    local oneOverRadiusSqrt :(number)   =   1 / radiusSquareRoot

    -- L / θ = C / 2π
    -- L = C / 2π * θ
    -- θ = L * 2π / C

    local sphereDiameter    :(number)   =   sphereRadius * 2
    local sphereCircumference:(number)  =   pi * sphereDiameter
    -- angle to keep arc distance at radiusEpsiloned: local angleOfSeparation :(number)   =   radiusEpsiloned * 2 * pi / sphereCircumference
    -- but we want the chord distance to be radiusEpsiloned:
    local angleOfSeparation :(number)   =   2.5 * asin(radiusEpsiloned / sphereDiameter)
    
    --local maxAcceptableAngle:(number)   =   minAngle * 2
    
    local gridUnitWidth     :(number)   =   ceil(oneOverRadiusSqrt * sphereDiameter) 
    local gridUnitArea      :(number)   =   gridUnitWidth * gridUnitWidth

    local numCells      :(number)   =   gridUnitArea * gridUnitWidth

    local grid  :{(point3d)}    =   tcreate(numCells)

    local initQueueSize = ceil(pi * sphereDiameter)

    local xQueue    :{[(number)]:   (number)} =   tcreate(initQueueSize)
    local yQueue    :{[(number)]:   (number)} =   tcreate(initQueueSize)
    local zQueue    :{[(number)]:   (number)} =   tcreate(initQueueSize)
    
    -- theta and phi queues:
    local thetaQueue    :{[(number)]:   (number)} =   tcreate(initQueueSize)
    local phiQueue      :{[(number)]:   (number)} =   tcreate(initQueueSize)

    local pointCount:(number)   =   0
    local queueCount:(number)   =   0
    
    local function sample(
        x       :(number),
        y       :(number),
        z       :(number),
        theta   :(number),
        phi     :(number)
    ): ()
        pointCount = pointCount + 1
        
        local xN = floor(x * oneOverRadiusSqrt)
        local yN = floor(y * oneOverRadiusSqrt)
        local zN = floor(z * oneOverRadiusSqrt)
        grid[
            gridUnitArea * zN + gridUnitWidth * yN + xN
        ] = {x = x, y = y, z = z}
        tinsert(xQueue, x)
        tinsert(yQueue, y)
        tinsert(zQueue, z)
        tinsert(thetaQueue, theta)
        tinsert(phiQueue, phi)
        queueCount = queueCount + 1
        if (visualizer ~= nil) then
            visualizer(x, y, z)
        end
    end

    sample(sphereRadius, sphereRadius, sphereDiameter, 0, 0)

    local oneOverMaxSampleAttempts = 1/maxSampleAttempts

    -- Pick a random existing sample from the queue.
    while (queueCount > 0) do
        local currentIndex :(number)    =   randomSource:NextInteger(1, queueCount)
        
        local xParent   :(number) = xQueue[currentIndex] or 0
        local yParent   :(number) = yQueue[currentIndex] or 0
        local zParent   :(number) = zQueue[currentIndex] or 0

        local thetaParent   :(number)   =   thetaQueue[currentIndex]-- or 0
        local phiParent     :(number)   =   phiQueue[currentIndex]-- or 0

        local seed  :(number)           =   randomSource:NextNumber() * 2 * pi

        local accepted = false

        for attempt = 0, maxSampleAttempts-1 do
            local angle = seed + 2 * pi * oneOverMaxSampleAttempts * attempt
            local theta = thetaParent + sin(angle) * angleOfSeparation
            local phi = phiParent + cos(angle) * angleOfSeparation

            local x :(number)   =   sphereRadius * sin(theta) * cos(phi) + sphereRadius
            local y :(number)   =   sphereRadius * sin(theta) * sin(phi) + sphereRadius
            local z :(number)   =   sphereRadius * cos(theta) + sphereRadius

            --Accept only candidates that are farther than 2*radius to all existing samples:

            local xIndex = floor(oneOverRadiusSqrt*x)
            local preX = max(xIndex - 2, 0)
            local postX = min(xIndex + 3, gridUnitWidth)

            local yIndex = floor(oneOverRadiusSqrt*y)
            local preY = max(yIndex - 2, 0)
            local postY = min(yIndex + 3, gridUnitWidth)

            local zIndex = floor(oneOverRadiusSqrt*z)
            local preZ = max(zIndex - 2, 0)
            local postZ = min(zIndex + 3, gridUnitWidth)

            local invalid = false

            for zValue = preZ, postZ - 1, 1 do
                local zCellsOffset = zValue * gridUnitArea
                for yValue = preY, postY - 1, 1 do
                    local yCellsOffset = yValue * gridUnitWidth
                    for xValue = preX, postX - 1, 1 do
                        local cell = grid[zCellsOffset + yCellsOffset + xValue]
                        if (cell) then
                            local dx = cell.x - x
                            local dy = cell.y - y
                            local dz = cell.z - z
                            if (dx * dx + dy * dy + dz * dz < radiusSquared) then
                                invalid = true
                                if (invalidVisualizer ~= nil) then
                                    invalidVisualizer(x, y, z)
                                end
                                if (invalidPathVisualizer ~= nil) then
                                    invalidPathVisualizer(x, xParent, y, yParent, z, zParent)
                                end
                                break
                            end
                        end
                    end
                    if invalid then break end
                end
                if invalid then break end
            end

            -- If invalid, move on to the next sample:
            if (invalid) then continue end

            -- Go ahead and add the sample if it's good:
            accepted = true
            sample(x, y, z, theta, phi)

            if (pathVisualizer ~= nil) then
                pathVisualizer(x, xParent, y, yParent, z, zParent)
            end

            if (pointCount >= maxPoints) then return grid end

            --task.wait()

            -------------------------------------------------------
            -- TODO: Here, break? or continue?
            -------------------------------------------------------

            continue

        end

        if (accepted) then continue end

        -- If none of the candidates were accepted, remove it from the queue.

        local poppedX       :(number) = tremove(xQueue) or 0 -- supposed to be a pop here.
        local poppedY       :(number) = tremove(yQueue) or 0
        local poppedZ       :(number) = tremove(zQueue) or 0
        local poppedTheta   :(number) = tremove(thetaQueue) or 0
        local poppedPhi     :(number) = tremove(phiQueue) or 0

        queueCount = queueCount - 1

        if currentIndex <= queueCount then
        --if (currentIndex ~= 1) then
            xQueue[currentIndex] = poppedX
            yQueue[currentIndex] = poppedY
            zQueue[currentIndex] = poppedZ
            thetaQueue[currentIndex] = poppedTheta
            phiQueue[currentIndex] = poppedPhi
        end

    end

    return grid
    
end

function PoissonDisc.GeneratePointsOnSphereSurface(

    sphereRadius        :(number),
    maxPoints           :(number),
    cullRadius          :(number),
    maxSampleAttempts   :(number),
    randomSource        :(Random),
    epsilon             :(number),
    visualizer          :(any?),
    invalidVisualizer   :(any?),
    pathVisualizer      :(any?),
    invalidPathVisualizer:(any?),
    sphereVisualizer     :(any?)

)   :{(point3d)}

    local radiusEpsiloned   :(number)   =   cullRadius + epsilon
    local radiusSquared     :(number)   =   cullRadius * cullRadius -- radius2
    local radiusSquareRoot  :(number)   =   cullRadius * sqrt(0.5) -- cellSize
    local oneOverRadiusSqrt :(number)   =   1 / radiusSquareRoot

    -- L / θ = C / 2π
    -- L = C / 2π * θ
    -- θ = L * 2π / C

    local sphereDiameter    :(number)   =   sphereRadius * 2
    local sphereCircumference:(number)  =   pi * sphereDiameter
    -- angle to keep arc distance at radiusEpsiloned: local angleOfSeparation :(number)   =   radiusEpsiloned * 2 * pi / sphereCircumference
    -- but we want the chord distance to be radiusEpsiloned:
    local separationDistance :(number)   =  radiusEpsiloned * 1.5

    if (sphereVisualizer) then
        sphereVisualizer(sphereDiameter)
    end

    --radiusEpsiloned * 2 * pi / sphereCircumference
    -- 1.6 * asin(radiusEpsiloned / sphereDiameter)

    --local maxAcceptableAngle:(number)   =   minAngle * 2

    -- note: grid cells are of size radiusSqrt.
    local gridUnitWidth     :(number)   =   ceil(oneOverRadiusSqrt * sphereDiameter) 
    local gridUnitArea      :(number)   =   gridUnitWidth * gridUnitWidth

    local numCells      :(number)   =   gridUnitArea * gridUnitWidth

    local grid  :{(point3d)}    =   tcreate(numCells)

    local initQueueSize = ceil(pi * sphereDiameter)

    local xQueue    :{[(number)]:   (number)} =   tcreate(initQueueSize)
    local yQueue    :{[(number)]:   (number)} =   tcreate(initQueueSize)
    local zQueue    :{[(number)]:   (number)} =   tcreate(initQueueSize)

    local pointCount:(number)   =   0
    local queueCount:(number)   =   0

    local function sample(
        x       :(number),
        y       :(number),
        z       :(number)
    ): ()
        pointCount = pointCount + 1

        local xIndex = floor((x + sphereRadius) * oneOverRadiusSqrt)
        local yIndex = floor((y + sphereRadius) * oneOverRadiusSqrt)
        local zIndex = floor((z + sphereRadius) * oneOverRadiusSqrt)
        grid[
            gridUnitArea * zIndex + gridUnitWidth * yIndex + xIndex
        ] = {x = x, y = y, z = z}
        tinsert(xQueue, x)
        tinsert(yQueue, y)
        tinsert(zQueue, z)
        queueCount = queueCount + 1
        if (visualizer ~= nil) then
            visualizer(x, y, z)
        end
    end

    local startTheta = randomSource:NextNumber() * 2 * pi
    local startPhi = randomSource:NextNumber() * 2 * pi
    
    sample(
        sphereRadius * sin(startTheta) * cos(startPhi),
        sphereRadius * sin(startTheta) * sin(startPhi),
        sphereRadius * cos(startTheta))
    
    --sample(0, sphereRadius, 0)

    local oneOverMaxSampleAttempts = 1/maxSampleAttempts

    -- Pick a random existing sample from the queue.
    while (queueCount > 0) do
        local currentIndex :(number)    =   randomSource:NextInteger(1, queueCount)

        local xParent   :(number) = xQueue[currentIndex] or 0
        local yParent   :(number) = yQueue[currentIndex] or 0
        local zParent   :(number) = zQueue[currentIndex] or 0
        
        local seed  :(number)   =   randomSource:NextNumber() * 2 * pi

        local angleStep :(number) = 2 * pi * oneOverMaxSampleAttempts

        local accepted = false

        local function unitize(
            x   :(number),
            y   :(number),
            z   :(number)
        ): ((number), (number), (number))
            local oneOverMagnitude = 1/sqrt(x * x + y * y + z * z)
            return oneOverMagnitude * x, oneOverMagnitude * y, oneOverMagnitude * z
        end

        local function crossProduct(
            aX  :(number),
            aY  :(number),
            aZ  :(number),
            bX  :(number),
            bY  :(number),
            bZ  :(number)
        ): ((number), (number), (number))
            return
                aY * (bZ or 0) - (aZ or 0) * bY,
                (aZ or 0) * bX - aX * (bZ or 0),
                aX * bY - aY * bX
        end
        
        local function dotProduct(
            aX  :(number),
            aY  :(number),
            aZ  :(number),
            bX  :(number),
            bY  :(number),
            bZ  :(number)
        ): (number)
            return aX * bX + aY * bY + aZ * bZ
        end
        
        local function rodriguesRotationOnSphere(
            x       :(number),
            y       :(number),
            z       :(number),
            axisX   :(number),
            axisY   :(number),
            axisZ   :(number),
            angle   :(number)
        ) :(number, number, number)
            
            -- first, make sure the axis vector is unit:
            axisX, axisY, axisZ = unitize(axisX, axisY, axisZ)
            
            -- the below is an attempt at rewriting the below formula:
            -- v*cos + (1-angleCos)*v:Dot(k)*k + k:Cross(v)*angleSin
            
            local vectorDotAxis = x * axisX + y * axisY + z * axisZ
            local crossX, crossY, crossZ = crossProduct(axisX, axisY, axisZ, x, y, z)
            
            local angleCos = cos(angle)
            local angleInvCos = 1 - angleCos
            local invCosDot = angleInvCos * vectorDotAxis
            
            local angleSin = sin(angle)
            crossX = crossX * angleSin
            crossY = crossY * angleSin
            crossZ = crossZ * angleSin
            
            x = x*angleCos + invCosDot * axisX + crossX
            y = y*angleCos + invCosDot * axisY + crossY
            z = z*angleCos + invCosDot * axisZ + crossZ
            
            -- unitize points and map to sphere surface:
            x, y, z = unitize(x, y, z)
            
            x = x * sphereRadius
            y = y * sphereRadius
            z = z * sphereRadius
            
            return x, y, z
        end
        
        local oneOverParentMagnitude = 1/sqrt(xParent * xParent + yParent * yParent + zParent * zParent)
        
        local randX, randY, randZ = unitize(randomSource:NextNumber()*2-1, randomSource:NextNumber()*2-1, randomSource:NextNumber()*2-1)
        
        -- cross the up vector with the lookVector to get leftVector:
        local leftX, leftY, leftZ = unitize(crossProduct(
            randX,
            randY,
            randZ,
            xParent,
            yParent,
            zParent))
        
        local startX = xParent + leftX * separationDistance
        local startY = yParent + leftY * separationDistance
        local startZ = zParent + leftZ * separationDistance
        
        startX, startY, startZ = unitize(startX, startY, startZ)
        
        startX = startX * sphereRadius
        startY = startY * sphereRadius
        startZ = startZ * sphereRadius
 
        for attempt = 0, maxSampleAttempts-1 do
            local angle = seed + angleStep * attempt
            
            -- below is an attempt to perform a rodriguez rotation:

            local x :(number), y :(number), z :(number) = 
                rodriguesRotationOnSphere(
                    startX,
                    startY,
                    startZ,
                    xParent,
                    yParent,
                    zParent,
                    angle
                )

            --Accept only candidates that are farther than 2*radius to all existing samples:

            local xIndex = floor(oneOverRadiusSqrt * (x + sphereRadius))
            local preX = max(xIndex - 2, 0)
            local postX = min(xIndex + 3, gridUnitWidth)

            local yIndex = floor(oneOverRadiusSqrt * (y + sphereRadius))
            local preY = max(yIndex - 2, 0)
            local postY = min(yIndex + 3, gridUnitWidth)

            local zIndex = floor(oneOverRadiusSqrt * (z + sphereRadius))
            local preZ = max(zIndex - 2, 0)
            local postZ = min(zIndex + 3, gridUnitWidth)

            local invalid = false

            for zValue = preZ, postZ - 1, 1 do
                local zCellsOffset = zValue * gridUnitArea
                for yValue = preY, postY - 1, 1 do
                    local yCellsOffset = yValue * gridUnitWidth
                    for xValue = preX, postX - 1, 1 do
                        local cell = grid[zCellsOffset + yCellsOffset + xValue]
                        if (cell) then
                            local dx = cell.x - x
                            local dy = cell.y - y
                            local dz = cell.z - z
                            if (dx * dx + dy * dy + dz * dz < radiusSquared) then
                                invalid = true
                                if (invalidVisualizer ~= nil) then
                                    invalidVisualizer(x, y, z)
                                end
                                if (invalidPathVisualizer ~= nil) then
                                    invalidPathVisualizer(x, xParent, y, yParent, z, zParent)
                                end
                                break
                            end
                        end
                    end
                    if invalid then break end
                end
                if invalid then break end
            end

            -- If invalid, move on to the next sample:
            if (invalid) then continue end

            -- Go ahead and add the sample if it's good:
            accepted = true
            sample(x, y, z)

            if (pathVisualizer ~= nil) then
                pathVisualizer(x, xParent, y, yParent, z, zParent)
            end

            if (pointCount >= maxPoints) then return grid end

            --task.wait()

            -------------------------------------------------------
            -- TODO: Here, break? or continue?
            -------------------------------------------------------

            continue

        end

        if (accepted) then continue end

        -- If none of the candidates were accepted, remove it from the queue.

        local poppedX       :(number) = tremove(xQueue) or 0 -- supposed to be a pop here.
        local poppedY       :(number) = tremove(yQueue) or 0
        local poppedZ       :(number) = tremove(zQueue) or 0

        queueCount = queueCount - 1

        if currentIndex <= queueCount then
            --if (currentIndex ~= 1) then
            xQueue[currentIndex] = poppedX
            yQueue[currentIndex] = poppedY
            zQueue[currentIndex] = poppedZ
        end

    end

    return grid

end

return PoissonDisc
