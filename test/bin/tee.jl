using Test
using Circo

@testset "tee" begin
    filename = "2x.test.csv"
    rm(filename;force=true)
    workflow = (x -> 2x) | tee(filename) | (y -> y^2)
    @test workflow([1]) == [4]
    s = open(filename) do file
        @test read(file, String) == "2\n"
    end
    rm(filename;force=true)
end
