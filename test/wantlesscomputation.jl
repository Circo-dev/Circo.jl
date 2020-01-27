using Test
using Circo

@testset "Circo tests" begin
    @testset "Multi-output connections" begin
      idnode = Node(x -> x)
      powxnodes = [Node(x -> x^k) for k=1:3]
      map(node -> connect(idnode, node), powxnodes)
      network = Network([idnode, powxnodes...])
      scheduler = SimpleScheduler(network)
      for i in 1:3
        scheduler(i)
        @test map(node -> node.output, scheduler.computations[2:end]) == [i^k for k=1:3]
      end
  end

   @testset "Multi-input connections" begin
      idnode = Node(x -> x)
      sourcenode1 = Node((superstep) -> 42)
      sourcenode2 = Node((superstep) -> 43)
      sourcenode3 = Node((superstep) -> 44)
      connect(sourcenode1, idnode)
      connect(sourcenode2, idnode)
      connect(sourcenode3, idnode)
      network = Network([sourcenode1, sourcenode2, sourcenode3, idnode])
      scheduler = SimpleScheduler(network)
      step!(scheduler.computations[1], scheduler, 1)
      step!(scheduler.computations[2], scheduler, 1)
      step!(scheduler.computations[3], scheduler, 1)
      step!(scheduler.computations[4], scheduler, 1)
      @test scheduler.computations[4].output == [42, 43, 44]
  end
 end