/datum/skill/tree/majin
	name="Majin Racials"
	desc="Given to all Majins at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Majin")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/namek/bigform,new/datum/skill/general/buuabsorb,new/datum/skill/general/splitform,new/datum/skill/general/regenerate,new/datum/skill/majin/Purification,new/datum/skill/majin/Super_Majin)

/datum/skill/general/splitform
	skilltype = "Creation"
	name = "Split Form"
	desc = "Split your body into two copies, halving your expressed BP."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1

/datum/skill/general/splitform/after_learn()
	savant.contents+=new/obj/SplitForm
	savant<<"You can split your body in two!"
/datum/skill/general/splitform/before_forget()
	for(var/obj/D in savant.contents)
		if(D.name=="SplitForm")
			del(D)
	savant<<"You've forgotten how to make copies of yourself!?"

/datum/skill/general/buuabsorb
	skilltype="Magical"
	name="Buu Absorb"
	desc="Cover someone with your flesh, then bring them into yourself, giving yourself a power boost."
	can_forget = FALSE
	common_sense = FALSE

/datum/skill/general/buuabsorb/after_learn()
	savant.contents+=new/obj/Buu_Absorb
	savant<<"You can absorb others!"

/datum/skill/majin/Purification
	skilltype="Magical"
	name="Purification"
	desc="If you're not angry and have an absorb, immediately heal completely, expelling all absorbs and gaining an anger boost. When you lose the anger or debuff, your Stamina and Ki are set to their minimums."
	can_forget = FALSE
	common_sense = FALSE
	skillcost = 2

	after_learn()
		assignverb(/mob/keyable/verb/Purification)
		savant<<"You can purfiy your essence!"
	login()
		..()
		assignverb(/mob/keyable/verb/Purification)


mob/keyable/verb/Purification()
	set category="Skills"
	if(isBuffed(/obj/buff/Purification)) stopbuff(/obj/buff/Purification)
	else if(Emotion=="Calm" && AbsorbDatum && AbsorbDatum.MajorAbsorbSigs.len)
		if(usr.startbuff(/obj/buff/Purification))
			AbsorbDatum.expellall()
	else usr<<"Either you're not calm, or you don't have anything major absorbed!"

/obj/buff/Purification
	name = "Purification"
	slot=sFORM
	Buff()
		..()
		container<<"Your essence purifies, leaving behind a stronger Majin!"
		container.emit_Sound('1aura.wav')
		if(AscensionStarted)
			container.transBuff=2
		container.SpreadHeal(100)
		container.Do_Anger_Stuff()
		container.StoredAnger=60
		container.Anger-=10
		container.Emotion = "Angry"
		container.Tphysoff+=1.2
		container.Tkioff+=1.2
		container.Tspeed+=1.2
	Loop()
		if(container.Emotion == "Calm") DeBuff()
	DeBuff()
		container<<"You relax."
		container.transBuff=1
		container.Tphysoff-=1.2
		container.Tkioff-=1.2
		container.Tspeed-=1.2
		container.Ki = 0
		container.stamina = 2
		container.SpreadDamage(5)
		..()

/datum/skill/majin/Super_Majin
	skilltype="Magical"
	name="Super Majin"
	desc="Gain a boost in speed and technique for less defense. If you're ascended, there's no defense penalty, and a decent BP boost and energy boost."
	can_forget = FALSE
	common_sense = FALSE
	skillcost = 2

	after_learn()
		assignverb(/mob/keyable/verb/Super_Majin)
		savant<<"You can absorb others!"
	login()
		..()
		assignverb(/mob/keyable/verb/Super_Majin)


mob/keyable/verb/Super_Majin()
	set category="Skills"
	if(isBuffed(/obj/buff/Super_Majin)) stopbuff(/obj/buff/Super_Majin)
	else usr.startbuff(/obj/buff/Super_Majin)

/obj/buff/Super_Majin
	name = "Super Majin"
	slot=sFORM
	var/defensepentl
	Buff()
		..()
		container<<"You become a Super Majin!"
		container.emit_Sound('1aura.wav')
		if(AscensionStarted)
			container.transBuff=3
			container.trueKiMod = 2
			container.MaxKi *= 2
		else
			container.Tphysdef-=0.1
			container.Tkidef-=0.1
			defensepentl=1
		container.Ttechnique+=1.2
		container.Tkioff+=1.2
		container.Tspeed+=1.2
	DeBuff()
		container<<"You relax."
		container.transBuff=1
		container.Ttechnique-=1.2
		container.Tkioff-=1.2
		container.Tspeed-=1.2
		if(defensepentl)
			container.Tphysdef+=0.1
			container.Tkidef+=0.1
		container.MaxKi = container.MaxKi / container.trueKiMod
		container.trueKiMod = 1
		..()