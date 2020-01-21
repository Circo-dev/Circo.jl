mutable struct SimpleScheduler <: AbstractScheduler
  network::Network
  globalstep::Int64
  SimpleScheduler(network) = new(network, 1)
end

function (network::Network)()
  scheduler = SimpleScheduler(network)
  scheduler()
end

function (scheduler::AbstractScheduler)()
  while hasinput(scheduler.network.nodes[1], scheduler.globalstep)
      step!(scheduler)
  end
  return scheduler.network.nodes[end].output
end

function step!(scheduler::SimpleScheduler)
  globalstep = scheduler.globalstep
  for node in scheduler.network.nodes
      step!(node, globalstep)
  end
  scheduler.globalstep += 1
end
