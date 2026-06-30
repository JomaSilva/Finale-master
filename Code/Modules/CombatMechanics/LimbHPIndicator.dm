mob
	var
		tmp/obj/screen/damage_indct/damage_indct = null

/obj/screen/damage_indct
	name = "damage indct"
	icon = 'health_hud.dmi'
	icon_state = "health_hud"
	screen_loc = "EAST-2,NORTH-2"
	mouse_opacity = 0
	New()
		..() //the /obj/screen base New() applies a 3x2 stretch meant for the HP/Ki bars; reset so this 96x96 limb paperdoll renders at its native size instead of a giant distorted body
		transform = matrix()

//Monotonic green->red severity colour, matching the Body tab status colours (Injuries.dm limbstatus).
//The paperdoll used to read the colour BAKED into each .dmi state, but that art skews DARK at the severe
//end (Critically Injured = muddy brown #993300, Broken = near-black) so a badly hurt part actually looked
//CALMER than a lightly-hurt one (bright orange). We now tint one uniform silhouette frame by HP% instead,
//so colour tracks damage cleanly and every limb uses the exact same scale.
proc/health_hud_color(pct)
	if(pct >= 100) return "#22ee22" //healthy   - green
	if(pct >= 80)  return "#9bff00" //slightly  - lime
	if(pct >= 60)  return "#ffe400" //injured   - yellow
	if(pct >= 40)  return "#ff8a00" //seriously - orange
	if(pct >= 20)  return "#ff2200" //critical  - red
	return "#7a0000"                //broken    - dark red

#define LOPPED_LIMB_COLOR "#9b30ff" //torn-off limbs read purple on the paperdoll, not just "0% dark red"

/obj/screen/damage_indct/proc/update_icon(mob/source)
	//Run synchronously: the old `set waitfor = 0` + `set background = 1` let the 0.3s HudUpdate loop fire
	//overlapping, deprioritized rebuilds that raced on overlays.Cut()/overlays= and left the paperdoll
	//showing stale wounds that didn't match the live Body tab. It's cheap (~15 overlays); just do it inline.
	var/mob/savant = null
	if(source)
		savant = source
	else return
	overlays.Cut()
	var/list/overlayList = list()
	//SHAPE is a single uniform silhouette frame (the yellow "Slightly Injured" art, present + identical-shape on
	//every part); we recolour it per part via .color so the hue comes 100% from HP, not from the baked art.
	var/shape = "Slightly Injured"
	//The per-part torso art (health_hud_torso.dmi "Slightly Injured") is only a small MID-BODY BAND -- it does NOT
	//cover the upper chest/shoulders, so that large region falls back to this base silhouette. Tinting the base by
	//OVERALL HP made a wrecked torso show GREEN there while the head (full-coverage art) correctly turned orange.
	//Tint the base by the TORSO's OWN HP so the chest tracks torso damage; every other region is painted over by
	//its own part overlay below, so this only changes the otherwise-uncovered chest.
	var/torsoColor = health_hud_color(round(savant.HP)) //fallback: overall HP if no torso part is somehow present
	for(var/datum/Body/T in savant.body)
		if(T.type == /datum/Body/Torso)
			torsoColor = T.lopped ? LOPPED_LIMB_COLOR : health_hud_color(round((T.health / T.maxhealth) * 100, 1))
			break
	var/image/baseI = image('health_hud_base.dmi', shape)
	baseI.color = torsoColor
	overlayList += baseI
	for(var/datum/Body/S in savant.body)
		if(istype(S,/datum/Body/Arm) || istype(S,/datum/Body/Leg) || istype(S,/datum/Body/Organs) || istype(S,/datum/Body/Head/Brain) || istype(S,/datum/Body/Tail)) continue //Tail (Saiyan) has no paperdoll art -> it would otherwise fall through to the DEFAULT torso.dmi and stamp a 2nd torso band tinted by TAIL hp, mis-colouring the chest
		//reasoning for excluding organs/brain this is because brain doesn't have a seperate status icon. We only show what's needed, and also adding duplicate overlays screws shit. Reproductive organs are shown and have status icons, so they're good.
		var/bodytype = 'health_hud_torso.dmi'
		switch(S.type)
			if(/datum/Body/Head) bodytype = 'health_hud_head.dmi'
			if(/datum/Body/Abdomen) bodytype = 'health_hud_abdomen.dmi'
			if(/datum/Body/Reproductive_Organs) bodytype = 'health_hud_reproductive_organs.dmi'
		var/selectHP = round((S.health / S.maxhealth) * 100,1)
		var/image/I = image(bodytype, shape)
		I.color = S.lopped ? LOPPED_LIMB_COLOR : health_hud_color(selectHP)
		overlayList += I


	var/overalllarmHP = 0
	var/larms = 0
	var/overallrarmHP = 0
	var/rarms = 0
	var/larm_lopped = 0
	var/rarm_lopped = 0
	for(var/datum/Body/Arm/A in savant.body)
		if(findtext(A.name,"Right")&&A.maxhealth)
			rarms += 1
			overallrarmHP += (A.health / A.maxhealth) * 100
			if(A.lopped && A.type == /datum/Body/Arm) rarm_lopped = 1 //the whole arm is gone (a lone lopped HAND still shows the average)
		else if(A.maxhealth)
			larms += 1
			overalllarmHP += (A.health / A.maxhealth) * 100
			if(A.lopped && A.type == /datum/Body/Arm) larm_lopped = 1
	var/overallllegHP = 0
	var/llegs = 0
	var/overallrlegHP = 0
	var/rlegs = 0
	var/lleg_lopped = 0
	var/rleg_lopped = 0
	for(var/datum/Body/Leg/A in savant.body)
		if(findtext(A.name,"Right")&&A.maxhealth)
			rlegs += 1
			overallrlegHP += (A.health / A.maxhealth) * 100
			if(A.lopped && A.type == /datum/Body/Leg) rleg_lopped = 1
		else if(A.maxhealth)
			llegs += 1
			overallllegHP += (A.health / A.maxhealth) * 100
			if(A.lopped && A.type == /datum/Body/Leg) lleg_lopped = 1

	var/totalllarmhp = 100 //default to healthy: if no left-arm limbs are counted this frame, treat as full
	if(larms)
		totalllarmhp = round(overalllarmHP/larms,1)
	var/image/LA = image('health_hud_leftarm.dmi', shape)
	LA.color = larm_lopped ? LOPPED_LIMB_COLOR : health_hud_color(totalllarmhp)
	overlayList += LA

	var/totalrarmhp = 100 //default to healthy (see left arm note)
	if(rarms)
		totalrarmhp = round(overallrarmHP/rarms,1)
	var/image/RA = image('health_hud_rightarm.dmi', shape)
	RA.color = rarm_lopped ? LOPPED_LIMB_COLOR : health_hud_color(totalrarmhp)
	overlayList += RA

	var/ltotalleghp = 100 //default to healthy (see left arm note)
	if(llegs)
		ltotalleghp = round(overallllegHP/llegs,1)
	var/image/LL = image('health_hud_leftleg.dmi', shape)
	LL.color = lleg_lopped ? LOPPED_LIMB_COLOR : health_hud_color(ltotalleghp)
	overlayList += LL

	var/rtotalleghp = 100 //default to healthy (see left arm note)
	if(rlegs)
		rtotalleghp = round(overallrlegHP/rlegs,1)
	var/image/RL = image('health_hud_rightleg.dmi', shape)
	RL.color = rleg_lopped ? LOPPED_LIMB_COLOR : health_hud_color(rtotalleghp)
	overlayList += RL
	overlays = overlayList