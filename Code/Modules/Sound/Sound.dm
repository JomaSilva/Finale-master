#define MUSIC_CHANNEL_1 1024
#define MUSIC_CHANNEL_2 1023
#define MUSIC_CHANNEL_3 1022
#define MUSIC_CHANNEL_4 1021
//Sometimes required to play music. A #define is basically a macro, and the compiler automatically replaces X with Y. (#define X Y will replace every X value in code with Y.)
//Despite being duplicated in Sound System.dm it doesn't seem to want to compile here for some reason, so if you're having issues with MUSIC_CHANNEL_1 being a undef variable, look no further.
mob
	var/tmp
		soundeffectlist
client
	var
		clientvolume=50
		clientsoundvolume=40
client
	var
		TitleMusicOn=1
		playing=0
	proc
		Title_Music() if(playing==0)
			//MENU OST (2026-07-05): toca UMA faixa aleatoria da pasta "Sounds/Music/Menu ost" em LOOP
			//ate o jogador entrar no jogo (Music_Fade corta). flist le o DISCO do host em runtime e
			//sound() em runtime exige file()+caminho completo (mesma regra da musica de batalha).
			if(!TitleMusicOn) return
			var/list/tracks = list()
			for(var/f in flist("Sounds/Music/Menu ost/"))
				if(copytext(f, length(f)) == "/") continue //subpasta: ignora
				var/ext = lowertext(copytext(f, max(length(f) - 3, 1)))
				if(ext == ".mp3" || ext == ".ogg" || ext == ".wav" || ext == ".mid")
					tracks += "Sounds/Music/Menu ost/[f]"
			if(!tracks.len) return
			var/tpath = pick(tracks)
			musicdatumvar = sound(file(tpath), volume=clientvolume, channel=1, wait=0, repeat=1)
			src << musicdatumvar
			playing = 1
			var/nm = tpath //nome amigavel no chat: so o arquivo, sem pasta nem extensao
			var/slash = 0
			for(var/i = length(nm), i >= 1, i--)
				if(copytext(nm, i, i + 1) == "/") { slash = i; break }
			if(slash) nm = copytext(nm, slash + 1)
			nm = copytext(nm, 1, max(length(nm) - 3, 1))
			if(mob) to_chat(mob, "Playing: [nm]")

		Music_Fade()
			musicdatumvar = sound()
			src << musicdatumvar
			playing=0
var/sound/musicdatumvar
//now for sound loops heh
mob
	var
		poweruprunning
		beamisrunning
		isflying
	var/tmp
		powerupsoundgo
		beamsoundgo
		flysoundgo
		powerupsoundon
		beamsoundon
		flysoundon
mob
	proc
		soundUpdate()
			set background = 1
			while(client) if(loggedin)
				sleep(2)
				if(!client) return
				var/sound/powerupsound=sound('aurapowered.wav',volume=round(usr.client.clientvolume/6,1),repeat=1,channel=50,wait=0)
				var/sound/beamsound=sound('beamhead.wav',volume=round(usr.client.clientvolume/10,1),repeat=1,channel=51,wait=0)
				var/sound/flysound=sound('aurapowered.wav',volume=round(usr.client.clientvolume/10,1),repeat=1,channel=52,wait=0)
				for(var/mob/M in view(usr))
					if(M.poweruprunning)
						powerupsoundgo=1
					if(M.beamisrunning)
						beamsoundgo=1
					if(M.isflying)
						flysoundgo=1
				//
				if(powerupsoundgo)
					if(!powerupsoundon)
						powerupsound.status |= SOUND_UPDATE
						usr << powerupsound
						powerupsoundon=1
				else if(powerupsoundon)
					powerupsound.status = SOUND_PAUSED
					usr << powerupsound
					powerupsoundon=0
				//
				if(beamsoundgo)
					if(!beamsoundon)
						beamsound.status |= SOUND_UPDATE
						usr << beamsound
						beamsoundon=1
				else if(beamsoundon)
					beamsound.status = SOUND_PAUSED
					usr << beamsound
					beamsoundon=0
				//
				if(flysoundgo)
					if(!flysoundon)
						flysound.status |= SOUND_UPDATE
						usr << flysound
						flysoundon=1
				else if(flysoundon)
					flysound.status = SOUND_PAUSED
					usr << flysound
					flysoundon=0
				//
				if(powerupsoundgo||beamsoundgo||flysoundgo) //optimizes by using only one for() statement.
					var/nobodyisdoingit=0
					var/nobodyisdoingit2=0
					var/nobodyisdoingit3=0
					for(var/mob/M in view(usr))
						CHECK_TICK
						sleep(1)
						if(M.poweruprunning)
							nobodyisdoingit=1
						if(M.beamisrunning)
							nobodyisdoingit2=1
						if(M.isflying)
							nobodyisdoingit3=1
					if(!nobodyisdoingit)
						powerupsoundgo=0
					if(!nobodyisdoingit2)
						beamsoundgo=0
					if(!nobodyisdoingit3)
						flysoundgo=0