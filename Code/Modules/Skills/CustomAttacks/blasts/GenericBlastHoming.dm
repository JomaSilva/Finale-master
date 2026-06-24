/obj/skill/CustomAttacks/ki/blast/Blast/proc/homingFire()
	var/KiCost = max(1,(Explode*10))*5
	if(!savant.KO&&!savant.med&&!savant.train&&!savant.blasting&&!savant.Guiding&&CanFire)
		if(savant.Ki>=KiCost)
			CanFire=0
			savant.blasting=1
			savant.Guiding=1
			savant.icon_state="Planet Destroyer"
			spawn(50) savant.icon_state=""
			emit_Sound('basicbeam_chargeoriginal.wav')
			savant.Ki-=KiCost*savant.BaseDrain
			if(savant.baseKi<=savant.baseKiMax)savant.baseKi+=savant.kicapcheck(0.05*savant.BPrestriction*savant.KiMod)
			var/bcolor=icon
			var/obj/attack/blast/A=new/obj/attack/blast/
			A.loc=locate(savant.x,(savant.y+1),savant.z)
			A.icon=bcolor
			A.color=color
			sleep(20)
			if(A)
				A.Burnout()
				A.icon=bcolor
				A.icon_state = icon_state
				A.density=1
				A.BP=savant.expressedBP
				A.mods=savant.Ekioff*savant.Ekiskill
				A.basedamage=2.5*max(1,(Explode*10))+basedamage
				A.guided = 1
				A.dir=savant.dir
				A.murderToggle=savant.murderToggle
				A.proprietor=savant
				A.ownkey=savant.displaykey
			savant.blasting=0
			spawn (Refire*10) CanFire=1
			savant.Blast_Gain()
			savant.Blast_Gain()
			sleep(savant.Eactspeed/8)
			if(A)
				A.density=0
				step(A,savant.dir)
				if(A) A.density=1
				emit_Sound(firesound)
			spawn while(A&&savant.Guiding)
				if(A)
					A.dir = savant.dir
				sleep(savant.Eactspeed/10)
			while(A)
				sleep(MoveDelay / 2)
				step(A,A.dir)
			savant.Guiding=0
		else savant<<"You dont have enough energy."
	if(!savant.KO&&!savant.med&&!savant.train&&!savant.blasting&&savant.Guiding)
		savant.Guiding = 0
//stop() and charge() isn't modified since the beam code in beams.dm do it for us.