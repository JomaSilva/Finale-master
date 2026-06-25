obj/ApeshitSetting/verb/ApeshitSetting()
	set name="Oozaru Setting"
	set category="Other"
	if(!usr.Osetting)
		usr.Osetting=1
		usr<<"You decide that if the moon is out, you will look at it."
	else
		usr.Osetting=0
		usr<<"You decide that if the moon is out, you will -not- look at it."
mob
	var
		storedicon
		list/storedoverlays=new/list
		list/storedunderlays=new/list
		Omult=6
		Osetting=1 //1 for enabled, 0 else
		Apeshitskill=0 //once this reaches 10 you can talk in Apeshit.
		golden
		canRevert
	proc
		RegularApeshit(var/N)
			if(transing) return
			if(!N)
				Revert()
				startbuff(/obj/buff/Oozaru)

		GoldenApeshit()
			if(transing) return
			if(SaiyanLineage=="Primal Saiyan"&&hasssj&&!transing)
				if(!Apeshit&&Tail&&!KO)
					if(ssj) Revert()
					src<<"You look at the moon and turn into a giant monkey!"
					golden=1
					Revert()
					startbuff(/obj/buff/Oozaru/SuperOozaru)
					spawn(1000)
					Apeshit_Revert(1)
		Apeshit()
			if(transing) return
			if(genome.race_percent("Saiyan") >= 50)
				if(!Apeshit&&Tail&&!KO)
					if(!ssj)
						src<<"You look at the moon and turn into a giant monkey!"
						Revert()
						RegularApeshit()
						spawn(3000)
						Apeshit_Revert()
					else
						Revert()
						GoldenApeshit()
			if(Race=="Saiyan")
				if(!ssj&&!transing)
					src<<"You look at the moon and turn into a giant monkey!"
					Revert()
					RegularApeshit()
					spawn(3000)
					Apeshit_Revert()
				else
					Revert()
					GoldenApeshit()
		Apeshit_Revert(var/N)
			if(Apeshit||isBuffed(/obj/buff/Oozaru)||isBuffed(/obj/buff/Oozaru/SuperOozaru))
				src<<"<font color=yellow>You come to your senses and return to your normal form."
				emit_Sound('descend.wav')
				stopbuff(/obj/buff/Oozaru)
				stopbuff(/obj/buff/Oozaru/SuperOozaru)
obj/ApeshitRevert/verb/ApeshitRevert()
	set name="Oozaru Revert"
	set category="Skills"
	if(usr.Apeshit&&!usr.golden)
		if(usr.Apeshitskill>=10)
			usr<<"You try to revert your transformation. You have enough skill, so it succeeds."
			usr.Apeshit_Revert()
		else usr<<"You try to revert your transformation. You don't have enough skill."
	else if(usr.golden&&usr.Apeshit&&usr.Race=="Saiyan")
		if(usr.hasssj4)
			usr<<"You try to revert your transformation, but end up being a Super Saiyan 4."
			usr.Apeshit_Revert()
			usr.SSj4()
		else
			if(usr.expressedBP>=usr.ssj4at&&usr.BP>=usr.rawssj4at&&!usr.canRevert)
				sleep(5)
				usr<<"You feel something coming from within you!"
				sleep(1)
				usr.Apeshit_Revert()
				usr.SSj4()
			else if(usr.Apeshitskill>=10&&!usr.canRevert&&usr.expressedBP<usr.ssj4at/1.5&&usr.BP>=usr.rawssj4at)
				sleep(5)
				usr<<"You try to revert your transformation. You have enough skill, so it succeeds."
				usr.Apeshit_Revert()
			else if(usr.Apeshitskill>=10&&!usr.canRevert&&usr.expressedBP>usr.ssj4at/1.5&&usr.BP>=usr.rawssj4at)
				usr<<"You try to revert your transformation! Your control and calmness brings you to a new level!"
				usr.Apeshit_Revert()
				usr.SSj4()
			else usr<<"You try to control it! It fights back- you're going to have to wait a bit!"

obj/buff/Oozaru
	name = "Oozaru"
	icon='SSJIcon.dmi'
	slot=sFORM //which slot does this buff occupy
	incompatiblebuffs = list()
	var/ticker
	var/angertick = 1000
	godki_effector(i)
		if(!did_godki && container.godki.usage)
			did_godki = 1
			if(i == TRUE) do_first_godki_appearance()
			if(i == FALSE) do_godki_appearance()
			if(container.golden) container.color = rgb(113, 146, 255)
			else container.color = rgb(248, 44, 44)
			return TRUE
		if(did_godki && !container.godki.usage)
			did_godki = 0
			container.color = null
		return FALSE
obj/buff/Oozaru/Buff()
	container.Apeshit=1
	container.storedicon=container.icon
	container.storedoverlays.Remove(container.overlayList)
	container.storedunderlays.Remove(container.underlays)
	container.storedoverlays.Add(container.overlayList)
	container.storedunderlays.Add(container.underlays)
	container.overlayList.Remove(container.overlayList)
	container.RemoveHair()
	container.overlaychanged=1
	container.OozaruBuff=container.Omult
	container.Tphysoff+=1.2
	container.Tspeed-=1.5
	container.Ttechnique-=1.5
	container.giantFormbuff = 2
	container.bigform=1
	container.Ki += container.OozaruBuff * container.MaxKi
	container.train=0
	container.med=0
	container.move=1
	container.FlashPoint = 0
	var/icon/targicon
	if(container.golden) targicon = 'goldoozaruhayate.dmi'
	else
		targicon = 'oozaruhayate.dmi'
		targicon += rgb(container.HairR,container.HairG,container.HairB)
	spawn
		animate(container,color = rgb(0,0,0),time = 4, alpha = 0)
		var/matrix/nmm = matrix()
		container.transform = nmm.Scale(1/5,1/5)
		container.overlay_x = 32
		container.overlay_y = 32
		container.pixel_x = -16
		container.pixel_y = -16
		animate(container,transform = null,time = 10, alpha = 255,color = null,icon = targicon)
		container.icon = targicon
	..()
obj/buff/Oozaru/Loop()
	if(!container.Tail) DeBuff()
	if(prob(10))
		if(container.hair in container.overlayList || container.HasOverlay(/obj/overlay/hairs/hair))
			container.RemoveHair()
		if(container.HasOverlay(/obj/overlay/hairs/tails/saiyantail))
			container.removeOverlay(/obj/overlay/hairs/tails/saiyantail)
	if(prob(1)&&prob(50))
		container.emit_Sound('Roar.wav')
	ticker++
	if(container.Apeshitskill<10||(container.golden && !container.canSSJ))//canSSJ is the Baby only var. Allows Reibis to control Golden Oozaru.
		container.ctrlParalysis=1
		if(container.med)
			angertick--
			if(angertick <= 0) DeBuff()
		if(!container.KO && ticker > 5)
			ticker = 0
			container.ctrlParalysis=1
			if(container.Apeshitskill < 10) container.Apeshitskill += 0.01 //gain Oozaru control mastery from time spent transformed (was commented out, so it never grew)
			if(prob(container.Ekiskill*10))
				var/bcolor='12.dmi'
				bcolor+=rgb(container.blastR,container.blastG,container.blastB)
				var/obj/attack/blast/A=new/obj/attack/blast/
				if(prob(5)) container.Blast_Gain()
				container.emit_Sound('fire_kiblast.wav')
				A.loc=locate(container.x,container.y,container.z)
				A.icon=bcolor
				A.density=1
				A.basedamage=1
				A.BP=container.expressedBP
				A.mods=container.Ekioff*container.Ekiskill
				A.murderToggle=container.murderToggle
				A.proprietor=container
				A.dir=container.dir
				spawn A.Burnout()
				if(container.client) A.ownkey=container.displaykey
				step(A,A.dir)
				walk(A,A.dir,2)
			if(!container.target)
				for(var/mob/M in oview(container)) if(M.client&&!container.target&&!M.KO)
					container.target=M
					break
				step_rand(container)
			if(container.target)
				if(container.target in oview(container))
					if(container.totalTime >= container.OMEGA_RATE)
						container.MeleeAttack()
					step(container,get_dir(container,container.target))
				else
					container.target=null
	else container.ctrlParalysis=0
	..()
obj/buff/Oozaru/DeBuff()
	container.Apeshit=0
	container.icon=container.storedicon
	container.pixel_x = 0
	container.pixel_y = 0
	container.overlay_x = 0
	container.overlay_y = 0
	container.overlayList.Remove(container.overlayList)
	container.overlayList.Add(container.storedoverlays)
	container.storedoverlays.Remove(container.storedoverlays)
	container.Ki /= container.OozaruBuff
	container.OozaruBuff = 1
	container.giantFormbuff = 1
	container.bigform=0
	container.Tphysoff-=1.2
	container.Tspeed+=1.5
	container.Ttechnique+=1.5
	container.color = null
	container.AddHair()
	container.overlaychanged=1
	container.golden=0
	container.canRevert = 0
	container.ctrlParalysis=0
	..()

obj/buff/Oozaru/SuperOozaru
	name = "Super Oozaru"
	icon='SSJIcon.dmi'
	slot=sFORM //which slot does this buff occupy
	Buff()
		..()
		container.Ki += container.OozaruBuff * container.MaxKi
		container.OozaruBuff=(container.Omult + 10)
		container.ssjBuff=container.ssjmult
/*
obj/overlay/g_oozarou_overlay
	name = "G Oozaru"
	icon = 'goldoozaruhayate.dmi'
	pixel_x = -16
	pixel_y = -16
	o_px = -16
	o_py = -16
	ID = 233
obj/overlay/oozarou_overlay
	name = "Oozaru"
	icon = 'oozaruhayate.dmi'
	pixel_x = -16
	pixel_y = -16
	o_px = -16
	o_py = -16
	ID = 231
*/

/mob/keyable/verb/Wrathful_State()
	set category = "Skills"
	if(Apeshit)
		usr << "Can't use this with Oozaru!"
		return
	if(Class != "Legendary" || Tail)
		usr << "Only Legendary Saiyans who have lost their tail can enter the Wrathful State!"
		return
	else if(isBuffed(/obj/buff/Wrathful_State)) stopbuff(/obj/buff/Wrathful_State)
	else startbuff(/obj/buff/Wrathful_State)

/obj/buff/Wrathful_State
	name = "Super Oozaru"
	icon='SSJIcon.dmi'
	slot=sBUFF //which slot does this buff occupy
	incompatiblebuffs = list()
	var/ticker
	Buff()
		if(container.Class !="Legendary" && !container.LSSJType)
			switch(container.Emotion)
				if("Annoyed") container.SpreadDamage(2)
				if("Slightly Angry") container.SpreadDamage(5)
				if("Angry") container.SpreadDamage(10)
				if("Very Angry") container.SpreadDamage(15)
		container << "You activate your wrathful state!"
		view(container) << "<font color=yellow>[container]'s eyes glow a faint yellow as their energy and aura skyrockets!</font>"
		container.OozaruBuff=container.Omult * 0.45
		if(container.Class =="Legendary" || container.LSSJType) container.OozaruBuff=container.Omult * 0.65
		container.Tphysoff+=1.2
		container.Tspeed+=1.5
		container.Ttechnique-=1.5
		container.Tkiskill-=1.5
		container.giantFormbuff = 1.55
		container.bigform=1
		container.Ki += container.Omult * container.MaxKi //danger signs- as long as you keep the extra energy, it'll fuck yu up
		container.train=0
		container.med=0
		container.move=1
		container.FlashPoint = 0
		..()
	Loop()
		if(container.Ki <= container.MaxKi) DeBuff()
		spawn
			if(container.Class !="Legendary" && !container.LSSJType)
				switch(container.Emotion)
					if("Annoyed") container.SpreadDamage(0.01)
					if("Slightly Angry") container.SpreadDamage(0.02)
					if("Angry") container.SpreadDamage(0.04)
					if("Very Angry") container.SpreadDamage(0.06)
	DeBuff()
		//container.icon=container.storedicon
		container << "Your wrath vanishes."
		view(container) << "<font color=yellow>[container]'s eyes faint yellow glow fades...</font>"
		container.OozaruBuff = 1
		container.giantFormbuff = 1
		container.Tphysoff-=1.2
		container.Tspeed-=1.5
		container.Ttechnique+=1.5
		container.Tkiskill+=1.5
		..()