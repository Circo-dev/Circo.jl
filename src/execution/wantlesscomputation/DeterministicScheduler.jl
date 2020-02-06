mutable struct DeterministicScheduler <: CooperativeScheduler
    computations::Array{WantlessComputation} # TODO PERF: stabilize element type (multiple arrays if needed)
    computationcache::Dict{NodeId,WantlessComputation}
    networkdiameter::Int64
    step::Int64
    DeterministicScheduler(computations, networkdiameter) =
    networkdiameter > MAX_NETWORK_DIAMETER ? error("Invalid network diameter: $(networkdiameter), maximum allowed is $(MAX_NETWORK_DIAMETER).") :
    new(computations, Dict([(c.node.id, c) for c in computations]), networkdiameter, 1)
end

DeterministicScheduler(network::Network) = begin
    computations = [WantlessComputation(node) for node in network.nodes]
    return DeterministicScheduler(computations, diameter(network))
end

function (network::Network)()
    scheduler = DeterministicScheduler(network)
    scheduler()
end

function step!(scheduler::DeterministicScheduler)
    step = scheduler.step
    for computation in scheduler.computations
        step!(computation, step)
    end
    for computation in scheduler.computations
        forward_output(computation, scheduler, step)
    end
    scheduler.step += 1
end
