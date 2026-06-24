mob/var
	originalicon
	expandicon2
	expandicon3
	expandicon4
	doexpandicon1=0
	doexpandicon2=0
	doexpandicon3=0
	doexpandicon4=0
	expandicon
	MakyoTransform
	USSJMuscleForm
	form1icon
	form2icon
	form3icon
	form4icon
	form5icon
	form6icon
mob
	verb/Change_Form_Icon()
		set name="Change Form Icon"
		set category="Other"
		set hidden=1
		var/Choice=alert("Change your form icons? This will revert you! Your current icon has been saved!","","Yes","No","Default")
		switch(Choice)
			if("Yes")
				Revert()
				var/muscle
				var/list/BodyExpandIconList=new/list
				BodyExpandIconList+="Form 1"
				BodyExpandIconList+="Form 2"
				BodyExpandIconList+="Form 3"
				BodyExpandIconList+="Form 4"
				BodyExpandIconList+="Form 5"
				BodyExpandIconList+="Form 6"
				BodyExpandIconList+="Extra Form (Werewolf form)"
				BodyExpandIconList+="Cancel/Done"
				muscleformchoice
				muscle=input("Change which form icon?","Icon Form Selection") in BodyExpandIconList
				switch(muscle)
					if("Form 1")
						usr.form1icon=input(usr,"Select your first form.","",null) as icon
						goto muscleformchoice
					if("Form 2")
						usr.form2icon=input(usr,"Select your second form.","",null) as icon
						goto muscleformchoice
					if("Form 3")
						usr.form3icon=input(usr,"Select your third form.","",null) as icon
						goto muscleformchoice
					if("Form 4")
						usr.form4icon=input(usr,"Select your fourth form.","",null) as icon
						goto muscleformchoice
					if("Form 5")
						usr.form5icon=input(usr,"Select your fifth form.","",null) as icon
						goto muscleformchoice
					if("Form 6")
						usr.form6icon=input(usr,"Select your sixth form.","",null) as icon
						goto muscleformchoice
					if("Extra Form (Werewolf form)")
						usr.WolfFormIcon=input(usr,"Select your werewolf form.","",null) as icon
						goto muscleformchoice
			if("Default")
				switch(usr.Race)
					if("Bio-Android")
						usr.form2icon='Bio Android 2.dmi'
						usr.form3icon='Bio Android 3.dmi'
						usr.form4icon='Bio Android 4.dmi'
						if(Class=="Majin-Type")
							alert("Choose a body color. This is the body color of your super form.")
							var/rgbsuccess
							rgbsuccess=input("Choose a color. This is the body color of your super form.","Color",0) as color
							var/list/oldrgb=0
							oldrgb=hrc_hex2rgb(rgbsuccess,1)
							while(!oldrgb)
								sleep(1)
								oldrgb=hrc_hex2rgb(rgbsuccess,1)
							var/red=oldrgb[1]
							var/blue=oldrgb[3]
							var/green=oldrgb[2]
							var/Playericon='Majin1.dmi'
							var/choice2 = alert(usr,"Change your current icon into your default form icon? Ex. if you changed your icon in form 3, it'll become your form 3 default. If not, you'll be reset to your current form's icon.","","Yes","No")
							if(choice2=="Yes")
								Playericon = usr.icon
								if(usr.ssj)
									usr.form4icon = usr.icon
								else
									switch(usr.pgender)
										if("Female") Playericon='BaseWhiteFemale.dmi'
										if("Male") Playericon='BaseWhiteMale.dmi'
									Playericon += rgb(red,green,blue)
									usr.form4icon = Playericon
								usr.icon=Playericon
								originalicon=Playericon
								form3icon=Playericon
							else
								switch(pgender)
									if("Female") Playericon='BaseWhiteFemale.dmi'
									if("Male") Playericon='BaseWhiteMale.dmi'
								usr.icon=Playericon
								usr.originalicon=Playericon
								usr.form3icon=Playericon
								Playericon += rgb(red,green,blue)
								usr.form4icon = Playericon
						var/choice2 = alert(usr,"Change your current icon into your default form icon? Ex. if you changed your icon in form 3, it'll become your form 3 default. If not, you'll be reset to your current form's icon.","","Yes","No")
						if(choice2=="Yes")
							if(usr.ssj)
								usr.form4icon = usr.icon
							if(usr.cell2)
								usr.form2icon=usr.icon
							if(usr.cell3)
								usr.form3icon=usr.icon
						else
							if(usr.ssj)
								usr.icon = usr.form4icon
							if(usr.cell2)
								usr.icon = usr.form2icon
							if(usr.cell3)
								usr.icon = usr.form3icon
					if("Frost Demon")
						usr.form2icon='Changling - Form 2.dmi'
						usr.form3icon='Frostdemon Form 3.dmi'
						usr.form4icon='Frostdemon Form 4.dmi'
						usr.form5icon='Cooler Form 4.dmi'
						var/choice2 = alert(usr,"Change your default form icon into your current icon? Ex. if you changed your icon in form 3, it'll become your form 3 default. If not, you'll be reset to your current form's icon.","","Yes","No")
						if(choice2=="Yes")
							var/Playericon = usr.icon
							if(usr.cur_icr_form == 0)
								usr.form5icon = Playericon
							if(usr.cur_icr_form == 1)
								usr.form4icon = Playericon
							if(usr.cur_icr_form == 2)
								usr.form3icon = Playericon
							if(usr.cur_icr_form == 3)
								usr.form2icon = Playericon
							if(usr.cur_icr_form == 4)
								usr.form1icon = Playericon
								usr.originalicon=Playericon
						else
							icer_poll_icon()
				usr.doexpandicon1=0
				usr.doexpandicon2=0
				usr.doexpandicon3=0
				usr.doexpandicon4=0
				usr.WolfFormIcon = 'Demon, Wolf.dmi'
	verb/Change_Hair()
		set category = "Other"
		set name = "Change Hair"
		set hidden=1
		sleep(1)
		var/originalhair=usr.hair
		var/HairChoice=input("Do you want to change your hair to something custom?","","No") in list("Yes","No","Default","Change Hair Color")
		switch(HairChoice)
			if("Yes")
				usr.overlayList-=originalhair
				usr.overlaychanged=1
				usr.HairChoose()
			if("No")
				return
			if("Default")
				usr.overlayList-=originalhair
				usr.overlaychanged=1
				usr.Hair(1)
			if("Change Hair Color")
				sleep {usr.RemoveHair()}
				var/rgbsuccess
				rgbsuccess=input("Choose a color.","Color",0) as color
				var/list/oldrgb=0
				oldrgb=hrc_hex2rgb(rgbsuccess,1)
				while(!oldrgb)
					sleep(1)
					oldrgb=hrc_hex2rgb(rgbsuccess,1)
				hairred=oldrgb[1]
				hairblue=oldrgb[3]
				hairgreen=oldrgb[2]
				hair+= rgb(hairred,hairgreen,hairblue)
				updateOverlay(/obj/overlay/hairs/hair)
	verb/Change_Tail()
		set category = "Other"
		set name = "Change Tail"
		set hidden = 1
		sleep(1)
		var/TailChoice=alert("Do you want to change your tail to something custom? Only visible if you have a tail","","Yes","No","Default")
		switch(TailChoice)
			if("Yes")
				usr.tailicon = input(usr,"Select your tail.","",null) as null|icon
				usr.updateOverlay(/obj/overlay/hairs/tails/saiyantail,tailicon)
			if("No")
				return
			if("Default")
				usr.tailicon = 'Tail.dmi'
				usr.updateOverlay(/obj/overlay/hairs/tails/saiyantail,tailicon)
	verb/Change_Blast_Icon()
		set category = "Other"
		set name = "Change Blast Icon"
		set hidden = 1
		sleep(1)
		var/Choice=alert("Do you want to change your blast to something custom?","","Yes","No")
		switch(Choice)
			if("Yes")
				usr.BLASTICON = input(usr,"Select your icon.","",null) as null|icon
			if("No")
				return
	verb/Change_Beam_Icon()
		set category = "Other"
		set name = "Change Beam Icon"
		set hidden = 1
		sleep(1)
		var/Choice=alert("Do you want to change your beam to something custom?","","Yes","No")
		switch(Choice)
			if("Yes")
				usr.beamicon = input(usr,"Select your icon.","",null) as null|icon
			if("No")
				return

mob/verb/Muscle_Icons()
	set name="Muscle Icons"
	set category="Other"
	set hidden = 1
	var/Choice=alert("Change your Body Expand icon? This will revert you!","","Yes","No","Default")
	switch(Choice)
		if("Yes")
			var/muscle
			var/list/BodyExpandIconList=new/list
			usr.stopbuff(/obj/buff/Expand)
			BodyExpandIconList+="Cancel"
			BodyExpandIconList+="Muscle Form 1"
			BodyExpandIconList+="Muscle Form 2"
			BodyExpandIconList+="Muscle Form 3"
			if(usr.Race=="Makyo"||(usr.Parent_Race=="Makyo")) BodyExpandIconList+="Muscle Form 4"
			if(usr.hasussj) BodyExpandIconList+="Ultra SSJ Muscle Form"
			muscleformchoice
			muscle=input("Change which muscle form?","Muscle Hair Selection") in BodyExpandIconList
			switch(muscle)
				if("Muscle Form 1")
					usr.expandicon=input(usr,"Select your first form.","",null) as icon
					usr.doexpandicon1=1
					goto muscleformchoice
				if("Muscle Form 2")
					usr.expandicon2=input(usr,"Select your second form.","",null) as icon
					usr.doexpandicon2=1
					goto muscleformchoice
				if("Muscle Form 3")
					usr.expandicon3=input(usr,"Select your third form.","",null) as icon
					usr.doexpandicon3=1
					goto muscleformchoice
				if("Muscle Form 4")
					usr.expandicon4=input(usr,"Select your fourth form.","",null) as icon
					usr.doexpandicon4=1
					goto muscleformchoice
				if("Ultra SSJ Muscle Form")
					usr<<"This is your Muscle USSJ icon. This does not change your USSJ hair."
					usr.USSJMuscleForm=input(usr,"Select your Muscle USSJ form.","",null) as icon
					usr.doexpandicon4=1
					goto muscleformchoice
		if("Default")
			usr.doexpandicon1=0
			usr.doexpandicon2=0
			usr.doexpandicon3=0
			usr.doexpandicon4=0
mob
	proc
		Eye_Stuff()
			if("Yes"==alert(usr,"Change any eye stuff? You can change the Third Eye overlay, change your default Eye icon, or even make both Third Eye and your normal Eye icon invisible.","","Yes","No"))
				beginning
				var/Choice = ""
				var/list/ChoiceList=new/list
				ChoiceList += "Change Third Eye"
				ChoiceList += "Change Eye"
				ChoiceList += "Defaults"
				ChoiceList += "Exit"
				Choice = input("Change Third Eye to get to a query on whether you want to change it or default it, or invisible it. Same with Change Eye. Defaults set both to default. Exit exits.")
				switch(Choice)
					if("Change Third Eye")
						var/Choice2
						var/list/ChoiceList2=new/list

						ChoiceList2 += "Change Third Eye"
						ChoiceList2 += "Invisible"
						ChoiceList2 += "Defaults"
						ChoiceList2 += "Exit"
						Choice2 = input("Set Third Eye to default, make it invisible, or select a custom icon. Or exit.")
						switch(Choice2)
							if("Defaults")
								third_eye_icon = 'Third Eye.dmi'
							if("Change Third Eye")
								third_eye_icon = input(usr,"Third Eye Icon","Third Eye Icon") as icon
							if("Invisible")
								third_eye_icon = null
						goto beginning
					if("Change Eye")
						var/Choice2
						var/list/ChoiceList2=new/list

						ChoiceList2 += "Change Eye"
						ChoiceList2 += "Invisible"
						ChoiceList2 += "Defaults"
						ChoiceList2 += "Exit"
						Choice2 = input("Set Eye to default, make it invisible, or select a custom icon. Or exit.")
						switch(Choice2)
							if("Defaults")
								eyeicon = 'Eyes_Black.dmi'
								eyeicon += rgb(eyered,eyeblue,eyegreen)
							if("Change Eye")
								eyeicon = input(usr,"Eye Icon","Eye Icon") as icon
								updateOverlay(/obj/overlay/eyes/default_eye)
							if("Invisible")
								third_eye_icon = null
								hascustomeye =1
								removeOverlay(/obj/overlay/eyes/default_eye)
								overlayList-=eyeicon
								overlaychanged=1
						goto beginning
					if("Defaults")
						third_eye_icon = 'Third Eye.dmi'
						eyeicon = 'Eyes_Black.dmi'
						eyeicon += rgb(eyered,eyeblue,eyegreen)
					if("Exit")
						return
					/*
					if(!hascustomeye)
						hascustomeye =1
						removeOverlay(/obj/overlay/eyes/default_eye)
						overlayList-=eyeicon
						overlaychanged=1
					else
						hascustomeye = 0
						overlayList+=eyeicon
						updateOverlay(/obj/overlay/eyes/default_eye)
						overlaychanged=1
					*/
		HairChoose()
			if("Yes"==alert(usr,"Change any form hair?","","Yes","No"))
				var/list/SSJHairList=new/list
				var/Choice
				SSJHairList+="Cancel"
				SSJHairList+="SSJ"
				SSJHairList+="USSJ"
				SSJHairList+="PSSJ"
				SSJHairList+="SSJ2"
				SSJHairList+="SSJ3"
				SSJHairList+="SSJ4"
				SSJHairList+="True Hair"
				var/done = 0
				ssjhairselection
				Choice=input("Change which hair? If you're not a saiyan, this will still change any possible form hairs. For those races, note that USSJ is a inbetween form, I.E. a 1.5. Herans/Bios change 'True Hair'","SSJ Hair Selection") in SSJHairList
				switch(Choice)
					if("SSJ")
						ssjhair=input(usr,"Select your SSJ hair.","",null) as icon
						goto ssjhairselection
					if("USSJ")
						ussjhair=input(usr,"Select your USSJ hair.","",null) as icon
						goto ssjhairselection
					if("PSSJ")
						ssjfphair=input(usr,"Select your PSSJ hair.","",null) as icon
						goto ssjhairselection
					if("SSJ2")
						ssj2hair=input(usr,"Select your SSJ2 hair.","",null) as icon
						goto ssjhairselection
					if("SSJ3")
						ssj3hair=input(usr,"Select your SSJ3 hair.","",null) as icon
						goto ssjhairselection
					if("SSJ4")
						ssj4hair=input(usr,"Select your SSJ4 hair.","",null) as icon
						goto ssjhairselection
					if("True Hair")
						truehair=input(usr,"Select your true hair.","",null) as icon
						goto ssjhairselection
					if("Cancel")
						done=1
				if(done&&src.Race=="Saiyan") src<<"It's not normal for a full blood Saiyan to not have black hair, by the way."
			if("No"==alert(usr,"Change regular hair?","","Yes","No")) return
			hairred=0
			hairgreen=0
			hairblue=0
			hair=input("Select your normal hair.","Hair Select",null) as icon
			var rgbsuccess
			sleep rgbsuccess=input("Choose a color.","Color",0) as color
			var/list/oldrgb=0
			oldrgb=hrc_hex2rgb(rgbsuccess,1)
			while(!oldrgb)
				sleep(1)
				oldrgb=hrc_hex2rgb(rgbsuccess,1)
			hairred=oldrgb[1]
			hairblue=oldrgb[3]
			hairgreen=oldrgb[2]
			hair+= rgb(hairred,hairgreen,hairblue)
			updateOverlay(/obj/overlay/hairs/hair,hair)