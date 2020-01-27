module Circo
import Base.|

include("Input.jl")
include("Node.jl")
include("Network.jl")

include("dsl/index.jl")
include("formats/DataFrame.jl")
include("bin/index.jl")
include("components/index.jl")
include("execution/index.jl")

export Node, Input, connect, isconnected, inputto, step!, Network, |, hasinput,
    issource,
    
    tee, cat,
    
    AbstractScheduler,
    SimpleScheduler,
    
    Component, 
    KernelComp, InfraComp, AppComp, WorkerComp,
    compute,
    WantlessComputation,

    ManagementMessage,
    message_received,
    getstate,
    setstate,

    connected_inputs,
    connected_outputs,

    FunComp
end
