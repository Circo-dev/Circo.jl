using Test
using Circo

@testset "Network creation" begin
    network = (y -> y) | (y -> y)
    @test isa(network, Network)
    @test length(network.nodes) == 2
    n2 = network | x -> x^2
    @test length(n2.nodes) == 3
end

@testset "Network execution" begin
    network = (y -> 2y) | (y -> y^2)
    @test isa(network, Network)
    @test SimpleScheduler(network)(1) == 4
end

@testset "Network concatenation" begin
    n1 = (y -> y) | (y -> 2y)
    n2 = (y -> y) | (x -> x^2)
    n = n1 | n2
    @test length(n.nodes) == 4
    @test SimpleScheduler(n)(1) == 4
end

@testset "Network execution without input" begin
    hasinput = superstep -> superstep <= 3
    identity = x -> x
    network = (identity, hasinput) | (y -> y^2)
    @test isa(network, Network)
    @test network() == 9
end
