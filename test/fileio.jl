using AudioReader

file = "/home/paso/Documents/Aclai/Julia_additional_files/read_audiofile/test1.wav"
F1 = File{format"WAV"}(file)

@test_nowarn File{format"WAV"}(file)

invalid_file = "/home/paso/Documents/Aclai/Julia_additional_files/read_audiofile/test1.exe"
F1 = File{format"WAV"}(invalid_file)
