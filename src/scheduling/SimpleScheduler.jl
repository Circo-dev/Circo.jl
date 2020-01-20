mutable struct SimpleScheduler <: AbstractScheduler
  globalstep::Int64
  SimpleScheduler() = new(1)
end

Network(nodes) = Network(nodes, SimpleScheduler())

function step!(scheduler::SimpleScheduler, network::Network)
  globalstep = scheduler.globalstep
  for node in network.nodes
      step!(node, globalstep)
  end
  scheduler.globalstep += 1
end
