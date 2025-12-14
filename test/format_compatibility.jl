using Test
using AudioReader

using PyCall

const req_py_pkgs = ["librosa"]
pypkgs = getindex.(PyCall.Conda.parseconda(`list`, PyCall.Conda.ROOTENV), "name")
needinstall = !all(p -> in(p, pypkgs), req_py_pkgs)

if (needinstall)
    PyCall.Conda.add_channel("conda-forge")
    PyCall.Conda.add("librosa")
end

librosa = pyimport("librosa")

load_audio(file, sr) = librosa.load(file, sr=sr)

test_files_dir()    = joinpath(dirname(@__FILE__), "test_files")
test_file(filename) = joinpath(test_files_dir(), filename)

wav_file   = test_file("test.wav")
wav44_file = test_file("test44100.wav")
mp3_file   = test_file("test.mp3")
ogg_file   = test_file("test.ogg")
flac_file  = test_file("test.flac")

libw16, _ = load_audio(wav_file, 16000)
libw44, _ = load_audio(wav44_file, 44100)
libm16, _ = load_audio(mp3_file, 44100)
libo16, _ = load_audio(ogg_file, 44100)
libf16, _ = load_audio(flac_file, 44100)

w16 = AudioReader.load(wav_file)
w44 = AudioReader.load(wav44_file)
m16 = AudioReader.load(mp3_file; mono=true)
o16 = AudioReader.load(ogg_file; mono=true)
f16 = AudioReader.load(flac_file; mono=true)

@test isapprox(libw16, get_data(w16))
@test isapprox(libw44, get_data(w44))
@test isapprox(libm16, get_data(m16))
@test isapprox(libo16, get_data(o16))
@test isapprox(libf16, get_data(f16))

# resample
@test_nowarn AudioReader.load(wav_file; sr=8000)
