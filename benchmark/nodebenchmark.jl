using Circo

function iteratedsteps!(node, itercount)
    for stepnum in 1:itercount
        step!(node, stepnum)
    end
end

SUITE["Node"] = BenchmarkGroup()
SUITE["Node"]["iteratedsteps"] = @benchmarkable iteratedsteps!(node, 1000) setup=(node = Node(x -> x))
SUITE["Node"]["iteratedsteps2x"] = @benchmarkable iteratedsteps!(node, 1000) setup=(node = Node(x -> 2x))
