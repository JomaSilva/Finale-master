/datum/skill/tree/arlian
	name="Arlian Racials"
	desc="Given to all Arlians at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Arlian")
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,\
	new/datum/skill/general/regenerate,new/datum/skill/arlian/Stick,new/datum/skill/arlian/Supa,new/datum/skill/arlian/Acid_Spit)
	treegrow()
		if(savant.pitted==1)
			disableskill(/datum/skill/arlian/Supa)
		if(savant.pitted==2)
			disableskill(/datum/skill/arlian/Stick)
	treeshrink()
		if(savant.pitted==0)
			enableskill(/datum/skill/arlian/Supa)
			enableskill(/datum/skill/arlian/Stick)

/datum/skill/arlian/Acid_Spit
	skilltype = "misc"
	name = "Acid Spit"
	desc = "Vomit a projectile of poison damage towards a foe. The person it hits will become inflicted with short term poison damage. Kioff++"
	can_forget = TRUE
	common_sense = FALSE
	teacher = TRUE
	tier = 2
	skillcost=2
	after_learn()
		assignverb(/mob/keyable/verb/Acid_Spit)
		savant.kioffBuff++
		savant<<"You feel poisonous"
	before_forget()
		unassignverb(/mob/keyable/verb/Acid_Spit)
		savant.kioffBuff--
		savant<<"Your poison fades..."
	login()
		..()
		assignverb(/mob/keyable/verb/Acid_Spit)
mob/keyable/verb/Acid_Spit()
	set category = "Skills"
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=usr.MaxKi*0.1&&usr.HP>=10&&!usr.blasting)
		usr.blasting=1
		usr.Ki-=12*BaseDrain
		usr.Blast_Gain()
		var/obj/attack/blast/A=new/obj/attack/blast/Acid_spit(locate(usr.x,usr.y,usr.z))
		A.icon='Blasts.dmi'
		A.icon_state = "24"
		A.icon+=rgb(usr.blastR,usr.blastG,usr.blastB)
		A.basedamage=40
		A.density=1
		A.BP=expressedBP
		A.mods=Ekioff*Ekiskill
		A.murderToggle=usr.murderToggle
		A.proprietor=usr
		A.ownkey=usr.displaykey
		A.dir=usr.dir
		walk(A,usr.dir)
		spawn A.Burnout(50)
		sleep(10)
		blasting=0

obj/attack/blast/Acid_spit
	OnSucCollWMob(var/mob/M)
		if(M)
			M<<"You are poisoned!"
			spawn M.AddEffect(/effect/Alchemy/Health/Damage_Duration)
			sleep(1)
			var/effect/Alchemy/e = locate(/effect/Alchemy/Health/Damage_Duration) in M.effects
			if(e)
				e.duration = 30
				e.magnitude = 2
/datum/skill/arlian/Stick
	skilltype = "Physical"
	name = "Stick"
	desc = "You're an Arlian, so you're built like a stick. Conversely, that means Ki flows through you easier, granting you more skill. KiMod+++, KiSkillMod+++"
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 1
	tier = 1
	maxlevel = 1
	after_learn()
		savant<<"Your body's Ki control changes."
		savant.genome.add_to_stat("Energy Level",0.7)
		savant.kiskillMod += 0.5
		savant.pitted = 1
	before_forget()
		savant<<"Your body's Ki control returns to normal."
		savant.genome.sub_to_stat("Energy Level",0.7)
		savant.kiskillMod -= 0.5
		savant.pitted = 0

/datum/skill/arlian/Supa
	skilltype = "Physical"
	name = "Super Bug"
	desc = "Bug life is hard. Your body reflects and grows to accomadate this, increasing stamina and regeneration rates, along with a bit of durability. P.Def+, Zenkai+, Regen+, Will++"
	can_forget = TRUE
	common_sense = FALSE
	skillcost = 1
	tier = 1
	maxlevel = 1
	after_learn()
		savant<<"Your body's durability increases."
		savant.physdefMod += 0.03
		savant.genome.add_to_stat("Zenkai",1)
		savant.kiregenMod += 0.1
		savant.HPregenbuff += 0.1
		savant.willpowerMod += 0.3
		savant.pitted = 2
	before_forget()
		savant<<"Your body's durability returns to normal."
		savant.physdefMod -= 0.03
		savant.genome.sub_to_stat("Zenkai",1)
		savant.kiregenMod -= 0.1
		savant.HPregenbuff -= 0.1
		savant.willpowerMod -= 0.3
		savant.pitted = 0