# ---------------------------------------------------------------------------- #
#                               abstract types                                 #
# ---------------------------------------------------------------------------- #
abstract type AbstractAudioFile end

# ---------------------------------------------------------------------------- #
#                                   types                                      #
# ---------------------------------------------------------------------------- #
const AudioFormat{T} = Union{Vector{T}, Array{T}}

# ---------------------------------------------------------------------------- #
#                                 audio utils                                  #
# ---------------------------------------------------------------------------- #
@inline _convert_format(file::SampleBuf, T::Type) = T.(file.data)
@inline _convert_mono(data::AudioFormat{T}) where {T<:Real} =
    mean(data, dims=2)
@inline _normalize(data::AudioFormat{T}) where {T<:Real} =
    data ./ maximum(abs.(data))

function _convert_sr(file::AudioFormat{T}, sr::Int, new_sr::Int) where {T<:Real}
    ratio = Rational(new_sr, sr)
    eltype(file).(resample(file, ratio, dims=1))
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
- `data::AudioFormat{T}`: Stored audio data as Vector (mono) or Matrix
  (multi-channel)
- `sr::Int`: Current sample rate in Hz after any resampling
- `origin_sr::Int`: Original sample rate in Hz from the source file
- `norm::Bool`: Whether the audio data has been normalized

# Constructor
    AudioFile(
        file::SampleBuf;
        sr=nothing,
        norm=false,
        mono=true,
        format=Float32
    )

- `file`: Source audio buffer.
- `sr`: Target sample rate (optional; if not given, uses original).
- `norm`: If true, normalizes audio data.
- `mono`: If true, converts audio to mono.
- `format`: Output data type (default: `Float32`).

The constructor loads and processes audio data, applying type conversion,
mono conversion, resampling, and normalization as requested.

See also: [`load`](@ref)
"""
struct AudioFile{T} <: AbstractAudioFile
    data::AudioFormat
    sr::Int
    origin_sr::Int
    norm::Bool

    function AudioFile(
        @nospecialize(file::SampleBuf);
        sr::Union{Nothing,Int}=nothing,
        norm::Bool=false,
        mono::Bool=true,
        format::Type=Float32
    )::AudioFile
        audiodata = eltype(file) == format ? 
            data(file) :
            _convert_format(file, format)
        mono && (audiodata = _convert_mono(audiodata))

        origin_sr = samplerate(file)
        isnothing(sr) || sr==origin_sr ? 
            (sr = origin_sr) :
            (audiodata = _convert_sr(audiodata, samplerate(file), sr))

        norm && (audiodata = _normalize(audiodata))

        new{eltype(audiodata)}(audiodata, sr, origin_sr, norm)
    end
end

#------------------------------------------------------------------------------#
#                                    methods                                   #
#------------------------------------------------------------------------------#
Base.eltype(::AudioFile{T}) where T = T
Base.length(f::AudioFile) = size(f.data,1)

"""
    get_data(file::AudioFile) -> Array

Returns the audio data associated with [`AudioFile`](@ref) `file`.
"""
@inline get_data(f::AudioFile)::Array = f.data

"""
    get_sr(file::AudioFile) -> Int

Returns the sample rate associated with [`AudioFile`](@ref) `file`.
"""
@inline get_sr(f::AudioFile)::Int = f.sr

"""
    origin_sr(file::AudioFile) -> Int

Return the original sample rate of the [`AudioFile`](@ref) `file`
before any resampling.
Return the same value of sr() if any reasmplig was applied.
"""
@inline get_origin_sr(f::AudioFile)::Int = f.origin_sr

"""
    get_nchannels(file::AudioFile) -> Int

Return the number of audio channels in an [`AudioFile`](@ref) `file`.
"""
@inline get_nchannels(f::AudioFile)::Int = size(f.data, 2)

"""
    is_norm(file::AudioFile) -> Bool

Check whether the [`AudioFile`](@ref) `file` data has been normalized.
"""
@inline is_norm(f::AudioFile)::Bool = f.norm
