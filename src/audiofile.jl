abstract type AbstractAudioFile end

# ---------------------------------------------------------------------------- #
#                                   types                                      #
# ---------------------------------------------------------------------------- #
const AudioFormat{T} = Union{Vector{T}, Array{T}} where T

# ---------------------------------------------------------------------------- #
#                                 audio utils                                  #
# ---------------------------------------------------------------------------- #
@inline convert2float32(file::SampleBuf)::Array{Float32} = Float32.(file.data)
@inline convert2mono(data::Array{<:Real})::Vector{<:Real} = vec(mean(data, dims=2))
@inline normalize(data::Array{<:Real})::Array{<:Real} = data ./ maximum(abs.(data))

function convert_sr(file::Array{<:Real}, sr::Int64, new_sr::Int64)::Array{<:Real}
    ratio = Rational(new_sr, sr)
    eltype(file).(resample(file, ratio))
end

# ---------------------------------------------------------------------------- #
#                              AudioFile struct                                #
# ---------------------------------------------------------------------------- #
"""
    AudioFile{T} <: AbstractAudioFile

Wrapper for processed audio data with metadata and type safety.

This struct represents audio data that has been loaded and potentially processed
(resampled, normalized, converted to mono).

# Type Parameters
- `T`: Element type of the audio data (typically `Float32` or `Float64`)

# Fields
- `data::AudioFormat{T}`: Stored audio data as Vector (mono) or Matrix (multi-channel)
- `sr::Int64`: Current sample rate in Hz after any resampling
- `origin_sr::Int64`: Original sample rate in Hz from the source file
- `norm::Bool`: Whether the audio data has been normalized

See also: [`load`](@ref)
"""
struct AudioFile{T} <: AbstractAudioFile
    data      :: AudioFormat
    sr        :: Int64
    origin_sr :: Int64
    norm      :: Bool

    function AudioFile(
        audiodata :: AudioFormat{T},
        sr        :: Int64,
        origin_sr :: Int64,
        norm      :: Bool
    ) where T
        new{T}(audiodata, sr, origin_sr, norm)
    end
end

# ---------------------------------------------------------------------------- #
#                           AudioFile constructor                              #
# ---------------------------------------------------------------------------- #
function AudioFile(
    @nospecialize(file::SampleBuf);
    sr   :: Union{Nothing, Int64}=nothing,
    norm :: Bool=false,
    mono :: Bool=true,
)::AudioFile
    audiodata = eltype(file) == Float32 ? data(file) : convert2float32(file)
    mono && (audiodata = convert2mono(audiodata))

    origin_sr = samplerate(file)

    if isnothing(sr)
        sr = origin_sr
    else
        audiodata = convert_sr(audiodata, samplerate(file), sr)
    end

    norm && (audiodata = normalize(audiodata))

    AudioFile(audiodata, sr, origin_sr, norm)
end

#------------------------------------------------------------------------------#
#                                    methods                                   #
#------------------------------------------------------------------------------#
Base.eltype(::AudioFile{T}) where T = T
Base.length(f::AudioFile) = size(f.data,1)

"""
    data(file)

Returns the audio data associated with [`File`](@ref) `file`.
"""
@inline data(f::AudioFile) = f.data

"""
    samplerate(file)

Returns the sample rate associated with [`File`](@ref) `file`.
"""
@inline samplerate(f::AudioFile) = f.sr

"""
    nchannels(file::AudioFile) -> Int

Return the number of audio channels in an AudioFile.
"""
@inline nchannels(f::AudioFile) = size(f.data, 2)

"""
    origin_sr(file::AudioFile) -> Int

Return the original sample rate of the audio file before any resampling.
Return the same value of sr() if any reasmplig was applied.
"""
@inline origin_sr(f::AudioFile) = f.origin_sr

"""
    is_norm(file::AudioFile) -> Bool

Check whether the audio file data has been normalized.
"""
@inline is_norm(f::AudioFile) = f.norm
