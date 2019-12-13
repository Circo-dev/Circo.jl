using Test
using Circo

@testset "cat" begin
    sourcepath = tempname()
    mktemp() do resultpath, resultfile
        open(sourcepath, "w") do sourcefile
            println(sourcefile, "10\n200\n5\n")
        end
        workflow = (x -> 2x) | cat(sourcepath) | (x -> 2x) > resultpath
        workflow(0)
        step!(workflow)
        step!(workflow)
        @test read(resultfile, String) == "20\n400\n10\n"
        rm(sourcepath; force=true)
    end
end
