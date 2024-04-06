--!strict

-- Services:

local ServerStorage         =   game:GetService("ServerStorage")
local ReplicatedStorage     =   game:GetService("ReplicatedStorage")

-- Libraries:

local Debug             =   require(ReplicatedStorage["Debug"])
local Algaerhythms      =   ServerStorage["Algaerhythms"]

local PointDistribution =   require(Algaerhythms["PointDistribution"])
local Phyllotaxy        =   PointDistribution["Phyllotaxy"]

-- Test:

local DebugSpace = Instance.new("Model")
DebugSpace.Name = "PhyllotaxicSpiralPoints"
Debug.SetDebugSpace(DebugSpace)

local PhyllotaxicSpiralPoints   =   Phyllotaxy.SpiralInCircle(
    10,
    100,
    1000,
    Phyllotaxy["GoldenAngle"],
    Debug.Visualizers.ValidVisualizer
)

DebugSpace.Parent = workspace
