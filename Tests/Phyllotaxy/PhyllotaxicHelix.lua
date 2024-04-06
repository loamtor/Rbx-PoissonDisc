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
DebugSpace.Name = "PhyllotaxicHelixPoints"
Debug.SetDebugSpace(DebugSpace)

local PhyllotaxicHelixPoints   =   Phyllotaxy.Helix(
    1,
    100,
    10000,
    Phyllotaxy["GoldenAngle"],
    Debug.Visualizers.ValidVisualizer
)

DebugSpace.Parent = workspace
