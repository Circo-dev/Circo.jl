module Circo
import Base.|

include("components/index.jl")
include("graph/index.jl")
include("dsl/index.jl")
include("formats/index.jl")
include("bin/index.jl")
include("execution/executionindex.jl")

abstract type AbstractMachine end

mutable struct Machine <: AbstractMachine
    service::SimpleComponentService
    firstcomponent::ComponentId
    Machine(service) = new(service, 0)
end

function Machine(network::Network)
    service = SimpleComponentService(nothing, nothing)
    set_actor_scheduler!(service, SimpleActorScheduler(network, service))
    set_wantless_scheduler!(service, SimpleScheduler(network, service))
    return Machine(service)
end

Machine() = Machine(Network([]))
function Machine(firstcomponent::Component) 
    machine = Machine()
    spawn(machine, firstcomponent)
    return machine
end

service(machine::AbstractMachine) = machine.service
spawn(machine::AbstractMachine, component::Component)::ComponentId = begin
    if machine.firstcomponent == 0
        machine.firstcomponent = id(component)
    end
    spawn(service(machine), component)
end

function (machine::AbstractMachine)(data;rollout = true)
    service(machine).wantless_scheduler(data;rollout = rollout)
end

function (machine::AbstractMachine)(message::AbstractMessage)
    if target(message) == 0
        message = redirect(message, machine.firstcomponent)
    end
    service(machine).actor_scheduler(message)
end

export Machine, service,
    Node, Input, connect, isconnected, inputto, Network, |, hasinput,
    issource,

    tee, cat,

    WantlessScheduler,
    CooperativeScheduler,
    SimpleScheduler,
    DeterministicScheduler,

    Component,
    ComponentId, id,
    @component,
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
    redirect,
    onmessage,
    getstate,
    setstate!,

    connected_inputs,
    connected_outputs,
    spawn,
    send,

    FunComp
end
