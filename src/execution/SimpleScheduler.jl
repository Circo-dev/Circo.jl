const MAX_DIAMETER = 100_000

mutable struct SimpleScheduler <: AbstractScheduler
  computations::Array{WantlessComputation} #TODO PERF: stabilize element type (multiple arrays if needed)
  computationcache::Dict{NodeId,WantlessComputation}
  networkdiameter::Int64
  superstep::Int64
end

SimpleScheduler(network::Network) = begin
  computations = [WantlessComputation(node) for node in network.nodes]
  computationcache = Dict([(c.node.id, c) for c in computations])
  return SimpleScheduler(computations, computationcache, diameter(network), 1)
end

function (network::Network)()
  scheduler = SimpleScheduler(network)
  scheduler()
end

function forward_output(c::WantlessComputation, scheduler::SimpleScheduler, superstep::Int64)
  for target in c.node.connections
    inputto(scheduler.computationcache[target.id], Input(c.output, c.node.id, superstep))
  end
  return nothing
end

function (scheduler::SimpleScheduler)(data;rollout=true)
  inputto(scheduler, data)
  step!(scheduler)
  rollout && rollout!(scheduler)
  return scheduler.computations[end].output
end

function (scheduler::SimpleScheduler)(;rollout=true)
  while hasinput(scheduler.computations[1].node, scheduler.superstep)
      step!(scheduler)
  end
  rollout && rollout!(scheduler)
  return scheduler.computations[end].output
end

function step!(scheduler::SimpleScheduler)
  superstep = scheduler.superstep
  if length(scheduler.computations) < 10
    for computation in scheduler.computations
      step!(computation, superstep)
    end
    for computation in scheduler.computations
      forward_output(computation, scheduler, superstep)
    end
  else
    Threads.@threads for computation in scheduler.computations
        step!(computation, superstep)
    end
    Threads.@threads for computation in scheduler.computations
      forward_output(computation, scheduler, superstep)
    end
  end
  scheduler.superstep += 1
end

function rollout!(scheduler::SimpleScheduler)
  if scheduler.networkdiameter < MAX_DIAMETER # TODO Make it invariant
    for i in 1:scheduler.networkdiameter - 1
      step!(scheduler)
    end
  else
    @warn "Invalid network diameter: $(scheduler.networkdiameter), maximum allowed is $(MAX_DIAMETER)."
  end
  return nothing
end
