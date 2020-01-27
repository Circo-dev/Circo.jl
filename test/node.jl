using Test
using Circo

@testset "Circo tests" begin
    @testset "Node creation" begin
        idfunc = (x -> x)
        idnode = Node(idfunc)
        sqrnode = Node(x -> x.^2)
        @test typeof(idnode) == Node{FunComp{typeof(idfunc)}}
        @test compute(sqrnode.component,42) == 42^2
        @test compute(sqrnode.component, [42]) == [42^2]
        sourcenode = Node(superstep -> 42)
        @test issource(sourcenode) == true
        connect(idnode, sqrnode)
        @test issource(sqrnode) == false
    end

    @testset "Connecting" begin
        idnode = Node(x -> x)
        sqrnode = Node(x -> x.^2)
        connect(idnode, sqrnode)
        @test isconnected(idnode, sqrnode)
        @test !isconnected(sqrnode, idnode)
    end

end
