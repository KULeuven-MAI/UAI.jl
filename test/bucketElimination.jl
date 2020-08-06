using UAI
using Test
using Random
# Quick test from example of Lecture 5
# TODO write actual tests of exercises.
j = JPD("c<a>d;f<d<b;d>g<e")
bucks = eliminate(bucketInitialise(j,"ecbgadf")...)

@test bucks[(1,:e)] == []
@test bucks[(2,:c)] == []
@test bucks[(3,:b)] == []
@test bucks[(4,:g)] == []
@test bucks[(5,:a)] == []
@test bucks[(6,:d)] == []
@test string(bucks[(7,:f)][1]) == "γ_d(f)"
