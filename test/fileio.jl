using AudioReader

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


