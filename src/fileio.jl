# ---------------------------------------------------------------------------- #
#                               abstract types                                 #
# ---------------------------------------------------------------------------- #
"""
    AbstractDataFormat{sym}()

Indicates a known binary or text format of kind `sym`, where `sym`
is always a symbol. For example, a .csv file might have `AbstractDataFormat{:CSV}()`.

An easy way to write `AbstractDataFormat{:WAV}` is `format"WAV"`.
"""
# struct AbstractDataFormat{sym} end
abstract type AbstractDataFormat{sym} end
formatname(::Type{AbstractDataFormat{sym}}) where sym = sym

abstract type AbstractFormatted{F<:AbstractDataFormat} end  # a specific file
formatname(::AbstractFormatted{F}) where F<:AbstractDataFormat = formatname(F)

macro format_str(s)
    :(AbstractDataFormat{$(Expr(:quote, Symbol(s)))})
end

# ---------------------------------------------------------------------------- #
#                                  wav magic                                   #
# ---------------------------------------------------------------------------- #
detectwav(io) = detect_riff(io, b"WAVE")

# Cf. https://developers.google.com/speed/webp/docs/riff_container#riff_file_format, and https://learn.microsoft.com/en-us/windows/win32/xaudio2/resource-interchange-file-format--riff-#chunks
function detect_riff(io::IO, expected_magic::AbstractVector{UInt8})
    getlength(io) >= 12 || return false
    buf = Vector{UInt8}(undef, 4)
    fourcc = read!(io, buf)
    fourcc == b"RIFF" || return false
    seek(io, 8)
    magic = read!(io, buf)
    return magic == expected_magic
end

# ---------------------------------------------------------------------------- #
#                                 audio magic                                  #
# ---------------------------------------------------------------------------- #
const ext2sym = Dict{String, Union{Symbol,Vector{Symbol}}}(
    ".wav"  => :WAV,
    ".flac" => :FLAC,
    ".ogg"  => :OGG,
    ".mp3"  => :MP3,
)

const sym2info = Dict{Symbol,Any}(
    :WAV  => detectwav,
    :FLAC => UInt8[0x66, 0x4c, 0x61, 0x43],
    :OGG  => UInt8[0x4f, 0x67, 0x67, 0x53],
    :MP3  => (UInt8[0x49, 0x44, 0x33], UInt8[0xff, 0xfb]),
)

# ---------------------------------------------------------------------------- #
#                                 File struct                                  #
# ---------------------------------------------------------------------------- #
"""
    File{fmt}(filename)

Indicates that `filename` is a file of known [`AbstractDataFormat`](@ref) `fmt`.
For example, `File{format"WAV"}(filename)` would indicate a WAV file.
"""
struct File{F<:AbstractDataFormat} <: AbstractFormatted{F}
    filename::String

    File{F}(file::AbstractString) where F<:AbstractDataFormat = new{F}(String(file)) # canonicalize to limit type-diversity
end

File{F}(file::File{F}) where F<:AbstractDataFormat = file
File{AbstractDataFormat{sym}}(@nospecialize(file::AbstractFormatted)) where sym = throw(ArgumentError("cannot change the format of $file to $sym"))

function File(file::AbstractString)

end

# ---------------------------------------------------------------------------- #
#                                File methods                                  #
# ---------------------------------------------------------------------------- #
"""
    filename(file)

Returns the filename associated with [`File`](@ref) `file`.
"""
filename(@nospecialize(f::File)) = f.filename

"""
    file_extension(file)

Returns the file extension associated with [`File`](@ref) `file`.
"""
file_extension(@nospecialize(f::File)) = splitext(filename(f))[2]


