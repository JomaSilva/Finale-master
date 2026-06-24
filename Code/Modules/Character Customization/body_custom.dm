mob
	proc
		Skin()
			r_race = Race
			if(Parent_Race && genome)
				r_race = Parent_Race
			if(r_race=="Frost Demon"||r_race=="Bio-Android") return
			if(r_race=="Namekian")
				var/nicon='Namek Young.dmi'
				if(Class=="Albino Namekian")
					nicon='Albino Namek.dmi'
					icon=nicon
				else
					switch(input("Choose your skin color","",text) in list("Light Green", "Green", "Dark Green",))
						if("Light Green")
							nicon+=rgb(30,30,30)
							icon=nicon
						if("Green") icon=nicon
						if("Dark Green")
							nicon-=rgb(30,30,30)
							icon=nicon
				return
			var/list/skin_list = list()
			//see Genetic_Icons.dm
			skin_list += genome.returnIcons()
			var/list/tmp_obj_list = list()
			for(var/a in skin_list)
				var/obj/Dummy_Race_Icon/oba = new
				oba.icon = a
				tmp_obj_list += oba
			inAwindow = 1
			winshow(src,"race_pick",1)
			contents += new/obj/racewindowverbs
			var/dummyobjs
			for(var/obj/obja in tmp_obj_list)
				src<<output(obja,"race_pick.grid1: [++dummyobjs]")
			while(inAwindow)
				sleep(5)
			if(Class=="Genie"||Class=="Ogre"||Race=="Majin")
				alert("Choose a body color.")
				var/rgbsuccess
				sleep rgbsuccess=input("Choose a color.","Color",0) as color
				var/list/oldrgb=0
				oldrgb=hrc_hex2rgb(rgbsuccess,1)
				while(!oldrgb)
					sleep(1)
					oldrgb=hrc_hex2rgb(rgbsuccess,1)
				var/red=oldrgb[1]
				var/blue=oldrgb[3]
				var/green=oldrgb[2]
				var/Playericon=icon
				Playericon += rgb(red,green,blue)
				icon=Playericon
			if(r_race=="Heran")
				var/red=HairR
				var/green=HairG
				var/blue=HairB
				var/Playericon='Hair_Raditz.dmi'
				Playericon+=rgb(red,green,blue)
				truehair=Playericon
			if(!icon) switch(pgender)
				if("Male") icon='White Male.dmi'
				if("Female") icon='Whitefemale.dmi'
			oicon=icon

			racedone_remove()


obj/Dummy_Race_Icon
	name = "<- Icon"
	IsntAItem=1
	Click()
		usr.icon = icon
		usr.oicon = icon

obj/racewindowverbs
	IsntAItem=1
	verb/racedone()
		set category = null
		set hidden = 1
		winshow(usr,"race_pick", 0)
		usr.inAwindow=0
		usr.racedone_remove()//causes a infinite cross reference loop otherwise
		del(src)
mob/proc/racedone_remove()
	verbs -= typesof(/obj/racewindowverbs/verb)
	contents -= /obj/racewindowverbs
	inAwindow=0

mob/proc/formchoose(rtype)
	var/list/skin_list = list()
	usr << "Choose your form icons. You have a maximum of six forms. (Don't ask about the sixth.). If you're a biodroid, you don't need any more than 3. You start in form 1 if Biodroid, form 4 if Icer."
	if("Biodroid" == rtype)
		truehair=null
		skin_list += 'Bio Android 1.dmi'
		skin_list += 'Bio Android 2.dmi'
		skin_list += 'Bio Android 3.dmi'
		skin_list += 'Bio Android 4.dmi'
		skin_list += 'Bio Android - Form 5.dmi'
		skin_list += 'Bio Android 6.dmi'
		skin_list += 'BaseAndroid1.dmi'
		skin_list += 'BaseAndroid2.dmi'
		skin_list += 'BioAndroid1(Spore).dmi'
		skin_list += 'BioExperiment.dmi'
		skin_list += 'Cell Jr.dmi'
		skin_list += 'Female Bioandroid.dmi'
		skin_list += 'Female BioandroidDorado.dmi'
		skin_list += 'Female Bioandroidform2.dmi'
		skin_list += 'Frieza-Cell.dmi'
	if("Frost Demon" == rtype)
		skin_list+='Changeling Frieza 2.dmi'
		skin_list+='Changling - Form 2.dmi'
		skin_list+='Frostdemon Form 3.dmi'
		skin_list+='Frostdemon Form 4.dmi'
		skin_list+='Changeling 5 Kold.dmi'
		skin_list+='GoldIcer.dmi'
		skin_list += 'BaseCooler.dmi'
		skin_list += 'Changeling 1 Large.dmi'
		skin_list += 'Changeling 5 Frieza.dmi'
		skin_list += 'Changeling Form 3.dmi'
		skin_list += 'Changeling Form 4 Orange.dmi'
		skin_list += 'Changeling Form 4.dmi'
		skin_list += 'Changeling Frieza 100% 2.dmi'
		skin_list += 'Changeling Frieza 100% 3.dmi'
		skin_list += 'Changeling Frieza 100%.dmi'
		skin_list += 'Changeling Frieza Form 2, 2.dmi'
		skin_list += 'Changeling Frieza Form 2.dmi'
		skin_list += 'Changeling Frieza Form 3, 2.dmi'
		skin_list += 'Changeling Frieza Form 3.dmi'
		skin_list += 'Changeling Frieza Form 4, 2.dmi'
		skin_list += 'Changeling Frieza Form 4, 3.dmi'
		skin_list += 'Changeling Frieza Form 4.dmi'
		skin_list += 'Changeling Frieza.dmi'
		skin_list += 'Changeling Full Power.dmi'
		skin_list += 'Changeling Kold 2.dmi'
		skin_list += 'Mecha Frieza.dmi'
		skin_list += 'Changeling Kold Form 2.dmi'
		skin_list += 'Changeling Kold.dmi'
		skin_list += 'Changeling Koola 2.dmi'
		skin_list += 'Changeling Koola Expand 2.dmi'
		skin_list += 'Changeling Koola Expand.dmi'
		skin_list += 'Changeling Koola Form 2.dmi'
		skin_list += 'Changeling Koola Form 3, 2.dmi'
		skin_list += 'Changeling Koola Form 3.dmi'
		skin_list += 'Changeling Koola Form 4, 3.dmi'
		skin_list += 'Changeling Koola Form 4.dmi'
		skin_list += 'Changeling Koola.dmi'
		skin_list += 'Changeling Kuriza.dmi'
		skin_list += 'Changeling.dmi'
		skin_list += 'Changling - Form 1.dmi'
		skin_list += 'Changling - Form 2 Orange.dmi'
		skin_list += 'Changling - Form 3 Orange.dmi'
		skin_list += 'Changling - Form 3.dmi'
		skin_list += 'Changling - Form 6 - Orange.dmi'
		skin_list += 'Changling - Form 6.dmi'
		skin_list += 'ChanglingForm7.dmi'
		skin_list += 'ChanglingMetal.dmi'
		skin_list += 'Cooler Form 4.dmi'
		skin_list += 'Frostdemon Form 3.dmi'
		skin_list += 'Frostdemon Form 4.dmi'
		skin_list += 'Frostdemon Kold.dmi'
		skin_list += 'Frostdemon Koola.dmi'
		skin_list += 'Frostdemon.dmi'
		skin_list += 'Mecha Frieza.dmi'
		skin_list += 'King Kold Form 2 Orange.dmi'
		skin_list += 'King Kold Form 2.dmi'
		skin_list += 'Koola Final Form.dmi'

	var/list/tmp_obj_list = list()
	for(var/a in skin_list)
		var/obj/Dummy_Form_Icon/oba = new
		oba.icon = a
		tmp_obj_list += oba
	inAwindow = 1
	winshow(src,"race_pick",1)
	contents += new/obj/formwindowverbs
	var/dummyobjs
	for(var/obj/obja in tmp_obj_list)
		src<<output(obja,"race_pick.grid1: [++dummyobjs]")
	while(inAwindow)
		sleep(5)
	icon = form1icon
	switch(rtype)
		if("Frost Demon")
			if(isnull(form1icon)) form1icon = 'Changeling Frieza 2.dmi'
			if(isnull(form2icon)) form2icon='Changling - Form 2.dmi'
			if(isnull(form3icon)) form3icon='Frostdemon Form 3.dmi'
			if(isnull(form4icon)) form4icon='Frostdemon Form 4.dmi'
			if(isnull(form5icon)) form5icon='Changeling 5 Kold.dmi'
			if(isnull(form6icon)) form6icon='GoldIcer.dmi'
			icon = form4icon
			originalicon = form4icon
		if("Bio-Android")
			if(isnull(form1icon)) form1icon = 'Bio Android 1.dmi'
			if(isnull(form2icon)) form2icon = 'Bio Android 2.dmi'
			if(isnull(form3icon)) form3icon = 'Bio Android 3.dmi'
			if(isnull(form4icon)) form4icon = 'Bio Android 4.dmi'
			if(isnull(form5icon)) form5icon = 'Bio Android - Form 5.dmi'
			if(isnull(form6icon)) form6icon = 'Bio Android 6.dmi'
			icon = form1icon
			originalicon = form1icon
	oicon=icon
	formdone_remove()

mob/var/tmp/temp_form_var
obj/Dummy_Form_Icon
	name = "<- Icon"
	IsntAItem=1
	Click()
		usr.temp_form_var++
		if(usr.temp_form_var>6) usr.temp_form_var=1
		switch(usr.temp_form_var)
			if(1) usr.form1icon = icon
			if(2) usr.form2icon = icon
			if(3) usr.form3icon = icon
			if(4) usr.form4icon = icon
			if(5) usr.form5icon = icon
			if(6) usr.form6icon = icon
		usr << "Form [usr.temp_form_var] updated."
obj/formwindowverbs
	IsntAItem=1
	verb/racedone()
		set category = null
		set hidden = 1
		winshow(usr,"race_pick", 0)
		usr.inAwindow=0
		usr.formdone_remove()//causes a infinite cross reference loop otherwise
		del(src)
mob/proc/formdone_remove()
	verbs -= typesof(/obj/formwindowverbs/verb)
	contents -= /obj/formwindowverbs
	inAwindow=0