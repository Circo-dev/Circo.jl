using BenchmarkTools
import Base.Threads.@spawn

function createnode(calcfn)
  return (input, output) -> begin
    while true
      data = take!(input)
      put!(output, calcfn(data))
    end
  end
end

function createcalc(channellength=0)
  source, inter1, target = [Channel{Int64}(channellength) for i=1:3]
  node1 = @spawn createnode(x -> 2x)(source, inter1)
  node2 = @spawn createnode(x -> x+1)(inter1, target)
  return source, target
end

function runcalc(source, target, N=1000)
  @spawn begin
    for i=1:N
      put!(source, i)
    end
    put!(source, 0)
  end
  @spawn begin
    sum = 0
    for i=1:N
      sum += take!(target)
    end
    return sum
  end
end

SUITE["Coroutine-tests"] = BenchmarkGroup()
SUITE["Coroutine-tests"]["2nodes_1000steps2x+1"] = @benchmarkable wait(runcalc(params...)) setup=(params = createcalc())
