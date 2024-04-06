--!strict

local PointDistribution = {
    ["PoissonDisc"]     =   require(script["PoissonDisc"]),
    ["Phyllotaxy"]      =   require(script["Phyllotaxy"]),
    ["Tesselation"]     =   require(script["Tesselation"]),
    
    ["DefaultSettings"] =   {
        
        ["RandomSource"]    =   Random.new(tick()),
        ["Epsilon"]         =   0.0001,
        ["AngleMultiplier"] =   1
        
    }
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

--[[

points = Array.from({length: n}, (_, i) => [
  i / phi * 360 % 360, 
  Math.acos(2 * i / n - 1) / Math.PI * 180 - 90
])

]]

--...

function PointDistribution.UniformRandomSamplesOnSphere(
    
)   :({point3d})
    
    --[[
    
    (
     sqrt(1 - u1) * sin(2 * pi * u2),
     sqrt(1 - u1) * cos(2 * pi * u2),
     sqrt(u1) * sin(2 * pi * u3),
     sqrt(u1) * cos(2 * pi * u3)
    
    )
    
    where u1, u2, and u3 are uniformly random samples of [0, 1]
    
    ]]
    
    
    return {}
end


--Onward!
return PointDistribution
