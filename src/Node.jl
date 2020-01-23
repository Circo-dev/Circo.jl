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
    node.hasinput !== nothing && node.hasinput(globalstep)
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
