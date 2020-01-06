using Circo

function iterate_network!(network, itercount)
    for stepnum in 1:itercount
        network(stepnum)
    end
end

SUITE["Network"] = BenchmarkGroup()
SUITE["Network"]["1node_1000steps2x"] = @benchmarkable iterate_network!(network, 1000) setup=(network = Network([Node(x -> 2x)]))
SUITE["Network"]["2nodes_1000steps2x"] = @benchmarkable iterate_network!(network, 1000) setup=(network = ((x -> 2x) | (x -> 2x)))
SUITE["Network"]["4nodes_1000steps2x"] = @benchmarkable iterate_network!(network, 1000) setup=(network = ((x -> 2x) | (x -> 2x) | (x -> 2x) | (x -> 2x)))
