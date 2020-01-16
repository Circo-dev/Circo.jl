using Test
using Circo

@testset "FunComp" begin
  id = FunComp(identity)
  @test calculate(id, 15) == 15
  twoxer = FunComp(x->2x)
  @test calculate(twoxer, 15) == 30
end
