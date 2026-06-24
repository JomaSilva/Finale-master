//mob/proc/soundUpdate()
//	..()

mob/var/tmp/CurrentAmbiance = null

//ambiance: quiet music/soundtracks/effects (birds chirping/waves/wind) that blend into the background.


var/list/CurrentAmbianceglobalList = list() //global ambiance. Area ambiance could be added too.

var/list/CurrentAmbiancepeaceList = list() //in peaceful situations

var/list/CurrentAmbiancetensionList = list() //in non-peaceful situations

var/list/CurrentAmbiancecombatList = list() //in combat


atom/proc/emit_Sound(var/snd,volume)
	var/targvol
	for(var/mob/M in view(src))
		if(M.client)
			if(volume != null) targvol = M.client.clientvolume * volume
			else targvol = M.client.clientvolume
			M << sound(snd,volume=targvol)

atom/proc/o_emit_Sound(var/snd,volume)
	var/targvol
	for(var/mob/M in oview(src))
		if(M.client)
			if(volume != null) targvol = M.client.clientvolume * volume
			else targvol = M.client.clientvolume
			M << sound(snd,volume=targvol)

proc/emit_Sound_to(var/snd,var/mob/M,volume)
	if(M.client)
		var/targvol
		if(volume != null) targvol = M.client.clientvolume * volume
		else targvol = M.client.clientvolume
		M << sound(snd,volume=targvol)