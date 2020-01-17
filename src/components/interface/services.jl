function ismounted(component::Component)::Bool
end

"""
  connected_inputs(component::Component)

Returns an iterator over the ComponentId-s of upstream Components
"""
function connected_inputs(component::Component)
end

function connected_outputs(component::Component)::Vector{ComponentId}
end
