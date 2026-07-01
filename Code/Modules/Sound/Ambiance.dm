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
			M << sound(snd,volume=targvol,channel=rand(2,49)) //explicit SFX channel range (never the music channels 58/59/60 or 1021-1024): channel 0 auto-alloc could grab ch 60 and cut the battle music (e.g. during a ZanzoClash sound burst)

atom/proc/o_emit_Sound(var/snd,volume)
	var/targvol
	for(var/mob/M in oview(src))
		if(M.client)
			if(volume != null) targvol = M.client.clientvolume * volume
			else targvol = M.client.clientvolume
			M << sound(snd,volume=targvol,channel=rand(2,49)) //explicit SFX channel range (never the music channels 58/59/60 or 1021-1024): channel 0 auto-alloc could grab ch 60 and cut the battle music (e.g. during a ZanzoClash sound burst)

proc/emit_Sound_to(var/snd,var/mob/M,volume)
	if(M.client)
		var/targvol
		if(volume != null) targvol = M.client.clientvolume * volume
		else targvol = M.client.clientvolume
		M << sound(snd,volume=targvol,channel=rand(2,49)) //explicit SFX channel range: keep SFX off the battle-music channel