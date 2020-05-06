# Circo.jl
[![Build Status](https://travis-ci.com/Circo-dev/Circo.jl.svg?branch=master)](https://travis-ci.com/Circo-dev/Circo.jl)

*WARNING: Circo is in its infancy, not yet useful for real projects. The actor system will be released soon (See [CircoCore](https://github.com/Circo-dev/CircoCore), but the following description will only be true for v0.5, planned to be released in Q3 2020. Check the [GitHub Projects](https://github.com/Circo-dev/Circo.jl/projects) for the roadmap.*

Circo is a distributed computing platform, designed to scale to millions of nodes while providing metaphoric abstractions that help the programmer reason about such a complex system.

Circo achieves this by integrating an [Actor](https://en.wikipedia.org/wiki/Actor_model) model with a loosened [Bulk synchronous parallel](https://en.wikipedia.org/wiki/Bulk_synchronous_parallel) model into a component system that is driven by a distributed microkernel.

Components can send messages to each other, spawn new components and self-organize into a computing graph resembling a neural network. Components are "grounded" to a 3D space, their position is optimized to minimize approximated communication overhead.

Circo systems typically build themself from a single spawn and their structure responds dynamically to changes of the environment, e.g. they grow new components where load is high while unneeded components die. This dynamics can be described using a high level graph grammar.

Not much of that is available at the time, but you may feel the flavor if you check the following, working example:

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
```

Messages that components can send to each other are typed. The `@component` macro is a simple helper to generate the required fields and mark the component as subtype of `Component`.

```julia
function onmessage(me::TreeActor, message::GrowRequest, service)
    if length(me.children) == 0
        push!(me.children, spawn(service, TreeActor()))
        push!(me.children, spawn(service, TreeActor()))
        send(service, GrowResponse(me, body(message), me.children))
    else
        for child in me.children
            send(service, redirect(message, child)) 
        end # TODO Would be nice to allow this instead: me.children |> redirect(message) |> send(service))
    end
end
```

Leafs and inner nodes handle `GrowRequest`s differently:
- Leafs (nodes that have no children yet) grow two new leafs and report this event as a `GrowResponse` back to the address found in the body of the request.
- Inner nodes forward the message to all of their children.

```julia

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
```

The `TreeCreator` handles communication with both the user (by handling `Start` messages) and the tree (by sending a single `GrowRequest` to the root and receiving a `GrowResponse` from every node that was a leaf before this grow).

```julia
@testset "Actor-Tree" begin
    creator = TreeCreator()
    machine = Machine(creator) # Create the machine and spawn creator
    for i in 1:10
        machine(Start()) # The Start signal will be delivered to the firstly spawned component
        @test creator.nodecount == 2^(i+1)-1
    end
end
```

The `Machine` is your interface for creating and running the actor system. Its default behavior is to run synchronously until the message queue empties, so here we can grow a new level of the tree by sending a `Start` message. Check the [actor tests](https://github.com/tisztamo/Circo.jl/blob/master/test/actor/) and [benchmarks](https://github.com/tisztamo/Circo.jl/tree/master/benchmark) for more examples.
