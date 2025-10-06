using Test
using AudioReader

test_files_dir()    = joinpath(dirname(@__FILE__), "test_files")
test_file(filename) = joinpath(test_files_dir(), filename)

wav_file  = test_file("test.wav")
mp3_file  = test_file("test.mp3")
ogg_file  = test_file("test.ogg")
flac_file = test_file("test.flac")

@test_nowarn File{format"WAV"}(wav_file)
@test_nowarn File{format"MP3"}(mp3_file)

file = File{format"WAV"}(wav_file)

@test_nowarn load(wav_file)
@test_nowarn load(mp3_file)
@test_nowarn load(ogg_file)
@test_nowarn load(flac_file)

# Invalid files should throw errors
oga_file = test_file("invalid/test.oga")
actually_wav = test_file("invalid/test_is_a_wav.mp3")
text = test_file("invalid/text.txt")
fakewav = test_file("invalid/text.wav")

@test_throws ErrorException load(oga_file)     # Unsupported extension
@test_throws ErrorException load(actually_wav) # Wrong format (WAV with .mp3 extension)
@test_throws ErrorException load(text)         # Unsupported extension
@test_throws ErrorException load(fakewav)      # Wrong format (text with .wav extension)

audiofile = load(mp3_file)
@test audiofile isa AudioFile
@test nchannels(audiofile)  == 1
@test samplerate(audiofile) == 44100
@test origin_sr(audiofile)  == 44100
@test is_norm(audiofile)    == false

audiofile = load(mp3_file; mono=false, norm=true)
@test audiofile isa AudioFile
@test nchannels(audiofile)  == 2
@test samplerate(audiofile) == 44100
@test origin_sr(audiofile)  == 44100
@test is_norm(audiofile)    == true

audiofile = load(mp3_file; sr=8000)
@test audiofile isa AudioFile
@test samplerate(audiofile) == 8000
@test origin_sr(audiofile)  == 44100

audiofile = load(mp3_file; mono=true, sr=44513)
@test audiofile isa AudioFile
@test eltype(audiofile)     == Float32
@test samplerate(audiofile) == 44513

audio      = load(mp3_file; norm=false)
audio_norm = load(mp3_file; norm=true)
@test sum(abs.(data(audio_norm))) > sum(abs.(data(audio)))

# Create format types using string literals
@test format"WAV"  == AudioReader.AbstractDataFormat{:WAV}
@test format"MP3"  == AudioReader.AbstractDataFormat{:MP3}
@test format"FLAC" == AudioReader.AbstractDataFormat{:FLAC}

# Use in File construction
file = File{format"MP3"}("audio.mp3")

@test data(audio) isa Vector{Float32}
@test file_extension(file) == ".mp3"
