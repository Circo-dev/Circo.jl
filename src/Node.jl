SourceFunction = Tuple{Function, Function}

abstract type AbstractNode
end

mutable struct Node <: AbstractNode
    inputs::AbstractVector{Input}
    inputmap::IdDict{Node, Number} # source => input idx
    output
    connections::Set{Node}
    op!::Function
    hasinput::Union{Function, Nothing}
    Node(op!::Function) = new(Vector(), IdDict(), 0, Set(), op!, nothing)
    Node(source::SourceFunction) = new(Vector(), IdDict(), 0, Set(), source[1], source[2])
end

function inputslot(node::Node)::Int
    push!(node.inputs, Input(0, nothing, 0)) #TODO: nullable
    length(node.inputs)
end

function hasinput(node::Node, globalstep::Int64)
    node.hasinput != nothing && node.hasinput(globalstep)
end

function issource(node::Node)
    return applicable(node.op!)
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

function inputto(sourcenode::Node, data, globalstep::Int64)
    slot = isempty(sourcenode.inputs) ? inputslot(sourcenode) : 1
    input = Input(data, nothing, globalstep)
    sourcenode.inputs[slot] = input
end

function flatinputs(node::Node)
    Iterators.flatten([input.data for input = node.inputs])
end

function step!(node::Node, globalstep::Int64)
    inputs = collect(flatinputs(node))
    if length(node.inputs) == 0
        node.output = node.op!(globalstep)
    else
        node.output = node.op!(node.inputs[1].data)
    end
    for target in node.connections
        inputto(target, Input(node.output, node, globalstep))
    end
end
