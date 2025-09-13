# ---------------------------------------------------------------------------- #
#                               abstract types                                 #
# ---------------------------------------------------------------------------- #
abstract type AbstractDataFormat{sym} end
formatname(::Type{AbstractDataFormat{sym}}) where sym = sym

abstract type AbstractFormatted{F<:AbstractDataFormat} end  # a specific file
formatname(::AbstractFormatted{F}) where F<:AbstractDataFormat = formatname(F)

"""
    @format_str(s)

Create an AbstractDataFormat type for the given format string.

This macro provides a convenient string literal syntax for creating format types
used in file I/O operations. It converts a string into the corresponding
`AbstractDataFormat{Symbol}` type at compile time.

# Arguments
- `s`: Format string ("WAV", "MP3", "FLAC", "OGG")

# Returns
- `AbstractDataFormat{Symbol}`: Type representing the specified format

# Examples
```julia
# Create format types using string literals
wav_format  = format"WAV"     # AbstractDataFormat{:WAV}
mp3_format  = format"MP3"     # AbstractDataFormat{:MP3}
flac_format = format"FLAC"   # AbstractDataFormat{:FLAC}

# Use in File construction
file = File{format"WAV"}("audio.wav")
```

See also: [`File`](@ref), [`File`](@ref), [`formatname`](@ref)
"""
macro format_str(s)
    :(AbstractDataFormat{$(Expr(:quote, Symbol(s)))})
end

# ---------------------------------------------------------------------------- #
#                                  wav magic                                   #
# ---------------------------------------------------------------------------- #
detectwav(io) = detect_riff(io, b"WAVE")

# Cf. https://developers.google.com/speed/webp/docs/riff_container#riff_file_format, 
# and https://learn.microsoft.com/en-us/windows/win32/xaudio2/resource-interchange-file-format--riff-#chunks
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
    File{F<:AbstractDataFormat} <: AbstractFormatted{F}

Type-safe representation of an audio file with format information.

This struct provides a type-parameterized container for audio files that encodes
the file format in the type system. This enables compile-time format dispatch
and ensures type safety when working with different audio formats.

# Type Parameters
- `F<:AbstractDataFormat`: The audio format type (e.g., `AbstractDataFormat{:WAV}`)

# Fields
- `filename::String`: The canonical file path as a string

# Arguments
- `file`: File path as string or existing File object

# Examples
```julia
# Explicit format specification
wav_file  = File{format"WAV"}("audio.wav")
mp3_file  = File{format"MP3"}("music.mp3")
flac_file = File{format"FLAC"}("high_quality.flac")

# Get file properties
filename(wav_file)       # Returns "path_to_audio.wav"
file_extension(wav_file) # Returns ".wav"
formatname(wav_file)     # Returns :WAV

# Type information is preserved
typeof(wav_file)         # File{AbstractDataFormat{:WAV}}
```

See also: [`@format_str`](@ref)
"""
struct File{F<:AbstractDataFormat} <: AbstractFormatted{F}
    filename::String

    File{F}(file::AbstractString) where F<:AbstractDataFormat = 
        new{F}(String(file)) # canonicalize to limit type-diversity
end

File{F}(file::File{F}) where F<:AbstractDataFormat = file
File{AbstractDataFormat{sym}}(@nospecialize(file::AbstractFormatted)) where sym = 
    throw(ArgumentError("cannot change the format of $file to $sym"))

# ---------------------------------------------------------------------------- #
#                                File methods                                  #
# ---------------------------------------------------------------------------- #
"""
    filename(file)

Returns the filename associated with [`File`](@ref) `file`.
"""
filename(@nospecialize(f::File)) = f.filename

"""
    data(file)

Returns the audio data associated with [`File`](@ref) `file`.
"""
data(@nospecialize(f::File)) = f.data

"""
    file_extension(file)

Returns the file extension associated with [`File`](@ref) `file`.
"""
file_extension(@nospecialize(f::File)) = splitext(filename(f))[2]

"""
    Base.eltype(file)

Returns the file extension associated with [`File`](@ref) `file`.
"""
Base.eltype(@nospecialize(f::File)) = eltype(data(f))


