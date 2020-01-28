module Circo
import Base.|

include("components/index.jl")
include("graph/index.jl")
include("dsl/index.jl")
include("formats/index.jl")
include("bin/index.jl")
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
