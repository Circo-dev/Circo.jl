mutable struct Node
    inputs::AbstractVector{Input}
    inputmap::IdDict{Node, Number} # source => input idx
    output::AbstractVector{Number}
    connections::Set{Node}
    op!::Function
    Node(op!::Function) = new(Vector(), IdDict(), Vector(), Set(), op!)
end

function inputslot(node::Node)::Int
    push!(node.inputs, Input([], nothing, 0)) #TODO: nullable
    length(node.inputs)
end

function connect(source::Node, target::Node)
    push!(source.connections, target)
    slot = inputslot(target)
    target.inputmap[source] = slot
end

function isconnected(source::Node, target::Node)
    target in source.connections
end

function inputto(node::Node, input::Input)
    slot = node.inputmap[input.sender]#TODO enque if needed
    node.inputs[slot] = input
end

function inputto(sourcenode::Node, data::InputData, globalstep::Int64)
    slot = isempty(sourcenode.inputs) ? inputslot(sourcenode) : 1
    input = Input(data, nothing, globalstep)
    println(slot)
    sourcenode.inputs[slot] = input
end

function flatinputs(node::Node)
    Iterators.flatten([input.data for input = node.inputs])
end

function step!(node::Node, globalstep::Int64)
    inputs = collect(flatinputs(node))
    node.output = node.op!.(inputs)
    for target in node.connections
        inputto(target, Input(node.output, node, globalstep))
    end
end
