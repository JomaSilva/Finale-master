//skills relating to Defense
/datum/skill/stalwart
	skilltype = "Physical Buff"
	name = "Stalwart"
	desc = "Channel your Ki into your body, increasing defense. Ki Skill+, Physical Defense+++"
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	maxlevel = 1
	tier = 1
	after_learn()
		savant<<"You start circulating your Ki."
		savant.kiskillBuff+=0.15
		savant.physdefBuff+=1
	before_forget()
		savant<<"You stop circulating your Ki."
		savant.kiskillBuff-=0.15
		savant.physdefBuff-=1

/datum/skill/Ultradense_Body
	skilltype = "Physical Buff"
	name = "Ultradense Body"
	desc = "ULTRA DENSE BODY. OLD SPICE BOD- Increase your defense even further, and gain a temporary buff called Ultra Dense Body, which increases your defense and power to certifibly insane levels."
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	prereqs = list(new/datum/skill/stalwart)
	maxlevel = 1
	tier = 3
	after_learn()
		savant<<"You start making your body even more dense."
		savant.physdefBuff+=2
		assignverb(/mob/keyable/verb/Ultradense_Body)
	before_forget()
		savant<<"Your body loses its density."
		savant.physdefBuff-=2
		unassignverb(/mob/keyable/verb/Ultradense_Body)
	login(mob/logger)
		..()
		assignverb(/mob/keyable/verb/Ultradense_Body)
mob/keyable/verb/Ultradense_Body()
	set category = "Skills"
	desc = "Make your torso even more dense, increasing your defense even further beyond!"
	if(!isBuffed(/obj/buff/Ultradense_Body)&&!usr.KO)
		usr<<"You turn your body into something like steel!"
		usr.startbuff(/obj/buff/Ultradense_Body)
	else if(isBuffed(/obj/buff/Ultradense_Body))
		usr<<"You let your defense slack."
		usr.stopbuff(/obj/buff/Ultradense_Body)

/obj/buff/Ultradense_Body
	name = "Ultradense Body"
	slot=sBUFF
	Buff()
		..()
		container.emit_Sound('1aura.wav')
		container.initdrain = 5
		container.initbuff = 5
		container.DrainMod*=container.initdrain
		container.Tphysdef+=container.initbuff
		container.buffsBuff= 3
	DeBuff()
		container.DrainMod/=container.initdrain
		container.Tphysdef-=container.initbuff
		container.buffsBuff= 1
		..()

/datum/skill/Atomic_Point
	skilltype = "Physical Buff"
	name = "Atomic Point"
	desc = "Your defenses are ironclad. Unpenetrable and absolutely invincible. Your Ki defends even against the subatomic. Defense++++"
	can_forget = TRUE
	common_sense = TRUE
	enabled=1
	prereqs = list(new/datum/skill/Ultradense_Body)
	maxlevel = 1
	tier = 4
	after_learn()
		savant<<"Your defense has reached the endgame."
		savant.physdefBuff+=5
	before_forget()
		savant<<"Your body expands from its collapsed point..."
		savant.physdefBuff-=5