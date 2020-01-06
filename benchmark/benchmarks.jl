using BenchmarkTools

const SUITE = BenchmarkGroup()

include("nodebenchmark.jl")
include("networkbenchmark.jl")
