//skills relating to Speed
/datum/skill/flow
	skilltype = "Physical Buff"
	name = "Improved Flow"
	desc = "Channel your Ki into your legs, increasing speed. Ki Skill+, Speed+++"
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	maxlevel = 1
	tier = 1
	after_learn()
		savant<<"You start circulating your Ki."
		savant.kiskillBuff+=0.15
		savant.speedBuff+=1
	before_forget()
		savant<<"You stop circulating your Ki."
		savant.kiskillBuff-=0.15
		savant.speedBuff-=1

//skills relating to Speed
/datum/skill/Burst
	skilltype = "Physical Buff"
	name = "Extreme Burst"
	desc = "\"Don't ever slam on the breaks! Life's all about putting everything on the line and going further beyond!\" - Super Meta Senkai. Increase your speed even further, and gain a temporary buff called Speed, which increases your speed and power to insane levels."
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	maxlevel = 1
	prereqs = list(new/datum/skill/flow)
	tier = 3
	after_learn()
		savant<<"You can now burst your speed!"
		savant.kiskillBuff+=0.15
		savant.speedBuff+=2
		assignverb(/mob/keyable/verb/Extreme_Burst)
	before_forget()
		savant<<"You no longer burst it anymore."
		savant.kiskillBuff-=0.15
		savant.speedBuff-=2
		unassignverb(/mob/keyable/verb/Extreme_Burst)
	login(mob/logger)
		..()
		assignverb(/mob/keyable/verb/Extreme_Burst)
mob/keyable/verb/Extreme_Burst()
	set category = "Skills"
	desc = "Burst your speed even further beyond!"
	if(!isBuffed(/obj/buff/Extreme_Burst)&&!usr.KO)
		usr<<"You start bursting your speed!"
		usr.startbuff(/obj/buff/Extreme_Burst)
	else if(isBuffed(/obj/buff/Extreme_Burst))
		usr<<"You let your speed slack."
		usr.stopbuff(/obj/buff/Extreme_Burst)

/obj/buff/Extreme_Burst
	name = "Extreme Burst"
	slot=sBUFF
	Buff()
		..()
		container.emit_Sound('1aura.wav')
		container.initdrain = 5
		container.initbuff = 5
		container.DrainMod*=container.initdrain
		container.Tspeed+=container.initbuff
		container.buffsBuff= 3
	DeBuff()
		container.DrainMod/=container.initdrain
		container.Tspeed-=container.initbuff
		container.buffsBuff= 1
		..()

/datum/skill/Relentless_Strikes
	skilltype = "Physical Buff"
	name = "Relentless Strikes"
	desc = "You've learned to keep the momentum of your strikes, feeding into a endless loop of fury upon a opponent. Speed++++"
	can_forget = TRUE
	common_sense = TRUE
	prereqs = list(new/datum/skill/Burst)
	maxlevel = 1
	tier = 4
	after_learn()
		savant<<"Your speed has reached the endgame."
		savant.speedBuff+=5
	before_forget()
		savant<<"You stop manipulating your momentum..."
		savant.speedBuff-=5