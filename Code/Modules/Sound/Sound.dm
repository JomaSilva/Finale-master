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
			var/played=0
			TitleMusic
			if(TitleMusicOn)
				var/titlesong=0
				recalculaterand
				titlesong=rand(1,6)//calls a random number from 1 to 6 (if you're adding more title music, 6 is in this case the total number of tracks.)
				switch(titlesong)
					if(1)
						if(played!=1)//sees if this song has already been played
							musicdatumvar = sound('DBZBudokai2Theme.wav',volume=clientvolume,channel=1,wait=0) //sets the var to the song, with appropriate vars. channel makes the song overwrite the other song on it's channel.
							usr<<musicdatumvar //does the actual sending to the player.
							//can be wav, ogg, or midi. prefer midi because it's small.
							//parameters are numerous, but the minimum is ('FileName', volume=clientvolume)
							//additionally, channel=1 for music, to support fading in or out. (default is -1, which means it takes the first available channel, which is 1 or 2)
							usr<<"Playing: Dragon Ball Z Budokai 2 Opening (Sax Ver.)" //tells the person what's playing
							played=1 //kinda important, makes it so that the same song doesn't play multiple times in a row.
							playing=1 //also kinda important. if you don't have a sav file and press reload this stops songs from playing together.
							spawn(2520)//this is the song length, delay is to keep the next song from playing. Calculated by ((((songlength's min*60)+song length's sec)+1)*10)
								playing=0 //sets var back to 0 to signify song ain't playing doc.
								goto TitleMusic //finally, go back to titlemusic to redo everything all over again.
						else goto recalculaterand//if so, calculate rand again.
					if(2)
						if(played!=2)
							musicdatumvar = sound('DBZBudokaiPlanetNamekStage.mid',volume=clientvolume,wait=1)
							usr<<"Playing: Dragon Ball Z Budokai: Challenger"
							usr<<musicdatumvar
							played=2
							playing=1
							spawn(1620)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(3)
						if(played!=3)
							musicdatumvar = sound('getthatdragonball.mid',volume=clientvolume,wait=1)
							usr<<"Playing: Dragon Ball Theme: Makafugishi Adventure"
							usr<<musicdatumvar
							played=3
							playing=1
							spawn(1000)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(4)
						if(played!=4)
							musicdatumvar = sound('DragonballV.mid',volume=clientvolume,wait=1)
							usr<<"Playing: Dragon Ball Super Opening 2"
							usr<<musicdatumvar
							played=4
							playing=1
							spawn(900)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(5)
						if(played!=5)
							musicdatumvar = sound('Bloody Stream.ogg',volume=clientvolume,wait=1)
							usr<<"Playing: Bloody Stream - Orchestral (JoJo's BA - Part 2)"
							usr<<musicdatumvar
							played=5
							playing=1
							spawn(940)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(6)
						if(played!=6)
							musicdatumvar = sound('01. Super Survivor.ogg',volume=clientvolume,wait=1)
							usr<<"Playing: Dragon Ball Z: Super Survivor"
							usr<<musicdatumvar
							played=6
							playing=1
							spawn(2560)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(7)
						if(played!=7)
							musicdatumvar = sound('chala.ogg',volume=clientvolume,wait=1)
							usr<<"Playing: Cha-la Head Cha-la (2006 Remix)"
							usr<<musicdatumvar
							played=7
							playing=1
							spawn(2560)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(8)
						if(played!=8)
							musicdatumvar = sound('wegottapower.mid',volume=clientvolume,wait=1)
							usr<<"Playing: We Gotta Power"
							usr<<musicdatumvar
							played=8
							playing=1
							spawn(2560)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(9)
						if(played!=9)
							musicdatumvar = sound('Rightfully.ogg',volume=clientvolume,wait=1)
							usr<<"Playing: Rightfully by Mili."
							usr<<musicdatumvar
							played=9
							playing=1
							spawn(2100)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(10)
						if(played!=10)
							musicdatumvar = sound('fightinggold.ogg',volume=clientvolume,wait=1)
							usr<<"Playing: Fighting Gold by Coda."
							usr<<musicdatumvar
							played=10
							playing=1
							spawn(2530)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(11)
						if(played!=11)
							musicdatumvar = sound('metalgearsaga.ogg',volume=clientvolume,wait=1)
							usr<<"Playing: Metal Gear Saga, from Metal Gear Solid 4 OST, by Harry Gregson Williams."
							usr<<musicdatumvar
							played=11
							playing=1
							spawn(2600)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(12)
						if(played!=12)
							musicdatumvar = sound('Godhand.ogg',volume=clientvolume,wait=1)
							usr<<"Playing: Godhand!! (End Credits/ Outro) From Godhand (PS2)"
							usr<<musicdatumvar
							played=12
							playing=1
							spawn(1730)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(13)
						if(played!=13)
							musicdatumvar = sound('dbzkaiopening.ogg',volume=clientvolume,wait=1)
							usr<<"Playing: Dragon Ball Z Kai Opening"
							usr<<musicdatumvar
							played=13
							playing=1
							spawn(860)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(14)
						if(played!=14)
							musicdatumvar = sound('StandProud.ogg',volume=clientvolume,wait=1)
							usr<<"Playing: JoJo Opening 3: Stand Proud, by Jin Hashimoto"
							usr<<musicdatumvar
							played=14
							playing=1
							spawn(910)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(15)
						if(played!=15)
							musicdatumvar = sound('mysticaladventurenengl.ogg',volume=clientvolume,wait=1)
							usr<<"Playing: Mystical Adventure English (DB Opening 1)"
							usr<<musicdatumvar
							played=15
							playing=1
							spawn(1100)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					if(16)
						if(played!=16)
							musicdatumvar = sound('hitstheme.ogg',volume=clientvolume,wait=1)
							usr<<"Playing: Hit's Theme from Dragon Ball FighterZ"
							usr<<musicdatumvar
							played=16
							playing=1
							spawn(3160)
								playing=0
								goto TitleMusic
						else goto recalculaterand
					//TODO:
					//-Add custom soundtracks ingame.
					//-Add a way of removing disliked songs. (some kind of favorites menu?)
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