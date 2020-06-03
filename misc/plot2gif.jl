ENV["GKS_ENCODING"]="utf-8"
using Images
using Plots
gr()

mutable struct Animatable
	frames::Array{Function,1}
end

Base.push!(anm::Animatable, plot) = push!(anm.frames, plot)
Base.length(anm::Animatable) = length(anm.frames)
Base.iterate(anm::Animatable, state=1) = state > length(anm) ? nothing : 
begin 
	(anm.frames[state],state+1)
end

fns = ["original", "relevant", "moralized", "disoriented"]

function makePlot(fn;title=fn)
	return runIt() = begin 
		img = load(joinpath("plots",string(fn,".png")))
		plot(img, title=title,xaxis=false,yaxis=false,dpi=800,grid=nothing)
	end
end

a = Animatable(map(x->makePlot(x),fns))
anim = @animate for f in a 
	f() 
end
gif(anim, joinpath("plots","d-separation.gif"))
## Other failing test below:
#
# Some unicode chars not supported as per: https://github.com/jheinen/GR.jl/issues/143
a = Animatable([makePlot("disoriented",title="a ⫫⃥ b | c")])

using UAI
mitGraphStr = "a>c<b; d<c>e ; d>f>g"
@gidp(mitGraphStr, a, b | c)

fns = ["original", "relevant", "moralized", "disoriented"]

a = Animatable(map(x->makePlot(x),fns))
#push!(a,makePlot("disoriented",title="a ⫫⃥ b | c"))

anim = @animate for f in a end
gif(anim, "d-separation.gif")
