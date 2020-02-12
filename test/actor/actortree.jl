using Test
using Circo
import Circo.onmessage

GrowRequest = Message{ComponentId}
GrowResponse = Message{Vector{ComponentId}}
Start = Message{Nothing}

@component mutable struct TreeActor
    children::Vector{ComponentId}
    TreeActor() = new([])
end

function onmessage(message::GrowRequest, me::TreeActor, service)
    if length(me.children) == 0
        push!(me.children, spawn(service, TreeActor()))
        push!(me.children, spawn(service, TreeActor()))
        send(service, GrowResponse(me, body(message), me.children))
    else
        for child in me.children
            send(service, redirect(message, child))
        end
    end
end

@component mutable struct TreeCreator
    nodecount::UInt64
    root::ComponentId
    TreeCreator() = new(0, 0)
end

function onmessage(::Start, me::TreeCreator, service)
    if me.root == 0
        me.root = spawn(service, TreeActor())
        me.nodecount = 1
    end
    send(service, GrowRequest(me, me.root, id(me)))
end

function onmessage(message::GrowResponse, me::TreeCreator, service)
    me.nodecount += length(body(message))
end

@testset "Actor" begin
    @testset "Actor-Tree" begin
        creator = TreeCreator()
        machine = Machine(creator)
        for i in 1:10
            machine(Start())
            @test creator.nodecount == 2^(i+1)-1
        end
    end
end
