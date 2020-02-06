using DataStructures

abstract type ActorScheduler end

struct Actor{C<:Component}
    node::Node{C} #TODO rename both the field and the type
    Actor(node::Node) = new{typeof(node.component)}(node)
end

mutable struct SimpleActorScheduler <: ActorScheduler
    service
    actors::Array{Actor}
    actorcache::Dict{NodeId,Actor}
    messagequeue::Queue{Actor}
    function SimpleActorScheduler(service, actors) 
        return new(service, actors, Dict([(a.node.id, a) for a in actors]))
    end
end

SimpleActorScheduler(componentservice::ComponentService, network::Network) = begin
    actors = [Actor(node) for node in network.nodes]
    return SimpleActorScheduler(componentservice, actors)
end
  