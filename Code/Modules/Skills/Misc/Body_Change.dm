//don't fucking use yet (too buggy)
/datum/skill/Body_Change
	skilltype = "Ki"
	name = "Body Change"
	desc = "\"CHANGE... NOW!!\" - Captain Ginyu\nBodychange, also known as Bodyswap, is the ability to swap other's body with your own. It shoots out a purple beam for a second, anyone who touches it swaps minds with yourself."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	after_learn()
		savant.contents += new/obj/BodyswapOBJ
		savant<<"You can swap bodies!"
	before_forget()
		for(var/obj/O in savant.contents)
			if(istype(O,/obj/BodyswapOBJ))
				del(O)
		savant<<"You've forgotten how to swap bodies?"


obj/BodyswapOBJ//reason why this is a object is because it needs to 'transfer' between players.
	verb/Body_Swap()
		set category = "Skills"
		var/kireq=100*usr.Ephysoff*usr.BaseDrain
		if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
			var/passbp = 0
			usr.blastcount+=1
			usr.basicCD+=50
			usr.Ki-=kireq*usr.BaseDrain
			passbp=usr.expressedBP
			if(prob(5)) usr.Blast_Gain()
			var/bcolor='KiHead.dmi'
			bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
			var/obj/attack/A=new/obj/attack/blast/bodyswapblast
			emit_Sound('fire_kiblast.wav')
			A.loc=locate(usr.x,usr.y,usr.z)
			A.icon=bcolor
			A.icon_state="5"
			A.density=1
			A.basedamage=0.5
			A.distance = 6
			A.homingchance=0//no homing chance
			A.BP=passbp
			A.mods=usr.Ekioff*usr.Ekiskill
			A.murderToggle=usr.murderToggle
			A.proprietor=usr
			A.ownkey=usr.displaykey
			A.dir=usr.dir
			A.ogdir=usr.dir
			if(A)
				A.Burnout()
				walk(A,usr.dir)
				if(usr.target&&usr.target!=usr)
					A.blasthoming(usr.target)
			usr.icon_state="Blast"
			spawn(3) usr.icon_state=""
		else usr << "You need at least [kireq] Ki!"


/obj/attack/blast/bodyswapblast
	var/isswapping = 0
	OnSucCollWMob(mob/M)
		..()
		if(!isswapping || M.mindswappable)
			if(proprietor && M && M.client)
				isswapping = 1
				view(M)<<"[proprietor] activates the body change beam with [M]!"
				proprietor.contents -= /obj/BodyswapOBJ
				M.contents += new/obj/BodyswapOBJ
				var/save_admin1 = proprietor.Admin
				var/save_admin2 = M.Admin
				proprietor.client.BodySwap(M)
				proprietor.Admin = save_admin2
				M.Admin = save_admin1
				proprietor.Remove_All_Commands()
				proprietor.AdminCheck()
				M.Remove_All_Commands()
				M.AdminCheck()