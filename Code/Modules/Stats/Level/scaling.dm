mob/proc/processpoints()
	var/unAIDSpoints = totalskillpoints - (admingibbedpoints + wishedpoints) //meant to allow (b)admins to gib skillpoints without fucking up a player's next skillpoint total.
	var/pointgain = ((1+0.466)**unAIDSpoints)/skillpointMod
	totalskillpoints = min(totalskillpoints,round(40+(10*skillpointMod)))//50 maximum, or so.
	if(totalskillpoints<=round(40+(10*skillpointMod)))
		if(BP>=round(pointgain,1))
			totalskillpoints+=1
			return
	availablepoints = totalskillpoints - allocatedpoints
	if(globalpoints>globalpointsrecieved) //meant to allow (b)admins to give out free points to everyone regardless of login.
		globalpointsrecieved+=1
		admingibbedpoints+=1
		totalskillpoints+=1

mob/var
	admingibbedpoints
	globalpointsrecieved
	wishedpoints = 0
	allocatedpoints = 0
	availablepoints