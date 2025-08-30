module AudioReader

using FixedPointNumbers: Fixed
using LinearAlgebra: transpose!
using Unitful: Quantity

# ---------------------------------------------------------------------------- #
#                              audio libraries                                 #
# ---------------------------------------------------------------------------- #
using libsndfile_jll: libsndfile
using mpg123_jll: libmpg123

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
