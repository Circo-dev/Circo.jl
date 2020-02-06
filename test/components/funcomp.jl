using Test
using Circo

@testset "FunComp" begin
    id = FunComp(identity)
    @test compute(id, 15) == 15
    twoxer = FunComp(x->2x)
    @test compute(twoxer, 15) == 30
end
