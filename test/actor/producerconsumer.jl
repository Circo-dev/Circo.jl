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

function onmessage(message::Response, consumer::Consumer, service)
    consumer.messages_left -= 1
    consumer.sum += body(message)
    if consumer.messages_left > 0
        send(service, Request(id(consumer), consumer.producerId, nothing))
    end
end

function onmessage(message::Request, component::Producer, service::SimpleComponentService,)
    send(service, Response(id(component), sender(message), 42))
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
