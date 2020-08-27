using Documenter
using UAI

DocMeta.setdocmeta!(UAI, :DocTestSetup, :(using UAI); recursive=true)
makedocs(
    sitename = "UAI",
    format = Documenter.HTML(),
    modules = [UAI],
		doctest = true
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
