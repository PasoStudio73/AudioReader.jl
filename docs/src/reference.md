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

data(audiofile::AudioFile)
sr(audiofile::AudioFile)
nchannels(audiofile::AudioFile)
origin_sn(audiofile::AudioFile)
is_norm(audiofile::AudioFile)

File

filename(file::File)
data(file::File)
file_extension(file::File)

@format_str
formatname
```