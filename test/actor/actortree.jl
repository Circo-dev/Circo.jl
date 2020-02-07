using Test
using Circo
import Circo.onmessage

GrowRequest = Message{ComponentId}
GrowResponse = Message{Vector{ComponentId}}
Start = NothingMessage

mutable struct TreeActor <: Component
    id::ComponentId
    children::Vector{ComponentId}
    TreeActor() = new(rand(ComponentId), [])
end

function onmessage(service, me::TreeActor, message::GrowRequest)
    if length(me.children) == 0
        push!(me.children, spawn(service, TreeActor()))
        push!(me.children, spawn(service, TreeActor()))
        send(service, GrowResponse(id(me), message.body, me.children))
    else
        for child in me.children
            send(service, GrowRequest(id(me), child, message.body))
        end
    end
end

mutable struct TreeCreator <: Component
    id::ComponentId
    responsecount::UInt64
    root::ComponentId
    TreeCreator() = new(rand(ComponentId), 0, 0)
end

function onmessage(service, me::TreeCreator, message::Start)
    if me.root == 0
        me.root = spawn(service, TreeActor())
    end
    send(service, GrowRequest(id(me), me.root, id(me)))
end

function onmessage(service, me::TreeCreator, message::GrowResponse)
    me.responsecount += 1
end

@testset "Actor" begin
    @testset "Actor-Tree" begin
        service = SimpleComponentService(nothing, nothing)
        scheduler = SimpleActorScheduler([], service)
        set_actor_scheduler!(service, scheduler)
        creator = TreeCreator()
        spawn(service, creator)
        startrequest = Start(0, id(creator), nothing)
        for i in 1:10
            scheduler(startrequest)
            @test creator.responsecount == 2^i - 1
        end
    end
end
