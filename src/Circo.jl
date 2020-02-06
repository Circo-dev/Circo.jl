module Circo
import Base.|

include("components/index.jl")
include("graph/index.jl")
include("dsl/index.jl")
include("formats/index.jl")
include("bin/index.jl")
include("execution/executionindex.jl")

struct Machine
    service::SimpleComponentService
end

function Machine(network::Network)
    service = SimpleComponentService(nothing, nothing)
    set_actor_scheduler!(service, SimpleActorScheduler(network, service))
    set_wantless_scheduler!(service, SimpleScheduler(network, service))
    return Machine(service)
end

function (machine::Machine)(data;rollout = true)
    machine.service.wantless_scheduler(data;rollout = rollout)
end

export Machine,
    Node, Input, connect, isconnected, inputto, Network, |, hasinput,
    issource,
    
    tee, cat,
    
    WantlessScheduler,
    CooperativeScheduler,
    SimpleScheduler,
    DeterministicScheduler,
    
    Component,
    ComponentId, id,
    KernelComp, InfraComp, AppComp, WorkerComp,

    SimpleComponentService,
    SimpleActorScheduler,
    deliver!,
    set_actor_scheduler!,

    compute,
    WantlessComputation,
    step!,
    step_forward_output!,
    rollout!,

    AbstractMessage,
    Message,
    sender,
    target,
    body,
    onmessage,
    getstate,
    setstate!,

    connected_inputs,
    connected_outputs,
    spawn,
    send,

    FunComp
end
