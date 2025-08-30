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
