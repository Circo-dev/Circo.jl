ComponentId = UInt64
abstract type Component end

# Lifecycle interface
function mounted(component::Component)
end

function ejected(component::Component)
end

function input_connected(component::Component, source::ComponentId)
end

function input_disconnected(component::Component, source::ComponentId)
end

function output_connected(component::Component, target::ComponentId)
end

function output_disconnected(component::Component, target::ComponentId)
end

# Management interface
struct ManagementMessage{BodyType}
  sender::ComponentId
  type::String
  body::BodyType
end

function message_received(component::Component, message::ManagementMessage)::Union{ManagementMessage, Nothing}
  sender = message.sender
  body = message.body
  return nothing
end

function getstate(component::Component)
end

function setstate(component::Component, state)
end