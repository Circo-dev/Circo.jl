NodeId = UInt64
SourceFunction = Tuple{Function, Function}

mutable struct Node{F}
    id::NodeId
    inputs::Vector{Input}
    inputmap::Dict{NodeId, UInt} # source => input idx
    output
    connections::Set{Node}
    op!::F
    hasinput::Union{Function, Nothing}
    Node(op!) = new{typeof(op!)}(rand(UInt64), Vector(), IdDict(), 0, Set(), op!, nothing)
    Node(source::SourceFunction) = new{typeof(source[1])}(rand(UInt64), Vector(), IdDict(), 0, Set(), source[1], source[2])
end

function inputslot(node::Node)::Int
    push!(node.inputs, Input(0, nothing, 0)) #TODO: nullable
    length(node.inputs)
end

function hasinput(node::Node, globalstep::Int64)
    node.hasinput != nothing && node.hasinput(globalstep)
end

function issource(node::Node)
    return length(node.inputs) == 0 && applicable(node.op!, Int64)
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
        node.output = node.op!(globalstep)
    elseif inputlength == 1
        node.output = node.op!(node.inputs[1].data)
    else
        node.output = node.op!([input.data for input = node.inputs])
    end
    forward_output(node, globalstep)
end
