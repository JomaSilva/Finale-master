/obj/skill/CustomAttacks/ki/blast/Blast/proc/nonHomingFire()
	var/kireq=(10*(max(Piercer,Explode,Stun)*2)*savant.Ephysoff)/savant.Ekiskill //Any modifications? Kireq is 2x bigger.
	var/reload
	if(!savant.KO&&savant.Ki>=kireq&&!basicCD&&savant.canfight)
		reload=savant.Eactspeed*Refire
		if(reload<2)reload=2
		basicCD+=reload
		savant.Ki-=kireq*savant.BaseDrain
		savant.speedMod/=1.3
		var/bicon=icon
		//savant.canfight=0
		savant.mobTime-=0.4
		sleep((reload)/10)
		var/obj/attack/blast/A=new/obj/attack/blast/
		emit_Sound(firesound)
		A.Burnout()
		A.icon=bicon
		A.icon_state = icon_state
		A.color = color
		A.loc=locate(savant.x,savant.y,savant.z)
		A.density=1
		A.BP=savant.expressedBP
		A.mods=savant.Ekioff*savant.Ekiskill
		A.basedamage=2.5*max(1,(Explode*10))+basedamage
		A.paralysis = Stun
		A.shockwave = max(Explode,Piercer)
		A.dir=savant.dir
		A.murderToggle=savant.murderToggle
		A.proprietor=savant
		A.ownkey=savant.displaykey
		A.dir=savant.dir
		step(A,savant.dir)
		walk(A,savant.dir)
		savant.Blast_Gain()
		//savant.canfight=1
		savant.speedMod*=1.3
	else if(savant.Ki<=kireq) savant<<"This requires atleast [kireq] energy to use."