using Test
using Circo

@testset "cat" begin
    sourcepath = tempname()
    mktemp() do resultpath, resultfile
        open(sourcepath, "w") do sourcefile
            println(sourcefile, "10\n200\n5\n")
        end
        workflow = SimpleScheduler(cat(sourcepath) | (x -> 2x) > resultpath)
        for i in 1:3
            step!(workflow)
        end
        @test read(resultfile, String) == "20\n400\n10\n"
        rm(sourcepath; force=true)
    end
end
