using Documenter
using UAI

makedocs(
    sitename = "UAI",
    format = Documenter.HTML(),
    modules = [UAI]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
