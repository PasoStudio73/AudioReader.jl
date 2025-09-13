module AudioReader
# A Julia package for reading and preprocessing audio files with support for both lossless 
# and lossy audio formats.

# Provides a unified interface for loading various audio file formats into Julia,
# handling format detection, sample rate conversion, and channel management automatically.

# This package builds upon several key Julia packages:

# - **FileIO.jl**: Provides the file format detection and unified I/O interface
#   - Gunther, S., et al. (2016). FileIO.jl. https://github.com/JuliaIO/FileIO.jl
  
# - **libsndfile_jll.jl**: Julia bindings for libsndfile C library (lossless audio formats)
#   - Erikd, E. (2021). libsndfile. http://libsndfile.github.io/libsndfile/
#   - JLL wrapper: https://github.com/JuliaBinaryWrappers/libsndfile_jll.jl
  
# - **mpg123_jll.jl**: Julia bindings for mpg123 C library (MP3 and other lossy formats)
#   - Taschner, M., et al. mpg123. https://www.mpg123.de/
#   - JLL wrapper: https://github.com/JuliaBinaryWrappers/mpg123_jll.jl

# - **DSP.jl**: Digital signal processing for resampling operations
#   - JuliaDSP contributors. DSP.jl. https://github.com/JuliaDSP/DSP.jl

# ## Features

# - **Multi-format Support**: Reads both lossless (WAV, FLAC) and lossy (MP3) audio formats
# - **Automatic Format Detection**: Intelligently detects file format from extension and content
# - **Sample Rate Handling**: Built-in resampling capabilities using DSP.jl
# - **Channel Management**: Handles mono, stereo, and multi-channel audio files

# ## Basic Usage

# ```julia
# using AudioReader

# # Load an audio file
# audio = load("path/to/audio.wav")
# audio = load("path/to/audio.wav"; sr=8000, mono=true, norm=false)

# # Access audio properties
# sample_rate  = sr(audio)         # Get sample rate
# num_channels = nchannels(audio)  # Get number of channels
# audio_data   = data(audio)       # Get raw audio data

# # File format detection
# file = File("audio.mp3")
# format = formatname(file)        # Returns "MP3"
# ```

# ## Supported Formats

# - **Lossless**: WAV, FLAC
# - **Lossy**: MP3, OGG

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
export data, sr, nchannels, origin_sn, is_norm
include("audiofile.jl")

end
