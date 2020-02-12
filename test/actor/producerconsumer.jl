using Test
using Circo
import Circo.onmessage

Request = Message{Nothing}
Response = Message{Int64}

@component mutable struct Consumer
    producerId::ComponentId
    messages_left::Int64
    sum::Int64
    Consumer(producerId, message_count) = new(producerId, message_count, 0)
end

struct Producer <: Component
    id::ComponentId
    Producer() = new(rand(UInt64))
end

function onmessage(me::Consumer, message::Response, service)
    me.messages_left -= 1
    me.sum += body(message)
    if me.messages_left > 0
        send(service, Request(me, me.producerId, nothing))
    end
end

function onmessage(me::Producer, message::Request, service::ComponentService)
    send(service, Response(me, sender(message), 42))
end

@testset "Actor" begin
    @testset "Producer-Consumer" begin
        producer = Producer()
        consumer = Consumer(id(producer), 3)
        firstrequest = Request(consumer, id(producer))
        machine = Machine(producer)
        spawn(machine, consumer)
        machine(firstrequest)
        @test consumer.messages_left == 0
        @test consumer.sum == 3 * 42
    end
end
