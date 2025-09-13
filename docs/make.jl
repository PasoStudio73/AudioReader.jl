using AudioReader
using Documenter

# DocMeta.setdocmeta!(AudioReader, :DocTestSetup, :(using AudioReader); recursive = true)

makedocs(;
    modules = [AudioReader],
    authors = "Riccardo Pasini",
    # repo=Documenter.Remotes.GitHub("aclai-lab", "AudioReader.jl"),
    sitename = "AudioReader.jl",
    # format = Documenter.HTML(;
    #     size_threshold = 4000000,
    #     prettyurls = get(ENV, "CI", "false") == "true",
    #     canonical = "https://aclai-lab.github.io/AudioReader.jl",
    #     assets = String[],
    # ),
    pages = [
        "Home" => "index.md",
    ],
    warnonly = :true,
)

@info "`makedocs` has finished running."