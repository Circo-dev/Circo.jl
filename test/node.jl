using Test
using Circo

function sourceandinputs(targetnode)
    sourcenode = Node(() -> nothing)
    inputs = [Input(i, sourcenode, i) for i = 1:3]
    connect(sourcenode, targetnode)
    sourcenode, inputs
end

@testset "Circo tests" begin
    @testset "Node creation" begin
        idfunc = (x -> x)
        idnode = Node(idfunc)
        sqrnode = Node(x -> x.^2)
        @test typeof(idnode) == Node{FunComp{typeof(idfunc)}}
        @test compute(sqrnode.component,42) == 42^2
        @test compute(sqrnode.component, [42]) == [42^2]
        sourcenode = Node(globalstep -> 42)
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

    @testset "Sourcing using a fake node" begin
        idnode = Node(x -> x)
        sourcenode, inputs = sourceandinputs(idnode)
        sqrnode = Node(x -> x.^2)
        connect(idnode, sqrnode)
        @test_throws KeyError inputto(sourcenode, inputs[1])
        @test_throws KeyError inputto(sqrnode, inputs[1])
        @test isconnected(sourcenode, idnode)
        for i in 1:3
            inputto(idnode, inputs[i])
            step!(idnode, i)
            @test idnode.output == i
            step!(sqrnode, i)
            @test sqrnode.output == i^2
        end
    end

    @testset "Multi-output connections" begin
        idnode = Node(x -> x)
        sourcenode, inputs = sourceandinputs(idnode)
        powxnodes = [Node(x -> x^k) for k=1:3]
        map(node -> connect(idnode, node), powxnodes)
        for i in 1:3
            inputto(idnode, inputs[i])
            step!(idnode, i)
            map(node -> step!(node, i), powxnodes)
            @test map(node -> node.output, powxnodes) == [i^k for k=1:3]
        end
    end

    @testset "Multi-input connections" begin
        idnode = Node(x -> x)
        sourcenode1 = Node((globalstep) -> 42)
        sourcenode2 = Node((globalstep) -> 43)
        sourcenode3 = Node((globalstep) -> 44)
        connect(sourcenode1, idnode)
        connect(sourcenode2, idnode)
        connect(sourcenode3, idnode)
        step!(sourcenode1, 1)
        step!(sourcenode2, 1)
        step!(sourcenode3, 1)
        step!(idnode, 1)
        @test idnode.output == [42, 43, 44]
    end
end
