mob/proc/makeCopy(var/type,var/targetRace,var/targetClass,var/mobType,var/sentient)//sentient means: copy skills over, this copy is meant to be played.
	var/mob/z = new mobType
	AssignDupeVars(z)

	if(targetRace||targetClass)
		z.Race=targetRace
		z.Class=targetClass
		z.genome = new/datum/genetics/Artificial(fetch_race_by_Name("[targetRace]"))
	switch(type)
		if(1) //meta
			z.name="[usr.name] Meta-#[rand(1,1000)]"
			var/icon/I= icon(usr.icon)
			I.Blend(rgb(50,100,200,255),ICON_MULTIPLY)
			z.icon=I
			z.oicon=I
			z.Age=1
			z.Father = usr.name
			z.spacebreather=1
		if(2) //splitform
			z.BP = usr.expressedBP/2
			z.loc=locate(usr.x+rand(-1,1),usr.y+rand(-1,1),usr.z)
			z.name="[usr.name] Copy"
			if(usr.Race=="Bio-Android")
				z.overlayList.Remove(z.overlayList)
				z.overlaychanged=1
				z.icon='Cell Jr.dmi'
			if(usr.Race=="Tsujin"|usr.Class=="Tsujin") z.icon='GochekAndroid.dmi'
			else z.icon = icon
			if(!z.genome) z.genome = new usr.genome.type(fetch_race_by_Name("[usr.genome.majority_genome]"))
			z.attackable = 1
			z.temporary=1
		if(3) //clone
			z.name="[usr.name] (Clone)"
			var/icon/I= icon(usr.icon)
			z.icon=I
			z.oicon=I
			z.Father = usr.name
		if(4) // droid
			z.name="[usr.name] Android Body Model-#[rand(1,1000)]"
			z.icon='GochekAndroid.dmi'
			//var/icon/I= icon(z.icon)
			//I.Blend(rgb(50,100,200,255),ICON_MULTIPLY)
			//z.icon=I
			//z.oicon=I
			z.Age=1
			z.Father = usr.name
			z.genome = new/datum/genetics/Android(/datum/genetics/proto/Android)
			z.spacebreather=1
	if(sentient)
		//z.totalskillpoints = totalskillpoints
		switch(type)
			if(1) z.BP = BP * 0.5
			if(3) z.BP = BP * 0.15
			if(4) z.BP = BP * 0.25
		//CopySkills(z)
		z.needs_manual_custom = 1
	z.Savable=1
	z.nokill=1
	z.move=1
	z.displaykey = src.key
	z.Player=0
	z.oicon=z.icon
	z.BirthYear=Year
	z.overlayList = usr.overlayList//shouldn't need the overlayList var, but here it is
	z.overlays = usr.overlayList
	z.clone = 1
	z.loc=locate(usr.x,usr.y,usr.z)
	if(z.genome)
		z.genome.savant = src
		z.genome.post_init_savant()
	step(z,usr.dir)
	return z
mob/var/needs_manual_custom = 0
mob/var/clone = 0
mob/var/clone_degeneration = 0
mob/proc/AssignDupeVars(var/mob/A) //We have to manually add everything that is important to dupes.
	var/pt1=num2text(rand(1,999),3)
	var/insert1=num2text(rand(50,99),2)
	var/pt2=num2text(rand(1,999),3)
	var/insert2=num2text(rand(20,30),2)
	A.signature=addtext(pt1,insert1,pt2,insert2)
	A.AuraR= AuraR
	A.AuraG= AuraG
	A.AuraB= AuraB
	A.blastR= blastR
	A.blastG= blastG
	A.blastB= blastB
	A.AURA= AURA
	A.ssj4aura= ssj4aura
	A.see_in_dark=see_in_dark
	A.actspeed=actspeed
	A.TextSize=TextSize
	A.originalicon = originalicon
	A.biologicallyimmortal= biologicallyimmortal
	A.attackable=1
	A.SayColor=SayColor
	A.bursticon=bursticon
	A.burststate=burststate
	A.CBLASTICON=CBLASTICON
	A.CBLASTSTATE=CBLASTSTATE
	A.BLASTICON=BLASTICON
	A.BLASTSTATE=BLASTSTATE
	A.InclineAge=InclineAge
	A.Makkankoicon=Makkankoicon
	A.WaveIcon=WaveIcon
	A.healmod=healmod
	A.zanzomod=zanzomod
	A.BPMod=BPMod
	A.MaxAnger=MaxAnger
	A.KiMod=KiMod
	A.MaxKi=MaxKi
	A.physoffMod=physoffMod
	A.Created = 1
	A.kiregenMod=kiregenMod
	A.ZenkaiMod=ZenkaiMod
	A.TrainMod=TrainMod
	A.MedMod=MedMod
	A.SparMod=SparMod
	A.BP=BP
	A.Body=Body
	A.Age=Age
	A.SAge=0
	A.GravMastered=GravMastered
	A.GravMod=GravMod
	A.techskill=techskill
	A.techmod=techmod