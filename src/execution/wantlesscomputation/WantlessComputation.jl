mutable struct WantlessComputation{C<:Component}
  node::Node{C} #TODO rename both the field and the type
  inputs::Vector{Input}
  output
  WantlessComputation(node::Node) = new{typeof(node.component)}(node,Vector{Input}(undef,length(node.inputs)),nothing)
end

function inputto(c::WantlessComputation, input::Input)
  slot = c.node.inputmap[input.sender]
  c.inputs[slot] = input
end

function inputto(c::WantlessComputation, data, step::Int64)
  length(c.inputs) > 0 || push!(c.inputs, Input(nothing,0,0))
  slot = 1 # Source node has only one input
  input = Input(data, 0, step)
  c.inputs[slot] = input
end

function forward_output(c::WantlessComputation, scheduler::WantlessScheduler, step::Int64)
  return nothing
end

function step!(c::WantlessComputation, step::Int64)
  inputlength = length(c.inputs)
  try
    if inputlength == 0
        if hasinput(c.node, step)
          c.output = compute(c.node.component, step)
        else
          c.output = nothing
        end
    elseif inputlength == 1
        c.output = compute(c.node.component, c.inputs[1].data)
    else
        c.output = compute(c.node.component, [input.data for input = c.inputs])
    end
  catch e
    #@warn "Caught $e in step!"
  end
  return nothing
end

function step_forward_output!(c::WantlessComputation, scheduler::WantlessScheduler, step::Int64)
  step!(c, step)
  forward_output(c, scheduler, step)
end

function inputto(scheduler::WantlessScheduler, data)
  inputto(scheduler.computations[1], data, scheduler.step)
end
