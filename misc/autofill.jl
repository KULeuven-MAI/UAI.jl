using UAI
j = JPD("a>b<c")
setAllDomains!(j,["t","f"])
setDomain!(j,:b,["t","m","f"])
#= nt = getNamedTable(j,(@q b|a,c)) =#
#= @test view(nt,Not("f"),:,:) == view(nt,[1,2],:,:) =#

setTableInteractive!(j, (@q b|a,c), autofill="m")
