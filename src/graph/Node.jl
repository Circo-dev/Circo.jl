SourceFunction = Tuple{Function, Function}

mutable struct Node{C<:Component}
    inputs::Vector{ComponentId}
    inputmap::Dict{ComponentId, UInt} # source => input idx
    connections::Set{Node}
    component::C
    hasinput::Union{Function, Nothing}
    Node(op::Function) = new{FunComp{typeof(op)}}(Vector(), IdDict(), Set(), FunComp(op), nothing)
    Node(source::SourceFunction) = new{FunComp{typeof(source[1])}}(Vector(), IdDict(), Set(), FunComp(source[1]), source[2])
    Node(comp) = new{typeof(comp)}(Vector(), IdDict(), Set(), comp, nothing)
end

id(node::Node) = id(node.component)

function hasinput(node::Node, step::Int64)
    node.hasinput !== nothing && node.hasinput(step)
end

function issource(node::Node)
    return length(node.inputs) == 0 && applicable(compute, node.component, Int64)
end

function connect(source::Node, target::Node)
    push!(source.connections, target)
    push!(target.inputs, id(source))
    target.inputmap[id(source)] = length(target.inputs)
end

function isconnected(source::Node, target::Node)
    target in source.connections
end
