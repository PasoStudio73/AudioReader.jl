using Test
using AudioReader

using MAT

test_files_dir()    = joinpath(dirname(@__FILE__), "test_files")
test_file(filename) = joinpath(test_files_dir(), filename)

wav_file = test_file("test.wav")
mp3_file = test_file("test.mp3")

# ---------------------------------------------------------------------------- #
#                                audio reader                                  #
# ---------------------------------------------------------------------------- #
@testset "audioreader" begin
    @test_nowarn AudioReader.File{format"WAV"}(wav_file)
    @test_nowarn AudioReader.File{format"MP3"}(mp3_file)

    @test_nowarn AudioReader.load(wav_file)
    @test_nowarn AudioReader.load(mp3_file)

    audiofile = AudioReader.load(wav_file; format=Float64)
    @test AudioReader.get_data(audiofile) isa Array{Float64}
    @test AudioReader.get_sr(audiofile) == 16000
    @test AudioReader.get_origin_sr(audiofile) == 16000
    @test AudioReader.get_nchannels(audiofile) == 1
    @test AudioReader.is_norm(audiofile) == false

    audiofile = AudioReader.load(mp3_file; norm=true)
    @test AudioReader.get_data(audiofile) isa Array{Float32}
    @test AudioReader.get_sr(audiofile) == 44100
    @test AudioReader.get_origin_sr(audiofile) == 44100
    @test AudioReader.get_nchannels(audiofile) == 1
    @test AudioReader.is_norm(audiofile) == true

    audiofile = AudioReader.load(mp3_file; mono=false)
    @test AudioReader.get_data(audiofile) isa Array{Float32}
    @test AudioReader.get_sr(audiofile) == 44100
    @test AudioReader.get_origin_sr(audiofile) == 44100
    @test AudioReader.get_nchannels(audiofile) == 2
    @test AudioReader.is_norm(audiofile) == false

    audiofile = AudioReader.load(wav_file; sr=48000)
    @test AudioReader.get_data(audiofile) isa Array{Float32}
    @test AudioReader.get_sr(audiofile) == 48000
    @test AudioReader.get_origin_sr(audiofile) == 16000
    @test AudioReader.get_nchannels(audiofile) == 1
    @test AudioReader.is_norm(audiofile) == false

    audiofile = AudioReader.load(mp3_file; mono=false, sr=8000)  
    @test AudioReader.get_nchannels(audiofile) == 2 
    @test eltype(audiofile) == Float32
    @test length(audiofile) == 44513
end

# ---------------------------------------------------------------------------- #
#                            test against matlab                               #
# ---------------------------------------------------------------------------- #
matlab_files_dir()    = joinpath(dirname(@__FILE__), "matlab_files")
matlab_file(filename) = joinpath(matlab_files_dir(), filename)

    matfile_wav = matlab_file("matlab_audioread_wav.mat")
    matfile_mp3 = matlab_file("matlab_audioread_mp3.mat")

mat_wav = MAT.matread(matfile_wav)
wav_data_matlab = mat_wav["audio_wav"]

mat_mp3 = MAT.matread(matfile_mp3)
mp3_data_matlab = mat_mp3["audio_mp3"]

    a911_wav = AudioReader.load(wav_file)
    wav_data_a911 = AudioReader.data(a911_wav)

    a911_mp3 = AudioReader.load(mp3_file)
    mp3_data_a911 = AudioReader.data(a911_mp3)