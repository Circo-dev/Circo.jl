using Test
using Circo

@testset "tee" begin
    s = mktemp() do path, file
        workflow = SimpleScheduler((x -> 2x) | tee(path) | (y -> y^2))
        inputto(workflow, 1)
        step!(workflow)
        inputto(workflow, 5)
        step!(workflow)
        inputto(workflow, nothing)
        step!(workflow)
        @test workflow.computations[end].output == 4
        step!(workflow)
        @test workflow.computations[end].output == 100
        @test read(file, String) == "2\n10\n"
    end
end
