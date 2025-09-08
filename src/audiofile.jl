abstract type AbstractAudioFile end

# ---------------------------------------------------------------------------- #
#                                   types                                      #
# ---------------------------------------------------------------------------- #
const AudioFormat{T} = Union{Vector{T}, Matrix{T}} where T

# ---------------------------------------------------------------------------- #
#                                 audio utils                                  #
# ---------------------------------------------------------------------------- #
convert2float32(file::SampleBuf)::Array{Float32} = Float32.(file.data)
convert2mono(data::Array{Float32})::Vector{Float32} = vec(mean(data, dims=2))
normalize(data::Array{Float32})::Array{Float32} = data ./ maximum(abs.(data))

function convert_sr(file::Array{Float32}, sr::Integer, new_sr::Int64)::Array{Float32}
    ratio = Rational(new_sr, sr)
    resample(file, ratio)
end

# ---------------------------------------------------------------------------- #
#                              AudioFile struct                                #
# ---------------------------------------------------------------------------- #
struct AudioFile{T} <: AbstractAudioFile
    data :: AudioFormat
    sr   :: Int64

    function AudioFile(audiodata::AudioFormat{T}, sr::Int64) where T
        new{T}(audiodata, sr)
    end
end

# ---------------------------------------------------------------------------- #
#                             AudioFile methods                                #
# ---------------------------------------------------------------------------- #
function AudioFile(
    @nospecialize(file::SampleBuf);
    sr      :: Union{Nothing, Int64}=nothing,
    norm    :: Bool=false,
    mono    :: Bool=true,
)
    audiodata = eltype(file) == Float32 ? data(file) : convert2float32(file)
    mono && (audiodata = convert2mono(audiodata))

    if isnothing(sr)
        sr = samplerate(file)
    else
        audiodata = convert_sr(audiodata, samplerate(file), sr)
    end

    norm && (audiodata = normalize(audiodata))

    AudioFile(audiodata, sr)
end

Base.eltype(::AudioFile{T}) where T = T
Base.length(f::AudioFile) = size(f.data,1)

"""
    data(file)

Returns the audio data associated with [`File`](@ref) `file`.
"""
data(f::AudioFile) = f.data

"""
    sr(file)

Returns the sample rate associated with [`File`](@ref) `file`.
"""
sr(f::AudioFile) = f.sr

"""
    ismono(file)

Returns true [`File`](@ref) `file` is mono format.
"""
ismono(f::AudioFile) = f.data isa Vector
