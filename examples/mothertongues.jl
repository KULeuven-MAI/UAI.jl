# From BRML p. 12

str = "MT<Cnt"
mj = JPD(str)
setDomain!(mj, :Cnt, [:E, :S, :W])
setDomain!(mj, :MT, [:Eng, :Scot, :Wel])
mt_cnt = getNamedTable(mj, @q MT|Cnt )
cnt = getNamedTable(mj, @q Cnt )


