
function ismounted(service::ComponentService, component::Component)::Bool end

"""
  connected_inputs(component::Component)

Returns an iterator over the ComponentId-s of 'upstream' Components
"""
function connected_inputs(service::ComponentService, component::Component) end

"""
  connected_outputs(component::Component)

Returns an iterator over the ComponentId-s of 'downstream' Components
"""
function connected_outputs(service::ComponentService, component::Component)::Vector{ComponentId} end

function spawn(service::ComponentService, component::Component)::ComponentId
  error("spawn() not implemented")
end

function send(service::ComponentService, message::AbstractMessage) end