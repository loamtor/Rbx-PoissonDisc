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
DebugSpace.Name = "PoissonDiscRectanglePoints"
Debug.SetDebugSpace(DebugSpace)

PoissonDisc.GeneratePointsInRectangle(
    1000,
    1000,
    1000,
    3,
    DefaultSettings.MaxSampleAttempts,
    DefaultSettings.RandomSource,
    DefaultSettings.Epsilon,
    Debug.Visualizers.ValidVisualizer,
    Debug.Visualizers.Null,
    Debug.Visualizers.ValidConnectionVisualizer,
    Debug.Visualizers.Null
)

-- Benchmark:

local BenchmarkIterations = 0

Debug.Benchmark(function()

    PoissonDisc.GeneratePointsInRectangle(
        1000,
        1000,
        1000,
        3,
        DefaultSettings.DefaultMaxSampleAttempts,
        DefaultSettings.DefaultRandomSource,
        DefaultSettings.DefaultEpsilon,
        Debug.Visualizers.Null,
        Debug.Visualizers.Null,
        Debug.Visualizers.Null,
        Debug.Visualizers.Null
    )

end, BenchmarkIterations, true, "GeneratePointsInRectangle")

DebugSpace.Parent = workspace
