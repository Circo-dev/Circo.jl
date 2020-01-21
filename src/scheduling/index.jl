abstract type AbstractScheduler end

function inputto(scheduler::AbstractScheduler, data)
  inputto(scheduler.network.nodes[1], data, scheduler.globalstep)
end

function (scheduler::AbstractScheduler)(data)
  inputto(scheduler, data)
  step!(scheduler)
  return scheduler.network.nodes[end].output
end

include("SimpleScheduler.jl")