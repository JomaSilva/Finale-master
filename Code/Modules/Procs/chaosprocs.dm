proc/cause_Chaos(loc,storedenergy)
	set waitfor = 0
	if(!isturf(loc)) return
	if(!storedenergy) return
	switch(rand(1,100)) //10 different effects, all with differing rarity
		if(1 to 5)//5% chance. Free money!
			var/obj/Zenni/nZ = new
			nZ.zenni = round(storedenergy / 10)
			nZ.loc = locate(loc)
			return storedenergy
		if(6 to 10)//another 5% chance, get damaged
			for(var/mob/M in view(loc))
				M.SpreadDamage((log(2,max(2,storedenergy)) * 10),1)
		if(23 to 30)//8% chance | needs a 'rareish' effect
			createDustmisc(loc,1)
			return (storedenergy - ((storedenergy * 3)/ 4))
		if(31 to 40)//10% | actually a 'nothing' effect
			return (storedenergy / 5)
		if(11 to 22)//12% chance.
			spawnrandmob(loc,0) //spawn random mob, at 'loc' and with hostiles enabled, but no bosses.
			return (storedenergy / 5)
		if(41 to 60)//20% Exploooooosion!
			spawnExplosion(loc,null,storedenergy * 10,4)
			return storedenergy
		if(61 to 70)//10%
			spawnrandmob(loc,1) //spawn random mob, at 'loc' and with hostiles enabled, but no bosses.
			return (storedenergy / 5)
		if(71 to 80)
			createDustmisc(loc,3)
			return (storedenergy / 5)
			//random magic event here
		if(81 to 90)
			createLightningmisc(loc,4)
			return (storedenergy / 5)
			///random magic event here- mean actual magic, not spawning in mobs or something.
		if(91 to 100)//10% nothing but lightning showing up
			createLightningmisc(loc,2)
			return (storedenergy / 10)

proc/spawnrandmob(loc,mobtyp)
	if(!loc) return
	var/nm = rand(1, 1 + mobtyp)
	switch(nm)
		if(1)
			spawnrandPassMob(loc)
		if(2)
			spawnrandHostMob(loc)
		if(3)
			spawnrandBossMob(loc)

proc/spawnrandPassMob(loc)
	if(!loc) return
	var/list/rnmob = typesof(/mob/npc/shy)
	rnmob -= /mob/npc/shy
	spawnMob(loc,pick(rnmob))

proc/spawnrandHostMob(loc)
	if(!loc) return
	var/list/rnmob = typesof(/mob/npc/Enemy)
	rnmob -= /mob/npc/Enemy
	spawnMob(loc,pick(rnmob))

proc/spawnrandBossMob(loc)
	if(!loc) return
	var/list/rnmob = typesof(/mob/npc/Enemy/Bosses)
	rnmob -= /mob/npc/Enemy/Bosses
	spawnMob(loc,pick(rnmob))

proc/spawnMob(loc,type)
	for(var/a in args)
		if(a == null)
			return
	var/mob/nM = new type
	nM.loc = locate(loc)