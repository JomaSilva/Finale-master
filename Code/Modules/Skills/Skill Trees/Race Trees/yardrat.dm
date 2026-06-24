/datum/skill/tree/yardrat
	name="Yardrat Racials"
	desc="Given to all Yardrats at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Yardrat")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/shunkanido,new/datum/skill/yardrat/Telespeed,new/datum/skill/yardrat/Light,new/datum/skill/yardrat/Light_Buster)
	treegrow()
		if(savant.pitted==1)
			disableskill(/datum/skill/yardrat/Light)
		if(savant.pitted==2)
			disableskill(/datum/skill/yardrat/Telespeed)
	treeshrink()
		if(savant.pitted==0)
			enableskill(/datum/skill/yardrat/Light)
			enableskill(/datum/skill/yardrat/Telespeed)

/datum/skill/yardrat/Telespeed
	skilltype = "Physical"
	name = "Telespeed"
	desc = "The Instant Transmission movements begin to seep into your own, augmenting your speed even further. Spd++++"
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 1
	tier = 2
	maxlevel = 1
	after_learn()
		savant<<"Your body's speed changes, you start to 'flit' every so often in terms of movement."
		savant.speedBuff += 1
		savant.pitted = 1
	before_forget()
		savant<<"Your body's speed returns to normal."
		savant.speedBuff -= 1
		savant.pitted = 0

/datum/skill/yardrat/Light
	skilltype = "Physical"
	name = "Light"
	desc = "As your body is naturally acclimated to converting from and to Light, the repeated experiences teach you light absorption. Ki Regen increases, along with willpower. Will++++, KiRegen+++, StamGain++, Satiety++"
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 1
	tier = 2
	maxlevel = 1
	after_learn()
		savant<<"Your body begins to take in Light."
		savant.willpowerMod += 1
		savant.kiregenMod += 0.5
		savant.staminagainMod += 0.3
		savant.satiationMod += 0.3
		savant.pitted = 2
	before_forget()
		savant<<"Your body returns to normal."
		savant.willpowerMod -= 1
		savant.kiregenMod -= 0.5
		savant.staminagainMod -= 0.3
		savant.satiationMod -= 0.3
		savant.pitted = 0

mob/var/tmp
	IT=0
mob/var
	list/knowmob=list()
	teleskill=1 //cap at 300, 500 for yardrats.
	canAL=0

/datum/skill/shunkanido
	skilltype = "Ki"
	name = "Instant Transmission"
	desc = "Shiver your body apart and translate it to another place using your target's Ki as a homing beacon.\nAs difficult as it sounds."
	level = 1
	expbarrier = 100
	skillcost = 2
	maxlevel = 1
	teacher = TRUE
	can_forget = TRUE
	common_sense = TRUE

/datum/skill/shunkanido/after_learn()
	savant<<"You feel ready to teleport"
	if(savant.Race=="Yardrat")
		savant<<"You were born for this."
		savant.teleskill=70
	else savant<<"You feel nervous."
	assignverb(/mob/keyable/verb/Instant_Transmission)
/datum/skill/shunkanido/before_forget()
	savant<<"You don't remember how to teleport."
	if(!teacher)savant<<"It's probably for the best."
	savant.teleskill=1
	unassignverb(/mob/keyable/verb/Instant_Transmission)
/datum/skill/shunkanido/login()
	..()
	assignverb(/mob/keyable/verb/Instant_Transmission)

mob/keyable/verb/Instant_Transmission()
	set category="Skills"
	var/kireq=min(MaxKi,MaxKi/(teleskill/100)) //after you eclipe 100 teleskill you start to ramp down costs from all of your energy to as low as 1/3 of it- 1/5 for yardrats.)
	if(!usr.canmove || usr.KO || usr.deathregening || usr.grabParalysis || usr.stagger) return
	if(!usr.KO&&canfight&&!usr.med&&!usr.train&&usr.Planet!="Sealed")
		var/list/Choices=new/list
		var/approved
		var/mob/M
		Choices.Add("Cancel")
		Choices.Add(generateShunkanList())
		var/Selection=input("What ki signature do you want to teleport to?") in Choices
		if(Choices.len==1)
			usr<<"You have no valid targets. Add targets to your Contacts list to teleport to them, or get closer to them."
			return
		if(Selection=="Cancel")return
		for(var/mob/nM in player_list)
			if(nM.name == Selection)
				var/powerratio=nM.expressedBP/src.expressedBP
				var/Selection2=input("Teleport to [nM.name]?\n[nM.name] appears to be [powerratio]x your power.", "", text) in list("Yes", "Cancel")
				if(Selection2=="Yes")
					approved=1
					M=nM
				if(Selection2=="Cancel")
					return
			if(nM.signature == Selection)
				var/powerratio=(nM.expressedBP/src.expressedBP)*(rand(100,1000)/500) //a bit random for unfamiliarity
				var/Selection2=input("Teleport to [nM.signature]?\n[nM.signature] appears to be [powerratio]x your power.", "", text) in list("Yes", "Cancel")
				if(Selection2=="Yes")
					approved=1
					M=nM
				if(Selection2=="Cancel")
					return
			if(approved)
				var/loctest=src.loc
				//usr.canfight=0
				src.move=0
				src<<"You're teleporting, don't move..."
				sleep(max(600/usr.teleskill,15))
				if(src.loc==loctest)
					//src.canfight=1
					src.move=1
					if(src.Race=="Yardrat"&&src.teleskill < 500)
						src.teleskill+=get_dist(src,M)*0.2
						src.teleskill=min(500,src.teleskill)
					else if(src.teleskill < 300)
						src.teleskill+=get_dist(src,M)*0.1
						src.teleskill=min(300,src.teleskill)
					Ki-=kireq*BaseDrain
					src.Ki=max(Ki,0)
					usr<<"You successfully located your target..."
					oview(usr)<<"[usr] disappears in a flash!"
					emit_Sound('Instant_Pop.wav')
					for(var/mob/nnM in oview(1)) if(M.client)
						nnM.loc=M.loc
						nnM<<"[usr] brings you with them using Instant Transmission."
						flick('Zanzoken.dmi',nnM)
					usr.loc=M.loc
					flick('Zanzoken.dmi',src)
					emit_Sound('Instant_Pop.wav')
					view(usr)<<"[usr] appears in an instant!"
					return
				else
					//src.canfight=1
					src.move=1
					src<<"You moved!"
					return
			else return
	else
		src<<"You can't do that right now!"
		return

mob/proc/generateShunkanList()
	var/list/Choices=new/list
	for(var/mob/M in player_list)
		var/distancemod=max(get_dist(M,src),1)/30 //more raw cross-planar distance = harder teles - hope you're ready to G E T COORDINATED
		var/zlevelmod=max(1,abs(src.z-M.z))*2 //more Z's apart = harder teles
		var/skillmod=50/teleskill //higher teleskill = easier teles
		var/familiaritymod=1//makes it easier to teleport to people you know better
		if(M.client)
			var/famili = check_familiarity(M)
			if(famili)
				Choices.Add(M.name)
				if(famili>1)
					familiaritymod=log(10, famili)
				else
					familiaritymod=1
			if(src.BP<=((M.expressedBP*familiaritymod)/(zlevelmod*max(distancemod,0.2)*skillmod)))
				if(M.expressedBP<=(M.BP/3)&&M.name in Choices)
					Choices.Remove(M.name) //weak or concealing
				if((M.Planet=="Hell"||M.Planet=="Afterlife"||M.Planet=="Heaven")&&!canAL&&M.name in Choices)
					Choices.Remove(M.name)//in AL
				if(M.Planet=="Hyperbolic Time Dimension"||M.Planet=="Sealed"&&M.name in Choices)
					Choices.Remove(M.name)//in HBTC
				if(M!=src&&!(M.name in Choices))
					Choices.Add(M.signature)
					familiaritymod=1
			else
				Choices.Remove(M.name)
	return Choices

datum/skill/yardrat/Light_Buster
	skilltype = "Ki"
	name = "Light Buster"
	desc = "Using your lightspeed movement, dash towards a person lightning quick, deal several attacks, then move behind them. To everyone else, it'll look like you just teleported, and then they got hit."
	level = 1
	expbarrier = 100
	skillcost = 2
	maxlevel = 2
	teacher = TRUE
	can_forget = TRUE
	common_sense = TRUE

	after_learn()
		savant<<"You feel ready to MOVE"
		if(savant.Race=="Yardrat")
			savant<<"You were born for this."
		assignverb(/mob/keyable/verb/Light_Buster)
	before_forget()
		savant<<"You don't remember how to teleport."
		unassignverb(/mob/keyable/verb/Light_Buster)
	login()
		..()
		assignverb(/mob/keyable/verb/Light_Buster)
	effector()
		..()
		switch(level)
			if(1)
				if(levelup)
					levelup=0
			if(2)
				if(levelup)
					savant << "Your skill at blitzing people got better..."
					levelup=0

mob/keyable/verb/Light_Buster()
	set category = "Skills"
	sayType("Light Buster!",3)
	sleep(5)
	flick('Zanzoken.dmi',src)
	if(target in view(4))
		var/d = get_dir(target,src)
		Move(get_step(target,d),d)
		doAttack(target,2,0,0,"instantly strikes",0,1)
		doAttack(target,2,0,0,"instantly strikes",0,1)
		doAttack(target,2,0,0,"instantly strikes",0,1)
		doAttack(target,2,0,0,"instantly strikes",0,1)
		Skill_EXP_Add(/datum/skill/yardrat/Light_Buster,1)
	else usr << "Need a target."