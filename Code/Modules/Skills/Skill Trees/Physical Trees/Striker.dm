//skills relating to Offense
/datum/skill/Blow
	skilltype = "Physical Buff"
	name = "Improved Blows"
	desc = "Channel your Ki into your arms, increasing offense. Ki Skill+, Speed+++"
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	maxlevel = 1
	tier = 1
	after_learn()
		savant<<"You start circulating your Ki to your arms."
		savant.kiskillBuff+=0.15
		savant.physoffBuff+=1
	before_forget()
		savant<<"You stop circulating your Ki..."
		savant.kiskillBuff-=0.15
		savant.physoffBuff-=1

//skills relating to Speed
/datum/skill/Power
	skilltype = "Physical Buff"
	name = "Fighting Power"
	desc = "Increase your offense to incredible levels. Furthermore, gain the ability to temporarily expend more Ki into your body to increase your offense further."
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	maxlevel = 1
	prereqs = list(new/datum/skill/Blow)
	tier = 3
	after_learn()
		savant<<"You can now increase your fighting power!"
		savant.physoffBuff+=2
		assignverb(/mob/keyable/verb/Fighting_Power)
	before_forget()
		savant<<"You lose the ability to increase your offense further."
		savant.physoffBuff-=2
		unassignverb(/mob/keyable/verb/Fighting_Power)
	login(mob/logger)
		..()
		assignverb(/mob/keyable/verb/Fighting_Power)
mob/keyable/verb/Fighting_Power()
	set category = "Skills"
	desc = "Increase your fighting power even further beyond!"
	if(!isBuffed(/obj/buff/Fighting_Power)&&!usr.KO)
		usr<<"You start increasing your fighting power!"
		usr.startbuff(/obj/buff/Fighting_Power)
	else if(isBuffed(/obj/buff/Fighting_Power))
		usr<<"You let your power slack."
		usr.stopbuff(/obj/buff/Fighting_Power)

/obj/buff/Fighting_Power
	name = "Fighting Power"
	slot=sBUFF
	Buff()
		..()
		container.emit_Sound('1aura.wav')
		container.initdrain = 5
		container.initbuff = 5
		container.DrainMod*=container.initdrain
		container.Tphysoff+=container.initbuff
		container.buffsBuff= 3
	DeBuff()
		container.DrainMod/=container.initdrain
		container.Tphysoff-=container.initbuff
		container.buffsBuff=1
		..()

/datum/skill/Infinite_Strength
	skilltype = "Physical Buff"
	name = "Infinite Strength"
	desc = "Your physical power is unbound, with no peers. Physical Offense++++"
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	maxlevel = 1
	prereqs = list(new/datum/skill/Power)
	tier = 4
	after_learn()
		savant<<"Your power has reached the endgame."
		savant.physoffBuff+=5
	before_forget()
		savant<<"You stop your strength from increasing further..."
		savant.physoffBuff-=5