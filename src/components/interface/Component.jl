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

function onmessage(service, component, message) 
    println(422)
end

function getstate(component::Component) end

function setstate!(component::Component, state) end