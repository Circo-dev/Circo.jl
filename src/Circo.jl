module Circo
import Base.|

include("Input.jl")
include("Node.jl")
include("Network.jl")

export Input, Node, connect, isconnected, inputto, step!, Network, |

end
