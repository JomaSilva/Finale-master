/*These masteries are exclusively for Artifacts Masteries. Typically, an Artifact Mastery will unlock after meeting
certain circumstances for said artifact (pullling the Master Sword, crafting a Devil Arm/Heroes' Relic, etc.).
These should typically unlock through applications and major IC development.
Since Artifact Masteries are meant to signify the character improving and unleashing the true power of their artifact, it is recommended that, instead of primarily
stat increases, they add only skills.
*/
mob/var
	MSWorthy=0 //Is the user worthy of the Master Sword? Edit this on the character so it can be pulled from its pedestal. Will unlock MS mastery once the MS is pulled
	MSPower=0 //Impacts the strength of the Master Sword and its skills

/datum/mastery/Artifact
//Weapon Artifacts
	Soul_of_the_Hero //Master Sword mastery. Though you get few skills and the only stat boost is with MSPower, it is intended to -decimate- evil characters/beings
		name = "Soul of the Hero"
		desc = "Your unwavering courage and strength allows you to utilize the true power of the Master Sword. You step on the path of destiny, dedicating your life to protecting the world and eliminating evil where it lurks."
		lvltxt = "Per level: Master Sword Power +0.05\nEvery 10 levels: Sword Skill +0.1.\nLevel 10: Skyward Strike\nLevel 20: Hurricane Blade\nLevel 90: Seal the Darkness\nLevel 100: ???"
		reqtxt = "You must pull the Master Sword from its sacred pedestal before possessing the Soul of the Hero."
		visible = 0 //Hidden masteries aren't visible dummy
		hidden = 1 //So that its invisible from mastery lists
		tier = 1
		battle = 0
		nocost = 0
		acquire(mob/M)
			..()
			visible=1
			savant<<"Your soul resonates with the Master Sword, unlocking some of its true power!"
			savant.MSPower+=1.1

		remove()
			if(!savant)
				return
			savant<<"Your bond with the Blade of Evil's Bane diminishes, and it alongside its true splendor return to rest..."
			savant.MSPower=0
			savant.swordskill-=0.1*round(level/10)
			removeverb(/mob/keyable/combo/sword/verb/Skyward_Strike)
			removeverb(/mob/keyable/combo/sword/verb/Hurricane_Blade)
			removeverb(/mob/keyable/verb/Seal_the_Darkness)
			removeverb(/mob/keyable/verb/Blade_of_Evils_Bane)
			..()

		levelstat()
			..()
			savant<<"The Master Sword brimmers with a flashing aura! The Soul of the Hero is now level [level]!"
			savant.MSPower+=0.05
			if(level % 10 == 0)
				savant.swordskill+=0.1
			if(level == 10)
				savant<<"Your fortitude shines through the Master Sword, bursting holy power through the air! You learned Skyward Strike!"
				addverb(/mob/keyable/combo/sword/verb/Skyward_Strike)
			if(level == 20)
				savant<<"You feel you can execute an ancient sword technique combined with the might of the Master Sword. You learned Hurricane Blade!"
				addverb(/mob/keyable/combo/sword/verb/Hurricane_Blade)
			if(level == 90)
				savant<<"'Wielding the Blade of Evil's Bane, he sealed the dark one away and gave the land light.' You learned Seal the Darkness!"
				addverb(/mob/keyable/verb/Seal_the_Darkness)
			if(level == 100)
				savant<<"At long last, your soul and the Master Sword resonate as one; the true, ultimate power of the Master Sword is finally yours! You learned Blade of Evil's Bane!"
				addverb(/mob/keyable/verb/Blade_of_Evils_Bane)
				savant.MSPower-=0.05 //Look I did the math the max level wouldve ended in a 6.05 that extra .05 wouldve bothered me please understand

//Artifact Skills
//Typically, Artifact skills should only be usable when the usr has the respective artifact equipped, unless said artifact has permanent effects on their body or whatnot.
mob/keyable/combo/sword/verb/Skyward_Strike()
	set category = "Skills"
	desc = "Launch a sword beam through the air in a straight line similar to yet stronger than Wind Slice. Requires the Master Sword. Strengthens as you level up Soul of the Hero."
	var/counter=0
	for(var/obj/items/Equipment/Weapon/Sword/Master_Sword/A in usr)
		if(A.equipped)
			counter=1
	if(!counter)
		usr<<"You must have the Master Sword equipped to use this skill!"
		return
	if(usr.rangedCD)
		usr<<"Ranged skills are on CD for [rangedCD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<4||usr.HP<(100-usr.MSPower*2))
		usr<<"You can't use this now!"
		return
	var/passbp = usr.MSPower * usr.expressedBP //MSPower goes hand-in-hand with BP here
	usr.ki-=20
	usr.stamina-=4
	flick("Attack",usr)
	spawn(3)
		if(usr.flight)
			usr.icon_state="Attack"
	var/bcolor='Zankoukyokuha.dmi'
	bcolor+=rgb(usr.blastR,usr.blastG,usr.blastB)
	var/obj/attack/blast/A=new/obj/attack/blast
	usr.emit_Sound('fire_kiblast.wav',0.5)
	A.loc=locate(usr.x,usr.y,usr.z)
	A.icon=bcolor
	A.avoidusr=1
	A.density=1
	A.basedamage=1+usr.damage/2*MSPower
	A.BP=passbp
	A.physdamage=1
	A.mods=(usr.Ephysoff**2)*usr.Etechnique
	A.murderToggle=usr.murderToggle
	A.proprietor=usr
	A.ownkey=usr.displaykey
	A.dir=usr.dir
	A.ogdir=usr.dir
	spawn A.Burnout()
	walk(A,usr.dir)
	spawn AddExp(usr,/datum/mastery/Melee/Sword_Mastery,5)
	usr.rangedCD=10
	spawn(3) usr.icon_state=""

mob/keyable/combo/sword/verb/Hurricane_Blade()
	set category = "Skills"
	desc = "Spin the Master Sword around in a circle, attacking enemies surrounding you. This has a small charge-up time. Strengthens as you level up Soul of the Hero."
	var/counter=0
	for(var/obj/items/Equipment/Weapon/Sword/Master_Sword/A in usr)
		if(A.equipped)
			counter=1
	if(!counter)
		usr<<"You must have the Master Sword equipped to use this skill!"
		return
	 
	var/kireq=usr.Ephysoff*BaseDrain*0.4*10
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 13*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	usr.canmove=0
	animate(usr, color = "white", time = 10)
	animate(usr, color = null, time = 10)
	usr.canmove=1
	updateOverlay(/obj/overlay/effects/flickeffects/hurricaneblade)
	for(var/mob/M in oview(1))
		spawn MeleeAttack(M,usr.MSPower)
	sleep(2)
	for(var/mob/M in oview(1))
		spawn MeleeAttack(M,usr.MSPower)
	removeOverlay(/obj/overlay/effects/flickeffects/hurricaneblade)
	spawn AddExp(usr,/datum/mastery/Melee/Sword_Mastery,10)

mob/keyable/verb/Seal_the_Darkness()
	set category = "Skills"
	desc = "Using the Master Sword's sacred power, cast a powerful seal on a foe directly in front of you intended for evil forces. This skill can only be used once every 24 hours!"
	var/counter=0
	for(var/obj/items/Equipment/Weapon/Sword/Master_Sword/A in usr)
		if(A.equipped)
			counter=1
	if(!counter)
		usr<<"You must have the Master Sword equipped to use this skill!"
	if(usr.specialCD)
		usr<<"Special skills on CD for [specialCD/10] seconds."
		return
	if(usr.canfight<=0||usr.KO||usr.med||usr.stamina<50)
		usr<<"You can't use this now!"
		return
	var/kireq=usr.Ephysoff*BaseDrain*0.4*10
	if(!usr.med&&!usr.train&&!usr.KO&&usr.Ki>=kireq&&!usr.basicCD&&usr.canfight)
		usr.ki-=kireq
		usr.basicCD = 13*usr.Eactspeed
	else
		usr<<"You must be combat ready (not be stunned, be able to attack, and not have a cooldown happening (Basic CD = -[basicCD/10]- seconds)) and have at least [kireq] ki."
		return
	var/choice = input(usr,"Select a mob in view. A mafuba will be sent towards them. The sealing effect will be effective up to your BP, as long as the generated item is kept safe.") as null|mob in view()
	if(isnull(choice))
		usr << "You choose not to seal anything."
		return
	var/obj/items/SealingItem/B = new
	B.loc = locate(usr.x,usr.y,usr.z)
	var/obj/attack/blast/MafubaBlast/A  = new
	A.loc = locate(usr.x,usr.y,usr.z)
	step(A,usr.dir)
	A.density=1
	A.basedamage=0.1
	A.BP=expressedBP
	A.mods=Ekioff*Ekiskill
	A.murderToggle=usr.murderToggle
	A.proprietor=usr
	A.ownkey=usr.displaykey
	A.dir=usr.dir
	A.SealStrength = usr.expressedBP + (usr.expressedBP*(usr.MSPower*3))
	A.targetcontainer = B
	spawn(70) del(A)
	walk_to(A,choice)
	spawn AddExp(usr,/datum/mastery/Melee/Sword_Mastery,1000)
	var/CDDecidor = 864000 //24 hours divided by the usr's Master Sword power at the time of using the skill.
	usr.specialCD = CDDecidor

mob/keyable/verb/Blade_of_Evils_Bane()
	set category = "Skills"
	var/counter=0
	for(var/obj/items/Equipment/Weapon/Sword/Master_Sword/A in usr)
		if(A.equipped)
			counter=1
	if(!counter)
		usr<<"You must have the Master Sword equipped to use this skill!"
	if(usr.canfight<=0||usr.KO||usr.med)
		usr<<"You can't use this now!"
		return
	desc = "Tap into the full power of the Master Sword, dealing more damage with your blade and Master Sword skills. This buff does even more damage to evil beings."
	if(!usr.buffOn)
		view() << "<font color=yellow>[usr] calls upon the true power of the Master Sword to banish evil!"
		usr.AddEffect(/effect/buff/artifact/bladeofevilsbane) //the buffOn var is ticked to 1 inside where bladeofevilsbane is created (Damage Effects.dm)
	else if (usr.buffOn)
		usr << "This buff is already active!"
		return

obj/overlay/effects/flickeffects/BoEB/EffectStart()
	var/icon/I = icon('UIAurafixed.dmi')
	icon = I
	..()

obj/overlay/effects/flickeffects/hurricaneblade/EffectStart()
	var/icon/I = icon('CircleWind.dmi')
	icon = I
	pixel_x-=32
	pixel_y-=32
	animate(src, alpha=0, time=5)
	..()