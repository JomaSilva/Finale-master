/datum/skill/tree/shapeshifter
	name="Shapeshifter Racials"
	desc="Given to all Shapeshifters at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Shapeshifter")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/general/PermanentImitation,new/datum/skill/general/imitation)

/datum/skill/general/PermanentImitation
	skilltype = "Physical"
	name = "Permanent Imitation"
	desc = "Don't just imitate someone, BECOME them. If you do this, you'll lose your racial identity and become the other person's race! Even admins can't reverse this!"
	can_forget = FALSE
	common_sense = FALSE
	tier = 1

/datum/skill/general/PermanentImitation/after_learn()
	savant.contents+=new/obj/Permanent_Imitation
	savant<<"You can become other people! This will overload your genome with every \"safe\" modifier that race has. It won't change your race, but it'll give you their base stats. Can't be reversed except through a tech-synthized cure. This is permanent."

obj/Permanent_Imitation
	verb/Permanent_Imitate()
		set category = "Skills"
		if(usr.isimitate && usr.stored_race != "Shapeshifter")
			usr.name="[usr.holdname]"
			usr.overlayList.Add(usr.copiedoverlayList)
			usr.copiedoverlayList.Cut()
			usr.overlaychanged=1
			usr.overlayupdate=1
			usr.stored_race = "Shapeshifter"
			//var/prevgrav = usr.GravMastered
			//var/prevzenni = usr.zenni
			//usr.StatRace(usr.isimitate,1)
			//usr.GravMastered = prevgrav
			//usr.zenni = prevzenni
			usr.genome.FLAG_SHAPESHIFTER = TRUE
			usr.genome.FLAG_SHAPESHIFTER_TYPE = usr.isimitate
			//del(src)
		else
			usr<<"<b>You need to be imitating, or not already permanently imitated, in order to make this form Permanent!"

obj/items/Injections/Shapeshifters_Cure
	name = "Shapeshifter's Cure"
	desc = "This cures a permanently shapeshifted shapeshifter... at a small price. (Mutation chance, Lowered BP, Knockout, reset Gravity and reset physical age.)"
	cantblueprint=1
	IsntAItem=0
	Consume()
		if(usr.stored_race != "Shapeshifter") return
		if(!(..())) return
		usr.Age = 1
		usr.safetyBP *= 0.90
		usr.BP *= 0.90
		usr.stored_race = null
		usr.genome.FLAG_SHAPESHIFTER = FALSE
		usr.genome.FLAG_SHAPESHIFTER_TYPE = FALSE
		usr.genome.build_stats()
		usr.genome.reapply_stats(TRUE)
		spawn usr.KO()
		del(src)
		return

obj/Imitation
	var/list/imitatoroverlays=new/list
	var/list/imitatorvissies=new/list
	var/imitatoricon
	verb/Imitate()
		set category="Skills"
		if(usr.IM)
			usr.IM=0
			usr.isimitate = 0
			usr.name=usr.oname
			usr.icon=imitatoricon
			usr.overlayList.Cut()
			usr.overlayList.Add(imitatoroverlays)
			usr.copiedoverlayList.Cut()
			imitatoroverlays.Cut()
			usr.overlaychanged=1
		else if(!usr.IM)
			usr.IM=1
			usr.oname="[usr.name]"
			imitatoroverlays.Add(usr.overlayList)
			imitatoricon=usr.icon
			var/list/People=new/list
			for(var/mob/A in oview(usr)) if(A.client) People.Add(A)
			var/Choice=input("Imitate who?") in People
			for(var/mob/A) if(A==Choice)
				usr.icon=A.icon
				imitatoroverlays += usr.overlayList
				usr.overlayList.Remove(usr.overlayList)
				usr.copiedoverlayList.Add(A.overlayList)
				usr.overlayList.Add(A.vis_contents)
				usr.name=A.name
				usr.isimitate = A.Race
			usr.overlaychanged=1