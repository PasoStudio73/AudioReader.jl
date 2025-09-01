# ---------------------------------------------------------------------------- #
#                                  match utils                                 #
# ---------------------------------------------------------------------------- #
function magic_equal(magic, buffer)
    length(magic) > length(buffer) && return false
    for (i,elem) in enumerate(magic)
        buffer[i] != elem && return false
    end
    true
end

function getlength(io, pos=position(io))
    seekend(io)
    len = position(io)
    seek(io, pos)
    return len
end

function match(io, magic::Vector{UInt8})
    len = getlength(io)
    len < length(magic) && return false
    return magic_equal(magic, read(io, length(magic)))
end

function match(io, magics::Tuple{Vector{UInt8}, Vector{UInt8}})::Bool
    lengths = map(length, magics)
    len = getlength(io)
    tmp = read(io, min(len, maximum(lengths)))
    for m in magics # start with the longest since they are most specific
        if magic_equal(m, tmp)
            return true
        end
    end
    return false
end

function match(io, @nospecialize(magic::Function))
    seekstart(io)
    try
        magic(io)
    catch e
        @error("""There was an error in magic function $magic.""", exception=(e, catch_backtrace()))
        false
    end
end

# ---------------------------------------------------------------------------- #
#                              load audiofiles                                 #
# ---------------------------------------------------------------------------- #
function filecheck(file::AbstractString)
    _, ext = splitext(file)
    if haskey(ext2sym, ext)
        sym = ext2sym[ext]
        magic = sym2info[sym]

        return open(file) do io
            match(io, magic) ? sym :
            error("File '$file' has extension '$ext' but does not appear to be a valid" * 
            " $(uppercase(string(sym))) file.")
        end
    else
        supported = join(sort(collect(keys(ext2sym))), ", ")
        error("Unsupported file format '$ext'. Supported formats: $supported")
    end
end

# ---------------------------------------------------------------------------- #
#                                load helpers                                  #
# ---------------------------------------------------------------------------- #
const loseless_format = Union{format"WAV", format"FLAC", format"OGG"}
# convert a `load` call into a `loadstreaming` call that properly
# cleans up the stream
function load_helper(src::File{<:loseless_format}, args...)
    # str = loadstreaming(src, args...)

    sfinfo = SF_Info()
    fname = filename(src)

    # sf_open fills in sfinfo
    filePtr = sf_open(fname, SFM_READ, sfinfo)
    str = SndFileSource(fname, filePtr, sfinfo)

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

# function loadstream(path::File{format"MP3"}; blocksize = -1)
#     mpg123 = mpg123_new()
#     mpg123_open(mpg123, path.filename)
#     nframes = mpg123_length(mpg123)
#     samplerate, nchannels, encoding = mpg123_getformat(mpg123)
#     if blocksize < 0
#         blocksize = mpg123_outblock(mpg123)
#     end
#     datatype = encoding_to_type(encoding)
#     encsize = sizeof(datatype)

#     info = MP3INFO(nframes, nchannels, samplerate, datatype)
#     bufsize = div(blocksize, encsize * nchannels)
#     MP3FileSource(filename(path), mpg123, info, bufsize)
# end

# @inline function Base.read(source::MP3FileSource)
#     read(source, nframes(source) - source.pos)
# end

@inline function Base.close(source::MP3FileSource)
    mpg123_close(source.mpg123)
    mpg123_delete(source.mpg123)
end

# ---------------------------------------------------------------------------- #
#                             user function load                               #
# ---------------------------------------------------------------------------- #
function load(filename::AbstractString)
    sym = filecheck(filename)
    file = File{AbstractDataFormat{sym}}(filename)
    load_helper(file)
end