mob
	verb
		SetSoundVolume()
			set name="Set Sound Volume"
			set category="Other"
			set hidden= 1
			src <<"Sound Volume: [client.clientsoundvolume]%"
			client.clientsoundvolume=input(usr,"Type a number 1-100 as the new volume.","Sound Effect Volume",50) as num
			client.clientsoundvolume = round(abs(client.clientsoundvolume), 1)
			if(client.clientsoundvolume<0) client.clientsoundvolume=0
			if(client.clientsoundvolume>100) client.clientsoundvolume=100
			usr << "Sound Volume set to [client.clientsoundvolume]%"
		SetMusicVolume()
			set name="Set Music Volume"
			set category="Other"
			set hidden= 1
			src <<"Music Volume: [client.clientvolume]%"
			client.clientvolume=input(usr,"Type a number 1-100 as the new volume.","Music Volume",50) as num
			client.clientvolume = round(abs(client.clientvolume), 1)
			if(client.clientvolume<0) client.clientvolume=0
			if(client.clientvolume>100) client.clientvolume=100
			usr << "Music Volume set to [client.clientvolume]%"
		EndMusic()
			set name="End Music"
			set category="Other"
			set hidden=1
			musicdatumvar = sound()
			usr << musicdatumvar
			usr << "Any music OR SOUNDS able to be turned off were just turned off."
		TurnItTheFuckOff()
			set name="Toggle Title Music"
			set category="Other"
			set hidden=1
			musicdatumvar = sound()
			usr << musicdatumvar
			if(client.TitleMusicOn)
				client.TitleMusicOn=0
			else client.TitleMusicOn=1
			usr << "Title Music=[client.TitleMusicOn] (1 is on, 0 is off.)"
		DebugList()
			set hidden=1
			if(loggedin)
				var/list/SettingListing=new/list
				SettingListing+="Cancel"
				SettingListing+="Toggle Assess World"
				SettingListing+="Remove a Overlay"
				SettingListing+="Fix login"
				SettingListing+="Show/hide Invisible Browser"
				choose
				var/choice=input(usr,"Choose Option.","","Cancel") in SettingListing
				switch(choice)
					if("Cancel")
					if("Toggle Assess World")
						usr.Toggle_Assess_World()
						goto choose
					if("Remove a Overlay")
						usr.Overlay_Remove_List()
						goto choose
					if("Fix login") if(temporary)
						winshow(usr,"Login_Pane",1)
						winshow(usr,"characterpane",0)
						winshow(usr, "balancewin", 0)
						client.show_verb_panel=0
						var mob/lobby/A = new
						client.mob = A
					if("Show/hide Invisible Browser")
						if(winget(usr,"InvisibleBrowser","is-visible")=="true")
							winshow(usr,"InvisibleBrowser",0)
						else winshow(usr,"InvisibleBrowser",1)
		SettingsList()
			set hidden=1
			if(loggedin)
				var/list/SettingListing=new/list
				SettingListing+="Cancel"
				SettingListing+="Hair"
				SettingListing+="Form Icons"
				SettingListing+="Make Icon Default"
				SettingListing+="Specific Customizations"
				if(usr.ssj3able) SettingListing+="SSJ3 3 Minute Long Transformation Toggle"
				SettingListing+="Set Sound Volume"
				SettingListing+="Set Music Volume"
				SettingListing+="End Music"
				SettingListing+="Toggle Title Music"
				SettingListing+="See Telepathy"
				SettingListing+="Logs"
				if(Admin >= 2)SettingListing+="Power Ranks"
				SettingListing+="Mute Ckey"
				SettingListing+="OOC Switch"
				SettingListing+="Combo Toggle"
				if(usr.Admin) SettingListing+="Toggle RP Spy"
				SettingListing+="Aura Layer"
				SettingListing+="Text Size"
				SettingListing+="Eye Settings"
				SettingListing+="OOC Color"
				SettingListing+="Say Color"
				SettingListing+="Download Save"
				SettingListing+="Ignore"
				SettingListing+="OOC Channel"
				SettingListing+="Aura and Blast Color"
				SettingListing+="Blast Icon"
				SettingListing+="Beam Icon"
				SettingListing+="Get Rank?"
				SettingListing+="Transformation Options"
				SettingListing+="Muscle Icons"
				if(usr.Race=="Saiyan"||usr.genome.race_percent("Saiyan") >= 50) SettingListing+="Tail Icon"
				choose
				var/choice=input(usr,"Choose Option.","","Cancel") in SettingListing
				switch(choice)
					if("Cancel")
					if("Hair")
						Change_Hair()
						goto choose
					if("Form Icons")
						Change_Form_Icon()
						goto choose
					if("Make Icon Default")
						Skin()
						goto choose
					if("SSJ3 3 Minute Long Transformation Toggle")
						SSJ3TransformToggle()
						goto choose
					if("Set Sound Volume")
						SetSoundVolume()
						goto choose
					if("Set Music Volume")
						SetMusicVolume()
						goto choose
					if("End Music")
						EndMusic()
						goto choose
					if("Toggle Title Music")
						TurnItTheFuckOff()
						goto choose
					if("See Telepathy")
						SeeTelepathy()
						goto choose
					if("OOC Switch")
						OOC_Switch()
						goto choose
					if("Eye Settings")
						Eye_Stuff()
						goto choose
					if("Combo Toggle")
						usr.Combo_Toggle()
						goto choose
					if("Toggle RP Spy")
						usr.Toggle_RP_Spy()
						goto choose
					if("Aura Layer")
						usr.AuraLayer()
						goto choose
					if("Text Size")
						usr.TextSize()
						goto choose
					if("OOC Color")
						usr.OOC_Color()
						goto choose
					if("Say Color")
						usr.Say_Color()
						goto choose
					if("Ignore")
						usr.Ignore()
						goto choose
					if("OOC Channel")
						usr.OOC_Channel()
						goto choose
					if("Aura and Blast Color")
						usr.Aura_and_Blast_Color()
						goto choose
					if("Blast Icon")
						usr.Change_Blast_Icon()
						goto choose
					if("Beam Icon")
						usr.Change_Beam_Icon()
						goto choose
					if("Get Rank?")
						usr.GetRank()
						goto choose
					if("Download Save")
						usr.Download_Save()
						goto choose
					if("Transformation Options")
						usr.Toggle_Transform_Option()
						goto choose
					if("Muscle Icons")
						usr.Muscle_Icons()
						goto choose
					if("Specific Customizations")
						usr.Customization_Options()
						goto choose
					if("Tail Icon")
						usr.Change_Tail()
						goto choose
					if("Logs")
						usr.Logs()
						goto choose
					if("Power Ranks")
						usr:PowerRanks()
						goto choose
					if("Mute Ckey")
						if(client) client.Mute_ckey()
						goto choose
		SSJ3TransformToggle()
			set category="Other"
			set hidden=1
			if(ssj3able)
				var/Choice=alert("Turn the very long SSJ3 cutscene on? It's the Majin Buu version you're toggling.","","Yes","No")
				switch(Choice)
					if("Yes")
						ssj3firsttime=2
					if("No")
						ssj3firsttime=0
		SeeTelepathy()
			set category="Other"
			set hidden=1
			if(seetelepathy)
				usr<<"Telepathy messages off."
				seetelepathy=0
			else
				usr<<"Telepathy messages on."
				seetelepathy=1
		OOC_Switch()
			set category="Other"
			set hidden=1
			if(src.OOCon)
				usr.OOCon=0
				usr<<"OOC text is now off."
			else
				usr.OOCon=1
				usr<<"OOC text is now visible."

		Combo_Toggle()
			set category="Other"
			set hidden=1
			if(comboon)
				usr<<"Combo warping off."
				comboon=0
			else
				usr<<"Combo warping on."
				comboon=1
		Toggle_RP_Spy()
			set category="Other"
			set hidden=1
			if(Spying)
				usr<<"RP Spy off."
				Spying=0
			else
				usr<<"RP Spy on."
				Spying=1
		Toggle_Assess_World()
			set category="Other"
			set hidden=1
			if(Assessing)
				usr<<"Who tab off."
				Assessing=0
			else
				usr<<"Who tab on."
				Assessing=1
		AuraLayer()
			set category="Other"
			set hidden=1
			if(Over)
				usr<<"Aura from Power Up is now an underlay."
				Over=0
			else
				usr<<"Aura from Power Up is now an overlay."
				Over=1
		TextSize()
			set category="Other"
			set hidden=1
			TextSize=input("Enter a size for the text you will see on your screen, between 1 and 10, default is 2") as num
		Ignore()
			set category="Other"
			set hidden=1
			switch(input("Add or Remove someone from the ignore list?", "", text) in list ("Add","Remove","View List","Nevermind",))
				if("Add")
					var/mob/M=input("Which mob?","Mob") as null|mob in world
					if(M.client)
						Ignore+=M.key
						usr<<"[M.key] added to ignore list."
					else usr<<"They are an NPC"
				if("Remove")
					var/mob/M=input("Which mob?","Mob") as null|mob in world
					if(M.client)
						Ignore-=M.key
						usr<<"[M.key] removed from ignore list."
					else usr<<"They are an NPC"
				if("View List") usr<<"[list2params(Ignore)]"
		OOC_Channel()
			set category="Other"
			set hidden=1
			OOCchannel=input("What channel? As any number. Main channel is 1, secondary channels are 2 and 3, any others are personal channels.") as num
		Aura_and_Blast_Color()
			set category="Other"
			set hidden=1
			if(!powerup&&!shielding&&!flight)
				Aura_Color()
				Blast_Color()
				EnergyCalibrate()
			else usr<<"You have to stop powering up, down, shielding, or flying to do this."
		GetRank()
			set name ="Get Rank?"
			set category ="Other"
			set hidden=1
			if(usr.GetRank)
				usr.GetRank=0
				usr<<"Get Rank has been turned off."
				return
			if(!usr.GetRank)
				usr.GetRank=1
				usr<<"Get Rank has been turned on."
				return
		Toggle_Transform_Option()
			set name ="Toggle Transformation Option"
			set category = "Other"
			set hidden = 1
			var/list/options=new/list
			options+="Check Transformation"
			options+="Toggle DU style."
			options+="Toggle Transformation Verb"
			options+="Cancel"
			var/Choice=input(usr,"Choose Action","","Cancel") in options
			switch(Choice)
				if("Check Transformation")
					Transformations_Activate()
				if("Toggle DU style.")
					if(DUpowerupon)
						DUpowerupon=0
					else DUpowerupon=1
				if("Toggle Transformation Verb")
					if(/mob/Transform/verb/Transform in usr.verbs)
						verbs-=/mob/Transform/verb/Transform
						verblist-=/mob/Transform/verb/Transform
					else
						verbs+=/mob/Transform/verb/Transform
						verblist+=/mob/Transform/verb/Transform
		Popup_Settings()
			set name = "Toggle Popups"
			set category="Other"
			if(GetPops)
				alert("System Info: Popups OFF")
				GetPops=0
			else
				alert("System Info: Popups ON")
				GetPops=1
		Lethal_Setting()
			set category="Other"
			if(!murderToggle)
				murderToggle=1
				usr<<"Intent set to kill."
				view()<<"[usr]'s intent shifts maliciously!"
			else
				murderToggle=0
				usr<<"Intent set to knock out."
				view()<<"[usr]'s intent shifts passively!"
		DeflectionSetting()
			set category="Other"
			if(DRenabled)
				DRenabled=0
				usr<<"Blast Deflection/Reflection is disabled."
			else
				DRenabled=1
				usr<<"Blast Deflection/Reflection is enabled."
		Flavor_Text()
			set category="Other"
			if(attack_flavor)
				attack_flavor=0
				usr<<"Flavor Text for regular attacks are disabled."
			else
				attack_flavor=1
				usr<<"Flavor Text for regular attacks are enabled."
		Customization_Options()
			set category="Other"
			set hidden=1
			var/choice=input(usr,"Select Customization Option:","",text) in list("Auras","SSJ4 Body Icon","Toggle Eye Icon","Ki Sword Icon","Cancel")
			switch(choice)
				if("Ki Sword Icon")
					switch(alert(usr,"Change it to something custom?","Custom Forms","Yes","Default","No"))
						if("Default") usr.KiSwordIcon = null
						if("Yes")
							usr.KiSwordIcon = input("Select Icon") as icon
							KiSwordIcon.Blend(input("Select Color (Black if none)") as color)
				if("Auras")
					switch(alert(usr,"Change orientation or icon?","","Orientation","Icon"))
						if("Orientation")
							setAuracenter=input("Select the rigid options.") in list("center","center-left","center-right","center-top","center-bottom","top-left","top-right","bottom-left","bottom-right","old")
						if("Icon")
							switch(alert("Change form aura icons?","","Yes","No, change reg. Aura."))
								if("Yes")
									var/choice2=input("Which one? For saiyans, 1 is equal to SSJ, 1.5 USSJ, 2 SSJ2, etc. 5 only matters for other races. (There's no SSJ5 :^))") in list("1","1.5","2","3","4","5")
									var/choice3=alert("Make the chosen choice its default? Unlike base form, custom auras will not be blended with any color- it'll come from the icon itself.","","Yes","No")
									if(choice3=="Yes")
										switch(choice2)
											if("1")
												form1aura ='SSj Aura.dmi'
											if("2")
												form2aura ='SSj Aura.dmi'
											if("3")
												form3aura ='SSj Aura.dmi'
											if("4")
												form4aura ='Aura SSj4.dmi'
												ssj4aura+=rgb(AuraR,AuraG,AuraB)
											if("5")
												form5aura ='SSj Aura.dmi'
											if("1.5")
												formussjaura ='SSj Aura.dmi'
									else
										switch(choice2)
											if("1")
												form1aura =input("Select Icon") as icon
											if("2")
												form2aura =input("Select Icon") as icon
											if("3")
												form3aura =input("Select Icon") as icon
											if("4")
												form4aura =input("Select Icon") as icon
											if("5")
												form5aura =input("Select Icon") as icon
											if("1.5")
												formussjaura =input("Select Icon") as icon
								if("No, change reg. Aura.")
									if(alert(usr,"Default?","","Yes","No")=="Yes")
										AURA='colorablebigaura.dmi'
										AURA+=rgb(AuraR,AuraG,AuraB)
									else
										var/icon/I=icon(input("Select Icon","Select no icon to cancel.") as icon)
										I.Blend(input("Select Color") as color)
										if(I==null)
										else AURA=I
				if("SSJ4 Body Icon")
					switch(alert(usr,"Change form icon?","SSJ4 Form","Yes","Default","No"))
						if("Yes")
							var/icon/I=input("Select Icon") as icon
							I.Blend(input("Select Color (Black if none)") as color)
							if(I==null)
								defaultSSJ4icon='SSj4_Body.dmi'
							else defaultSSJ4icon=I
						if("Default")
							var/icon/I='SSj4_Body.dmi'
							I.Blend(input("Select Color (Black if none)") as color)
							defaultSSJ4icon=I
				if("Toggle Eye Icon")
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
		Stuck()
			set category = "Other"
			if(client.unstucktimer + (1 HOURS) >= world.time) client.unstucktimer = 0
			if(client.unstucktimer >= world.time) client.unstucktimer = 0
			if(client.unstucktimer) return
			switch(alert(usr,"This will unstuck you depending on the situation! 30 min cooldown! Regeneration Issues will, if you are a species with regeneration or an Icer, will heal or cause you to die.","Unstuck","Okay!","Cancel!","Regeneration Issues!"))
				if("Okay!")
					client.unstucktimer = world.time
					usr.Locate()
					usr.attacking = 0
					usr.stagger = 0
					usr.move = 1
					usr.canmove = 1
				if("Regeneration Issues!")
					client.unstucktimer = world.time
					if(usr.Race=="Frost Demon"&&usr.KO)
						usr.Death()
					else if(usr.Race=="Bio-Android"|usr.Race=="Majin"|usr.DeathRegen|usr.passiveRegen&&usr.KO)
						usr.SpreadHeal(10,1,0)
mob/var
	blck_verb_enbled
	attk_verb_enbled
//
client
	var
		HPWindowToggle = 2 // 1 == HP window outlet, 2 == HP window inlet.
		unstucktimer = 0
	verb
		HPToggle()
			set category = null
			set hidden = 1
			if(HPWindowToggle==1)
				HPWindowToggle=2
				winset(src, "lpane.lpanechild", "left=")
				winshow(src, "HealthWindow", 1)
			else if(HPWindowToggle==2)
				HPWindowToggle=1
				winset(src, "lpane.lpanechild", "left=hppane")
				winshow(src, "HealthWindow", 0)
		HPWinOff()
			set category = null
			set hidden = 1
			if(HPWindowToggle==1||HPWindowToggle==2)
				HPWindowToggle=3
				winshow(src, "HealthWindow", 0)
				winset(src, "lpane.lpanechild", "left=")
			else if(HPWindowToggle==3)
				HPWindowToggle=2
				winshow(src, "HealthWindow", 1)
				winset(src, "lpane.lpanechild", "left=")