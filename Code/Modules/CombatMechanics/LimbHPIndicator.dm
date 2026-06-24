mob
	var
		tmp/obj/screen/damage_indct/damage_indct = null

/obj/screen/damage_indct
	name = "damage indct"
	icon = 'health_hud.dmi'
	icon_state = "health_hud"
	screen_loc = "EAST-2,NORTH-2"
	mouse_opacity = 0

/obj/screen/damage_indct/proc/update_icon(mob/source)
	set waitfor = 0
	set background = 1
	var/mob/savant = null
	if(source)
		savant = source
	else return
	overlays.Cut()
	var/list/overlayList = list()
	var/bodygenHP = round(savant.HP)
	var/basestate = "Healthy"
	switch(bodygenHP)
		if(80 to 99) basestate = "Slightly Injured"
		if(60 to 79) basestate = "Injured"
		if(40 to 59) basestate = "Seriously Injured"
		if(20 to 39) basestate = "Critically Injured"
		if(0 to 19) basestate = "Broken"
	overlayList += image('health_hud_base.dmi', "[basestate]")
	for(var/datum/Body/S in savant.body)
		if(istype(S,/datum/Body/Arm) || istype(S,/datum/Body/Leg) || istype(S,/datum/Body/Organs) || istype(S,/datum/Body/Head/Brain)) continue
		//reasoning for excluding organs/brain this is because brain doesn't have a seperate status icon. We only show what's needed, and also adding duplicate overlays screws shit. Reproductive organs are shown and have status icons, so they're good.
		var/bodytype = 'health_hud_torso.dmi'
		switch(S.type)
			if(/datum/Body/Head) bodytype = 'health_hud_head.dmi'
			if(/datum/Body/Abdomen) bodytype = 'health_hud_abdomen.dmi'
			if(/datum/Body/Reproductive_Organs) bodytype = 'health_hud_reproductive_organs.dmi'
		var/selectHP = round((S.health / S.maxhealth) * 100,1)
		var/bodstate = "Healthy"
		switch(selectHP)
			if(80 to 99) bodstate = "Slightly Injured"
			if(60 to 79) bodstate = "Injured"
			if(40 to 59) bodstate = "Seriously Injured"
			if(20 to 39) bodstate = "Critically Injured"
			if(0 to 19) bodstate = "Broken"
		overlayList += image(bodytype, "[bodstate]")


	var/overalllarmHP = 0
	var/larms = 0
	var/overallrarmHP = 0
	var/rarms = 0
	for(var/datum/Body/Arm/A in savant.body)
		if(findtext(A.name,"Right")&&A.maxhealth)
			rarms += 1
			overallrarmHP += (A.health / A.maxhealth) * 100
		else if(A.maxhealth)
			larms += 1
			overalllarmHP += (A.health / A.maxhealth) * 100
	var/overallllegHP = 0
	var/llegs = 0
	var/overallrlegHP = 0
	var/rlegs = 0
	for(var/datum/Body/Leg/A in savant.body)
		if(findtext(A.name,"Right")&&A.maxhealth)
			rlegs += 1
			overallrlegHP += (A.health / A.maxhealth) * 100
		else if(A.maxhealth)
			llegs += 1
			overallllegHP += (A.health / A.maxhealth) * 100

	var/totalllarmhp = 0
	if(larms)
		totalllarmhp = round(overalllarmHP/larms,1)
	var/larmstate = "Healthy"
	switch(totalllarmhp)
		if(80 to 99) larmstate = "Slightly Injured"
		if(60 to 79) larmstate = "Injured"
		if(40 to 59) larmstate = "Seriously Injured"
		if(20 to 39) larmstate = "Critically Injured"
		if(0 to 19) larmstate = "Broken"
	overlayList += image('health_hud_leftarm.dmi', "[larmstate]")

	var/totalrarmhp = 0
	if(rarms)
		totalrarmhp = round(overallrarmHP/rarms,1)
	var/rarmstate = "Healthy"
	switch(totalrarmhp)
		if(80 to 99) rarmstate = "Slightly Injured"
		if(60 to 79) rarmstate = "Injured"
		if(40 to 59) rarmstate = "Seriously Injured"
		if(20 to 39) rarmstate = "Critically Injured"
		if(0 to 19) rarmstate = "Broken"
	overlayList += image('health_hud_rightarm.dmi', "[rarmstate]")

	var/ltotalleghp = 0
	if(llegs)
		ltotalleghp = round(overallllegHP/llegs,1)
	var/llegstate = "Healthy"
	switch(ltotalleghp)
		if(80 to 99) llegstate = "Slightly Injured"
		if(60 to 79) llegstate = "Injured"
		if(40 to 59) llegstate = "Seriously Injured"
		if(20 to 39) llegstate = "Critically Injured"
		if(0 to 19) llegstate = "Broken"
	overlayList += image('health_hud_leftleg.dmi', "[llegstate]")

	var/rtotalleghp = 0
	if(rlegs)
		rtotalleghp = round(overallrlegHP/rlegs,1)
	var/rlegstate = "Healthy"
	switch(rtotalleghp)
		if(80 to 99) rlegstate = "Slightly Injured"
		if(60 to 79) rlegstate = "Injured"
		if(40 to 59) rlegstate = "Seriously Injured"
		if(20 to 39) rlegstate = "Critically Injured"
		if(0 to 19) rlegstate = "Broken"
	overlayList += image('health_hud_rightleg.dmi', "[rlegstate]")
	overlays = overlayList