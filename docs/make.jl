using AudioReader
using Documenter

# DocMeta.setdocmeta!(AudioReader, :DocTestSetup, :(using AudioReader); recursive = true)

makedocs(;
    modules = [AudioReader],
    # doctest = true,
    # linkcheck = true,
    authors = "Riccardo Pasini",
    # repo=Documenter.Remotes.GitHub("aclai-lab", "AudioReader.jl"),
    sitename = "AudioReader.jl",
    # format = Documenter.HTML(;
    #     prettyurls = get(ENV, "CI", "false") == "true",
    #     canonical = "https://aclai-lab.github.io/AudioReader.jl",
    # ),
    pages = [
        "Home" => "index.md",
    ],
    warnonly = :true,
)

# deploydocs(;
#     repo = "github.com/aclai-lab/ModalAssociationRules.jl",
#     devbranch = "main",
#     target = "build",
#     branch = "gh-pages",
#     versions = ["main" => "main", "stable" => "v^", "v#.#"],
# )