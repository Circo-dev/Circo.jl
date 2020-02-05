ComponentId = UInt64
abstract type Component end
abstract type ComponentService end

# Lifecycle interface
function mounted(service::ComponentService, component::Component) end

function ejected(service::ComponentService, component::Component) end

function input_connected(service::ComponentService, component::Component, source::ComponentId) end

function input_disconnected(service::ComponentService, component::Component, source::ComponentId) end

function output_connected(service::ComponentService, component::Component, target::ComponentId) end

function output_disconnected(service::ComponentService, component::Component, target::ComponentId) end

# Actor interface
abstract type AbstractMessage end

sender(m::AbstractMessage) = m.sender::ComponentId
body(m::AbstractMessage) = m.body

function message_received(service::ComponentService, component::Component, message::AbstractMessage)::Union{AbstractMessage, Nothing} end

function getstate(component::Component) end

function setstate!(component::Component, state) end