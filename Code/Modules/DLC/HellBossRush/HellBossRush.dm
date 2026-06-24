obj/HellBossRush
	var/toggleGems=1
mob/var/BRAllowed=0
mob/var/gemcount=0
mob/proc/areYouAllowedInBR()
	if(inteleport==0)
		BRAllowed=0

mob/npc/Enemy/Bosses/BossRush
	var/isBR=1
	BRAllowed=1
	inteleport=1
	NPCTicker()
		set waitfor=0
		set background=1
		AIRunning=1
		BP = max(AverageBP * 4,BP)
		NPCAscension()
	Majin_Ooze
		mobDrops = newlist(/obj/Artifacts/Boosters/SealedGems/Ocean_Gem)
		icon='Majin.dmi'
		physdef = 18
		physoff = 15
		kidef = 18
		kioffMod = 15
		technique = 21
		speed = 21
		strafeAI = 1
		zanzoAI = 1
		isBlaster = 1
		BP_Unleechable = 1
		attackflavors = list("streches his arm out, smacking", "rapidly punches", "headbutts", "sticks his leg out and trips", "attacks")
		dodgeflavors = list("ducks from","turns into a puddle and slithers away from", "stretches several feet into the air, thinning his gut and dodging", "laughs madly as he avoids")
		counterflavors = list("wraps his ooze-like body around the incoming blow, squeezing","counters", "deflects the attack and jabs", "ducks the blow and jams his fist into")

	Rapini
		mobDrops = newlist(/obj/Artifacts/Boosters/SealedGems/Lava_Gem)
		icon='Big Broly.dmi'
		physdef = 21
		physoff = 27
		kidef = 15
		kioffMod = 21
		technique = 9
		speed = 3
		strafeAI = 1
		isBlaster = 1
		BP_Unleechable = 1
		attackflavors = list("charges forward, smashing", "laughs maniacally, stomping his towering foot on", "swings his log arm into", "uppercuts", "shouts incoherently and slams into")
		dodgeflavors = list("sidesteps","jumps out of the way of", "laughs madly as he avoids")
		counterflavors = list("stands still as he takes the attack, immune to it, and kicks","counters", "nullifies the incoming attack and smacks")

	Zenk
		mobDrops = newlist(/obj/Artifacts/Boosters/SealedGems/Ice_Gem)
		icon='Changeling Koola Form 4.dmi'
		physdef = 18
		physoff = 24
		kidef = 18
		kioffMod = 24
		technique = 12
		strafeAI = 1
		isBlaster = 1
		zanzoAI = 1
		BP_Unleechable = 1
		attackflavors = list("pounces on", "flicks his tail forward, smacking", "chomps down on", "uppercuts", "jams his index and middle finger into the eyes of")
		dodgeflavors = list("spins away from", "dodges", "cackles as he avoids", "runs away from")
		counterflavors = list("catches the incoming fist, taking a bite out of","confuses the opponent with an afterimage, slamming into", "catches his opponent mid-attack with his tail, strangling")

	Perfect_Vein
		mobDrops = newlist(/obj/Artifacts/Boosters/SealedGems/Desert_Gem)
		icon='Bio Android - Form 5.dmi'
		physdef = 18
		physoff = 27
		kidef = 15
		kioffMod = 24
		technique = 24
		speed = 18
		strafeAI = 1
		isBlaster = 1
		zanzoAI = 1
		BP_Unleechable = 1
		attackflavors = list("jabs", "flicks his tail forward, smacking", "launches a flying knee into", "roundhouse kicks")
		dodgeflavors = list("slithers away from", "narrowly sidesteps", "cackles as he avoids", "backflips away from")
		counterflavors = list("smirks as he sidesteps the blow, sucker punching","counters", "catches his opponent mid-attack with his tail, absorbing some blood from")

	Cage
		mobDrops = newlist(/obj/Artifacts/Boosters/SealedGems/Anguish_Gem)
		icon='Demon Leader 1.dmi'
		physdef = 18
		physoff = 15
		kidef = 9
		kioff = 21
		technique = 24
		speed = 18
		strafeAI = 1
		isBlaster = 1
		zanzoAI = 1
		BP_Unleechable = 1
		attackflavors = list("uppercuts", "headbutts", "chokeslams", "lets loose a flurry of rapid punches at")
		dodgeflavors = list("sidesteps", "is hit by...wait, it was an Afterimage! Cage snickers at", "swiftly dodges", "bends backwards, ducking the incoming blow")
		counterflavors = list("phases through the attack, punching","counters", "bends backwards and launches his feet into","dodges the attack, slamming his knuckles into")

	Shadow
		mobDrops = newlist(/obj/Artifacts/Boosters/SealedGems/Forgotten_Gem)
		icon='Shadow Mob.dmi'
		physdef = 15
		physoff = 15
		kidef = 15
		kioff = 15
		technique = 15
		speed = 15
		strafeAI = 1
		zanzoAI = 1
		BP_Unleechable = 1
		attackflavors = list("voids", "damages", "erases", "hurts")
		dodgeflavors = list("is not hit by", "denies the attack by", "steps beside", "will never be hit by")
		counterflavors = list("Get out get out get out get out","counters", "reverses the attack onto","takes back control and attacks")

	El_Hermano
		mobDrops = newlist(/obj/Artifacts/Boosters/SealedGems/Jungle_Gem)
		icon='El Hermano.dmi'
		New()
			..()
			overlays += 'El Hermano Suit.dmi'
		physdef = 8
		physoff = 5
		kidef = 8
		kioff = 5
		technique = 5
		speed = 3
		strafeAI = 1
		zanzoAI = 1
		isBlaster = 1
		BP_Unleechable = 1
		attackflavors = list("pounds", "swings a right hook into", "jabs", "headbutts")
		dodgeflavors = list("jumps away from", "ignores the attack by", "steps beside", "dodges")
		counterflavors = list("deflects the attack and shouts, 'Owari da,' and jabs","counters", "reverses the attack onto","catches the incoming blow elbows")

	Guard
		mobDrops = newlist(/obj/Artifacts/Boosters/SealedGems/Armor_Gem)
		icon='Guard1.dmi'
		mobDeath()
			view(8)<<"<font size=[TextSize]><[SayColor]>[src]: I used to be an adventurer like you. Then I took an arrow in the knee..."
			sleep(30)
			icon_state=""
			view(6)<<"<font color=yellow>*[src] takes an arrow to the knee!*"
			sleep(10)
			..()
		physdef = 8
		physoff = 5
		kidef = 8
		kioff = 5
		technique = 5
		speed = 3
		strafeAI = 1
		zanzoAI = 1
		isBlaster = 1
		BP_Unleechable = 1
		attackflavors = list("says \"Trouble?\" as he pounds", "says \"No lollygaggin'\" as he stabs", "jabs", "says \"Disrespect the law, and you disrespect me.\" to")
		dodgeflavors = list("jumps away from", "says \"Let me guess... someone stole your sweetroll!\" as he ignores", "says \"I'd be a lot warmer and a lot happier with a bellyfull of mead.\" to", "dodges")
		counterflavors = list("says \"What is it? Dragons?\" as he counters","counters", "says \"Wait... I know you.\" as reverses the attack onto","says \"You should have never come here!\" as catches the incoming blow and stabs")

	Gatekeeper
		mobDeath()
			view(8)<<"<font size=[TextSize]><[SayColor]>[src]: Not yet...no one else shall bear this Devil Sword!!"
			sleep(30)
			icon_state=""
			view(6)<<"<font color=yellow>*[src] forces himself back up, and lets out a blood curling scream as his entire body transforms!*"
			sleep(10)
			emit_Sound('DTshout.wav')
			icon='Vergil DT.dmi'
			spawn for(var/mob/M in view(usr))
				M.Quake()
			for(var/turf/T in view(24,src))
				if(prob(20)) createDustmisc(T,2)
				if(prob(1)) createDustmisc(T,3)
				if(prob(1)) createLightningmisc(T,9)
				if(prob(1)) createLightningmisc(T,5)
			sleep(50)
			view(8)<<"<font size=[TextSize]><[SayColor]>[src]: You're going down..."
			emit_Sound('VergilDT1.wav')
			var/mob/npc/Enemy/Bosses/BossRush/Gatekeeper_DT/A=new/mob/npc/Enemy/Bosses/BossRush/Gatekeeper_DT
			A.loc=locate(src.x,src.y,src.z)
			..()
		icon='Deaths Form.dmi'
		physdef = 6
		physoff = 9
		kidef = 7
		technique = 9
		speed = 9
		strafeAI = 1
		zanzoAI = 1
		BP_Unleechable = 1
		attackflavors = list("slices", "swipes his sword at", "uses the sheathe of his blade to smack")
		dodgeflavors = list("teleports away from", "sidesteps", "dodges")
		counterflavors = list("deflects the attack and strikes", "parries","counters")

	Gatekeeper_DT
		mobDeath()
			emit_Sound('landhard.ogg')
			var/list/localmobs[1]
			for(var/mob/worthyopponent in view(usr))
				if(!worthyopponent==usr&&localmobs[1]==null)
					localmobs[1] = worthyopponent
			if(localmobs[1])
				var/mob/worthyopponent = localmobs[1]
				view(8)<<"<font size=[TextSize]><[SayColor]>[src]: [worthyopponent]..."
			sleep(20)
			view(8)<<"<font color=yellow>*[src] falls to the ground, dropping his sword as he fades away*"
			var/obj/items/Equipment/Weapon/Sword/Yamato/C = new
			C.loc = locate(src.x,src.y-1,src.z)
			..()
		icon='Vergil DT.dmi'
		New()
			..()
			overlays += 'Yamato.dmi'
		physdef = 9
		physoff = 10
		kioff = 7
		kidef = 9
		technique = 10
		speed = 10
		strafeAI = 1
		zanzoAI = 1
		isBlaster = 1
		BP_Unleechable = 1
		attackflavors = list("furiously slices", "chops down", "rushes in and stabs", "cuts")
		dodgeflavors = list("phases away from", "is unharmed from the attack by", "sidesteps", "dodges")
		counterflavors = list("deflects the attack and impales","counters", "reverses the attack onto","parries")

obj/HellBossRush/Gatekeeper
	IsntAItem=1
	density=1
	Bolted=1
	canGrab=0
	icon='Deaths Form.dmi'
	icon_state="Meditate"
	verb
		Talk()
			set src in oview(1)
			set category = null
			switch(alert(usr, "Abandon all hope ye who enter here...","","Who are you?","What is this place?","What are you guarding?"))
				if("Who are you?")
					switch(alert(usr, "That name is lost to time. I am but a gatekeeper for the Demon Lord now, a role I have served as for many, many years. All that matters to me is that I see my duty through...","","Ok","Can we fight?"))
						if("Can we fight?")
							alert(usr, "No. I have no reason to, not here at least. You can hit me as much as you wish, it would affect me very little here.","","Ok")
				if("What is this place?")
					switch(alert(usr, "A mystic plane of Hell abandoned by its denizens. A great demon once fought off armies of his own kind upon this once blood-stained ground. Now, it is but a memory of a time long past. Very few souls come out here. Although, you seem to be the exception...","","Ok...","Demon lord?"))
						if("Demon lord?")
							alert(usr, "You have heard of it, have you not? The legend of the Dark Knight? Millenia ago, there was a war between the mortal world and the Underworld. But, one demon from the Underworld woke up to justice, and stood against Hell's legions alone. With his sword, he shut the portal to Hell, and he sealed the evil entities off from the mortal plane. Although, since he was a demon himself, his power was also sealed here. This spot marks where he first began his war, as well as where he ended it...","","Ok.")
				if("What are you guarding?")
					switch(alert(usr, "The sealed plane of Hell. I alone hold the key to accessing this cursed and revered dimension. It is a place no mere demon would ever set foot in. The strongest and most evil souls of the mortal world rest here. Upon entering, it is impossible to leave until you put them all to rest, or unless you yourself are slain. A legendary artifact awaits for the one to clear this bloody palace, if you wish to enter. Such a feat has not been done in over a hundred years, however...","","I want to fight!", "I'll pass."))
						if("I'll pass.")
							alert(usr, "A shame...I receive so few visitors. I truly hoped you would at least entertain me. If you change your mind, do come back.")
						if("I want to fight!")
							if(!AscensionStarted)
								alert(usr, "Hmm...no. You are far too weak. It would be a waste to send you in there if you cannot even provide them a challenge. Come back when your power has ascended.","","Fine.","(Yeah well tell Iro to go fuck himself)")
							else
								alert(usr, "I envy your optimism. May you reign victorious over the accursed one, or die in glory.")
								emit_Sound('YamatoJudgementCut.wav')
								view(usr) << "The gatekeeper slashes an object through the air at lightning speed, opening a small rift that sucks in [usr]!"
								sleep(30)
								usr.BRAllowed=1
								usr.loc=locate(460,280,9)
								usr.inteleport=1

obj/Artifacts/Boosters/SealedGems
	icon='Soul Gems.dmi'
	dropProbability=10
	cantblueprint=1
	IsntAItem=1
	Bolted=1
	canGrab=0
	/*var/strength=0
	var/defense=0
	var/ki=0
	var/resistance=0
	var/teq=0
	var/kiskl=0
	var/magskl=0
	var/spd=0
	var/willpower=0*/

	Ocean_Gem
		icon_state="Blue Gem"
		name="Ocean Gem"
		defense = 2
		ki = 2
		resistance = 2
		teq = 3
		Click()
			usr<<"The gemstone responds to your touch with somber ocean waves."
			sleep(10)
			usr.GotoPlanet("Earth")
	Lava_Gem
		icon_state="Red Gem"
		name="Lava Gem"
		defense = 2
		strength = 2
		spd = 2
		willpower = 3
		Click()
			usr<<"The gemstone responds to your touch with a raging blaze."
			sleep(10)
			usr.GotoPlanet("Vegeta")
	Desert_Gem
		icon_state="Yellow Gem"
		name="Desert Gem"
		teq = 2
		strength = 2
		spd = 2
		defense = 3
		Click()
			usr<<"The gemstone responds to your touch with the endless sands of time."
			sleep(10)
			usr.GotoPlanet("Desert")
	Jungle_Gem
		icon_state="Green Gem"
		name="Jungle Gem"
		ki = 2
		kiskl = 2
		spd = 2
		strength = 3
		Click()
			usr<<"The gemstone responds to your touch with the adventurous scents of the jungle."
			sleep(10)
			usr.GotoPlanet("Arconia")
	Forgotten_Gem
		icon_state="Gray Gem"
		name="Forgotten Gem"
		spd = 2
		strength = 2
		ki = 3
		resistance = 3
		Click()
			usr<<"The gemstone responds to your touch with a melody of the past."
			sleep(10)
			usr.Move(locate(440,387,9))
			usr<<"The gem returns you to the False Paradise."
	Ice_Gem
		icon_state="Ligh Blue Gem"
		name="Ice Gem"
		spd = 2
		resistance = 2
		kiskl = 2
		ki = 3
		Click()
			usr<<"The gemstone responds to your touch with the chills of the frozen tundra."
			sleep(10)
			usr.GotoPlanet("Icer Planet")
	Anguish_Gem
		icon_state="Purple Gem"
		name="Anguish Gem"
		spd = 2
		willpower = 2
		resistance = 2
		defense = 3
		Click()
			usr<<"The gemstone responds to your touch with dark premonitions."
			sleep(10)
			usr.GotoPlanet("Hell")
	
	Armor_Gem
		icon_state="Gray Gem"
		name="Armor Gem"
		willpower = 2
		resistance = 3
		defense = 3