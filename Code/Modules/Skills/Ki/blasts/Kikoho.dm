/datum/skill/general/kikoho
	skilltype = "Ki"
	name = "Kikoho"
	desc = "Kikoho is a powerful attack that takes some of your health as a price."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	enabled = 0

/datum/skill/general/kikoho/after_learn()
	assignverb(/mob/keyable/verb/Kikoho)
	savant<<"You can fire an [name]!"

/datum/skill/general/kikoho/before_forget()
	unassignverb(/mob/keyable/verb/Kikoho)
	savant<<"You've forgotten how to fire an [name]!?"
datum/skill/general/kikoho/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/Kikoho)

mob/var/Kikohoicon='Kikoho.dmi'
mob/var/tmp/kikohoblasts=0
/mob/keyable/verb/Kikoho()
	set category = "Skills"
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=usr.MaxKi*0.1&&usr.HP>=10&&!usr.blasting)
		usr.kikohoblasts += 1
		if(usr.kikohoblasts > 3) usr.kikohoblasts = 1
		emit_Sound('kikoho.wav')
		for(var/mob/M in view(usr))
			if(M.client)
				if(kikohoblasts==1)
					M<<output("<font size=[M.TextSize]><[SayColor]>[name] says, 'KI'","Chatpane.Chat")
					M.TestListeners("<font size=[M.TextSize]><[SayColor]>[name] says, 'KI'","Chatpane.Chat")
				if(kikohoblasts==2)
					M<<output("<font size=[M.TextSize]><[SayColor]>[name] says, 'KO'","Chatpane.Chat")
					M.TestListeners("<font size=[M.TextSize]><[SayColor]>[name] says, 'KO'","Chatpane.Chat")
				if(kikohoblasts==3)
					M<<output("<font size=[M.TextSize]><[SayColor]>[name] says, 'HO'","Chatpane.Chat")
					M.TestListeners("<font size=[M.TextSize]><[SayColor]>[name] says, 'HO'","Chatpane.Chat")
		usr.blasting=1
		usr.Ki-=50*BaseDrain * kikohoblasts
		usr.SpreadDamage(2 * kikohoblasts)
		spawn(10) if(usr.HP<=0)
			spawn usr.KO()
			if(prob(10)) usr.Death()
		usr.Blast_Gain()
		usr.Blast_Gain()
		usr.Blast_Gain()
		var/obj/attack/blast/A=new/obj/attack/blast(locate(usr.x,usr.y,usr.z))
		A.icon='Kikoho.dmi'
		A.icon+=rgb(usr.blastR,usr.blastG,usr.blastB)
		A.basedamage=40
		A.density=1
		A.BP=expressedBP
		A.mods=Ekioff*Ekiskill * kikohoblasts
		A.murderToggle=usr.murderToggle
		A.proprietor=usr
		A.ownkey=usr.displaykey
		A.dir=usr.dir
		walk(A,usr.dir)
		A.Burnout(50)
		var/amount = 3
		var/scale = 1
		var/matrix/nM = new
		spawn while(amount && A)
			sleep(2)
			CHECK_TICK
			scale += 1
			A.basedamage *= 1.1
			nM.Scale(scale,scale)
			A.transform = nM
		sleep(10)
		blasting=0
		sleep(60)
		usr.kikohoblasts = 0