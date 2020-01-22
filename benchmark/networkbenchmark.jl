using Circo
using BenchmarkTools

function createchain(chainlength=1000)
    chain = Network([])
    for i=1:chainlength
        chain | (x->x+1)
    end
    return chain
end

function iterate_network!(scheduler, itercount)
    sum = 0
    for stepnum in 1:itercount
        sum += scheduler(stepnum)
    end
    return sum
end
#network = ((x -> 2x) | (x -> x+1))
#total = iterate_network!(network, 1000) 
#println("Results of sum(x=1:1000 2x+1):$total") 
#@btime iterate_network!(network, 1000) setup=(network = ((x -> 2x) | (x -> x+1)))

SUITE["Network"] = BenchmarkGroup()
SUITE["Network"]["1node_1000steps2x"] = @benchmarkable iterate_network!(scheduler, 1000) setup=(scheduler = SimpleScheduler(Network([Node(x -> 2x)])))
SUITE["Network"]["2nodes_1000steps2xplus1"] = @benchmarkable iterate_network!(scheduler, 1000) setup=(scheduler = SimpleScheduler(((x -> 2x) | (x -> x+1))))
SUITE["Network"]["4nodes_1000steps4xplus2"] = @benchmarkable iterate_network!(scheduler, 1000) setup=(scheduler = SimpleScheduler(((x -> 2x) | (x -> 2x) | (x -> x+1) | (x -> x+1))))
SUITE["Network"]["1000nodes_1step"] = @benchmarkable iterate_network!(scheduler, 1) setup=(scheduler = (SimpleScheduler(createchain())))
