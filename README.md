# AudioReader - A simple audio files reader

[![Build Status](https://github.com/PasoStudio73/AudioReader.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/PasoStudio73/AudioReader.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/PasoStudio73/AudioReader.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/PasoStudio73/AudioReader.jl)

**AudioReader.jl** lets you read audiofiles, wav, flac, ogg and also mp3 format.
It also include simple audio transformations, like DSP.jl's resample, normalization and mono downsample.
This package is a simplified and adapted version of some well written packages:
[FileIO.jl](https://github.com/JuliaIO/FileIO.jl)
[LibSndFile](https://github.com/JuliaAudio/LibSndFile.jl)
[WAV.jl](https://github.com/dancasimiro/WAV.jl)
[MP3.jl](https://github.com/JuliaAudio/MP3.jl)

---

## Installation

```julia
using Pkg
Pkg.add("https://github.com/PasoStudio73/AudioReader.jl")
```

---

## Quick Start

```julia
using Audioreader

# Load wav audiofile
audio = load("example.wav")

# Load wav file and convert it to mono
audio = load("example.wav"; mono=true)

# and normalize it
audio = load("example.wav"; mono=true, norm=true)

# Load an mp3 file and resample it to 8000kHz
audio = load("example.mp3"; sn=8000)
```

---


