using Test
using Circo

@testset "tee" begin
    s = mktemp() do path, file
        workflow = (x -> 2x) | tee(path) | (y -> y^2)
        @test workflow([1]) == [4]
        @test workflow([5]) == [100]
        @test read(file, String) == "2\n10\n"
    end
end
