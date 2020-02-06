using Test
using Circo
import Circo.onmessage

Request = Message{Nothing}
Response = Message{Int64}

mutable struct Consumer <: Component
    id::ComponentId
    producerId::ComponentId
    messages_left::Int64
    sum::Int64
    Consumer(producerId, message_count) = new(rand(ComponentId), producerId, message_count, 0)
end

struct Producer <: Component
    id::ComponentId
    Producer() = new(rand(UInt64))
end

function onmessage(service, consumer::Consumer, message)
    consumer.messages_left -= 1
    consumer.sum += body(message)
    if consumer.messages_left > 0
        send(service, Request(id(consumer), consumer.producerId, nothing))
    end
end

function onmessage(service::SimpleComponentService, component::Producer, message::Message)
    send(service, Response(id(component), sender(message), 42))
end

@testset "Actor" begin
    producer = Producer()
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
