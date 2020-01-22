abstract type AbstractScheduler end

function inputto(scheduler::AbstractScheduler, data)
  inputto(scheduler.network.nodes[1], data, scheduler.globalstep)
end

include("SimpleScheduler.jl")