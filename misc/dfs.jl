using LightGraphs

function dfs(g,v,isDiscovered)
   isDiscovered[v] = true
   for nb in all_neighbors(g,v)
	   print("$v-")
	   if isDiscovered[nb] == false
		   dfs(g,nb,isDiscovered)
		   print("$nb")
	   end
   end
   println("$v END")
end

function depthFirst(g,src)
	isDiscovered = repeat([false],nv(g))
	dfs(g,src,isDiscovered)
end


g = SimpleDiGraph([ 0 1 1; 0 0 1; 0 1 0])
