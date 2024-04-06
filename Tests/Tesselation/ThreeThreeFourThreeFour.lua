--!strict

-- Services:

local ServerStorage         =   game:GetService("ServerStorage")
local ReplicatedStorage     =   game:GetService("ReplicatedStorage")

-- Libraries:

local Debug             =   require(ReplicatedStorage["Debug"])
local Algaerhythms      =   ServerStorage["Algaerhythms"]

local PointDistribution =   require(Algaerhythms["PointDistribution"])
local Tesselation       =   PointDistribution["Tesselation"]

-- Test:

local DebugSpace = Instance.new("Model")
DebugSpace.Name = "PhyllotaxicHelixPoints"
Debug.SetDebugSpace(DebugSpace)

local ThreeThreeFourThreeFourPoints   =   Tesselation.ThreeThreeFourThreeFourInCircle(
    2,
    100,
    10000,
    100,
    Debug.Visualizers.ValidVisualizer
)

DebugSpace.Parent = workspace
