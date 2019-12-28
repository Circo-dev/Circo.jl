using Test
using BenchmarkTools
using Circo

function iteratedsteps!(node, itercount)
    for stepnum in 1:itercount
        step!(node, stepnum)
    end
end

@testset "Node Performance" begin
    @btime iteratedsteps!(node, 1000) setup=(node = Node(x -> x)
)
end
