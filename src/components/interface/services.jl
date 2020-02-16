function ismounted(service::ComponentService, component::Component)::Bool end

"""
    connected_inputs(service::ComponentService, component::Component)

Returns an iterator over the ComponentId-s of 'upstream' Components
"""
function connected_inputs(service::ComponentService, component::Component) end

"""
    connected_outputs(service::ComponentService, component::Component)

Returns an iterator over the ComponentId-s of 'downstream' Components
"""
function connected_outputs(service::ComponentService, component::Component)::Vector{ComponentId} end

function spawn(service::ComponentService, component::Component)::ComponentId end

function send(service::ComponentService, message::AbstractMessage) end