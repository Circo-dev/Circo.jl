module Circo
import Base.|

include("Input.jl")
include("Node.jl")
include("Network.jl")

include("formats/DataFrame.jl")
include("bin/index.jl")

export Input, Node, connect, isconnected, inputto, step!, Network, |, hasinput,
    tee, cat

end
