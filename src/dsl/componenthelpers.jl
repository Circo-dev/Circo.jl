using MacroTools

function addfields(ex)
    MacroTools.postwalk(ex) do x
        @capture(x, mutable struct T_ fields__ end) || return x
        return quote
            mutable struct $T <: Component
                id::ComponentId
                $(fields...)
            end
        end
    end
end

function extendnews(ex)
    return MacroTools.prewalk(x -> @capture(x, new(xs__)) ? :(new(rand(ComponentId), $(xs...))) : x, ex)
end

macro component(ex)
    return addfields(ex) |> extendnews
end