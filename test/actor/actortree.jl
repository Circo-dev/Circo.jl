using Test
using Circo
import Circo.onmessage

GrowRequest = Message{ComponentId}
GrowResponse = Message{Vector{ComponentId}}

mutable struct TreeActor <: Component
    id::ComponentId
    children::Vector{ComponentId}
    TreeActor() = new(rand(ComponentId), [])
end

function onmessage(service, tree::TreeActor, message::GrowRequest)
    if length(children) == 0
        tree.children.push!(spawn(service, TreeActor()))
        tree.children.push!(spawn(service, TreeActor()))
        send(service, GrowResponse(id(tree), message.body, tree.children))
    else
        for child in tree.children
            send(service, GrowRequest(id(tree), child, message.body))
        end
    end
end

mutable struct TreeCreator <: Component
    id::ComponentId
end

function onmessage(service, tree::TreeActor, message::GrowRequest)
end

@testset "Actor" begin
    @testset "Actor-Tree" begin
        creator = Producer()
        consumer = Consumer(id(producer), 3)
        firstrequest = Request(id(consumer), id(producer), nothing)
        service = SimpleComponentService(nothing, nothing)
        scheduler = SimpleActorScheduler([producer, consumer], service)
        set_actor_scheduler!(service, scheduler)
        deliver!(scheduler, firstrequest)
        scheduler()
        @test consumer.messages_left == 0
        @test consumer.sum == 3 * 42
    end
end
