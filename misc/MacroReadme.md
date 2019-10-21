# Julia LaTeX expansion code 2 macro table
#

I wrote some vim macros to convert the table listed here into julia macros
It's a three step process:

1) Clean the full html table
https://docs.julialang.org/en/v1/manual/unicode-input/


2) Strip down the html table to commented out csv 

Vim macro to do this:

let @j = 'dtUi#f<r,ld2f>f<r,ldt\f<r,ld2f>f<d$jI'

Turns:
<tr><td style="text-align: left">U+02200</td><td style="text-align: left">∀</td><td style="text-align: left">\forall</td><td style="text-align: left">For All</td></tr>
Into:
#U+02200,∀,\forall,For All


3) Convert the comments into actual macro's

let @q = 'yypdf,imacro name	:(f,r)ld$oendkkfnPlF\d f,d$jjjI'


Turns:
#U+02249,≉,\napprox,Not Almost Equal To
Into:
#U+02249,≉,\napprox,Not Almost Equal To
macro approx
	return :()
end


4) Do 1000@q all lines in the post-step-2) document
