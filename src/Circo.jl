module Circo
import Base.|

include("Input.jl")
include("Node.jl")
include("Network.jl")

include("formats/DataFrame.jl")
include("bin/index.jl")
include("components/index.jl")

export Node, Input, connect, isconnected, inputto, step!, Network, |, hasinput,
    issource,
    
    tee, cat,
    
    Component, 
    KernelComp, InfraComp, AppComp, WorkerComp,
    compute,

    connected_inputs,
    connected_outputs,

    FunComp
end
