# Macros seem to break with UTF8 chars.
# TODO investigate
# Define LaTeX expansion macros for easy use instead of tab expansion.
# see MacroReadme.md
#U+02200,∀,\forall,For All
macro forall()
	return :( ∀ )
end
#U+02248,≈,\approx,Almost Equal To
macro approx()
	return :( ≈ )
end
#U+02249,≉,\napprox,Not Almost Equal To
macro napprox()
	return :( ≉ )
end
#U+02248,≈,\approx,Almost Equal To
macro approx()
	return :( ≈ )
end



1 @approx 2
1 @approx 1.000000000000001
