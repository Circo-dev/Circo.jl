ComponentId = UInt64
abstract type Component end
abstract type ComponentService end

id(component::Component) = component.id

# Lifecycle interface
function mounted(service::ComponentService, component::Component) end

function ejected(service::ComponentService, component::Component) end

function input_connected(service::ComponentService, component::Component, source::ComponentId) end

function input_disconnected(service::ComponentService, component::Component, source::ComponentId) end

function output_connected(service::ComponentService, component::Component, target::ComponentId) end

function output_disconnected(service::ComponentService, component::Component, target::ComponentId) end

# Actor interface
abstract type AbstractMessage end

struct Message{BodyType} <: AbstractMessage
    senderid::ComponentId
    targetid::ComponentId
    body::BodyType
end
Message{T}(sender::Component, targetid:: ComponentId, body::T) where {T} = Message{T}(id(sender), targetid, body)
Message(sender::Component, targetid:: ComponentId, body::T) where {T} = Message{T}(id(sender), targetid, body)
Message{Nothing}(senderid, targetid) = Message{Nothing}(senderid, targetid, nothing)
Message{Nothing}(targetid) = Message{Nothing}(0, targetid)
Message{Nothing}() = Message{Nothing}(0, 0)

sender(m::AbstractMessage) = m.senderid::ComponentId
target(m::AbstractMessage) = m.targetid::ComponentId
body(m::AbstractMessage) = m.body 
redirect(m::AbstractMessage, to::ComponentId) = (typeof(m))(target(m), to, body(m))

function onmessage(service, component, message) end

function getstate(component::Component) end

function setstate!(component::Component, state) end
