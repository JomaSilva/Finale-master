mob/proc/BioCustomization()
	if(Class == "None")
		formchoose("Biodroid")
	else if(Class == "Majin-Type")
		cell2 = 1
		cell3 = 1
		RaceDescription={"This Bio-Android is a majin type bio-android. Majin bio-androids comes with less Zenkai, higher Regen, regular Cell absorb, only one super form, and a higher than normal BP mod."}
		newrgb=0
		alert("Choose a body color. This is the body color of your super form.")
		var/rgbsuccess
		sleep rgbsuccess=input("Choose a color. This is the body color of your super form.","Color",0) as color
		var/list/oldrgb=0
		oldrgb=hrc_hex2rgb(rgbsuccess,1)
		while(!oldrgb)
			sleep(1)
			oldrgb=hrc_hex2rgb(rgbsuccess,1)
		var/red=oldrgb[1]
		var/blue=oldrgb[3]
		var/green=oldrgb[2]
		var/Playericon='Majin1.dmi'
		switch(pgender)
			if("Female") Playericon='BaseWhiteFemale.dmi'
			if("Male") Playericon='BaseWhiteMale.dmi'
		icon=Playericon
		originalicon=Playericon
		form3icon=Playericon
		Playericon += rgb(red,green,blue)
		usr.form4icon = Playericon
		Hair(1)
		truehair=hair
		truehair+= rgb(100,100,100)