module AudioReader

using FixedPointNumbers: Fixed
using LinearAlgebra: transpose!

# ---------------------------------------------------------------------------- #
#                                  files io                                    #
# ---------------------------------------------------------------------------- #
include("fileio.jl")

export @format_str

# ---------------------------------------------------------------------------- #
#                                   types                                      #
# ---------------------------------------------------------------------------- #
include("types/loseless.jl")
include("types/lossy.jl")

end
