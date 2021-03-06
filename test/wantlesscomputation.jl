using Test
using Circo

@testset "Circo tests" begin
    @testset "Multi-output connections (SimpleScheduler, DeterministicScheduler)" begin
      idnode = Node(x -> x)
      powxnodes = [Node(x -> x^k) for k=1:3]
      map(node -> connect(idnode, node), powxnodes)
      network = Network([idnode, powxnodes...])
      simplescheduler = SimpleScheduler(network)
      deterministicscheduler = DeterministicScheduler(network)
      for i in 1:3
        function test(scheduler)
          @test map(node -> node.output, scheduler.computations[2:end]) == [i^k for k=1:3]
        end
        simplescheduler(i)
        deterministicscheduler(i)
        test(simplescheduler)
        test(deterministicscheduler)
      end
  end

  @testset "Multi-input connections" begin
      idnode = Node(x -> x)
      sourcenode1 = Node((step -> 42, step -> true))
      sourcenode2 = Node((step -> 43, step -> true))
      sourcenode3 = Node((step -> 44, step -> true))
      connect(sourcenode1, idnode)
      connect(sourcenode2, idnode)
      connect(sourcenode3, idnode)
      network = Network([sourcenode1, sourcenode2, sourcenode3, idnode])
      scheduler = SimpleScheduler(network)
      step_forward_output!(scheduler.computations[1], scheduler, 1)
      step_forward_output!(scheduler.computations[2], scheduler, 1)
      step_forward_output!(scheduler.computations[3], scheduler, 1)
      step_forward_output!(scheduler.computations[4], scheduler, 1)
      @test scheduler.computations[4].output == [42, 43, 44]
  end
 end