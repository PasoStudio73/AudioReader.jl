using AudioReader

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

@test_nowarn File{format"WAV"}(wav_file)
@test_nowarn File{format"MP3"}(mp3_file)

@test_nowarn load(wav_file)
@test_nowarn load(mp3_file)
@test_nowarn load(ogg_file)
@test_nowarn load(flac_file)

# Invalid files should throw errors
@test_throws ErrorException load(oga_file)     # Unsupported extension
@test_throws ErrorException load(actually_wav) # Wrong format (WAV with .mp3 extension)
@test_throws ErrorException load(text)         # Unsupported extension
@test_throws ErrorException load(fakewav)      # Wrong format (text with .wav extension)


