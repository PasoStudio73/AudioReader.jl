module AudioReader
# A Julia package for reading and preprocessing audio files with support for both lossless 
# and lossy audio formats.

using FixedPointNumbers: Fixed, Q0f15, Q0f31
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
export @format_str, formatname
export File, filename, data, file_extension
include("fileio.jl")

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

export load
include("load.jl")

export AudioFile
export get_data, get_sr, get_origin_sr, get_nchannels, is_norm
include("audiofile.jl")

end
