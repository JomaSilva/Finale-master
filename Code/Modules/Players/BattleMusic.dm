//=================== BATTLE MUSIC ===================
// While a player IsInFight, a random-order playlist from Sounds/Music/battle ost plays LOCALLY to
// that ONE player (not to nearby players). It DUCKS (pauses) while a first-time transformation theme
// plays -- those keep playing to EVERYONE nearby exactly as before -- then resumes if the fight is
// still going. When combat ends, the music stops.
//
// Logic summary requested:
//   battle music      = local, only for the player who is fighting
//   transformation    = plays for everyone nearby (unchanged), and battle music yields to it

#define BATTLE_MUSIC_CHANNEL 60 //dedicated channel. In-use elsewhere: 1 (title), 50/51/52 (powerup/beam/fly SFX loops), 1021-1024 (reserved music). 60 is free.
#define BATTLE_MUSIC_DEFAULT_DUR 1200 //fallback track length (deciseconds) for any file not in the duration map (e.g. a newly added track)

var/battle_music_volume_mult = 0.7 //battle music volume as a fraction of the player's clientvolume (the music-volume setting)

//Random-order playlist source: the files actually present in the folder (built dynamically via flist on first use).
var/list/battle_ost_list = null

//Exact track lengths (deciseconds) so the playlist advances seamlessly the moment each track ends.
//Generated from the folder via ffprobe; any file not listed here falls back to BATTLE_MUSIC_DEFAULT_DUR.
var/list/battle_ost_durations = list(
		"Believe in Yourself Unbreakable Determination (Dragon Ball Super OST).mp3" = 841,
		"DBZ - Battle Music 26.mp3" = 887,
		"DBZ - Battle Music 27.mp3" = 848,
		"DBZ - Battle Music 28.mp3" = 1152,
		"DBZ- Battle Music 1 \[EDIT].mp3" = 898,
		"DBZ- Battle Music 1.mp3" = 731,
		"DBZ- Battle Music 10.mp3" = 857,
		"DBZ- Battle Music 11.mp3" = 548,
		"DBZ- Battle Music 12.mp3" = 723,
		"DBZ- Battle Music 13.mp3" = 354,
		"DBZ- Battle Music 14.mp3" = 454,
		"DBZ- Battle Music 15.mp3" = 916,
		"DBZ- Battle Music 16.mp3" = 412,
		"DBZ- Battle Music 17.mp3" = 911,
		"DBZ- Battle Music 18.mp3" = 447,
		"DBZ- Battle Music 19.mp3" = 987,
		"DBZ- Battle Music 2.mp3" = 417,
		"DBZ- Battle Music 20.mp3" = 623,
		"DBZ- Battle Music 21.mp3" = 547,
		"DBZ- Battle Music 22.mp3" = 460,
		"DBZ- Battle Music 23.mp3" = 421,
		"DBZ- Battle Music 24.mp3" = 433,
		"DBZ- Battle Music 25.mp3" = 1166,
		"DBZ- Battle Music 3.mp3" = 738,
		"DBZ- Battle Music 4.mp3" = 525,
		"DBZ- Battle Music 5.mp3" = 516,
		"DBZ- Battle Music 6.mp3" = 287,
		"DBZ- Battle Music 7.mp3" = 905,
		"DBZ- Battle Music 8.mp3" = 740,
		"DBZ- Battle Music 9.mp3" = 854,
		"Dragon Ball Super OST - Dream Tag Match   Coordinate Attack.mp3" = 1399,
		"Dragonball Super - All-Out Battle! (HQ Cover).mp3" = 2028,
		"Dragonball Super - Full Power! \[HQ Cover].mp3" = 1311,
		"Dragonball Super - Mystic Gohan Theme \[HQ Epic Arrangement].mp3" = 850,
		"Dragonball Super - Theme of Android 17 (HQ Cover).mp3" = 1244,
		"Dragonball Super OST - A Dangerous New Enemy \[HQ Cover].mp3" = 646,
		"Dragonball Super OST - Desperate Assault Theme \[HQ Cover].mp3" = 931,
		"The Power to Resist - Dragon Ball Super   Norihito Sumitomo.mp3" = 1412,
	)

proc/get_battle_ost()
	if(battle_ost_list && battle_ost_list.len) return battle_ost_list
	battle_ost_list = list()
	for(var/f in flist("Sounds/Music/battle ost/")) //dynamic: picks up whatever audio is in the folder
		if(findtext(f, ".mp3") || findtext(f, ".ogg") || findtext(f, ".wav")) //skip subdirs / non-audio entries
			battle_ost_list += f
	if(!battle_ost_list.len) //flist found nothing (folder missing at runtime) -> fall back to the known track names
		for(var/k in battle_ost_durations)
			battle_ost_list += k
	return battle_ost_list

mob
	var/tmp
		battle_music_on = 0 //is this player's battle-music loop currently running
		battle_music_suspend_until = 0 //world.time until which battle music is ducked for a transformation theme
		battle_music_last = "" //last track played, so the random pick never repeats the same song back-to-back

mob/proc/start_battle_music()
	set waitfor = 0
	if(battle_music_on || !client) return //already running, or not a real player (NPCs get no battle music)
	battle_music_on = 1
	battle_music_loop()

mob/proc/battle_music_loop()
	set waitfor = 0
	set background = 1
	var/list/L = get_battle_ost()
	if(!L || !L.len)
		battle_music_on = 0
		return
	while(IsInFight && client)
		//ducked for a transformation theme? go silent and wait out the duck window before resuming.
		if(world.time < battle_music_suspend_until)
			client << sound(null, channel = BATTLE_MUSIC_CHANNEL)
			while(world.time < battle_music_suspend_until && IsInFight && client)
				sleep(10)
			continue
		//pick a random track, avoiding an immediate repeat
		var/track = pick(L)
		if(L.len > 1)
			var/guard = 0
			while(track == battle_music_last && guard < 8)
				track = pick(L)
				guard++
		battle_music_last = track
		//play LOCALLY to this one player on the dedicated channel (not to anyone nearby).
		//file()+full path: a RUNTIME string filename does NOT resolve via FILE_DIR (that's compile-time, for 'literal' refs only),
		//so Dream Daemon must stream it from disk. The Sounds folder must ship alongside the .dmb on the host.
		client << sound(file("Sounds/Music/battle ost/" + track), repeat = 0, channel = BATTLE_MUSIC_CHANNEL, volume = round(client.clientvolume * battle_music_volume_mult, 1))
		//hold for this track's length, waking early if the fight ends, the client drops, or a transformation ducks us
		var/dur = battle_ost_durations[track]
		if(!dur) dur = BATTLE_MUSIC_DEFAULT_DUR
		var/waited = 0
		while(waited < dur && IsInFight && client && world.time >= battle_music_suspend_until)
			sleep(10)
			waited += 10
	//fight over (or client gone): silence the channel and let the loop end
	if(client) client << sound(null, channel = BATTLE_MUSIC_CHANNEL)
	battle_music_on = 0

mob/proc/stop_battle_music()
	if(client) client << sound(null, channel = BATTLE_MUSIC_CHANNEL)
	battle_music_suspend_until = 0
	//deliberately do NOT clear battle_music_on here: StopFightingStatus already set IsInFight=0, so the loop will
	//exit and clear the flag itself. Clearing it now would let GlobalStats spin up a 2nd loop if combat re-enters
	//within the loop's <=1s sleep window (two loops fighting over channel 60 -> audible stutter).

//Transformation/form theme. Plays to EVERYONE nearby exactly like emit_Sound (view(src), at each listener's
//clientvolume) AND ducks each listener's battle music for the theme's length so the two never overlap. Battle
//music resumes after, if the listener is still fighting.
mob/proc/emit_TransformMusic(snd, durationDs)
	for(var/mob/M in view(src))
		if(M.client)
			M << sound(snd, volume = M.client.clientvolume)
			if(durationDs) M.duck_battle_music(durationDs)

mob/proc/duck_battle_music(durationDs)
	if(!battle_music_on) return //not playing battle music, nothing to duck
	battle_music_suspend_until = max(battle_music_suspend_until, world.time + durationDs) //extend to the latest end if themes overlap
	if(client) client << sound(null, channel = BATTLE_MUSIC_CHANNEL) //silence battle music immediately; the loop resumes after the window if still fighting
