using AudioReader
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

libw16, _ = load_audio(wav_file, 16000)
libm16, _ = load_audio(mp3_file, 44100)
libo16, _ = load_audio(ogg_file, 44100)
libf16, _ = load_audio(flac_file, 44100)

w16 = load(wav_file)
m16 = load(mp3_file)
o16 = load(ogg_file)
f16 = load(flac_file)

m32 = map(Float32, m16)
testmono = vec(mean(m32, dims=2))

o16mono = vec(mean(o16, dims=2))

f32 = map(Float32, f16)
f32mono = vec(mean(f32, dims=2))

@test isapprox(libw16, map(Float32, w16.data))
@test isapprox(libm16, map(Float32, testmono))
@test isapprox(libo16, o16mono)
@test isapprox(libf16, f32mono)

@btime load(wav_file)
# LibSndFile
# 1.277 ms (1110 allocations: 480.74 KiB)
# WAV
# 1.372 ms (722 allocations: 811.11 KiB)
# AudioReader
# 575.113 μs (34357 allocations: 1.51 MiB)

