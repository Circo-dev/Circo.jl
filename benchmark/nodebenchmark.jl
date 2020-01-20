using Circo

function iteratedsteps!(node, itercount)
    for stepnum in 1:itercount
        step!(node, stepnum)
    end
end

SUITE["Node"] = BenchmarkGroup()
SUITE["Node"]["nodeonly_1000steps_id"] = @benchmarkable iteratedsteps!(node, 1000) setup=(node = Node(x -> x))
SUITE["Node"]["nodeonly_1000steps_2x"] = @benchmarkable iteratedsteps!(node, 1000) setup=(node = Node(x -> 2x))
