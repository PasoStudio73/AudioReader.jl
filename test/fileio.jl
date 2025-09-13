using AudioReader

@test_nowarn File{format"WAV"}(wav_file)
@test_nowarn File{format"MP3"}(mp3_file)

file = File{format"WAV"}(wav_file)

@test_nowarn load(wav_file)
@test_nowarn load(mp3_file)
@test_nowarn load(ogg_file)
@test_nowarn load(flac_file)

# Invalid files should throw errors
@test_throws ErrorException load(oga_file)     # Unsupported extension
@test_throws ErrorException load(actually_wav) # Wrong format (WAV with .mp3 extension)
@test_throws ErrorException load(text)         # Unsupported extension
@test_throws ErrorException load(fakewav)      # Wrong format (text with .wav extension)

audiofile = load(mp3_file)
@test audiofile isa AudioFile
@test nchannels(audiofile) == 1
@test sr(audiofile) == 44100
@test origin_sr(audiofile) == 44100
@test is_norm(audiofile) == false

audiofile = load(mp3_file; mono=false, norm=true)
@test audiofile isa AudioFile
@test nchannels(audiofile) == 2
@test sr(audiofile) == 44100
@test origin_sr(audiofile) == 44100
@test is_norm(audiofile) == true

audiofile = load(mp3_file; sr=8000)
@test audiofile isa AudioFile
@test sr(audiofile) == 8000
@test origin_sr(audiofile) == 44100

@test eltype(audiofile) == Float32
@test length(audiofile) == 44513

audio      = load(mp3_file; norm=false)
audio_norm = load(mp3_file; norm=true)
@test sum(abs.(data(audio_norm))) > sum(abs.(data(audio)))

data(audio)
