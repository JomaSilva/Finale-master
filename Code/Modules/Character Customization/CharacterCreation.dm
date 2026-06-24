mob/var/signature
mob
	proc
		New_Character()
			if(Created) return
			if(client) client.charcreationSpecial += 1
			else return
			if(client) client.show_map=0 //black void during creation; map restored after Locate() sends them to their planet
			loc=locate(rand(5,20),rand(3,19),30)
			inAwindow=1
			initialize_planet_window()
			while(inAwindow)
				sleep(5)
			Gender()
			Skin()
			Hair()
			Eyes()
			Age()
			BodyType()
			AuraR=rand(0,255)
			AuraG=rand(0,255)
			AuraB=rand(0,255)
			blastR=rand(0,255)
			blastG=rand(0,255)
			blastB=rand(0,255)
			see_in_dark=5
			var/aura='colorablebigaura.dmi'
			if(Race=="Demon"||(Parent_Race=="Demon"))
				Over=1
				aura='Black Demonflame.dmi'
			if(Race=="Makyo"||(Parent_Race=="Makyo"))
				Over=1
				aura='AuraKiia.dmi'
			aura+=rgb(AuraR,AuraG,AuraB)
			AURA=aura
			ssj4aura='Aura SSj4.dmi'
			ssj4aura+=rgb(AuraR,AuraG,AuraB)
			var/startingage=1
			if(Age<1)
				Age=startingage
				Body=startingage
			SAge=1
			//BP = 1
			if(BP<1)
				BP = 1
			if(Dragonball_Start)
				BP = 1
			if(Father_BP)
				BP += rand(round(Father_BP / InclineAge),round(Father_BP / 6))
				hiddenpotential += Father_BP
			if(Parent_BP)
				hiddenpotential += Parent_BP
				BP += rand(round(Parent_BP / InclineAge),round(Parent_BP / 6))
			CustomizeFurther()
			if(GravMastered>25)
				GravMastered=25
			Name()
			switch(alert(usr,"Satisfied?","","Yes","No"))
				if("No")
					client.mob = new /mob/lobby
					del(src)
					return
			usr.AddHair()
			if(Race != "Frost Demon" && !ChangieType) usr.form1icon = icon
			usr.originalicon = icon
			Locate()
			if(Class=="Legendary")
				legend_override=0
			move=1
			//
			Created=1
			dead=0
			/*if(Race=="Kai")
				var/obj/items/Potara_Earring/A = new
				A.name = "[name]'s Potara Earring (Left)"
				var/obj/items/Potara_Earring/B = new
				B.name = "[name]'s Potara Earring (Right)"
				contents+=A
				contents+=B*/
			MeditateGivesKiRegen=0
			Ki=0
			spawn(10)
				Ki=100
				HP=100
		Name()
			var/pt1=num2text(rand(1,999),3)
			var/insert1=num2text(rand(50,99),2)
			var/pt2=num2text(rand(1,999),3)
			var/insert2=num2text(rand(20,30),2)
			signature=addtext(pt1,insert1,pt2,insert2)
			name=input("What do you want your name to be? (30 letter limit.)")
			name=copytext(name,1,30)
			var/tempfirst = uppertext(copytext(name,1,2))
			name="[tempfirst][copytext(name,2,30)]" //ensures that the first letter will always be capitalized.
			if(!name || (findtext(name," ") && length(name) == 1) || findtext(name,"  "))
				src << "Invalid name."
				Name()

		Gender()
			if(Race=="Kanassa-Jin"|Race=="Makyo"|Race=="Namekian"|Race=="Yardrat"|Race=="Saibamen")
				gender = MALE
			else
				var/Choice=alert(src,"Choose gender","","Male","Female")
				switch(Choice)
					if("Female")
						pgender="Female"
						gender = FEMALE
						genome?.gender = "Female"
					if("Male")
						pgender="Male"
						gender = MALE
		Age()
			if(!cansetage)
				var/setage=input("How old is your character?",1) as num
				if(setage<1|setage>130)setage=1
				Age=setage
				Body=setage
				SAge=setage
		Eyes()
			alert(usr,"Select your eye color.")
			var/newrgb
			newrgb=input("Choose a color.","Color",0) as color
			var/list/oldrgb=0
			oldrgb=hrc_hex2rgb(newrgb,1)
			while(!oldrgb)
				sleep(1)
				oldrgb=hrc_hex2rgb(newrgb,1)
			eyered = oldrgb[1]
			eyeblue = oldrgb[3]
			eyegreen = oldrgb[2]
			eyeicon += rgb(eyered,eyeblue,eyegreen)
			updateOverlay(/obj/overlay/eyes/default_eye)
		Aura_Color()
			set waitfor = 0
			newrgb=0
			alert("Choose a aura color.")
			var/rgbsuccess
			rgbsuccess=input("Choose a color.","Color",0) as color
			var/list/oldrgb=0
			oldrgb=hrc_hex2rgb(rgbsuccess,1)
			while(!oldrgb)
				sleep(1)
				oldrgb=hrc_hex2rgb(rgbsuccess,1)
			AuraR=oldrgb[1]
			AuraB=oldrgb[3]
			AuraG=oldrgb[2]
			var/aura='colorablebigaura.dmi'
			if(Race=="Demon"||(Parent_Race=="Demon"))
				Over=1
				aura='Black Demonflame.dmi'
			if(Race=="Makyo"||(Parent_Race=="Makyo"))
				Over=1
				aura='AuraKiia.dmi'
			aura+=rgb(AuraR,AuraG,AuraB)
			AURA=aura
			ssj4aura='Aura SSj4.dmi'
			ssj4aura+=rgb(AuraR,AuraG,AuraB)
		Blast_Color()
			set waitfor = 0
			alert("Customize your blast color")
			var/rgbsuccess
			rgbsuccess=input("Choose a color.","Color",0) as color
			var/list/oldrgb=0
			oldrgb=hrc_hex2rgb(rgbsuccess,1)
			while(!oldrgb)
				sleep(1)
				oldrgb=hrc_hex2rgb(rgbsuccess,1)
			blastR=oldrgb[1]
			blastB=oldrgb[3]
			blastG=oldrgb[2]
mob/var
	eye
	BodyType
mob/proc/BodyType()
	var/Choice=alert(src,"What type of body do you want?","","Medium","Small","Large")
	switch(Choice)
		if("Medium")
			Choice=alert(src,"Choosing Medium will leave your stats as they are, most males are this, although it is not uncommon for females as well, do you want this?","","Yes","No")
			switch(Choice)
				if("No") BodyType()
				if("Yes") BodyType="Medium"
		if("Small")
			Choice=alert(src,"Small will make you able to land hits easier, dodge easier, attack faster, run faster, heal faster, and recover energy faster, but you will take a -severe- cut in strength and endurance, this setting is modeled as a female archetype, do you want this?","","Yes","No")
			switch(Choice)
				if("No") BodyType()
				if("Yes")
					speedMod*=1.4
					kioffMod*=1.3
					physoffMod*=0.9
					physdefMod*=0.7
					kidefMod*=0.8
					kiregenMod+=0.6
					BodyType="Small"
		if("Large")
			Choice=alert(src,"Large is like being a giant, far beyond any normal person in size. You will receive an insanely huge boost in Endurance, and a still insane but less boost to Strength, but you will attack slower, heal slower, recover energy slower, be easier to hit, and easier to dodge, do you want this?","","Yes","No")
			switch(Choice)
				if("No") BodyType()
				if("Yes")
					speedMod*=0.7
					kioffMod*=1.1
					physoffMod*=1.1
					physdefMod*=1.3
					kidefMod-=0.2
					BodyType="Large"
mob/proc/NewCharacterStuff()
	verbs+=typesof(/mob/default/verb)
	Keyableverbs+=typesof(/mob/default/verb)
	contents+=new/obj/Crandal
	generatetrees(1)
	spawn Variance()
	TestMobParts()
	if(has_Tail()) get_Tail().login(src) //newborn Saiyans: activate the tail body-part now so mob.Tail=1 and the tail overlay shows immediately
	Generate_Droid_Parts()
	Savable=1
	var/hasZenni
	for(var/obj/Zenni/Z in src.contents) hasZenni = 1
	if(!hasZenni) contents+=new/obj/Zenni
	RandomizeText()
	Clear_Overlays()
	spawn(5) TryStats()
	CheckIncarnate()
	race_genome_post_init()

mob/proc/CustomizeFurther()
	if(Race == "Frost Demon" || (Parent_Race == "Frost Demon"))
		IcerCustomization()
	if(Race == "Bio-Android" || (Parent_Race=="Bio-Android"))
		BioCustomization()


mob/proc/CHECK()
		var/icount=0
		for(var/obj/items/o in src)count++
		if(icount>inven_max)src<<output("You have more items in your inventory than the allowed amount. Take this into attention or you will lose your save file.","output")
		inven_min=icount
		for(var/mob/M in world)if(M)M.InvenSet()
