# ---------------------------------------------------------------------------- #
#                                    types                                     #
# ---------------------------------------------------------------------------- #
const DEFAULT_BLOCKSIZE=4096

# ---------------------------------------------------------------------------- #
#                                    read!                                     #
# ---------------------------------------------------------------------------- #
function Base.read!(source::AbstractSampleSource, buf::SampleBuf, n::Integer)
    if nchannels(source) == nchannels(buf) &&
            eltype(source) == eltype(buf) &&
            isapprox(samplerate(source), samplerate(buf))
        unsafe_read!(source, buf.data, 0, n)
    else
        # some conversion is necessary. Wrap in a sink so we can use the
        # stream conversion machinery
        write(SampleBufSink(buf), source, n)
    end
end

# if no frame count is given default to the number of frames in the destination
Base.read!(source::AbstractSampleSource, arr::AbstractArray) = read!(source, arr, nframes(arr))

function unsafe_read!(source::SndFileSource, buf::Array, frameoffset, framecount)
    total = min(framecount, nframes(source) - source.pos + 1)
    nread = 0
    readbuf = source.readbuf
    while nread < total
        n = min(size(readbuf, 2), total - nread)
        # transpose! needs the ranges to all use Ints, which on 32-bit systems
        # is an Int32, but sf_writef returns Int64 on both platforms, so we
        # convert to a platform-native Int. This also avoids a
        # type-inferrability problem where `nw` would otherwise change type.
        nr::Int = sf_readf(source.filePtr, readbuf, n)
        # the data comes in interleaved, so we need to transpose
        transpose!(view(buf, (1:nr) .+ frameoffset .+ nread, :),
                   view(readbuf, :, 1:nr))
        source.pos += nr
        nread += nr
        nr == n || break
    end

    nread
end

function unsafe_read!(source::MP3FileSource, buf::Array, frameoffset, framecount)
    total = min(framecount, nframes(source) - source.pos)
    nread = 0

    mpg123 = source.mpg123
    encsize = sizeof(source.info.datatype)
    readbuf = source.readbuf
    nchans = nchannels(source)

    while nread < total
        n = min(size(readbuf, 2), total - nread)
        nr = mpg123_read!(mpg123, readbuf, n * encsize * nchans)
        nr = div(nr, encsize * nchans)

        transpose!(view(buf, (1:nr) .+ (nread+frameoffset), :), view(readbuf, :, 1:nr))

        source.pos += nr
        nread += nr
        nr == n || break
    end

    nread
end

# ---------------------------------------------------------------------------- #
#                                    read                                      #
# ---------------------------------------------------------------------------- #
function Base.read(source::AbstractSampleSource)
    buf = SampleBuf(eltype(source),
                    samplerate(source),
                    DEFAULT_BLOCKSIZE,
                    nchannels(source))
    # during accumulation we keep the channels separate so we can grow the
    # arrays without needing to copy data around as much
    cumbufs = [Vector{eltype(source)}() for _ in 1:nchannels(source)]
    while true
        n = read!(source, buf)
        for ch in 1:length(cumbufs)
            append!(cumbufs[ch], @view buf.data[1:n, ch])
        end
        n == nframes(buf) || break
    end
    SampleBuf(hcat(cumbufs...), samplerate(source))
end

# ---------------------------------------------------------------------------- #
#                                   close                                      #
# ---------------------------------------------------------------------------- #
function Base.close(s::SndFileSource)
    if s.filePtr != C_NULL
        sf_close(s.filePtr)
        s.filePtr = C_NULL
    else
        @warn "close called more than once on $s"
    end
end






# ---------------------------------------------------------------------------- #
#                                  readers                                     #
# ---------------------------------------------------------------------------- #
const loseless_format = Union{format"WAV", format"FLAC", format"OGG"}
# convert a `load` call into a `loadstreaming` call that properly
# cleans up the stream
function load_helper(src::File{<:loseless_format}, args...)
    @show "PASO SNDLIB QUI 3"
    # str = loadstreaming(src, args...)

    @show "PASO SNDLIB QUI 1"
    sfinfo = SF_Info()
    @show "PROVA"
    @show sfinfo
    fname = filename(src)
    @show fname
    # sf_open fills in sfinfo
    filePtr = sf_open(fname, SFM_READ, sfinfo)
    @show filePtr
    
    str = SndFileSource(fname, filePtr, sfinfo)

    @show "PASONE"
    @show str isa AbstractSampleSource

    buf = try
        read(str)
    finally
        close(str)
    end

    buf
end

"""
loads an MP3 file as SampledSignals.SampleBuf.

# Arguments
* `file::File{format"MP3"}`: the MP3 file to open
* `blocksize::Int`: the size of block to read from the disk at one time.
                   defaults to the outblock size of the MP3 file.
"""
# function load_helper(path::File{format"MP3"}; blocksize = -1)
function load_helper(path::File{format"MP3"})
    mpg123 = mpg123_new()
    mpg123_open(mpg123, path.filename)
    nframes = mpg123_length(mpg123)
    samplerate, nchannels, encoding = mpg123_getformat(mpg123)
    # if blocksize < 0
        blocksize = mpg123_outblock(mpg123)
    # end
    datatype = encoding_to_type(encoding)
    encsize = sizeof(datatype)

    info = MP3INFO(nframes, nchannels, samplerate, datatype)
    bufsize = div(blocksize, encsize * nchannels)
    source = MP3FileSource(filename(path), mpg123, info, bufsize)

    # loadstream(file; blocksize = blocksize)
    buffer = try
        read(source)
    finally
        close(source)
    end
    buffer
end

# @inline loadstream(path::AbstractString, args...; kwargs...) =
#     loadstream(query(path), args...; kwargs...)

# function loadstream(f::Function, args...; kwargs...)
#     str = loadstream(args...; kwargs...)
#     try
#         f(str)
#     finally
#         close(str)
#     end
# end

function loadstream(path::File{format"MP3"}; blocksize = -1)
    mpg123 = mpg123_new()
    mpg123_open(mpg123, path.filename)
    nframes = mpg123_length(mpg123)
    samplerate, nchannels, encoding = mpg123_getformat(mpg123)
    if blocksize < 0
        blocksize = mpg123_outblock(mpg123)
    end
    datatype = encoding_to_type(encoding)
    encsize = sizeof(datatype)

    info = MP3INFO(nframes, nchannels, samplerate, datatype)
    bufsize = div(blocksize, encsize * nchannels)
    MP3FileSource(filename(path), mpg123, info, bufsize)
end

# @inline function Base.read(source::MP3FileSource)
#     read(source, nframes(source) - source.pos)
# end

@inline function Base.close(source::MP3FileSource)
    mpg123_close(source.mpg123)
    mpg123_delete(source.mpg123)
end
