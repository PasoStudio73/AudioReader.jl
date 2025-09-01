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
export @format_str, formatname
export File, filename, data, file_extension

# ---------------------------------------------------------------------------- #
#                                   types                                      #
# ---------------------------------------------------------------------------- #
include("types/loseless.jl")
include("types/lossy.jl")

# ---------------------------------------------------------------------------- #
#                              sampledsignals                                  #
# ---------------------------------------------------------------------------- #
include("sampledsignals.jl")

# ---------------------------------------------------------------------------- #
#                                   jlls                                       #
# ---------------------------------------------------------------------------- #
include("jlls/loseless.jl")
include("jlls/lossy.jl")

# ---------------------------------------------------------------------------- #
#                                   main                                       #
# ---------------------------------------------------------------------------- #
using DSP: resample
using StatsBase: mean

include("readers.jl")
include("load.jl")
include("audiofile.jl")
export load

end
