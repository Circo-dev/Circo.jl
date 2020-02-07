using DataStructures

abstract type ActorScheduler end
abstract type AbstractActor end

id(a::AbstractActor) = id(a.component)

struct Actor{C <: Component} <: AbstractActor
    component::C
    Actor(node::Node) = new{typeof(node.component)}(node.component)
    Actor(component::Component) = new{typeof(component)}(component)
end

mutable struct SimpleActorScheduler <: ActorScheduler
    service::ComponentService
    actors::Array{Actor}
    actorcache::Dict{ComponentId,Actor}
    messagequeue::Queue{AbstractMessage}
    function SimpleActorScheduler(actors, service::ComponentService)
        return new(service, actors, Dict([(id(a), a) for a in actors]), Queue{AbstractMessage}())
    end
end

SimpleActorScheduler(components::AbstractArray{Component}, service::ComponentService) = begin
    actors = [Actor(component) for component in components]
    return SimpleActorScheduler(actors, service)
end

SimpleActorScheduler(network::Network, service::ComponentService) = begin
    actors = [Actor(node) for node in network.nodes]
    return SimpleActorScheduler(actors, service)
end

function deliver!(scheduler::SimpleActorScheduler, message::AbstractMessage)
    enqueue!(scheduler.messagequeue, message)
end

function schedule!(scheduler::SimpleActorScheduler, component::Component)::ComponentId
    actor = Actor(component)
    scheduler.actorcache[id(actor)] = actor
    push!(scheduler.actors, actor)
    return id(actor)
end

function step!(scheduler::SimpleActorScheduler)
    message = dequeue!(scheduler.messagequeue)
    t = target(message)
    c = scheduler.actorcache[t].component
    onmessage(scheduler.service, scheduler.actorcache[target(message)].component, message)
end

function (scheduler::SimpleActorScheduler)(message::AbstractMessage)
    deliver!(scheduler, message)
    scheduler()
end

function (scheduler::SimpleActorScheduler)()
    while !isempty(scheduler.messagequeue)
        step!(scheduler)
    end
end
