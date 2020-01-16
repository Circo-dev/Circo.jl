struct FunComp{F} <: Component
  op::F
end

function calculate(component::FunComp, inputs)
  component.op(inputs)
end