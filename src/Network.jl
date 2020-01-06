import Base.>

mutable struct Network
     nodes::Array{Node}
     globalstep::Int64
     Network(nodes) = new(nodes, 1)
end

function addnode!(network::Network, node::Node)
    push!(network.nodes, node)
end

function addfirstnode!(network::Network, node::Node)
    pushfirst!(network.nodes, node)
end

(|)(a::Function, b::Function) = begin
    anode, bnode = Node(a), Node(b)
    connect(anode, bnode)
    Network([anode, bnode])
end

(|)(source::SourceFunction, b::Function) = begin
    anode, bnode = Node(source), Node(b)
    connect(anode, bnode)
    Network([anode, bnode])
end

(|)(source::SourceFunction, n::Network) = begin
    sourcenode = Node(source)
    isempty(n.nodes) || connect(sourcenode, n.nodes[1])
    addfirstnode!(n, sourcenode)
    n
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

(|)(n1::Network, n2::Network) = begin
    isempty(n1.nodes) || isempty(n2.nodes) || connect(n1.nodes[end], n2.nodes[1])
    for node in n2.nodes
        addnode!(n1, node)
    end
    n1
end

(>)(n::Network, path::String) = begin
   n | input -> begin
            if input != nothing
                open(path, "a") do file
                   println(file, "$input")
                end
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

function inputto(network::Network, data)
    inputto(network.nodes[1], data, network.globalstep)
end

function (network::Network)(data)
    inputto(network, data)
    step!(network)
    network.nodes[end].output
end

function (network::Network)()
    while hasinput(network.nodes[1], network.globalstep)
        step!(network)
    end
    network.nodes[end].output
end
