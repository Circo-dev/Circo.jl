import Base.>
import Base.show

struct Network
     nodes::Array{Node}
     diameter::Union{Int64, Nothing}
     Network(nodes, diameter=nothing) = new(nodes, diameter)
end

function diameter(network::Network)::Int64
    return isnothing(network.diameter) ? length(network.nodes) : network.diameter
end

function withdiameter(network::Network, diameter::Int64)::Network
    return Network(network.nodes, diameter)
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

