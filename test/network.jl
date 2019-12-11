using Test
using Circo

@testset "Network creation" begin
    network = (y -> y) | (y -> y)
    @test typeof(network) == Network
    @test length(network.nodes) == 2
    n2 = network | x -> x^2
    @test length(n2.nodes) == 3
end

@testset "Network execution" begin
    network = (y -> 2y) | (y -> y^2)
    @test typeof(network) == Network
    @test network([1]) == [4]
end
