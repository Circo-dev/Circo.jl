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

function onmessage(me::Consumer, message::Response, service)
    me.messages_left -= 1
    if me.messages_left > 0
        send(service, Request(me, me.producerId))
    end
end

function onmessage(me::Producer, message::Request, service)
    send(service, Response(me, sender(message), 42))
end

function initscheduler(rounds)
    producer = Producer()
    consumer = Consumer(id(producer), rounds)
    machine = Machine(producer)
    spawn(machine, consumer)
    scheduler = service(machine).actor_scheduler
    deliver!(scheduler, Request(consumer, id(producer)))
    return scheduler
end

SUITE["Actor"] = BenchmarkGroup()
SUITE["Actor"]["producer-consumer_1000steps"] = @benchmarkable scheduler() setup=(scheduler = initscheduler(1000))
