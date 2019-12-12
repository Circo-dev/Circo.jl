using Serialization

function tee(filename::String)
    return (input) -> begin
        open(filename, "a") do file
            println(file, "$input")
        end
        input
    end
end
