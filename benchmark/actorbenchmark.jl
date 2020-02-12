using BenchmarkTools
using Circo
import Circo.onmessage

Request = Message{Nothing}
Response = Message{Int64}

mutable struct Consumer <: Component
    id::ComponentId
    producerId::ComponentId
    messages_left::Int64
    Consumer(producerId, message_count) = new(rand(ComponentId), producerId, message_count)
end

struct Producer <: Component
    id::ComponentId
    Producer() = new(rand(UInt64))
end

function onmessage(message::Response, consumer::Consumer, service::SimpleComponentService)
    consumer.messages_left -= 1
    if consumer.messages_left > 0
        send(service, Request(id(consumer), consumer.producerId, nothing))
    end
end

function onmessage(message::Request, component::Producer, service::SimpleComponentService)
    send(service, Response(id(component), sender(message), 42))
end

function initscheduler(rounds)
    producer = Producer()
    consumer = Consumer(id(producer), rounds)
    firstrequest = Request(id(consumer), id(producer), nothing)
    service = SimpleComponentService(nothing, nothing)
    scheduler = SimpleActorScheduler([producer, consumer], service)
    set_actor_scheduler!(service, scheduler)
    deliver!(scheduler, firstrequest)
    return scheduler
end

SUITE["Actor"] = BenchmarkGroup()
SUITE["Actor"]["producer-consumer_1000steps"] = @benchmarkable scheduler() setup=(scheduler = initscheduler(1000))
