mob/var
	tmp/limiteroverload=0
	artificialbuff=1
	limiteroverloaddrain=0.01

obj/buff/limiteroverload
	name = "Limiter Overload"
	icon='SSJIcon.dmi'
	slot=sFORM //which slot does this buff occupy
	var/lastForm=0
obj/buff/limiteroverload/Buff()
	lastForm=0
	..()
obj/buff/limiteroverload/Loop()
	if(!container.transing)
		if(container.limiteroverload==1) if(container.limiteroverloaddrain)
			if(container.stamina>=container.maxstamina*container.limiteroverloaddrain)
				if(prob(20)) container.Ki-=container.limiteroverloaddrain*container.BaseDrain //ki takes a small hit regardless.
				if(container.Ki<=container.MaxKi*container.limiteroverloaddrain)
					container.Revert()
					container<<"You are too tired to sustain your form."
				container.stamina -= trans_drain*max(0.001,container.limiteroverloaddrain) //max statement ensures you won't be hitting exactly zero if drain changes mid drain.
			else container.Revert()
	var/artificialcount=0
	for(var/datum/Body/A in container.body)
		if(A.artificial)
			artificialcount+=1
			A.health-=0.25
	for(var/obj/Modules/B in container.contents)
		if(B.isequipped&&B.functional)
			if(B.elec_energy>0)
				B.elec_energy-=1
			else if(B.elec_energy<=0&&B.integrity>0)
				B.integrity-=1
			else
				B.functional=0
	if(lastForm!=container.limiteroverload)
		lastForm=container.limiteroverload
		switch(container.limiteroverload)
			if(1)
				container.artificialbuff=(1+artificialcount/10)
				container.transBuff=container.artificialbuff
				container.overlayList+='snamek Elec.dmi'
				container.overlaychanged=1
	..()
obj/buff/limiteroverload/DeBuff()
	container.transBuff = 1
	container.overlayList-='snamek Elec.dmi'
	container.overlaychanged=1
	..()