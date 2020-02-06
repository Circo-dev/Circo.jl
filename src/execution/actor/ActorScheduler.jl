using DataStructures

abstract type ActorScheduler end

struct Actor{C<:Component}
    node::Node{C} #TODO rename both the field and the type
    Actor(node::Node) = new{typeof(node.component)}(node)
end

mutable struct SimpleActorScheduler <: ActorScheduler
    service::ComponentService
    actors::Array{Actor}
    actorcache::Dict{ComponentId,Actor}
    messagequeue::Queue{Actor}
    function SimpleActorScheduler(service, actors) 
        return new(service, actors, Dict([(id(a.node), a) for a in actors]))
    end
end

SimpleActorScheduler(network::Network, componentservice::ComponentService) = begin
    actors = [Actor(node) for node in network.nodes]
    return SimpleActorScheduler(componentservice, actors)
end
  