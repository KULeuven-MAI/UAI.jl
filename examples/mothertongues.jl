# From BRML p. 12

str = "MT<Cnt"
mj = JPD(str)
setDomain!(mj, :Cnt, [:E, :S, :W])
setDomain!(mj, :MT, [:Eng, :Scot, :Wel])
getNamedTable(mj, @q MT|Cnt )
getNamedTable(mj, @q Cnt )
