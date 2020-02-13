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
    nodecount::UInt64
    root::ComponentId
    TreeCreator() = new(rand(ComponentId), 0, 0)
end

function onmessage(service, me::TreeCreator, message::Start)
    if me.root == 0
        me.root = spawn(service, TreeActor())
        me.nodecount = 1
    end
    send(service, GrowRequest(id(me), me.root, id(me)))
end

function onmessage(service, me::TreeCreator, message::GrowResponse)
    me.nodecount += length(body(message))
end

@testset "Actor" begin
    @testset "Actor-Tree" begin
        creator = TreeCreator()
        machine = Machine(creator)
        for i in 1:10
            machine(Start())
            @test creator.nodecount == 2^(i+1) - 1
        end
    end
end
