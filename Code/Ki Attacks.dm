
mob/var/ChargeState="1"

//---------------------
mob/var
	CBLASTICON='AllBlasts.dmi'
obj/var/tmp/mob/target

mob/var
	BLASTICON='12.dmi'
	BLASTSTATE="12"

mob/var
	CBLASTSTATE

obj/var/ownkey
mob/proc/Nova()
	for(var/turf/A in view(1,src)) if(prob(70))
		createDustmisc(A,1)
		emit_Sound('kiplosion.wav')

obj/var/shockwave
obj/var
	BP
	firstfire
	murderToggle=0 //kill
	mob/proprietor
	piercer
	paralysis
mob/var/proprietor
obj/Move()
	..()
	if(istype(src,/obj/attack/blast))
		for(var/turf/T in view(1,src))
			if(prob(Pow/100)&&BP>10000)
				if(!istype(T,/turf/Other/Stars))
					if(BP>=(T.Resistance+100)*10)
						createDust(T,1)
						T.Destroy()