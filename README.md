# Circo.jl
[![Build Status](https://travis-ci.com/tisztamo/Circo.jl.svg?branch=master)](https://travis-ci.com/tisztamo/Circo.jl)

*WARNING: Circo is in its infancy, the following description will be true for v0.1, planned to be released in Q2 2020.*

Circo is a distributed computing platform, designed to scale to millions of nodes while providing metaphoric abstractions that help the programmer reason about such a complex system.

Circo achives this by integrating an [Actor](https://en.wikipedia.org/wiki/Actor_model) model with a loosened [Bulk synchronous parallel](https://en.wikipedia.org/wiki/Bulk_synchronous_parallel) model into a component system.

Components can send messages to each other, spawn new components and self-organize into a computing graph resembling a neural network. Components are "grounded" to a 3D space, their position is optimized to minimize approximated communication overhead.

Circo systems typically build themself from a single spawn and their structure responds dynamically to changes of the environment, e.g. they grow new components where load is high, while unneeded components die. This dynamics can be described using a biology-inspired graph grammar (not yet fully designed) or by hand as in the following (already working) example:

```julia
# This test builds a binary tree of actors, growing a new level for every
# Start() message received by the original spawn (the TreeCreator).
# The growth of every leaf is reported back by its parent to the
# TreeCreator, which counts the nodes in the tree.

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

function onmessage(me::TreeActor, message::GrowRequest, service)
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

function onmessage(me::TreeCreator, ::Start, service)
    if me.root == 0
        me.root = spawn(service, TreeActor())
        me.nodecount = 1
    end
    send(service, GrowRequest(me, me.root, id(me)))
end

function onmessage(me::TreeCreator, message::GrowResponse, service)
    me.nodecount += length(body(message))
end

@testset "Actor" begin
    @testset "Actor-Tree" begin
        creator = TreeCreator()
        machine = Machine(creator)
        for i in 1:10
            machine(Start()) # The Start signal will be delivered to creator, the firstly spawned component
            @test creator.nodecount == 2^(i+1)-1
        end
    end
end
```

