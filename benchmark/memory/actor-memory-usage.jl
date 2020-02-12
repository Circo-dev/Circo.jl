# This simple script measures the memory consumption of actor instances by creating 1e6 of them
# and calling varinfo()

using Circo
import Circo.onmessage

machine = Machine()

varinfo()

actorids=Array{ComponentId}(undef, 0)

mutable struct SimpleActor <: Component
    id::ComponentId
    SimpleActor() = new(rand(ComponentId))
end

function onmessage(message::Message{String}, me::SimpleActor, service)
    println("Actor #$(id(me)) got message $(body(message))")
end

for i in 1:1000000
    a = SimpleActor()
    push!(actorids, id(a))
    spawn(machine, a)
end

varinfo()

for i=1:10
    machine(Message{String}(0, actorids[i], "Hello"))
end