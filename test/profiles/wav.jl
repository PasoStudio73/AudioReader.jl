using Test
using WAV

test_files_dir()    = joinpath(dirname(@__FILE__), "..", "test_files")
test_file(filename) = joinpath(test_files_dir(), filename)

wav_file = test_file("test.wav")

y, fs = wavread(wav_file)

@btime y, fs = wavread(wav_file)
