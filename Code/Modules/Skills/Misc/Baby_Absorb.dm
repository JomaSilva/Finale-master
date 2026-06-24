var/list/reibi_list = list()
datum/reibi_ctrller
	var
		source_sig
		victim_sig
		is_exhabiting

obj/Modules/Reibi_Module
	desc = "An item that allows you to take over other beings bodies. For non-organics only."
	elec_energy_max = 10000
	elec_energy = 10000
	var/hasbody
	var/ohair
	var/absorbedsig
	var/hadssj
	verb/Inhabit_Player()
		set category="Skills"
		if(!hasbody)
			var/list/PeopleList=new/list
			PeopleList+="Cancel"
			for(var/mob/P in oview(usr)) PeopleList.Add(P.name)
			var/Choice=input("Take whoms body? They must be KO'd or angry.") in PeopleList
			if(Choice=="Cancel")
				return
			else
				for(var/mob/M in oview(1,usr))
					if(M.name==Choice)
						if((M.KO||(M.Emotion!="Calm"&&M.Emotion!="Annoyed"))&&!hasbody)
							hasbody=1
							usr.Revert()
							usr.absorbadd+=M.BP
							usr.absorbadd+=M.absorbadd
							absorbedsig = M.signature
							usr.originalicon = icon
							usr.icon=M.icon
							sleep usr.RemoveHair()
							ohair = usr.hair
							usr.hair = M.hair
							usr.hair += rgb(100,100,100)
							usr.overlayList+=M.hair
							usr.overlayList+='ReibiFace.dmi'
							usr.stored_race="[usr.Race]"
							usr.stored_class="[usr.Class]"
							usr.Apeshitskill=M.Apeshitskill+5
							usr.Class="[M.Race]"
							usr.Race="Meta"
							if(M.Race=="Saiyan"|M.genome.race_percent("Saiyan") >= 50||M.Parent_Race=="Saiyan"&&M.SaiyanType||M.canSSJ) //need to expand for other races.
								usr.canSSJ = 1
								hadssj = 1
								usr.TransferSSJStats(M)
							view(usr)<<"[usr] inhabits [M]'s body!"
							M.ReibiAbsorber=usr.signature
							M.ReibiX = usr.x
							M.ReibiY = usr.y
							M.ReibiZ = usr.z
							M.GotoPlanet("Sealed")
							var/datum/reibi_ctrller/nrc = new
							nrc.source_sig = usr.signature
							nrc.victim_sig = M.signature
							reibi_list += nrc
							new/obj/ReibiAbsorbed(M)
						else usr<<"They must be knocked out, or angrier past Annoyed."
		else
			usr<<"You need to be in your true body."
	verb/Exhabit()
		set category = "Skills"
		if(hasbody)
			hasbody = 0
			usr.Revert()
			usr.icon=usr.originalicon
			if(ohair) usr.hair=ohair
			usr.Class="[usr.stored_class]"
			usr.Race="[usr.stored_race]"
			if(hadssj && usr.Race != "Saiyan" && usr.Parent_Race != "Saiyan")
				hadssj=0
				usr.canSSJ = 0
			view(usr)<<"[usr] exhabits [usr]'s body!"
			for(var/datum/reibi_ctrller/nrc in reibi_list)
				if(nrc.victim_sig==absorbedsig && nrc.source_sig==usr.signature)
					nrc.is_exhabiting = 1


mob/proc/checkReibi()
	set waitfor = 0
	if(ReibiAbsorber)
		for(var/datum/reibi_ctrller/nrc in reibi_list)
			if(nrc.victim_sig==signature && nrc.is_exhabiting)
				ReibiAbsorber = null
				contents -= /obj/ReibiAbsorbed
				loc=locate(ReibiX,ReibiY,ReibiZ)
				ReibiX = null
				ReibiY = null
				ReibiZ = null
				break

mob/proc/TransferSSJStats(var/mob/M)
	hasssj = M.hasssj
	ssjat = M.ssjat
	hasultrassj = M.hasultrassj
	ultrassjat = M.ultrassjat
	ultrassjenabled = M.ultrassjenabled
	ssjat = M.ssjat
	hasssj2 = M.hasssj2
	ssj3able = M.ssj3able
	ssj3at = M.ssj3at
	ssj2at = M.ssj2at

obj/ReibiAbsorbed
	var/absorbersig
	IsntAItem = 1
	verb/View_Absorber()
		set category="Other"
		if(absorbersig)
			for(var/mob/M in player_list)
				if(M.signature == absorbersig)
					usr.client.perspective=EYE_PERSPECTIVE
					usr.client.eye=M
					break
		else
			del(src)
	verb/Reset_View()
		set category="Other"
		usr.client.perspective=MOB_PERSPECTIVE
		usr.client.eye=src
		usr.observingnow=0
