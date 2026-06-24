mob/proc/Impact(var/mob/M,var/dmg,var/unavoidable,var/grnd)
	set waitfor = 0
	if(!M)
		return
	if(M.KB)
		return
	dmg = round(dmg,1)
	var/testdir = rand_dir_in_dir(dir)
	//var/olddir = dir
	//var/oldloc = M.loc
	dmg = min(dmg,30)//thirty tile max KB. Can be changed or log'd
	var/threshold = 4*M.Ewillpower*M.hpratio*BPModulus(M.expressedBP,expressedBP)
	if((dmg > threshold||unavoidable)&&!M.KB)
		dmg = round(min(max(dmg,5)/1.5,9),1)
		M.kbdir = usr.dir
		M.kbpow = usr.expressedBP
		M.kbdur = dmg
		M.AddEffect(/effect/knockback)

	else if(dmg>0.5*threshold&&!M.stagger&&!M.KB)//stagger
		M.AddEffect(/effect/stagger)
		step(M,testdir)
		sleep(1)
		step(M,testdir)
		sleep(3)
	else if(dmg>1&&!M.slowed&&!M.stagger&&!M.KB)//slow
		M.AddEffect(/effect/slow)
		//M.Small_Impact(1,dir)
		step(M,testdir)
		sleep(1)

mob/proc/Small_Impact(dmgtype,mdir)
	set waitfor = 0
	var/translatenum
	var/peak
	var/origdir = mdir
	var/matrix/nM = src.transform
	var/adjustnum1
	var/adjustnum2
	switch(dmgtype)
		if(null)
			return FALSE
		if(1)
			translatenum = 2
			peak = 1
		if(2)
			translatenum = 4
			peak = 2
	while(translatenum >= 1)
		nM = src.transform
		var/num
		if(translatenum > peak)
			num += 5
		if(translatenum <= peak)
			num += -5
		translatenum -= 1
		switch(origdir)
			if(NORTH)
				adjustnum1 = num
			if(SOUTH)
				adjustnum1 = -num
			if(EAST)
				adjustnum2 = -num
			if(WEST)
				adjustnum2 = num
			if(NORTHEAST)
				adjustnum1 = -num
				adjustnum2 = -num
			if(NORTHWEST)
				adjustnum1 = num
				adjustnum2 = -num
			if(SOUTHEAST)
				adjustnum1 = -num
				adjustnum2 = num
			if(SOUTHWEST)
				adjustnum1 = num
				adjustnum2 = num
		nM.c += adjustnum2
		nM.f += adjustnum1
		src.transform = nM
		sleep(1)