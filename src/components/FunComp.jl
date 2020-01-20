struct FunComp{F} <: Component
  op::F
end

function compute(component::FunComp, inputs)
  component.op(inputs)
end