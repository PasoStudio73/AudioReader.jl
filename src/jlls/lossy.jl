struct MP3Info
    nframes    :: Int64
    nchannels  :: Int32
    samplerate :: Int64
    datatype   :: DataType
end

"""create an MP3Info object from given audio buffer"""
function MP3Info(buf::SampleBuf{T})::MP3Info where {T}
    MP3Info(nframes(buf), nchannels(buf), samplerate(buf), T)
end

mutable struct MP3FileSource{T} <: AbstractSampleSource
    path::AbstractString
    mpg123  :: MPG123
    info    :: MP3Info
    pos     :: Int64
    readbuf :: Array{T, 2}
end

function MP3FileSource(path::String, mpg123::MPG123, info::MP3Info, bufsize::Int64)::MP3FileSource
    readbuf = Array{info.datatype, 2}(undef, info.nchannels, bufsize)
    MP3FileSource(path, mpg123, info, Int64(0), readbuf)
end

@inline nchannels(source::MP3FileSource)  = Int(source.info.nchannels)
@inline samplerate(source::MP3FileSource) = source.info.samplerate
@inline nframes(source::MP3FileSource)    = source.info.nframes
@inline Base.eltype(source::MP3FileSource{T}) where {T} = T

"""return a string that explains given error code"""
function mpg123_plain_strerror(err)
    str = ccall((:mpg123_plain_strerror, libmpg123), Ptr{Cchar}, (Cint,), err)
    bytestring(str)
end

"""initialize mpg123 library"""
function mpg123_init()::Int32
    err = ccall((:mpg123_init, libmpg123), Cint, ())
    if err != MPG123_OK
        error("Could not initialize mpg123: ", mpg123_plain_strerror(err))
    end
end

"""create new mpg123 handle"""
function mpg123_new()::Ptr{Nothing}
    err = Ref{Cint}(0)
    mpg123 = ccall((:mpg123_new, libmpg123), MPG123,
                   (Ptr{Cchar}, Ref{Cint}),
                   C_NULL, err)

    if err.x != MPG123_OK
        error("Could not create mpg123 handle: ", mpg123_plain_strerror(err.x))
    end

    mpg123
end

"""open an mp3 file at fiven path"""
function mpg123_open(mpg123::MPG123, path::String)::Int32
    err = ccall((:mpg123_open, libmpg123), Cint,
                (MPG123, Ptr{Cchar}),
                mpg123, path)

    if err != MPG123_OK
        mpg123_delete(mpg123)
        error("Could not open $path: ", mpg123_plain_strerror(err))
    end

    err
end

"""close a file that is opened by given handle"""
function mpg123_close(mpg123::MPG123)::Int32
    err = ccall((:mpg123_close, libmpg123), Cint, (MPG123,), mpg123)

    if err != MPG123_OK
        warn("Could not close mpg123 $mpg123: ", mpg123_plain_strerror(err))
    end

    err
end

"""delete mpg123 handle"""
function mpg123_delete(mpg123::MPG123)::Int32
    ccall((:mpg123_delete, libmpg123), Cint, (MPG123,), mpg123)
end

"""return birtate, number of channels and encoding of the mp3 file"""
function mpg123_getformat(mpg123::MPG123)::Tuple{Int64,Int64,Int64}
    bitrate = Ref{Clong}(0)
    nchannels = Ref{Cint}(0)
    encoding = Ref{Cint}(0)
    err = ccall((:mpg123_getformat, libmpg123), Cint,
                (MPG123, Ref{Clong}, Ref{Cint}, Ref{Cint}),
                mpg123, bitrate, nchannels, encoding)

    if err != MPG123_OK
        error("Could not read format: ", mpg123_plain_strerror(err))
    end

    bitrate.x, nchannels.x, encoding.x
end

"""return the appropriate block size for handling this mpg123 handle"""
function mpg123_outblock(mpg123::MPG123)::Int32
    ccall((:mpg123_outblock, libmpg123), Csize_t, (MPG123,), mpg123)
end

"""return the number of samples in the file"""
function mpg123_length(mpg123::MPG123)::Int64
    length = ccall((:mpg123_length, libmpg123), Int64, (MPG123,), mpg123)
    if length == MPG123_ERR
        error("Could not determine the frame length")
    end
    convert(Int64, length)
end

"""return how many bytes a sample (in a channel) uses"""
function mpg123_encsize(encoding::Cint)::Int32
    ccall((:mpg123_encsize, libmpg123), Cint, (Cint,), encoding)
end

"""
read audio samples from the mpg123 handle

# Arguments
* `mpg123::MPG123`: the mpg123 handle
* `out::Array{T}`: Array with appropriate data type, to store the samples
* `size::Integer`: the amount to read, in bytes. nchannels * encsize * nsamples
"""
function mpg123_read!(mpg123::MPG123, out::Array{T}, size::Int64)::Int32 where {T}
    done = Ref{Csize_t}(0)
    err = ccall((:mpg123_read, libmpg123), Cint,
                (MPG123, Ptr{T}, Csize_t, Ref{Csize_t}),
                mpg123, out, size, done)

    if err != MPG123_OK && err != MPG123_DONE
        error("Error while reading $mpg123: ", mpg123_plain_strerror(err))
    end

    Int32(done.x)
end

##############################################################################
function initialize_readers()::MPG123
    # initialize mpg123; this needs to be done only once
    mpg123_init()
end



"""convert mpg123 encoding to julia datatype"""
function encoding_to_type(encoding::Int64)::DataType
    mapping = Dict{Int64, Type}(
       MPG123_ENC_SIGNED_16 => PCM16Sample,
       # TODO: support more
    )

    encoding in keys(mapping) || error("Unsupported encoding $encoding")
    mapping[encoding]
end