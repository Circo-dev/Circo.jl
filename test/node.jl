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
        idnode = Node(x -> x)
        sqrnode = Node(x -> x.^2)
        @test typeof(idnode) == Node
        @test sqrnode.op!(42) == 42^2
        @test sqrnode.op!([42]) == [42^2]
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

    @testset "Multi-connections" begin
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
end
