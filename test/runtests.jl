#!/usr/local/bin/julia
# Author: Dieter Castel
using UAI
using Test

#tests = ["independence", "normalization","visualizer"]
tests = ["types","normalization","parser","independence"]
for t in tests
	include("$(t).jl")
end
