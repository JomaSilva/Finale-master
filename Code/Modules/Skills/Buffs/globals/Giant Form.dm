/datum/skill/namek/bigform
	skilltype = "Form"
	name = "Become Huge"
	desc = "Become Huge, increasing your strength by a lot. This is not the same as Body Expand."
	can_forget = TRUE
	common_sense = FALSE
	tier = 2
	maxlevel = 2
	skillcost=2
	var/expbuffer
	after_learn()
		savant.canbigform=1
		savant.physoffBuff += 0.5
		assignverb(/mob/keyable/verb/Giant_Form)
		savant<<"You have learned how to expand your body to over 4 times its normal size."
	before_forget()
		savant.canbigform=0
		savant.physoffBuff -= 0.5
		unassignverb(/mob/keyable/verb/Giant_Form)
		savant<<"You have forgotten how to expand your body to over 4 times its normal size."
	login(var/mob/logger)
		..()
		assignverb(/mob/keyable/verb/Giant_Form)
	effector()
		..()
		if(level < 2 && savant.bigform)
			expbuffer+= 1 * rand(1,7)
			if(expbuffer>= 20)
				exp += 1 * savant.giant_form_efficiency
				expbuffer = 0
		switch(level)
			if(0)
				if(levelup)
					levelup=0
			if(1)
				if(levelup)
					levelup=0
					savant<<"Your Giant Form has improved a bit!"
					savant.giant_form_efficiency = 0.5
					expbarrier=60

			if(2)
				if(levelup)
					levelup=0
					savant<<"Your Giant Form has improved even more!"
					savant.giant_form_efficiency = 0.15
					expbarrier=60
mob/var
	giant_form_efficiency = 1
mob/keyable/verb/Giant_Form()
	set category="Skills"
	if(bigforming)
		return
	else
		bigforming = 1
		spawn(10) bigforming = 0
	if(isBuffed(/obj/buff/Giant_Form))
		stopbuff(/obj/buff/Giant_Form)
	else
		startbuff(/obj/buff/Giant_Form)

/obj/buff/Giant_Form
	name = "Giant Form"
	icon='Electric_Blue.dmi'
	slot=sFORM
	var/drainbuffer
	Buff()
		..()
		container.emit_Sound('deathball_charge.wav')
		container.bigform=1
		container.giantFormbuff = 1.55
		container.Tphysoff+=1.5
		container.Tphysdef+=1.5
		container.Tspeed-=0.5
		//container.transform = nM.Scale(3,3)
		container<<"You concentrate on the power of your energy, increasing your size!"
		animate(container,transform = matrix()*2, time = 5)
	Loop()
		if(!container.transing)
			drainbuffer += rand(1,5)
			if(drainbuffer >= 20)
				if(container.stamina>=container.maxstamina*0.005*trans_drain*container.giant_form_efficiency || container.dead)
					container.stamina -= trans_drain*max(0.001,container.maxstamina*container.giant_form_efficiency*0.005)/2

	DeBuff()
		container.bigform=0
		animate(container,transform = matrix(), time = 5)
		container.giantFormbuff = 1
		container.Tphysoff-=1.5
		container.Tphysdef-=1.5
		container.Tspeed+=0.5
		container<<"You release your energy... and your size!"
		..()