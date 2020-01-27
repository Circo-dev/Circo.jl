using Circo

struct NoneScheduler <: AbstractScheduler
end

function iteratedsteps!(computation, scheduler, itercount=1000)
    for stepnum in 1:itercount
        step!(computation, scheduler, stepnum)
    end
end

SUITE["WantlessComputation"] = BenchmarkGroup()
SUITE["WantlessComputation"]["computationonly_1000steps_id"] = @benchmarkable iteratedsteps!(params...) setup=(params=(WantlessComputation(Node(x -> x)), NoneScheduler(), 1000))
SUITE["WantlessComputation"]["computationonly_1000steps_2x"] = @benchmarkable iteratedsteps!(params...) setup=(params=(WantlessComputation(Node(x -> 2x)), NoneScheduler(), 1000))
