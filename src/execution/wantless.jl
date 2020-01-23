function inputto(node::Node, input::Input)
  slot = node.inputmap[input.sender.id]
  node.inputs[slot] = input
end

function inputto(sourcenode::Node, data, globalstep::Int64)
  slot = isempty(sourcenode.inputs) ? inputslot(sourcenode) : 1
  input = Input(data, nothing, globalstep)
  sourcenode.inputs[slot] = input
end

function forward_output(sourcenode, globalstep::Int64)
  for target in sourcenode.connections
      inputto(target, Input(sourcenode.output, sourcenode, globalstep))
  end
end

function step!(node::Node, globalstep::Int64)
  inputlength = length(node.inputs)
  if inputlength == 0
      node.output = compute(node.component, globalstep)
  elseif inputlength == 1
      node.output = compute(node.component, node.inputs[1].data)
  else
      node.output = compute(node.component, [input.data for input = node.inputs])
  end
  forward_output(node, globalstep)
end

function inputto(scheduler::AbstractScheduler, data)
  inputto(scheduler.network.nodes[1], data, scheduler.globalstep)
end
