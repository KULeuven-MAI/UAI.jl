using UAI

# Example taken from The Book of Why (By Judea Pearl).
domains = ["Drug" => ["Taken","NotTaken"],
		   "Gender" => ["Male","Female"],
		   "HeartAtt" => ["Attack","NoAttack"]]


#TODO: Consistent Dimension ordering

pG = [0.5 0.5]

#		    M   FM 
# No Drug 
pD_G = [  40/60  20/60;
# Drug
		  20/60	 40/60] 

# P ( HeartAtt | Drug, G=WOMAN)
#			HA      No HA
#  No Drug 
pH_DW = [ 1 / 20 19/20 ;
#   Drug
		 3/40  37/40  ]
#	No Drug 
pH_DM = [ 12/40  28/40;
#	Drug
		 8/20   12/20 ]		
pH_DG = cat(pHDW, pHDM,dims=3)

str = "Drug<Gender>HeartAtt;Drug>HeartAtt"
drawFromStr(str ,"examples/simpson.png")
factoriz, variables = getFactorization(str)
