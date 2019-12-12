import Base.>

mutable struct Network
     nodes::Array{Node}
     globalstep::Int64
     Network(nodes::Array{Node}) = new(nodes, 0)
end

function addnode!(network::Network, node::Node)
    push!(network.nodes, node)
end

(|)(a::Function, b::Function) = begin
    anode, bnode = Node(a), Node(b)
    connect(anode, bnode)
    Network([anode, bnode])
end

(|)(anode::Node, b::Function) = begin
    bnode = Node(b)
    connect(anode,bnode)
    Network([anode, bnode])
end

(|)(n::Network, f::Function) = begin
    fnode = Node(f)
    isempty(n.nodes) || connect(n.nodes[end], fnode)
    addnode!(n, fnode)
    n
end

(>)(n::Network, path::String) = begin
   n | input -> begin
            open(path, "a") do file
               println(file, "$input")
            end
            input
        end
end

function step!(network::Network)
    for node in network.nodes
        step!(node, network.globalstep)
    end
    network.globalstep += 1
end

function inputto(network::Network, data::InputData)
    inputto(network.nodes[1], data, network.globalstep)
end

function (network::Network)(data::InputData)
    inputto(network, data)
    step!(network)
    network.nodes[end].output
end
