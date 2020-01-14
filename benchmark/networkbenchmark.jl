using Circo
using BenchmarkTools

function iterate_network!(network, itercount)
    sum = 0
    for stepnum in 1:itercount
        sum += network(stepnum)
    end
    return sum
end
#network = ((x -> 2x) | (x -> x+1))
#total = iterate_network!(network, 1000) 
#println("Results of sum(x=1:1000 2x+1):$total") 
#@btime iterate_network!(network, 1000) setup=(network = ((x -> 2x) | (x -> x+1)))

SUITE["Network"] = BenchmarkGroup()
SUITE["Network"]["1node_1000steps2x"] = @benchmarkable iterate_network!(network, 1000) setup=(network = Network([Node(x -> 2x)]))
SUITE["Network"]["2nodes_1000steps2xplus1"] = @benchmarkable iterate_network!(network, 1000) setup=(network = ((x -> 2x) | (x -> x+1)))
SUITE["Network"]["4nodes_1000steps4xplus2"] = @benchmarkable iterate_network!(network, 1000) setup=(network = ((x -> 2x) | (x -> 2x) | (x -> x+1) | (x -> x+1)))
