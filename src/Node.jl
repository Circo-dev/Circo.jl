NodeId = UInt64
SourceFunction = Tuple{Function, Function}

mutable struct Node{C}
    id::NodeId
    inputs::Vector{Input}
    inputmap::Dict{NodeId, UInt} # source => input idx
    output
    connections::Set{Node}
    component::C
    hasinput::Union{Function, Nothing}
    Node(op::Function) = new{FunComp{typeof(op)}}(rand(UInt64), Vector(), IdDict(), 0, Set(), FunComp(op), nothing)
    Node(source::SourceFunction) = new{FunComp{typeof(source[1])}}(rand(UInt64), Vector(), IdDict(), 0, Set(), FunComp(source[1]), source[2])
    Node(comp) = new{typeof(comp)}(rand(UInt64), Vector(), IdDict(), 0, Set(), comp, nothing)
end

function inputslot(node::Node)::Int
    push!(node.inputs, Input(0, nothing, 0)) #TODO: nullable
    length(node.inputs)
end

function hasinput(node::Node, globalstep::Int64)
    node.hasinput != nothing && node.hasinput(globalstep)
end

function issource(node::Node)
    return length(node.inputs) == 0 && applicable(compute, node.component, Int64)
end

function connect(source::Node, target::Node)
    push!(source.connections, target)
    slot = inputslot(target)
    target.inputmap[source.id] = slot
end

function isconnected(source::Node, target::Node)
    target in source.connections
end

function inputto(node::Node, input::Input)
    slot = node.inputmap[input.sender.id]#TODO enque if needed
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
