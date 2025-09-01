using AudioReader
using Test
using PyCall

const AR = AudioReader

function run_tests(list)
    println("\n" * ("#"^50))
    for test in list
        println("TEST: $test")
        include(test)
    end
end

test_files_dir() = joinpath(dirname(@__FILE__), "test_files")
test_file(filename) = joinpath(test_files_dir(), filename)

wav_file     = test_file("test.wav")
mp3_file     = test_file("test.mp3")
ogg_file     = test_file("test.ogg")
flac_file    = test_file("test.flac")
oga_file     = test_file("invalid/test.oga")
actually_wav = test_file("invalid/test_is_a_wav.mp3")
text         = test_file("invalid/test.txt")
fakewav      = test_file("invalid/text.wav")

println("Julia version: ", VERSION)

test_suites = [
    ("File Reader",          ["fileio.jl",               ]),
    ("Format Compatibility", ["format_compatibility.jl", ]),
]

@testset "AudioReader.jl" begin
    for ts in eachindex(test_suites)
        name = test_suites[ts][1]
        list = test_suites[ts][2]
        let
            @testset "$name" begin
                run_tests(list)
            end
        end
    end
    println()
end

