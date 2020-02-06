abstract type CooperativeScheduler <: WantlessScheduler end

const MAX_NETWORK_DIAMETER = 100_000

function forward_output(c::WantlessComputation, scheduler::CooperativeScheduler, step::Int64)
  for target in c.node.connections
    inputto(scheduler.computationcache[target.id], Input(c.output, c.node.id, step))
  end
  return nothing
end

function (scheduler::CooperativeScheduler)(data;rollout=true)
  inputto(scheduler, data)
  step!(scheduler)
  rollout && rollout!(scheduler)
  return scheduler.computations[end].output
end

function (scheduler::CooperativeScheduler)(;rollout=true)
  while hasinput(scheduler.computations[1].node, scheduler.step)
      step!(scheduler)
  end
  rollout && rollout!(scheduler)
  return scheduler.computations[end].output
end

function step!(scheduler::CooperativeScheduler)
  error("step! not implemented for scheduler $scheduler")
end

function rollout!(scheduler::CooperativeScheduler)
  for i in 1:scheduler.networkdiameter - 1
    step!(scheduler)
  end
  return nothing
end
