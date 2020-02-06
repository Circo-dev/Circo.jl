struct FunComp{F} <: Component
    op::F
end

function compute(component::FunComp, inputs)
    isnothing(inputs) && return nothing
    component.op(inputs)
end