import MLStyle
import MacroTools

function addfields(ex)
    MacroTools.postwalk(ex) do x
        MacroTools.@capture(x, mutable struct T_ fields__ end) || return x
        return quote
            mutable struct $T <: Component
                id::ComponentId
                $(fields...)
            end
        end
    end
end

function extendnews(ex)
    return MacroTools.prewalk(x -> MacroTools.@capture(x, new(xs__)) ? :(new(rand(ComponentId), $(xs...))) : x, ex)
end

macro component(ex)
    return addfields(ex) |> extendnews
end

macro message(typeex, descriptor...)
    (MLStyle.Modules.AST.@matchast typeex quote
        struct $typename
            $(fields...)
        end =>
        begin
            bodytype = Symbol(string(typename) * "Body")
            quote
                struct $(bodytype)
                    $(fields...)
                end
                $(typename) = Message{$bodytype}
            end
        end
        $typename{$param} => :($typename = Message{$param})
        $typename => :($typename = Message{Nothing})
        _ => nothing
    end) |> esc
end