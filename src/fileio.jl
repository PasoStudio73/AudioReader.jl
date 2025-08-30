"""
    DataFormat{sym}()

Indicates a known binary or text format of kind `sym`, where `sym`
is always a symbol. For example, a .csv file might have `DataFormat{:CSV}()`.

An easy way to write `DataFormat{:WAV}` is `format"WAV"`.
"""
struct DataFormat{sym} end

macro format_str(s)
    :(DataFormat{$(Expr(:quote, Symbol(s)))})
end

formatname(::Type{DataFormat{sym}}) where sym = sym


abstract type Formatted{F<:DataFormat} end  # A specific file or stream

formatname(::Formatted{F}) where F<:DataFormat = formatname(F)

## File:

"""
    File{fmt}(filename)

Indicates that `filename` is a file of known [`DataFormat`](@ref) `fmt`.
For example, `File{format"PNG"}(filename)` would indicate a PNG file.

!!! compat
    `File{fmt}(filename)` requires FileIO 1.6 or higher. The deprecated syntax `File(fmt, filename)` works
    on all FileIO 1.x releases.
"""
struct File{F<:DataFormat, Name} <: Formatted{F}
    filename::Name
end
File{F}(file::File{F}) where F<:DataFormat = file
File{DataFormat{sym}}(@nospecialize(file::Formatted)) where sym = throw(ArgumentError("cannot change the format of $file to $sym"))
File{F}(file::AbstractString) where F<:DataFormat = File{F,String}(String(file)) # canonicalize to limit type-diversity
File{F}(file) where F<:DataFormat = File{F,typeof(file)}(file)

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
