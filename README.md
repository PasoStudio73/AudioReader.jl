# AudioReader - A simple audio files reader

[![Build Status](https://github.com/PasoStudio73/AudioReader.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/PasoStudio73/AudioReader.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/PasoStudio73/AudioReader.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/PasoStudio73/AudioReader.jl)

**AudioReader.jl**
A Julia package for reading and preprocessing audio files with support for both lossless 
and lossy audio formats.

Provides a unified interface for loading various audio file formats into Julia,
handling format detection, sample rate conversion, and channel management automatically.

This package builds upon several key Julia packages:

- **FileIO.jl**: Provides the file format detection and unified I/O interface
  - Gunther, S., et al. (2016). FileIO.jl. https://github.com/JuliaIO/FileIO.jl
  
- **libsndfile_jll.jl**: Julia bindings for libsndfile C library (lossless audio formats)
  - Erikd, E. (2021). libsndfile. http://libsndfile.github.io/libsndfile/
  - JLL wrapper: https://github.com/JuliaBinaryWrappers/libsndfile_jll.jl
  
- **mpg123_jll.jl**: Julia bindings for mpg123 C library (MP3 and other lossy formats)
  - Taschner, M., et al. mpg123. https://www.mpg123.de/
  - JLL wrapper: https://github.com/JuliaBinaryWrappers/mpg123_jll.jl

- **DSP.jl**: Digital signal processing for resampling operations
  - JuliaDSP contributors. DSP.jl. https://github.com/JuliaDSP/DSP.jl

## Features

- **Multi-format Support**: Reads both lossless (WAV, FLAC) and lossy (MP3) audio formats
- **Automatic Format Detection**: Intelligently detects file format from extension and content
- **Sample Rate Handling**: Built-in resampling capabilities using DSP.jl
- **Channel Management**: Handles mono, stereo, and multi-channel audio files

## Installation

```julia
using Pkg
Pkg.add("https://github.com/PasoStudio73/AudioReader.jl")
```

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
audio = load("example.mp3"; sr=8000)
```
