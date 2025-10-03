using Test
using AudioReader

test_files_dir()    = joinpath(dirname(@__FILE__), "..", "test_files") # Remove the "../"
test_file(filename) = joinpath(test_files_dir(), filename)

wav_file = test_file("test.wav")
mp3_file = test_file("test.mp3")

load(wav_file)