
struct FunComp{F} <: Component
    id::ComponentId
    op::F
    FunComp(f::Function) = new{typeof(f)}(rand(UInt64), f)
end

function compute(component::FunComp, inputs)
    isnothing(inputs) && return nothing
    component.op(inputs)
end