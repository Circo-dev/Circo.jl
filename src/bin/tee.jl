using Serialization

function tee(filename::String)
    return (input) -> begin
        s = open("2x.test.csv", "a") do file
            println(file, "$input")
        end
        input
    end
end
