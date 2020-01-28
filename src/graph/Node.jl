NodeId = UInt64
SourceFunction = Tuple{Function, Function}

mutable struct Node{C}
    id::NodeId
    inputs::Vector{NodeId}
    inputmap::Dict{NodeId, UInt} # source => input idx
    connections::Set{Node}
    component::C
    hasinput::Union{Function, Nothing}
    Node(op::Function) = new{FunComp{typeof(op)}}(rand(UInt64), Vector(), IdDict(), Set(), FunComp(op), nothing)
    Node(source::SourceFunction) = new{FunComp{typeof(source[1])}}(rand(UInt64), Vector(), IdDict(), Set(), FunComp(source[1]), source[2])
    Node(comp) = new{typeof(comp)}(rand(UInt64), Vector(), IdDict(), Set(), comp, nothing)
end

function hasinput(node::Node, superstep::Int64)
    node.hasinput !== nothing && node.hasinput(superstep)
end

function issource(node::Node)
    return length(node.inputs) == 0 && applicable(compute, node.component, Int64)
end

function connect(source::Node, target::Node)
    push!(source.connections, target)
    push!(target.inputs, source.id)
    target.inputmap[source.id] = length(target.inputs)
end

function isconnected(source::Node, target::Node)
    target in source.connections
end
