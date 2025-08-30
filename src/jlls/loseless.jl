

function virtual_read(dest, count, userdata)::sf_count_t
    io = unsafe_pointer_to_objref(userdata)
    read = readbytes!(io, unsafe_wrap(Array, Ptr{UInt8}(dest), count))

    read
end

struct SF_VIRTUAL_IO
    read::Ptr{Cvoid}
end

# make a struct of function pointers where the userdata argument is a pointer of
# the specified type
function SF_VIRTUAL_IO(::Type{T}) where T<:IO
    SF_VIRTUAL_IO(
        @cfunction(virtual_read,        sf_count_t, (Ptr{Cvoid}, sf_count_t, Ptr{T})),
    )
end

function sf_open(fname::String, mode, sfinfo)
    filePtr = ccall((:sf_open, libsndfile), Ptr{Cvoid},
                    (Cstring, Int32, Ref{SF_Info}),
                    fname, mode, sfinfo)

    if filePtr == C_NULL
        error("LibSndFile.jl error while opening $fname: ", sf_strerror(C_NULL))
    end

    filePtr
end

# internals to get the virtual IO interface working
# include("virtualio.jl")

function sf_open(io::T, mode, sfinfo) where T <: IO
    virtio = SF_VIRTUAL_IO(T)
    filePtr = ccall((:sf_open_virtual, libsndfile), Ptr{Cvoid},
                    (Ref{SF_VIRTUAL_IO}, Int32, Ref{SF_Info}, Ptr{T}),
                    virtio, mode, sfinfo, pointer_from_objref(io))
    if filePtr == C_NULL
        error("LibSndFile.jl error while opening stream: ", sf_strerror(C_NULL))
    end

    filePtr
end

function sf_close(filePtr)
    err = ccall((:sf_close, libsndfile), Int32, (Ptr{Cvoid},), filePtr)
    if err != 0
        error("LibSndFile.jl error: Failed to close file: ", sf_strerror(filePtr))
    end
end

"""
Wrappers for the family of sf_readf_* functions, which read the given number
of frames into the given array. Returns the number of frames read.
"""
function sf_readf end

sf_readf(filePtr, dest::Array{T}, nframes) where T <: Union{Int16, PCM16Sample} =
    ccall((:sf_readf_short, libsndfile), Int64,
        (Ptr{Cvoid}, Ptr{T}, Int64),
        filePtr, dest, nframes)

sf_readf(filePtr, dest::Array{T}, nframes) where T <: Union{Int32, PCM32Sample} =
    ccall((:sf_readf_int, libsndfile), Int64,
        (Ptr{Cvoid}, Ptr{T}, Int64),
        filePtr, dest, nframes)

sf_readf(filePtr, dest::Array{Float32}, nframes) =
    ccall((:sf_readf_float, libsndfile), Int64,
        (Ptr{Cvoid}, Ptr{Float32}, Int64),
        filePtr, dest, nframes)

sf_readf(filePtr, dest::Array{Float64}, nframes) =
    ccall((:sf_readf_double, libsndfile), Int64,
        (Ptr{Cvoid}, Ptr{Float64}, Int64),
        filePtr, dest, nframes)