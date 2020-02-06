mutable struct SimpleScheduler <: CooperativeScheduler
  service::Union{ComponentService,Nothing} #TODO parametrize
  computations::Array{WantlessComputation} #TODO PERF: stabilize element type (multiple arrays if needed)
  computationcache::Dict{NodeId,WantlessComputation}
  networkdiameter::Int64
  step::Int64
  function SimpleScheduler(service, computations, networkdiameter) 
    networkdiameter <= MAX_NETWORK_DIAMETER || error("Invalid network diameter: $(networkdiameter), maximum allowed is $(MAX_NETWORK_DIAMETER).")
    return new(service, computations, Dict([(c.node.id, c) for c in computations]), networkdiameter, 1)
  end
end

SimpleScheduler(network::Network, componentservice=nothing) = begin
  computations = [WantlessComputation(node) for node in network.nodes]
  return SimpleScheduler(componentservice, computations, diameter(network))
end

function addcomputation()
end

#function spawn(service::SimpleComponentService, component::Component)::ComponentId
#  scheduler(service).
#end


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
