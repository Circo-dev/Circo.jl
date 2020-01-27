# julia -i -q --color=yes --project revise.jl example

using Revise, Jive
using Circo

trigger = function (path)
    printstyled("changed ", color=:cyan)
    println(path)
    revise()
    runtests(@__DIR__, skip=["revise.jl"])
end

watch(trigger, @__DIR__, sources=[pathof(Circo)])
trigger("")

Base.JLOptions().isinteractive==0 && wait()
