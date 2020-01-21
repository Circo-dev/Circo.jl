import Base.>
import Base.show

struct Network
     nodes::Array{Node}
     Network(nodes) = new(nodes)
end

function Base.show(io::IO, n::Network)
    l = length(n.nodes)
    print("Circo.Network with $l nodes.")
end

function addnode!(network::Network, node::Node)
    push!(network.nodes, node)
end

function addfirstnode!(network::Network, node::Node)
    pushfirst!(network.nodes, node)
end