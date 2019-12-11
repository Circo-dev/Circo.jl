using Serialization

function tee(filename::String)
    println("Tee: writing into $filename")
    return (input) -> begin
        println("Tee: $input")
        serialize("2x.test.bin", input)
        input
    end
end
