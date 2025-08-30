# ---------------------------------------------------------------------------- #
#                               abstract types                                 #
# ---------------------------------------------------------------------------- #
abstract type AbstractSampleSource end
abstract type AbstractSampleBuf{T, N} <: AbstractArray{T, N} end

# ---------------------------------------------------------------------------- #
#                                   types                                      #
# ---------------------------------------------------------------------------- #
const sf_count_t = Int64

# ---------------------------------------------------------------------------- #
#                               wav soundfiles                                 #
# ---------------------------------------------------------------------------- #
mutable struct SF_Info
    frames::sf_count_t
    samplerate::Int32
    channels::Int32
    format::Int32
    sections::Int32
    seekable::Int32
end

SF_Info() = SF_Info(0, 0, 0, 0, 0, 0)

# ---------------------------------------------------------------------------- #
#                                 LengthIO                                     #
# ---------------------------------------------------------------------------- #
# wrapper around an arbitrary IO stream that also includes its length, which
# libsndfile requires. Needs to be mutable so it's stored as a reference and
# we can pass a pointer into the C code
mutable struct LengthIO{T<:IO} <: IO
    io::T
    length::Int64
end

LengthIO(io, l::Integer) = LengthIO(io, Int64(l))

# ---------------------------------------------------------------------------- #
#                               SndFileSource                                  #
# ---------------------------------------------------------------------------- #
# src is either a string representing the path to the file, or an IO stream
mutable struct SndFileSource{T, S<:Union{String, LengthIO}} <: AbstractSampleSource
    src::S
    filePtr::Ptr{Cvoid}
    sfinfo::SF_Info
    pos::Int64
    readbuf::Array{T, 2}
end

function SndFileSource(src, filePtr, sfinfo, bufsize=4096)
    T = fmt_to_type(sfinfo.format)
    readbuf = zeros(T, sfinfo.channels, bufsize)

    SndFileSource(src, filePtr, sfinfo, Int64(1), readbuf)
end

# ---------------------------------------------------------------------------- #
#                                 SampleBuf                                    #
# ---------------------------------------------------------------------------- #
"""
Represents a multi-channel regularly-sampled buffer that stores its own sample
rate (in samples/second). The wrapped data is an N-dimensional array. A 1-channel
sample can be represented with a 1D array or an Mx1 matrix, and a C-channel
buffer will be an MxC matrix. So a 1-second stereo audio buffer sampled at
44100Hz with 32-bit floating-point samples in the time domain would have the
type SampleBuf{Float32, 2}.
"""
mutable struct SampleBuf{T, N} <: AbstractSampleBuf{T, N}
    data::Array{T, N}
    samplerate::Float64
end

# define constructor so conversion is applied to `sr`
SampleBuf(arr::Array{T, N}, sr::Real) where {T, N} = SampleBuf{T, N}(arr, sr)

SampleBuf(T::Type, sr, dims...) = SampleBuf(Array{T}(undef, dims...), sr)
SampleBuf(T::Type, sr, len::Quantity) = SampleBuf(T, sr, inframes(Int,len,sr))
SampleBuf(T::Type, sr, len::Quantity, ch) = SampleBuf(T, sr, inframes(Int,len,sr), ch)

samplerate(buf::AbstractSampleBuf) = buf.samplerate
nchannels(buf::AbstractSampleBuf{T, 2}) where {T} = size(buf.data, 2)
nchannels(buf::AbstractSampleBuf{T, 1}) where {T} = 1
nframes(buf::AbstractSampleBuf) = size(buf.data, 1)

Base.size(buf::AbstractSampleBuf) = size(buf.data)
Base.IndexStyle(::Type{T}) where {T <: AbstractSampleBuf} = Base.IndexLinear()
# this is the fundamental indexing operation needed for the AbstractArray interface
Base.getindex(buf::AbstractSampleBuf, i::Int) = buf.data[i];
Base.setindex!(buf::AbstractSampleBuf, val, i::Int) = buf.data[i] = val

