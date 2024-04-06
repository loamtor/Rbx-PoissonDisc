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
DebugSpace.Name = "SphereSurfacePoints"
Debug.SetDebugSpace(DebugSpace)
DebugSpace.Parent = workspace

local SphereSurfacePoints   =   PoissonDisc.GeneratePointsOnSphereSurface(
    100,
    10000,
    5,
    DefaultSettings.MaxSampleAttempts,
    DefaultSettings.RandomSource,
    DefaultSettings.Epsilon,
    Debug.Visualizers.ValidVisualizer,
    Debug.Visualizers.Null,
    Debug.Visualizers.ValidConnectionVisualizer,
    Debug.Visualizers.Null,
    Debug.Visualizers.Null
)

