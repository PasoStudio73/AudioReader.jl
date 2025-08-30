using PyCall

const req_py_pkgs = ["librosa"]
function __init__()
    pypkgs = getindex.(PyCall.Conda.parseconda(`list`, PyCall.Conda.ROOTENV), "name")
    needinstall = !all(p -> in(p, pypkgs), req_py_pkgs)

    if (needinstall)
        PyCall.Conda.add_channel("conda-forge")
        PyCall.Conda.add("librosa")
    end

    py"""
    import librosa as librosa
    import soundfile as soundfile

    def load_audio(file, sr):
        x, sr_def = librosa.load(file, sr=sr)
        return x, sr_def
    """
end
__init__()
load_audio(file, sr) = py"load_audio"(file, sr)

# using FileIO: load
# using MP3
# using SampledSignals
# using LibSndFile
using AudioReader

file = "/home/paso/Documents/Aclai/Julia_additional_files/read_audiofile/test1.wav"
fmp3 = "/home/paso/Documents/Aclai/Julia_additional_files/read_audiofile/test2.mp3"

lib16, _ = load_audio(file, 16000)
# lib8, _  = load_audio(file, 8000)
mib16, _ = load_audio(fmp3, 44100)

# w16 = load(file)
w16 = load_helper(File{format"WAV"}(file))
# m16 = load(fmp3)
m16 = load_helper(File{format"MP3"}(fmp3))
f32 = map(Float32, m16)
# testmono = vec(mean(f32.data, dims=2))
testmono = vec(mean(f32, dims=2))


# @btime load(file)
@btime load_helper(File{format"WAV"}(file))
# LibSndFile
# 1.277 ms (1110 allocations: 480.74 KiB)

# WAV
# 1.372 ms (722 allocations: 811.11 KiB)

# AudioReader
# 949.352 μs (34504 allocations: 1.57 MiB)

@test isapprox(lib16, map(Float32, w16.data))
@test isapprox(mib16, map(Float32, testmono))
