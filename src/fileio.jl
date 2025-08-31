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
