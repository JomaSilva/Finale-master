mob/proc/compareStyles(var/mob/M)
	if(isnull(currentStyle)) return
	if(isnull(M.currentStyle)) return sqrt(currentStyle.mastery_Percent)
	var/chance = (currentStyle.mastery_Percent - M.currentStyle.mastery_Percent)
	if(M.currentStyle.name==currentStyle.name) chance += 15
	if(chance < 0)
		if(prob(60 + chance))
			chance += 10 * Etechnique
		else chance = 0
	else
		chance += 10 * Etechnique
	if(prob(chance))
		return sqrt(currentStyle.mastery_Percent)
	else return FALSE

mob/var
	datum/style/currentStyle = null
	list/styleList = list()
	list/activeStyles = list()
	list/availableStyles = list()
	personalchangedstyles = 0
	personalphysicalchangevalue
	personalmentalchangevalue
	personalabstractchangevalue

mob/proc/StyleUpdate()
	if(currentStyle)
		currentStyle.mastery_buffer += 1
		if(currentStyle.mastery_buffer >= 100)
			currentStyle.mastery_buffer = 0
			currentStyle.mastery_Cap = max(currentStyle.mastery_Cap,min(5 + (allocatedpoints) + round(allocatedpoints + (allocatedpoints/40.5)),100))
			currentStyle.mastery_Percent += (allocatedpoints + 1) / currentStyle.mastery_Cap
			if(train) currentStyle.mastery_Percent += (allocatedpoints + 3) / currentStyle.mastery_Cap
			if(IsInFight) currentStyle.mastery_Percent += (allocatedpoints + 4) / currentStyle.mastery_Cap
			currentStyle.mastery_Percent = min(currentStyle.mastery_Cap,currentStyle.mastery_Percent)
			for(var/datum/style/A in activeStyles)
				if(A!=currentStyle && prob(10))
					A.mastery_Percent = max(0,A.mastery_Percent - (A.mastery_Percent/25))
	if(isnull(personalphysicalchangevalue)&&isnull(personalmentalchangevalue)&&isnull(personalabstractchangevalue))
		personalphysicalchangevalue = physicalchangevalue
		personalmentalchangevalue = mentalchangevalue
		personalabstractchangevalue = abstractchangevalue
	if(personalchangedstyles!=changedstyles|personalphysicalchangevalue!=physicalchangevalue|personalmentalchangevalue!=mentalchangevalue|personalabstractchangevalue!=abstractchangevalue)
		usr<<"Styles reset due to update. Check your unallocated skillpoints and current styles for more info."
		personalchangedstyles = changedstyles
		personalphysicalchangevalue = physicalchangevalue
		personalmentalchangevalue = mentalchangevalue
		personalabstractchangevalue = abstractchangevalue
		for(var/datum/style/A in activeStyles)
			A.styleReset()
		//spawn(1000) StyleUpdate() //every 100 or so seconds, check again.

mob/proc
	CheckStyle()
		set waitfor = 0
		set background = 1
		DOESEXIST
		CHECK_TICK
		verbs+=(/mob/verb/Pick_Current_Style)
		verbs+=(/mob/verb/Edit_Current_Style)
		if(!activeStyles)
			activeStyles = list()
		if(!availableStyles)
			availableStyles = list()
		while(src)
			sleep(15)
			if(currentStyle)
				currentStyle.UpdateStyle()
				StyleUpdate()
				CHECK_TICK
				physoffStyle = currentStyle.physoff
				physdefStyle = currentStyle.physdef
				techniqueStyle = currentStyle.technique
				kioffStyle = currentStyle.kioff
				kidefStyle = currentStyle.kidef
				kiskillStyle = currentStyle.kiskill
				speedStyle = currentStyle.speed
				magiStyle = currentStyle.magi
				kiregenStyle=currentStyle.kiregen
				staminadrainStyle = currentStyle.staminadrain
				staminagainStyle = currentStyle.staminagain