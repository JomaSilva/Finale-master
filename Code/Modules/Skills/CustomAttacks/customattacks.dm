// Various Vars and Other Decs
// ---------------------------

mob/var
	tmp/custom1train = 0
	id
	list/customattacks = list() //the list of every custom attack you've made. use this in addition to contents. (When you customize attacks, Customize_Attack loops through this list.)


obj/CreateAttackWindow/var
	customWindowOpen

var/datum/skill/CustomAttack/CurrentEditedSkill



var/datum/list/beam_modifiers = list()





// The proxy vars we edit when we do customization
// This allows us to edit non-destructively, and then
// Finalize changes when we finish up.
datum/skill/CustomAttack/var/tmp
	customattack_base_damage
	customattack_minimum_chargetime
	customattack_ki_cost
	customattack_stamina_cost
	customattack_use_stamina
	customattack_chargeattack
	customattack_dochargeshout
	customattack_doshout
	customattack_usechargeaura
	customattack_useattackaura
	customattack_speed
	customattack_range
	customattack_rangemodifier
	customattack_instantattack
	customattack_shout
	customattack_chargeshout
	customattack_name
	customattack_desc
	customattack_total_custompoints
	customattack_custompoints_spent
	customattack_custompoints_left
	icon/customattack_attackicon
	icon/customattack_chargeaura
	icon/customattack_attackaura
	icon/customattack_chargeicon



// attacktype key because I can't find a way to make enums
// -------------------------------------------------------
// 0 - Beam
// 1 - Blast
// 2 - Guided Attack
// 3 - Melee Attack
// -------------------------------------------------------

// Generic skills that are editable and replaced as custom attacks
// ---------------------------------------------------------------

/datum/skill/CustomAttack
	var/icon/attackicon
	var/icon/chargeaura
	var/icon/attackaura
	var/icon/chargeicon
	var/id
	var/attacktype = 0
	var/attackcounter
	var/tmp/expbuffer
	var/shout = "RAAAAGH!!"
	var/chargeshout = "Take this....!"
	var/base_damage = 0.8
	var/minimum_chargetime = 1
	var/ki_cost = 20
	var/stamina_cost = 0
	var/use_stamina = 0
	var/chargeattack = 0
	var/dochargeshout = 0
	var/doshout = 0
	var/usechargeaura = 0
	var/useattackaura = 0
	var/total_custompoints = 5
	var/custompoints_spent = 0
	var/speed = 1
	var/range = 20
	var/rangemodifier = 1
	var/instantattack = 0
	var/created = 0
	skilltype = "Ki"
	name = "Custom Attack"
	desc = "Add a description here."
	level = 0
	expbarrier = 10000
	maxlevel = 10
	//
	can_forget = FALSE
	common_sense = FALSE
	//
	skillcost=0
	attacktype = "Beam"
	attackcounter
	expbuffer = 0
	prereqs = list()

	var
		verb_type = null
		given_verb = null

	effector()
		..()
		if(savant.custom1train == id)
			expbuffer+= 1 * rand(1,7)
			if (expbuffer >= 10)
				exp += 1
				expbuffer = 0

	after_learn()
		if(verb_type)
			var/V = new verb_type(savant,"[name]",desc)
			savant.Keyableverbs += V
			savant.verbs += V
			given_verb = V
	
	login(var/mob/logger)
		..()
		if(verb_type)
			var/V = new verb_type(logger,"[name]",desc)
			logger.Keyableverbs += V
			logger.verbs += V
			given_verb = V
	before_forget()
		savant.Keyableverbs -= given_verb
		savant.verbs -= given_verb

/datum/skill/CustomAttack/Custom_Attack1
	verb_type = /mob/keyable/verb/Custom_Attack1

/datum/skill/CustomAttack/Custom_Attack2
	verb_type = /mob/keyable/verb/Custom_Attack2

/datum/skill/CustomAttack/Custom_Attack3
	verb_type = /mob/keyable/verb/Custom_Attack3

/datum/skill/CustomAttack/Custom_Attack4
	verb_type = /mob/keyable/verb/Custom_Attack4

/datum/skill/CustomAttack/Custom_Attack5
	verb_type = /mob/keyable/verb/Custom_Attack5

/datum/skill/CustomAttack/Custom_Attack6
	verb_type = /mob/keyable/verb/Custom_Attack6

/datum/skill/CustomAttack/Custom_Attack7
	verb_type = /mob/keyable/verb/Custom_Attack7

/datum/skill/CustomAttack/Custom_Attack8
	verb_type = /mob/keyable/verb/Custom_Attack8

/datum/skill/CustomAttack/Custom_Attack9
	verb_type = /mob/keyable/verb/Custom_Attack9

/datum/skill/CustomAttack/Custom_Attack10
	verb_type = /mob/keyable/verb/Custom_Attack10

// List of custom attack verbs.  Until we find some way to pass values to verbs
// This is the best we have.  If we think we want players to have more ( or less)
// Verbs, handle it here first.  You can then go into the create attack function
// And mess with the switch statement to give an appropriate amount.
// -----------------------------------------------------------------------------
mob/keyable/verb/Custom_Attack1()
	set category = "Skills"
	CustomAttackHandler(1)

mob/keyable/verb/Custom_Attack2()
	set category = "Skills"
	CustomAttackHandler(2)

mob/keyable/verb/Custom_Attack3()
	set category = "Skills"
	CustomAttackHandler(3)

mob/keyable/verb/Custom_Attack4()
	set category = "Skills"
	CustomAttackHandler(4)

mob/keyable/verb/Custom_Attack5()
	set category = "Skills"
	CustomAttackHandler(5)

mob/keyable/verb/Custom_Attack6()
	set category = "Skills"
	CustomAttackHandler(6)

mob/keyable/verb/Custom_Attack7()
	set category = "Skills"
	CustomAttackHandler(7)

mob/keyable/verb/Custom_Attack8()
	set category = "Skills"
	CustomAttackHandler(8)

mob/keyable/verb/Custom_Attack9()
	set category = "Skills"
	CustomAttackHandler(9)

mob/keyable/verb/Custom_Attack10()
	set category = "Skills"
	CustomAttackHandler(10)





// Custom attack customization and creation verbs.
// If I get around to teach it'll be here too.
// -----------------------------------------------
/mob/default/verb/Customize_Attack()
	set category = "Learning"
	if(inAwindow==1)return
	inAwindow=1
	generatecustomizableskills()

/mob/default/verb/Create_Attack()
	set category = "Learning"
	if(inAwindow==1)return
	createcustomizableskill()

/mob/default/verb/Forget_Attack()
	set category = "Learning"
	if(inAwindow==1)return
	forgetcustomizableskill()

///mob/default/verb/Teach_Custom_Attack(var/mob/M in view(1))
//	set category = "Learning"
//	if(inAwindow==1)return
//	inAwindow=1
//	generateteachableskills(M)

mob/proc/generatecustomizableskills()
	var/list/customize= list()
	for(var/datum/skill/CustomAttack/V in usr.customattacks)
		customize.Add(V)
	customize.Add("Cancel")
	var/Choice=input("Customize which skill?")as null|anything in customize
	if(Choice=="Cancel"|isnull(Choice))
		inAwindow=0
		return
	for(var/datum/skill/CustomAttack/V in usr.customattacks) if(V==Choice)
		usr.inAwindow=0
		CustomAttackWindow(V, 1)
		return

//mob/proc/generateteachableskills(var/T)
//	var/list/teach= list()
//	for(var/obj/skill/CustomAttacks/S in customattacks)
//		if(!S.commonsense) continue
//		teach.Add(S)
//	teach.Add("Cancel")
//	var/Choice=input("Teach which skill? (In the case of things like Beam, they will need to know the Beam skill!)")as null|anything in teach
//	if(Choice=="Cancel"|isnull(Choice))
//		inAwindow=0
//		return
//	for(var/obj/skill/CustomAttacks/S in customattacks) if(S==Choice)
//		S.Teach(T)
//		usr.inAwindow=0

// Creates a dummy skill and adds it to the customize list
// And then customizes that skill.  If cancel is pressed
// Instead of create, dummy skill is discarded an never assigned
// Effectively deleting it.
mob/proc/createcustomizableskill()
	var/datum/skill/CustomAttack/S
	switch(usr.customattacks.len)
		if (0)
			S = new /datum/skill/CustomAttack/Custom_Attack1
			S.id = 1
			CustomAttackWindow(S, 0)
		if (1)
			S = new /datum/skill/CustomAttack/Custom_Attack2
			S.id = 2
			CustomAttackWindow(S, 0)
		if (2)
			S = new /datum/skill/CustomAttack/Custom_Attack3
			S.id = 3
			CustomAttackWindow(S, 0)
		if (3)
			S = new /datum/skill/CustomAttack/Custom_Attack4
			S.id = 4
			CustomAttackWindow(S, 0)
		if (4)
			S = new /datum/skill/CustomAttack/Custom_Attack5
			S.id = 5
			CustomAttackWindow(S, 0)
		if (5)
			S = new /datum/skill/CustomAttack/Custom_Attack6
			S.id = 6
			CustomAttackWindow(S, 0)
		if (6)
			S = new /datum/skill/CustomAttack/Custom_Attack7
			S.id = 7
			CustomAttackWindow(S, 0)
		if (7)
			S = new /datum/skill/CustomAttack/Custom_Attack8
			S.id = 8
			CustomAttackWindow(S, 0)
		if (9)
			S = new /datum/skill/CustomAttack/Custom_Attack9
			S.id = 9
			CustomAttackWindow(S, 0)
		if (10)
			S = new /datum/skill/CustomAttack/Custom_Attack10
			S.id = 10
			CustomAttackWindow(S, 0)

mob/proc/forgetcustomizableskill()
	var/list/forgetcustom = list()
	for(var/datum/skill/CustomAttack/V in usr.customattacks)
		forgetcustom.Add(V)
	forgetcustom.Add("Cancel")
	var/Choice=input("Forget which attack?")as null|anything in forgetcustom
	if(Choice=="Cancel"|isnull(Choice))
		inAwindow=0
		return
	for(var/datum/skill/CustomAttack/S in usr.customattacks) if(S==Choice)
		var/AreYouSure=alert("Are you sure?  This decision is irreversable!", "", "Yes", "No")
		switch(AreYouSure)
			if ("Yes")
				for (var/V in usr.verbs)
					if (S.id == 1 && "[V]" == "/mob/keyable/verb/Custom_Attack1")
						usr.Keyableverbs -= V
						usr.verbs -= V
						break
					if (S.id == 2 && "[V]" == "/mob/keyable/verb/Custom_Attack2")
						usr.Keyableverbs -= V
						usr.verbs -= V
						break
					if (S.id == 3 && "[V]" == "/mob/keyable/verb/Custom_Attack3")
						usr.Keyableverbs -= V
						usr.verbs -= V
						break
					if (S.id == 4 && "[V]" == "/mob/keyable/verb/Custom_Attack4")
						usr.Keyableverbs -= V
						usr.verbs -= V
						break
					if (S.id == 5 && "[V]" == "/mob/keyable/verb/Custom_Attack5")
						usr.Keyableverbs -= V
						usr.verbs -= V
						break
					if (S.id == 6 && "[V]" == "/mob/keyable/verb/Custom_Attack6")
						usr.Keyableverbs -= V
						usr.verbs -= V
						break
					if (S.id == 7 && "[V]" == "/mob/keyable/verb/Custom_Attack7")
						usr.Keyableverbs -= V
						usr.verbs -= V
						break
					if (S.id == 8 && "[V]" == "/mob/keyable/verb/Custom_Attack8")
						usr.Keyableverbs -= V
						usr.verbs -= V
						break
					if (S.id == 9 && "[V]" == "/mob/keyable/verb/Custom_Attack9")
						usr.Keyableverbs -= V
						usr.verbs -= V
						break
					if (S.id == 10 && "[V]" == "/mob/keyable/verb/Custom_Attack10")
						usr.Keyableverbs -= V
						usr.verbs -= V
						break
				usr.customattacks.Remove(S)
				usr.learned_skills.Remove(S)
				del(S)
				inAwindow=0
				return
			if ("No")
				inAwindow=0
				return



// Various functions
// -----------------

// Use this to say shit - usually the name of your attack.
/mob/proc/voice(var/S)
	for(var/mob/M in view(usr))
		if(M.client)
			M << output("<font size=[src.TextSize]><[src.SayColor]>[src.name] says, '[html_encode(S)]'","Chatpane.Chat")

// Big bad proc function that handles every custom attack verbs insides.
/mob/proc/CustomAttackHandler(giv_id)
	var/datum/skill/CustomAttack/S
	src.custom1train = 0
	for (var/datum/skill/CustomAttack/X in usr.customattacks)
		if (X.id == giv_id)
			S = X
	var/kireq=S.ki_cost*usr.BaseDrain
	if(beaming)
		canmove = 1
		stopbeaming()
		src.custom1train = 0
		return
	if(usr.Ki>=kireq)
		if(charging&&accum>=10*chargedelay/3)
			if (S.doshout == 1)
				voice(S.shout)
			usr.icon_state="Blast"
			beaming=1
			src.custom1train = giv_id
			charging=0
			if (S.useattackaura)
				spawn usr.CustomBeamOverlay(S.attackaura, 98)
			emit_Sound('kamehameha_fire.wav')
			return
		else if(charging&&accum<10*chargedelay/3)
			stopcharging()
			return
		else
			src.custom1train = 0
		if(!charging&&!KO&&!med&&!train&&canfight)
			if (S.dochargeshout)
				voice(S.chargeshout)

			if (S.attackicon != null)
				usr.forceicon=S.attackicon
			else
				usr.forceicon=usr.beamicon

			emit_Sound('kame_charge.wav')
			canmove = 0
			lastbeamcost=S.ki_cost*BaseDrain//base drain will end up multiplying in each cycle, making beams burn you out much quicker
			beamspeed= (1 / S.speed)
			powmod= S.base_damage
			chargedelay = S.minimum_chargetime
			maxdistance=S.range
			rangemod = S.rangemodifier
			//canfight = 0
			charging=1
			bypass=1
			if (S.usechargeaura)
				spawn usr.CustomChargeOverlay(S.chargeaura, 98)

			if (S.chargeicon != null)
				spawn usr.CustomChargeOverlay(S.chargeicon, 99)
			else
				spawn usr.addchargeoverlay()
			if (S.instantattack == 1)
				sleep(S.minimum_chargetime)
				if (S.doshout == 1)
					voice(S.shout)
				usr.icon_state="Blast"
				beaming=1
				src.custom1train = giv_id
				charging=0
				if (S.useattackaura)
					spawn usr.CustomBeamOverlay(S.attackaura, 98)
				emit_Sound('kamehameha_fire.wav')
				return
		return
	else
		src << "You need at least [kireq] Ki!"
		src.custom1train = 0

mob/proc/CustomChargeOverlay(var/icon/thisIcon, var/layermod) //copied from the mob handler, god willing it'll do the trick
	var/obj/I=new/obj
	I.layer=MOB_LAYER+layermod
	I.plane=7
	I.icon=thisIcon
	I.icon_state=1
	I.icon+=rgb(blastR,blastG,blastB)
	overlayList+=I
	overlaychanged=1
	spawn
		sleep(10)
		while(charging) sleep(1)
		overlayList-=I
		overlaychanged=1
		if(I) del(I)

mob/proc/CustomBeamOverlay(var/icon/thisIcon, var/layermod) //copied from the mob handler, god willing it'll do the trick
	var/obj/I=new/obj
	I.layer=MOB_LAYER+layermod
	I.plane=7
	I.icon=thisIcon
	I.icon_state=1
	I.icon+=rgb(blastR,blastG,blastB)
	overlayList+=I
	overlaychanged=1
	spawn
		sleep(10)
		while(beaming) sleep(1)
		overlayList-=I
		overlaychanged=1
		if(I) del(I)

// Various Custom Attack Window functions
// --------------------------------------

mob/proc/CustomAttackWindow(var/datum/skill/CustomAttack/S, var/windowtype)
	winshow(usr, "CreateAttackWindow",1)
	contents += new/obj/CreateAttackWindow
	CurrentEditedSkill = S
	GenerateCustomAttackStats(S)
	if (windowtype == 0)
		InitializeCreate()
	if (windowtype == 1)
		InitializeCustomize()
	UpdateCustomAttack(S)




datum/proc/GenerateCustomAttackStats(var/datum/skill/CustomAttack/S)
	S.customattack_base_damage = S.base_damage
	S.customattack_minimum_chargetime = S.minimum_chargetime
	S.customattack_ki_cost = S.ki_cost
	S.customattack_stamina_cost = S.stamina_cost
	S.customattack_use_stamina = S.use_stamina
	S.customattack_chargeattack = S.chargeattack
	S.customattack_dochargeshout = S.dochargeshout
	S.customattack_doshout = S.doshout
	S.customattack_usechargeaura = S.usechargeaura
	S.customattack_useattackaura = S.useattackaura
	S.customattack_speed = S.speed
	S.customattack_range = S.range
	S.customattack_rangemodifier = S.rangemodifier
	S.customattack_instantattack = S.instantattack
	S.customattack_shout = S.shout
	S.customattack_chargeshout = S.chargeshout
	S.customattack_name = S.name
	S.customattack_attackicon = S.attackicon
	S.customattack_chargeaura = S.chargeaura
	S.customattack_attackaura = S.attackaura
	S.customattack_chargeicon = S.chargeicon
	S.customattack_desc = S.desc
	S.customattack_total_custompoints = S.total_custompoints
	S.customattack_custompoints_spent = S.custompoints_spent
	S.customattack_custompoints_left = (S.total_custompoints) - (S.custompoints_spent)
	winset(usr, "CreateAttackWindow.attacknameinput", "text=\"[S.customattack_name]\"")
	winset(usr, "CreateAttackWindow.attackdescriptiontext", "text=\"[S.customattack_desc]\"")
	winset(usr, "CreateAttackWindow.beforeattacktext", "text=\"[S.customattack_chargeshout]\"")
	winset(usr, "CreateAttackWindow.afterattacktext", "text=\"[S.customattack_shout]\"")
	if (S.customattack_chargeattack == 1)
		winset(usr, "CreateAttackWindow.chargeattackcheckbox", "is-checked=true")
	else
		winset(usr, "CreateAttackWindow.chargeattackcheckbox", "is-checked=false")
	if (S.customattack_use_stamina == 1)
		winset(usr, "CreateAttackWindow.usestaminacheckbox", "is-checked=true")
	else
		winset(usr, "CreateAttackWindow.usestaminacheckbox", "is-checked=false")
	if (S.customattack_usechargeaura == 1)
		winset(usr, "CreateAttackWindow.chargeauraoverlaycheckbox", "is-checked=true")
	else
		winset(usr, "CreateAttackWindow.chargeauraoverlaycheckbox", "is-checked=false")
	if (S.customattack_useattackaura == 1)
		winset(usr, "CreateAttackWindow.attackauraoverlaycheckbox", "is-checked=true")
	else
		winset(usr, "CreateAttackWindow.attackauraoverlaycheckbox", "is-checked=false")
	if (S.customattack_dochargeshout == 1)
		winset(usr, "CreateAttackWindow.shoutbeforecheckbox", "is-checked=true")
	else
		winset(usr, "CreateAttackWindow.shoutbeforecheckbox", "is-checked=false")
	if (S.customattack_doshout == 1)
		winset(usr, "CreateAttackWindow.shoutaftercheckbox", "is-checked=true")
	else
		winset(usr, "CreateAttackWindow.shoutaftercheckbox", "is-checked=false")

datum/proc/UpdateCustomAttack(var/datum/skill/CustomAttack/S)
	S.customattack_custompoints_left = round((S.customattack_total_custompoints) - (S.customattack_custompoints_spent),1)
	winset(usr, "CreateAttackWindow.baseattackpowerdisplay", "text=\"[S.customattack_base_damage]\"")
	winset(usr, "CreateAttackWindow.chargetimedisplay", "text=\"[S.customattack_minimum_chargetime]\"")
	winset(usr, "CreateAttackWindow.kicostdisplay", "text=\"[S.customattack_ki_cost]\"")
	winset(usr, "CreateAttackWindow.staminacostdisplay", "text=\"[S.customattack_stamina_cost]\"")
	winset(usr, "CreateAttackWindow.speeddisplay", "text=\"[S.customattack_speed]\"")
	if (S.customattack_chargeattack == 1)
		winset(usr, "CreateAttackWindow.chargetimeplus", "is-disabled=false")
		winset(usr, "CreateAttackWindow.chargetimeminus", "is-disabled=false")
		winset(usr, "CreateAttackWindow.chargeauraoverlaycheckbox", "is-disabled=false")
		winset(usr, "CreateAttackWindow.chargeiconbtn", "is-disabled=false")
	else
		winset(usr, "CreateAttackWindow.chargetimeplus", "is-disabled=true")
		winset(usr, "CreateAttackWindow.chargetimeminus", "is-disabled=true")
		winset(usr, "CreateAttackWindow.chargeauraoverlaycheckbox", "is-disabled=true")
		winset(usr, "CreateAttackWindow.chargeiconbtn", "is-disabled=true")
		S.customattack_usechargeaura = 0

	if (S.customattack_use_stamina == 1)
		winset(usr, "CreateAttackWindow.staminacostminus", "is-disabled=false")
		winset(usr, "CreateAttackWindow.staminacostplus", "is-disabled=false")
	else
		winset(usr, "CreateAttackWindow.staminacostplus", "is-disabled=true")
		winset(usr, "CreateAttackWindow.staminacostminus", "is-disabled=true")

	if (S.customattack_dochargeshout == 1)
		winset(usr, "CreateAttackWindow.beforeattacktext", "is-disabled=false")
	else
		winset(usr, "CreateAttackWindow.beforeattacktext", "is-disabled=true")

	if (S.customattack_doshout == 1)
		winset(usr, "CreateAttackWindow.afterattacktext", "is-disabled=false")
	else
		winset(usr, "CreateAttackWindow.afterattacktext", "is-disabled=true")

	if (S.customattack_usechargeaura == 1 || S.customattack_useattackaura == 1)
		winset(usr, "CreateAttackWindow.auraoverlaybtn", "is-disabled=false")
	else
		winset(usr, "CreateAttackWindow.auraoverlaybtn", "is-disabled=true")

	// Beam modifier updater
	if (S.attacktype == 0)
		var/count = 0
		var/list/current_beam_modifiers = list()
		winset(usr,"CreateAttackWindow.customattackmodifiergrid","cells=0")

		if (S.customattack_instantattack == 1)
			var/obj/CreateAttackWindow/DummyModifier/X = new /obj/CreateAttackWindow/DummyModifier
			X.name = "Instant Attack"
			current_beam_modifiers.Add(X)

		if (S.customattack_range != 20)
			var/obj/CreateAttackWindow/DummyModifier/X = new /obj/CreateAttackWindow/DummyModifier
			X.name = "Maximum Range: [S.customattack_range]"
			current_beam_modifiers.Add(X)

		if (S.customattack_rangemodifier != 1)
			var/obj/CreateAttackWindow/DummyModifier/X = new /obj/CreateAttackWindow/DummyModifier
			X.name = "Distance Modifier: [S.customattack_rangemodifier]"
			current_beam_modifiers.Add(X)

		for (var/obj/CreateAttackWindow/DummyModifier/X in current_beam_modifiers)
			++count
			usr<<output(X,"CreateAttackWindow.customattackmodifiergrid:[count]")



	winset(usr, "CreateAttackWindow.custompointsdisplay", "text=\"[S.customattack_custompoints_left]\"")


mob/proc/InitializeCreate()
	winset(usr, "CreateAttackWindow.attacktypebtn", "is-disabled=false")
	winset(usr, "CreateAttackWindow.attacktypebtn", "text=\"Select Attack Type\"")
	winset(usr, "CreateAttackWindow.attacknameinput", "is-disabled=true")
	winset(usr, "CreateAttackWindow.baseattackpowerplus", "is-disabled=true")
	winset(usr, "CreateAttackWindow.baseattackpowerminus", "is-disabled=true")
	winset(usr, "CreateAttackWindow.chargetimeplus", "is-disabled=true")
	winset(usr, "CreateAttackWindow.chargetimeminus", "is-disabled=true")
	winset(usr, "CreateAttackWindow.kicostplus", "is-disabled=true")
	winset(usr, "CreateAttackWindow.kicostminus", "is-disabled=true")
	winset(usr, "CreateAttackWindow.staminacostplus", "is-disabled=true")
	winset(usr, "CreateAttackWindow.staminacostminus", "is-disabled=true")
	winset(usr, "CreateAttackWindow.speedplus", "is-disabled=true")
	winset(usr, "CreateAttackWindow.speedminus", "is-disabled=true")
	winset(usr, "CreateAttackWindow.chargeattackcheckbox", "is-disabled=true")
	winset(usr, "CreateAttackWindow.usestaminacheckbox", "is-disabled=true")
	winset(usr, "CreateAttackWindow.addmodifierbtn", "is-disabled=true")
	winset(usr, "CreateAttackWindow.attackdescriptiontext", "is-disabled=true")
	winset(usr, "CreateAttackWindow.beforeattacktext", "is-disabled=true")
	winset(usr, "CreateAttackWindow.afterattacktext", "is-disabled=true")
	winset(usr, "CreateAttackWindow.chargeauraoverlaycheckbox", "is-disabled=true")
	winset(usr, "CreateAttackWindow.attackauraoverlaycheckbox", "is-disabled=true")
	winset(usr, "CreateAttackWindow.shoutbeforecheckbox", "is-disabled=true")
	winset(usr, "CreateAttackWindow.shoutaftercheckbox", "is-disabled=true")
	winset(usr, "CreateAttackWindow.chargeiconbtn", "is-disabled=true")
	winset(usr, "CreateAttackWindow.attackiconbtn", "is-disabled=true")
	winset(usr, "CreateAttackWindow.auraoverlaybtn", "is-disabled=true")
	winset(usr, "CreateAttackWindow.createbtn", "is-disabled=true")
	winset(usr, "CreateAttackWindow.createbtn", "text=\"Create\"")


mob/proc/InitializeCustomize()
	winset(usr, "CreateAttackWindow.createbtn", "text=\"Done\"")
	winset(usr, "CreateAttackWindow.attacktypebtn", "is-disabled=true")
	if (CurrentEditedSkill.attacktype == 0)
		winset(usr, "CreateAttackWindow.attacktypebtn", "text=\"Beam\"")
		InitBeam()
	if (CurrentEditedSkill.attacktype == 1)
		winset(usr, "CreateAttackWindow.attacktypebtn", "text=\"Blast\"")
		InitBlast()
	if (CurrentEditedSkill.attacktype == 2)
		winset(usr, "CreateAttackWindow.attacktypebtn", "text=\"Guided\"")
		InitGuided()
	if (CurrentEditedSkill.attacktype == 3)
		winset(usr, "CreateAttackWindow.attacktypebtn", "text=\"Melee\"")
		InitMelee()
	FullInit()

datum/proc/InitBeam()
	winset(usr, "CreateAttackWindow.chargeattackcheckbox", "is-disabled=true")
	winset(usr, "CreateAttackWindow.attackiconbtn", "text=\"Select Beam Icon\"")
	winset(usr, "CreateAttackWindow.speedlabel", "text=\"Beam Speed\"")

datum/proc/InitBlast()
	winset(usr, "CreateAttackWindow.chargeattackcheckbox", "is-disabled=false")
	winset(usr, "CreateAttackWindow.attackiconbtn", "text=\"Select Blast Icon\"")
	winset(usr, "CreateAttackWindow.speedlabel", "text=\"Blast Speed\"")

datum/proc/InitGuided()
	winset(usr, "CreateAttackWindow.chargeattackcheckbox", "is-disabled=false")
	winset(usr, "CreateAttackWindow.attackiconbtn", "text=\"Select Ball Icon\"")
	winset(usr, "CreateAttackWindow.speedlabel", "text=\"Ball Speed\"")

datum/proc/InitMelee()
	winset(usr, "CreateAttackWindow.chargeattackcheckbox", "is-disabled=false")
	winset(usr, "CreateAttackWindow.attackiconbtn", "text=\"Attack Effect\"")
	winset(usr, "CreateAttackWindow.speedlabel", "text=\"Attack Speed\"")

datum/proc/FullInit()
	winset(usr, "CreateAttackWindow.attacknameinput", "is-disabled=false")
	winset(usr, "CreateAttackWindow.baseattackpowerplus", "is-disabled=false")
	winset(usr, "CreateAttackWindow.baseattackpowerminus", "is-disabled=false")
	if (CurrentEditedSkill.attacktype == 0)
		winset(usr, "CreateAttackWindow.chargetimeplus", "is-disabled=false")
		winset(usr, "CreateAttackWindow.chargetimeminus", "is-disabled=false")
		winset(usr, "CreateAttackWindow.chargeiconbtn", "is-disabled=false")
		winset(usr, "CreateAttackWindow.chargeauraoverlaycheckbox", "is-disabled=false")
	else
		winset(usr, "CreateAttackWindow.chargetimeplus", "is-disabled=true")
		winset(usr, "CreateAttackWindow.chargetimeminus", "is-disabled=true")
		winset(usr, "CreateAttackWindow.chargeiconbtn", "is-disabled=true")
		winset(usr, "CreateAttackWindow.chargeauraoverlaycheckbox", "is-disabled=true")
	winset(usr, "CreateAttackWindow.kicostminus", "is-disabled=false")
	winset(usr, "CreateAttackWindow.kicostplus", "is-disabled=false")
	winset(usr, "CreateAttackWindow.usestaminacheckbox", "is-disabled=false")
	winset(usr, "CreateAttackWindow.speedminus", "is-disabled=false")
	winset(usr, "CreateAttackWindow.speedplus", "is-disabled=false")
	winset(usr, "CreateAttackWindow.attackdescriptiontext", "is-disabled=false")
	winset(usr, "CreateAttackWindow.attackauraoverlaycheckbox", "is-disabled=false")
	winset(usr, "CreateAttackWindow.shoutbeforecheckbox", "is-disabled=false")
	winset(usr, "CreateAttackWindow.shoutaftercheckbox", "is-disabled=false")
	winset(usr, "CreateAttackWindow.createbtn", "is-disabled=false")
	winset(usr, "CreateAttackWindow.addmodifierbtn", "is-disabled=false")
	if (CurrentEditedSkill.useattackaura == 1 || CurrentEditedSkill.usechargeaura == 1)
		winset(usr, "CreateAttackWindow.auraoverlaybtn", "is-disabled=false")
	else
		winset(usr, "CreateAttackWindow.auraoverlaybtn", "is-disabled=true")
	if (CurrentEditedSkill.attacktype == 3)
		winset(usr, "CreateAttackWindow.attackiconbtn", "is-disabled=true")
	else
		winset(usr, "CreateAttackWindow.attackiconbtn", "is-disabled=false")

mob/proc/CloseCustomWindowProc()
	verbs -= typesof(/obj/CreateAttackWindow/verb)
	winshow(usr, "CreateAttackWindow",0)




// Custom Attack Window buttons
// ----------------------------

obj/CreateAttackWindow/verb
	PickAttackType()
		set hidden = 1
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		if (customWindowOpen == 1) return
		customWindowOpen = 1
		var/list/attacktype= list()
		attacktype.Add("Beam")
		//attacktype.Add("Blast")
		//attacktype.Add("Guided")
		//attacktype.Add("Melee")
		attacktype.Add("Cancel")
		var/Choice=input("Choose Your Attack Type")as null|anything in attacktype
		if(Choice=="Cancel"|isnull(Choice))
			customWindowOpen = 0
			return
		if(Choice=="Beam")
			S.attacktype = 0
			S.chargeattack = 1
			winset(usr, "CreateAttackWindow.attacktypebtn", "text=\"Beam\"")
			InitBeam()
			FullInit()
			GenerateCustomAttackStats(S)
			UpdateCustomAttack(S)
			customWindowOpen = 0
			return
		if(Choice=="Blast")
			S.attacktype = 1
			S.chargeattack = 0
			winset(usr, "CreateAttackWindow.attacktypebtn", "text=\"Blast\"")
			InitBlast()
			FullInit()
			GenerateCustomAttackStats(S)
			UpdateCustomAttack(S)
			customWindowOpen = 0
			return
		if(Choice=="Guided")
			S.attacktype = 2
			S.chargeattack = 0
			winset(usr, "CreateAttackWindow.attacktypebtn", "text=\"Guided\"")
			InitGuided()
			FullInit()
			GenerateCustomAttackStats(S)
			UpdateCustomAttack(S)
			customWindowOpen = 0
			return
		if(Choice=="Melee")
			S.attacktype = 3
			S.chargeattack = 0
			winset(usr, "CreateAttackWindow.attacktypebtn", "text=\"Melee\"")
			InitMelee()
			FullInit()
			GenerateCustomAttackStats(S)
			UpdateCustomAttack(S)
			customWindowOpen = 0
			return

	CloseCustomWindow()
		set hidden = 1
		usr.CloseCustomWindowProc()

	ChargeAttackCheckmark()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		var/chargeistrue = winget(usr, "CreateAttackWindow.chargeattackcheckbox", "is-checked")
		var/refund_difference = ((S.customattack_minimum_chargetime) - (1))*(2.5)
		if (chargeistrue == "true")
			S.customattack_chargeattack = 1
			S.customattack_custompoints_spent += -1
			UpdateCustomAttack(S)
		else if (chargeistrue == "false" && (refund_difference + S.customattack_custompoints_spent <= S.customattack_total_custompoints))
			S.customattack_chargeattack = 0
			S.customattack_custompoints_spent += (refund_difference) + 1
			S.customattack_minimum_chargetime = 1
			UpdateCustomAttack(S)
		else
			usr << "You don't have enough points to do this!"
			winset(usr, "CreateAttackWindow.chargeattackcheckbox", "is-checked=true")
			return

	ChargeAttackPlus()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		S.customattack_minimum_chargetime += 0.4
		S.customattack_custompoints_spent -= 1
		UpdateCustomAttack(S)

	ChargeAttackMinus()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		if ((S.customattack_custompoints_spent + 1 <= S.customattack_total_custompoints) && (S.customattack_minimum_chargetime - 0.4 >= 0.2))
			S.customattack_minimum_chargetime -= 0.4
			S.customattack_custompoints_spent += 1
			UpdateCustomAttack(S)
		else if (!(S.customattack_custompoints_spent + 1 <= S.customattack_total_custompoints))
			usr << "You don't have enough points to do this!"
			return
		else if (S.customattack_minimum_chargetime - 0.4 < 0.2)
			usr << "You cannot lower your charge time any further!"
			return

	AttackPowerPlus()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		if (S.customattack_custompoints_spent + 1 <= S.customattack_total_custompoints)
			S.customattack_base_damage += 0.1
			S.customattack_custompoints_spent += 1
			UpdateCustomAttack(S)
		else if (!(S.customattack_custompoints_spent + 1 <= S.customattack_total_custompoints))
			usr << "You don't have enough points to do this!"
			return

	AttackPowerMinus()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		if ((S.customattack_base_damage - 0.1 >= 0.1))
			S.customattack_base_damage -= 0.1
			S.customattack_custompoints_spent -= 1
			UpdateCustomAttack(S)
		else if ((S.customattack_base_damage - 0.1 < 0.1))
			usr << "You cannot lower your attack power any further!"
			return

	KiCostPlus()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		S.customattack_ki_cost += 40
		S.customattack_custompoints_spent -= 1
		UpdateCustomAttack(S)

	KiCostMinus()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		if ((S.customattack_custompoints_spent + 1 <= S.customattack_total_custompoints) && (S.customattack_ki_cost - 40 >= 20))
			S.customattack_ki_cost -= 40
			S.customattack_custompoints_spent += 1
			UpdateCustomAttack(S)
		else if (!(S.customattack_custompoints_spent + 1 <= S.customattack_total_custompoints))
			usr << "You don't have enough points to do this!"
			return
		else if ((S.customattack_ki_cost - 40 < 20))
			usr << "You cannot lower your ki cost any further!"
			return

	UseStaminaCheckmark()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		var/staminaistrue = winget(usr, "CreateAttackWindow.usestaminacheckbox", "is-checked")
		var/refund_difference = ((S.customattack_stamina_cost) - (1))
		if (staminaistrue == "true")
			S.customattack_use_stamina = 1
			S.customattack_custompoints_spent += -2
			S.customattack_stamina_cost = 1
			UpdateCustomAttack(S)
		else if (staminaistrue == "false" && (refund_difference + S.customattack_custompoints_spent <= S.customattack_total_custompoints))
			S.customattack_use_stamina = 0
			S.customattack_custompoints_spent += (refund_difference) + 2
			S.customattack_stamina_cost = 0
			UpdateCustomAttack(S)
		else
			usr << "You don't have enough points to do this!"
			winset(usr, "CreateAttackWindow.usestaminacheckbox", "is-checked=true")
			return

	StaminaPlus()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		S.customattack_stamina_cost += 1
		S.customattack_custompoints_spent -= 1
		UpdateCustomAttack(S)

	StaminaMinus()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		if ((S.customattack_custompoints_spent + 1 <= S.customattack_total_custompoints) && (S.customattack_stamina_cost - 1 >= 1))
			S.customattack_stamina_cost -= 1
			S.customattack_custompoints_spent += 1
			UpdateCustomAttack(S)
		else if (!(S.customattack_custompoints_spent + 1 <= S.customattack_total_custompoints))
			usr << "You don't have enough points to do this!"
			return
		else if (S.customattack_stamina_cost - 1 < 1)
			usr << "You cannot lower your stamina cost any further!"
			return

	SpeedPlus()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		if (S.customattack_speed >= 1)
			if (S.customattack_custompoints_spent + 1 <= S.customattack_total_custompoints && S.customattack_speed + 1 <= 5)
				S.customattack_speed += 1
				S.customattack_custompoints_spent += 1
				UpdateCustomAttack(S)
			else if (!(S.customattack_custompoints_spent + 1 <= S.customattack_total_custompoints))
				usr << "You don't have enough points to do this!"
				return
			else if (S.customattack_speed + 1 > 5)
				usr << "Your speed cannot be greater than five!"
		else
			S.customattack_speed += 0.2
			S.customattack_custompoints_spent += 1
			UpdateCustomAttack(S)

	SpeedMinus()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		if (S.customattack_speed <= 1)
			if ((S.customattack_speed - 0.2 >= 0.2))
				S.customattack_speed -= 0.2
				S.customattack_custompoints_spent -= 1
				UpdateCustomAttack(S)
			else if ((S.customattack_speed - 0.2 < 0.2))
				usr << "You cannot lower your speed any further!"
				return
		else
			S.customattack_speed -= 1
			S.customattack_custompoints_spent -= 1
			UpdateCustomAttack(S)

	ShoutBeforeCheckbox()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		var/shoutbeforeistrue = winget(usr, "CreateAttackWindow.shoutbeforecheckbox", "is-checked")
		if (shoutbeforeistrue == "true")
			S.customattack_dochargeshout = 1
			UpdateCustomAttack(S)
		else
			S.customattack_dochargeshout = 0
			UpdateCustomAttack(S)

	ShoutAfterCheckbox()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		var/shoutbeforeistrue = winget(usr, "CreateAttackWindow.shoutaftercheckbox", "is-checked")
		if (shoutbeforeistrue == "true")
			S.customattack_doshout = 1
			UpdateCustomAttack(S)
		else
			S.customattack_doshout = 0
			UpdateCustomAttack(S)

	ChargeAuraCheckbox()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		var/chargeauraistrue = winget(usr, "CreateAttackWindow.chargeauraoverlaycheckbox", "is-checked")
		if (chargeauraistrue == "true")
			S.customattack_usechargeaura = 1
			UpdateCustomAttack(S)
		else
			S.customattack_usechargeaura = 0
			UpdateCustomAttack(S)

	AttackAuraCheckbox()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		var/attackauraistrue = winget(usr, "CreateAttackWindow.attackauraoverlaycheckbox", "is-checked")
		if (attackauraistrue == "true")
			S.customattack_useattackaura = 1
			UpdateCustomAttack(S)
		else
			S.customattack_useattackaura = 0
			UpdateCustomAttack(S)

	ChargeIcon()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		var/Choice=alert("Do you want to change your charge icon?","","Yes","No","Default")
		switch(Choice)
			if("Yes")
				S.customattack_chargeicon = input(usr,"Select your icon.","",null) as null|icon
			if("No")
				return
			if("Default")
				S.customattack_chargeicon = null

	AttackIcon()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		var/Choice=alert("Do you want to change your attack icon?","","Yes","No","Default")
		switch(Choice)
			if("Yes")
				S.customattack_attackicon = input(usr,"Select your icon.","",null) as null|icon
			if("No")
				return
			if("Default")
				S.customattack_attackicon = null

	AuraIcon()
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		set hidden = 1
		var/Choice=alert("Do you want to change your auras?","","Yes","No")
		switch(Choice)
			if("Yes")
				//S.customattack_attackicon = input(usr,"Select your icon.","",null) as null|icon
				if (S.customattack_useattackaura == 1 && S.customattack_usechargeaura == 1)
					var/list/auralist = list()
					auralist.Add("Attack")
					auralist.Add("Charge")
					auralist.Add("Default Attack")
					auralist.Add("Default Charge")
					auralist.Add("Cancel")
					var/auratypeChoice=input("Do you wish to change your attack or charge aura?")as null|anything in auralist
					switch(auratypeChoice)
						if ("Attack")
							S.customattack_attackaura = input(usr,"Select your icon.","",null) as null|icon
						if ("Charge")
							S.customattack_chargeaura = input(usr,"Select your icon.","",null) as null|icon
						if ("Default Attack")
							S.customattack_attackaura = null
						if ("Default Charge")
							S.customattack_chargeaura = null
						if ("Cancel")
							return
				else if (S.customattack_useattackaura == 1)
					var/auratypeChoice=alert("Do you wish to change your attack aura?","","Yes", "Default", "Cancel")
					switch(auratypeChoice)
						if ("Yes")
							S.customattack_attackaura = input(usr,"Select your icon.","",null) as null|icon
						if ("Default")
							S.customattack_attackaura = null
						if ("Cancel")
							return
				else if (S.customattack_usechargeaura == 1)
					var/auratypeChoice=alert("Do you wish to change your charge aura?","","Yes", "Default", "Cancel")
					switch(auratypeChoice)
						if ("Yes")
							S.customattack_chargeaura = input(usr,"Select your icon.","",null) as null|icon
						if ("Default")
							S.customattack_chargeaura = null
						if ("Cancel")
							return

			if("No")
				return


	CreateCustomSkill()
		set hidden = 1
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		var/AreYouSure
		if (S.created == 0)
			AreYouSure = alert("Are you sure you're finished?  You cannot edit attack types after completion!", "", "Yes", "No")
		if (S.created == 1)
			AreYouSure = alert("Are you sure you're finished?  This will finalaze all changes made!", "", "Yes", "No")

		switch (AreYouSure)
			if ("Yes")
				S.base_damage = S.customattack_base_damage
				S.minimum_chargetime = S.customattack_minimum_chargetime
				S.ki_cost = S.customattack_ki_cost
				S.stamina_cost = S.customattack_stamina_cost
				S.use_stamina = S.customattack_use_stamina
				S.chargeattack = S.customattack_chargeattack
				S.dochargeshout = S.customattack_dochargeshout
				S.doshout = S.customattack_doshout
				S.usechargeaura = S.customattack_usechargeaura
				S.useattackaura = S.customattack_useattackaura
				S.speed = S.customattack_speed
				S.range = S.customattack_range
				S.rangemodifier = S.customattack_rangemodifier
				S.instantattack = S.customattack_instantattack
				S.attackicon = S.customattack_attackicon
				S.chargeaura = S.customattack_chargeaura
				S.attackaura = S.customattack_attackaura
				S.chargeicon = S.customattack_chargeicon
				S.custompoints_spent = S.customattack_custompoints_spent

				S.name = winget(usr, "CreateAttackWindow.attacknameinput", "text")
				S.desc = winget(usr, "CreateAttackWindow.attackdescriptiontext", "text")
				S.shout = winget(usr, "CreateAttackWindow.afterattacktext", "text")
				S.chargeshout = winget(usr, "CreateAttackWindow.beforeattacktext", "text")


				if (S.created == 0)
					usr.customattacks.Add(S)
					usr.learned_skills.Add(S)
					S.savant = usr
					S.level = 0
					S.after_learn()
					S.created = 1
					winshow(usr, "CreateAttackWindow",0)
				else
					for (var/V in usr.verbs)
						if (S.id == 1 && "[V]" == "/mob/keyable/verb/Custom_Attack1")
							usr.Keyableverbs -= V
							usr.verbs -= V
							S.after_learn()
							break
						if (S.id == 2 && "[V]" == "/mob/keyable/verb/Custom_Attack2")
							usr.Keyableverbs -= V
							usr.verbs -= V
							S.after_learn()
							break
						if (S.id == 3 && "[V]" == "/mob/keyable/verb/Custom_Attack3")
							usr.Keyableverbs -= V
							usr.verbs -= V
							S.after_learn()
							break
						if (S.id == 4 && "[V]" == "/mob/keyable/verb/Custom_Attack4")
							usr.Keyableverbs -= V
							usr.verbs -= V
							S.after_learn()
							break
						if (S.id == 5 && "[V]" == "/mob/keyable/verb/Custom_Attack5")
							usr.Keyableverbs -= V
							usr.verbs -= V
							S.after_learn()
							break
						if (S.id == 6 && "[V]" == "/mob/keyable/verb/Custom_Attack6")
							usr.Keyableverbs -= V
							usr.verbs -= V
							S.after_learn()
							break
						if (S.id == 7 && "[V]" == "/mob/keyable/verb/Custom_Attack7")
							usr.Keyableverbs -= V
							usr.verbs -= V
							S.after_learn()
							break
						if (S.id == 8 && "[V]" == "/mob/keyable/verb/Custom_Attack8")
							usr.Keyableverbs -= V
							usr.verbs -= V
							S.after_learn()
							break
						if (S.id == 9 && "[V]" == "/mob/keyable/verb/Custom_Attack9")
							usr.Keyableverbs -= V
							usr.verbs -= V
							S.after_learn()
							break
						if (S.id == 10 && "[V]" == "/mob/keyable/verb/Custom_Attack10")
							usr.Keyableverbs -= V
							usr.verbs -= V
							S.after_learn()
							break
					winshow(usr, "CreateAttackWindow",0)
					return

			if ("No")
				return
	AddModifiers()
		set hidden = 1
		var/datum/skill/CustomAttack/S = CurrentEditedSkill
		// If attack type is a beam, choose a beam attack modifier
		if (S.attacktype == 0)
			beam_modifiers.Add("Instant Attack")
			beam_modifiers.Add("Change Maximum Range")
			beam_modifiers.Add("Distance Modifier")
			beam_modifiers.Add("Cancel")
			modifierchoicelbl:
			var/ModifierChoice=input("Select a modifier.")as null|anything in beam_modifiers
			switch(ModifierChoice)
				if ("Instant Attack")
					if (S.customattack_instantattack == 0)
						var/AreYouSure = alert("This modifier makes it so that beams are fired the second they are finished charging.  Combined with a short charge time, this could make an excellent suprise attack.  Costs 2 Points.  Add?", "", "Yes", "No")
						switch(AreYouSure)
							if ("Yes")
								if (S.customattack_custompoints_spent + 2 <= S.customattack_total_custompoints)
									S.customattack_instantattack = 1
									S.customattack_custompoints_spent += 2
									UpdateCustomAttack(S)
									return
								else
									alert("You don't have enough points to add this!", "", "Ok")
									goto modifierchoicelbl
							if ("No")
								goto modifierchoicelbl
					else
						var/AreYouSure = alert("This modifier makes it so that beams are fired the second they are finished charging.  Combined with a short charge time, this could make an excellent suprise attack.  Costs 2 Points.  Remove?", "", "Yes", "No")
						switch(AreYouSure)
							if ("Yes")
								S.customattack_instantattack = 0
								S.customattack_custompoints_spent -= 2
								UpdateCustomAttack(S)
								return
							if ("No")
								goto modifierchoicelbl
				if ("Change Maximum Range")
					var/AreYouSure = alert("This modifier changes the overall range of your beam.  -/+ 1 point per gained or lost range.  Your current range is [S.customattack_range].  Choosing default will remove the modifier.  Change?", "", "Yes", "No", "Default")
					switch(AreYouSure)
						if ("Yes")
							customrangeinput:
							var/amount = input("Enter Desired Range (Default is 20)", "", S.customattack_range) as num
							amount = round(amount)
							var/custompointadder = round((amount - S.customattack_range))
							if ((custompointadder + S.customattack_custompoints_spent <= S.customattack_total_custompoints) && amount >= 5)
								S.customattack_custompoints_spent += custompointadder
								S.customattack_range = amount
								UpdateCustomAttack(S)
								return
							else if (amount < 5)
								alert("You can't set your range that low (miniumum range of 5)!", "", "Ok")
								goto customrangeinput
							else
								alert("You don't have enough points to add that much range!", "", "Ok")
								goto modifierchoicelbl
						if ("No")
							goto modifierchoicelbl
						if ("Default")
							var/defaultpointadder = round(S.customattack_range - 20)
							if (S.customattack_custompoints_spent - defaultpointadder <= S.customattack_total_custompoints)
								S.customattack_custompoints_spent -= defaultpointadder
								S.customattack_range = 20
								UpdateCustomAttack(S)
								return
							else
								alert("You don't have enough points to reset your range!", "", "Ok")
								goto modifierchoicelbl
				if ("Distance Modifier")
					var/AreYouSure = alert("This modifier will either increase or decrease your beams power the further it travels. Costs 2 points in either direction.  Your current range modifier is [S.customattack_rangemodifier]  Change?", "", "Yes", "No", "Default")
					switch(AreYouSure)
						if ("Yes")
							customrangemodinput:
							var/amount = input("Enter Desired Modifier (Default is 1)", "", S.customattack_rangemodifier) as num
							amount = round(amount, 0.1)
							var/custompointadder = round((amount - S.customattack_rangemodifier)*10)
							if ((custompointadder + S.customattack_custompoints_spent <= S.customattack_total_custompoints) && amount >= 0.5)
								S.customattack_custompoints_spent += custompointadder
								S.customattack_rangemodifier = amount
								UpdateCustomAttack(S)
								return
							else if (amount < 0.5)
								alert("You can't set your range modifier that low (minimum of 0.5)!", "", "Ok")
								goto customrangemodinput
							else
								alert("You don't have enough points to add that much range!", "", "Ok")
								goto modifierchoicelbl
						if ("No")
							goto modifierchoicelbl
						if ("Default")
							var/defaultpointadder = round((S.customattack_rangemodifier - 1)*10)
							if (S.customattack_custompoints_spent - defaultpointadder <= S.customattack_total_custompoints)
								S.customattack_custompoints_spent -= defaultpointadder
								S.customattack_rangemodifier = 1
								UpdateCustomAttack(S)
								return
							else
								alert("You don't have enough points to reset your range!", "", "Ok")
								goto modifierchoicelbl

obj/CreateAttackWindow/DummyModifier
	var/datum/skill/CustomAttack/S = null
	var/modifier_amt
	//Click()



// Legacy Crap
// -----------
//obj/skill
	// IsntAItem=1
// /obj/skill/CustomAttacks
// some things now have new definitions
	// var/mob/savant = null
	// var/usecost = 1 //how much it takes to use this thing (in Ki)
	// var/CustomizationPoints = 5 //Attacks have a set number of customization points you can use to make them good. Preset attacks do not have this luxury.
	// var/attacktype //used to figure out what happens when the thing is used (do you punch super faasst? or is it a beam?)
	// var/firetype //used to figure out what type of thing happens when the thing is used. (blast spreading, etc.)
	// var/attackname = "HAAAAAAAAAA!" //what you say out loud.
	// var/firesound = 'fire_kiblast.wav' //sound, if you make a punchy and don't change this, it'll make this sound.
	// var/ChargeSound = 'basicbeam_chargeoriginal.wav' //if you can charge a attack, this is yo sound
	// var/commonsense = TRUE //teachable? can you teach it?
	// var/KiReq=2
	// var/tmp //temp vars
		// firing
		// charging = 0
//also: type definition is probably a bit more important.

// /obj/skill/CustomAttacks/proc/voice(var/S) //you can call this one in fire or whatever. simply a ease-of-use proc
	// if(savant)
		// view(savant)<<output("<font size=[savant.TextSize]><[savant.SayColor]>[savant.name] says, '[html_encode(S)]'","Chatpane.Chat")

// /obj/skill/CustomAttacks/proc/fire(var/mob/savant) //call this one in your verb
	// firing = 1
	// charging = 0
	// ..()

// /obj/skill/CustomAttacks/proc/charge() //and this one
	// charging = 1
	// ..()

// /obj/skill/CustomAttacks/proc/stop() //this one too - also called when player encounters knockback or is KO'd (right now due to uneven knockback implementation its merely on KO)
	// charging = 0
	// firing = 0
	// ..()


// /obj/skill/CustomAttacks/proc/Customize(var/mob/source) //called proc when the player wishes to customize-might be filled with standard shit like Icon, Name, and etc
	// ..()

// /obj/skill/CustomAttacks/proc/Teach(var/mob/target) //called proc when the player wishes to customize-might be filled with standard shit like Icon, Name, and etc
	// ..()

// /obj/skill/CustomAttacks/proc/Update() //called upon login, logout, forget/learn, and customize.
	// ..()

//------ skillpoints handler (what happens when skills take away/add allocated skillpoints

// /obj/skill/CustomAttacks/proc/EnoughPoints(var/cost,var/mob/M)
	// if(CustomizationPoints >= cost)
		// return TRUE

// /obj/skill/CustomAttacks/proc/SubtractPoints(var/cost)
	// CustomizationPoints -= cost

// /obj/skill/CustomAttacks/proc/UndoPoints(var/cost)
	// CustomizationPoints += cost





