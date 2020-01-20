import Base.>
import Base.show

abstract type AbstractScheduler end

struct Network{Scheduler<:AbstractScheduler}
     nodes::Array{Node}
     scheduler::Scheduler
     Network(nodes,scheduler::AbstractScheduler) = new{typeof(scheduler)}(nodes, scheduler)
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

function inputto(network::Network, data)
    inputto(network.nodes[1], data, network.scheduler.globalstep)
end

function (network::Network)(data)
    inputto(network, data)
    step!(network.scheduler, network)
    network.nodes[end].output
end

function (network::Network)()
    while hasinput(network.nodes[1], network.scheduler.globalstep)
        step!(network.scheduler, network)
    end
    network.nodes[end].output
end

function step!(network::Network)
    step!(network.scheduler, network)
end