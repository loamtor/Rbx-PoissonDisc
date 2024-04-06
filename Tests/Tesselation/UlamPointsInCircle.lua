--!strict

-- Services:

local ReplicatedStorage     =   game:GetService("ReplicatedStorage")

-- Libraries:

local Debug             =   require(ReplicatedStorage["Debug"])
local Algaerhythms      =   ReplicatedStorage["Algaerhythms"]

local PointDistribution =   require(Algaerhythms["PointDistribution"])
local Tesselation       =   PointDistribution["Tesselation"]

-- Test:

local DebugSpace = Instance.new("Model")
DebugSpace.Name = "UlamGridPoints"
Debug.SetDebugSpace(DebugSpace)

local UlamGridPoints   =   Tesselation.GenerateUlamPointsInCircle(
    10,
    100,
    1000,
    100,
    Debug.Visualizers.ValidVisualizer
)

DebugSpace.Parent = workspace
