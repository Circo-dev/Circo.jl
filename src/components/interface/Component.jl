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
sender(m::AbstractMessage) = m.senderid::ComponentId
target(m::AbstractMessage) = m.targetid::ComponentId
body(m::AbstractMessage) = m.body 
forward(m::AbstractMessage, target::ComponentId) = (typeof(m))(sender(m), target, body(m))

struct NothingMessage <: AbstractMessage # As of julia 1.3 and my understanding, Message{Nothing} does not allow creating the outer constructor NothingMessage(senderid, targetid)
    senderid::ComponentId
    targetid::ComponentId
    NothingMessage(senderid, targetid, droppedbody) = new(senderid, targetid)
    NothingMessage(senderid, targetid) = new(senderid, targetid)
    NothingMessage(targetid) = new(0, targetid)
    NothingMessage() = new(0, 0)
end
body(m::NothingMessage) = nothing

function onmessage(service, component, message) end

function getstate(component::Component) end

function setstate!(component::Component, state) end
