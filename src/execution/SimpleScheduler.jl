mutable struct SimpleScheduler <: CooperativeScheduler
  computations::Array{WantlessComputation} #TODO PERF: stabilize element type (multiple arrays if needed)
  computationcache::Dict{NodeId,WantlessComputation}
  networkdiameter::Int64
  step::Int64
  SimpleScheduler(computations, networkdiameter) =
    networkdiameter > MAX_NETWORK_DIAMETER ? error("Invalid network diameter: $(networkdiameter), maximum allowed is $(MAX_NETWORK_DIAMETER).") :
    new(computations, Dict([(c.node.id, c) for c in computations]), networkdiameter, 1)
end

SimpleScheduler(network::Network) = begin
  computations = [WantlessComputation(node) for node in network.nodes]
  return SimpleScheduler(computations, diameter(network))
end

function step!(scheduler::SimpleScheduler)
  step = scheduler.step
  if length(scheduler.computations) < 10
    for computation in scheduler.computations
      step!(computation, step)
    end
    for computation in scheduler.computations
      forward_output(computation, scheduler, step)
    end
  else
    Threads.@threads for computation in scheduler.computations
        step!(computation, step)
    end
    Threads.@threads for computation in scheduler.computations
      forward_output(computation, scheduler, step)
    end
  end
  scheduler.step += 1
end
