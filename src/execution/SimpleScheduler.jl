mutable struct SimpleScheduler <: AbstractScheduler
  computations::Array{WantlessComputation} #TODO PERF: stabilize element type (multiple arrays if needed)
  computationcache::Dict{NodeId,WantlessComputation}
  superstep::Int64
end

SimpleScheduler(network::Network) = begin
  computations = [WantlessComputation(node) for node in network.nodes]
  computationcache = Dict([(c.node.id, c) for c in computations])
  return SimpleScheduler(computations, computationcache, 1)
end

function (network::Network)()
  scheduler = SimpleScheduler(network)
  scheduler()
end

function forward_output(c::WantlessComputation, scheduler::SimpleScheduler, superstep::Int64)
  for target in c.node.connections
      inputto(scheduler.computationcache[target.id], Input(c.output, c.node, superstep))
  end
  return nothing
end

function (scheduler::SimpleScheduler)(data)
  inputto(scheduler, data)
  step!(scheduler)
  return scheduler.computations[end].output
end

function (scheduler::SimpleScheduler)()
  while hasinput(scheduler.computations[1].node, scheduler.superstep)
      step!(scheduler)
  end
  return scheduler.computations[end].output
end

function step!(scheduler::SimpleScheduler)
  superstep = scheduler.superstep
  for computation in scheduler.computations
      step!(computation, scheduler, superstep)
  end
  scheduler.superstep += 1
end
