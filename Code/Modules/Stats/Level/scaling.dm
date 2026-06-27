mob/proc/processpoints()
	var/unAIDSpoints = totalskillpoints - (admingibbedpoints + wishedpoints) //meant to allow (b)admins to gib skillpoints without fucking up a player's next skillpoint total.
	var/pointgain = ((1+0.466)**unAIDSpoints)/skillpointMod
	var/spcap = round(40+(10*skillpointMod)) + admingibbedpoints + wishedpoints //natural cap (~50) PLUS admin/wished gifts, so gifts STACK on top instead of being clamped away.
	totalskillpoints = min(totalskillpoints,spcap)
	if(globalpoints>globalpointsrecieved) //admin "Global - Give all Milestones" queue. Runs every call now (was dead code behind the natural-gain return below, so the verb did nothing for anyone still gaining naturally).
		globalpointsrecieved+=1
		admingibbedpoints+=1
		totalskillpoints+=1
	if(totalskillpoints<spcap) //natural gain: raw BP buys the next milestone (threshold grows exponentially via unAIDSpoints, so this self-limits well before the cap)
		if(BP>=round(pointgain,1))
			totalskillpoints+=1
	availablepoints = totalskillpoints - allocatedpoints

mob/var
	admingibbedpoints
	globalpointsrecieved
	wishedpoints = 0
	allocatedpoints = 0
	availablepoints
	tmp/nextMilestoneTick = 0 //world.time gate so idle players (e.g. powering up in place) still convert BP->milestones ~once/sec; tmp so it resets each world boot