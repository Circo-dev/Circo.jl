scheduler(s::ComponentService) = s.scheduler

mutable struct SimpleComponentService <: ComponentService
    wantless_scheduler::Union{SimpleScheduler,Nothing}
    actor_scheduler::Union{SimpleActorScheduler,Nothing}
end

function set_wantless_scheduler!(service::SimpleComponentService, wantless_scheduler::SimpleScheduler)
    service.wantless_scheduler=wantless_scheduler
end

function set_actor_scheduler!(service::SimpleComponentService, actor_scheduler::SimpleActorScheduler)
    service.actor_scheduler=actor_scheduler
end

function send(service::SimpleComponentService, message::AbstractMessage)
    deliver!(service.actor_scheduler, message)
end
