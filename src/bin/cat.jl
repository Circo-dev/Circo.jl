import Base.cat

function cat(filename::String)
    f = open(filename)
    return (globalstep) -> begin
        if eof(f)
            close(f)
            return nothing
        end
        line = readline(f)
        parse(Int64, line)
    end, (globalstep) -> !eof(f)
end
