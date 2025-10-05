using AudioReader
using FileIO
using MP3

filepath = "/home/paso/Documents/Aclai/PasoStudio73/Audio911.jl/test/test_files/test.wav"

# @profview FileIO.load(filepath)
# @profview AudioReader.load(filepath)

test1 = FileIO.load(filepath)
@btime FileIO.load(filepath)
# 431.596 μs (101 allocations: 674.66 KiB)

test2 = AudioReader.load(filepath)
@btime AudioReader.load(filepath)
# 253.447 μs (117 allocations: 592.44 KiB)
# 197.545 μs (78 allocations: 579.35 KiB)

filepath = "/home/paso/Documents/Aclai/PasoStudio73/Audio911.jl/test/test_files/test.mp3"

# @profview FileIO.load(filepath)
# @profview AudioReader.load(filepath)

test1 = FileIO.load(filepath)
@btime FileIO.load(filepath)
# 431.596 μs (101 allocations: 674.66 KiB)

test2 = AudioReader.load(filepath)
@btime AudioReader.load(filepath)
# 253.447 μs (117 allocations: 592.44 KiB)
# 197.545 μs (78 allocations: 579.35 KiB)