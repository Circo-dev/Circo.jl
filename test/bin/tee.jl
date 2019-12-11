using Test
using Circo

@testset "tee" begin
    workflow = (x -> 2x) | tee("2x.test.bin") | (y -> y^2)
    @test_broken workflow([1]) == [4]
    s = open("2x.test.bin") do file
        read(file, String)
    end
end
