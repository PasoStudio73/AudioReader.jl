```@meta
CurrentModule = AudioReader
```

# Reference

## Contents

```@contents
Pages = ["reference.md"]
```

## Index

```@index
Pages = ["reference.md"]
```

```@docs
load(filename::AbstractString)

AudioFile

get_data(audiofile::AudioFile)
get_sr(audiofile::AudioFile)
get_origin_sr(audiofile::AudioFile)
get_nchannels(audiofile::AudioFile)
is_norm(audiofile::AudioFile)

File

filename(file::File)
file_extension(file::File)

@format_str
```