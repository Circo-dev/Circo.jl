using BenchmarkTools

const SUITE = BenchmarkGroup()

include("nodebenchmark.jl")
include("networkbenchmark.jl")
include("coroutine-tests.jl")
include("actorbenchmark.jl")
