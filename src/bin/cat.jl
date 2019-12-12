import Base.cat

function cat(filename::String)
    f = open(filename)
    return (input) -> begin
        if eof(f)
            close(f)
            return input
        end
        line = readline(f)
        parse(Int64, line)
    end
end
