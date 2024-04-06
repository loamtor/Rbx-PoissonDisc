--!strict

-- Services:

local ServerStorage         =   game:GetService("ServerStorage")
local ReplicatedStorage     =   game:GetService("ReplicatedStorage")

-- Libraries:

local Debug             =   require(ReplicatedStorage["Debug"])
local Algaerhythms      =   ServerStorage["Algaerhythms"]

local PointDistribution =   require(Algaerhythms["PointDistribution"])
local PoissonDisc       =   PointDistribution["PoissonDisc"]

local DefaultSettings   =   PoissonDisc["DefaultSettings"]

-- Test:

local DebugSpace = Instance.new("Model")
DebugSpace.Name = "PoissonDiscRectangularPrismPoints"
Debug.SetDebugSpace(DebugSpace)

local RectangularPrismPoints   =   PoissonDisc.GeneratePointsInRectangularPrism(
    3000,
    3000,
    50,
    5000,
    10,
    DefaultSettings.MaxSampleAttempts,
    DefaultSettings.RandomSource,
    DefaultSettings.Epsilon,
    Debug.Visualizers.ValidVisualizer,
    Debug.Visualizers.Null,
    Debug.Visualizers.ValidConnectionVisualizer,
    Debug.Visualizers.Null
)

DebugSpace.Parent = workspace
