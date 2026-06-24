obj/Creatables
	verb/Cost()
		set category =null
		usr<<"[cost] zenni."
	Research_Station
		icon = 'ResearchBench.dmi'
		cost=500
		neededtech=5
		desc="Research Stations are pretty important. They're the only really good way of getting Tech XP at all, along with certain robotic modules."
		create_type = /obj/Technology/Research_Station
	Fabricator
		icon = 'PDA.dmi'
		cost=500
		neededtech=10
		desc="Fabricators allow you to create technology on the fly."
		create_type = /obj/items/Fabricator

obj/items/Fabricator
	icon = 'PDA.dmi'
	verb/Create()
		set category = "Skills"
		set src in usr
		usr.OpenTechWindow()
		return

obj
	Technology
		Research_Station
			icon = 'ResearchBench.dmi'
			desc = "The Research Station is used to study and create technology."
			name = "Research Bench"
			SaveItem=1
			Bolted = 1
			fragile = 1
			density=1
			canbuild=1
			pixel_x=-32
			verb/Experiment()
				set category=null
				set src in view(1)
				if(!Bolted)
					usr << "You need to bolt [name] before you can use it!"
					return
				expstart
				var/list/studylist = list()
				for(var/obj/items/Material/A in usr.contents)
					studylist+=A
				if(studylist.len==0)
					usr<<"You have no materials to study!"
				else
					var/obj/items/Material/choice = input(usr,"Which material would you like to study? You will gain some technology skill, but sacrifice the material.","") as null|anything in studylist
					if(choice == null || choice == "Cancel")
						return
					else
						AddExp(usr,/datum/mastery/Crafting/Technology,15 + 10*choice.tier*(1+choice.quality/100)*usr.techmod)
						usr.contents-=choice
						goto expstart
			verb/Craft()
				set category=null
				set src in view(1)
				if(!Bolted)
					usr << "You need to bolt [name] before you can use it!"
					return
				switch(input(usr,"Which function of the research station will you use?","","Cancel") in list("Technology","Items","Robotics","Cancel"))
					if("Technology")
						usr.OpenTechWindow()
						return
					if("Items")
						switch(input(usr,"Craft which item?","","Cancel") in list("Enhancer","Cancel"))
							if("Enhancer")
								if(usr.zenni>=4000)
									usr.zenni-=4000
									var/obj/A=new/obj/items/Enhancer(locate(usr.x,usr.y,usr.z))
									A.techcost+=4000
								else usr<<"You dont have enough money (You need 4,000 zenni to craft.)"
					if("Robotics")
						switch(input(usr,"Which type of robotics item?","","Cancel") in list("Modules","Cybernetic Limbs","Robotic Limbs","Weapons"))
							if("Modules")
								thechoices
								if(usr.KO) return
								var/cost=0
								var/list/Choices=new/list
								Choices.Add("Cancel")
								if(usr.zenni>=10000&&usr.techskill>=20)
									Choices.Add("Solar Cell ([10000]z)")
								if(usr.zenni>=500000&&usr.techskill>=70)
									Choices.Add("Researcher AI ([500000]z)")
								if(usr.zenni>=5000&&usr.techskill>=20)
									Choices.Add("Basic Repair Core ([5000]z)")
								if(usr.zenni>=5000000&&usr.techskill>=100)
									Choices.Add("Time Stop Inhibitor ([5000000]z)")
								if(usr.zenni>=100000&&(usr.techskill>=80||(usr.pitted&&usr.Race=="Tsujin")))
									Choices.Add("Infinite Energy Core ([100000]z)")
								if(usr.zenni>=10000&&usr.techskill>=40)
									Choices.Add("Repair Core ([10000]z)")
								if(usr.zenni>=10000&&usr.techskill>=40)
									Choices.Add("Energy Core ([10000]z)")
								if(usr.zenni>=15000&&usr.techskill>=30)
									Choices.Add("Metabolic Interchange ([15000]z)")
								if(usr.zenni>=15000&&usr.techskill>=30)
									Choices.Add("Metabolic Autonomer ([15000]z)")
								if(usr.zenni>=95000&&usr.techskill>=50)
									Choices.Add("Repair Nanobots ([95000]z)")
								if(usr.zenni>=10000&&usr.techskill>=35)
									Choices.Add("Rebreather Module ([10000]z)")
								if(usr.zenni>=100000&&usr.techskill>=45)
									Choices.Add("Levitation Systems ([100000]z)")
								if(usr.zenni>=1000000&&usr.techskill>=30)
									Choices.Add("Advanced Targeting Systems ([1000000]z)")
								if(usr.zenni>=1000000&&usr.techskill>=30)
									Choices.Add("Hydraulic Force Multiplier ([1000000]z)")
								if(usr.zenni>=4000000&&usr.techskill>=50)
									Choices.Add("Forcefield Generator ([4000000]z)")
								if(usr.zenni>=4000000&&usr.techskill>=50)
									Choices.Add("Matter Assimilator ([4000000]z)")
								if(usr.zenni>=1000000&&usr.techskill>=50)
									Choices.Add("Limiter Overload ([1000000]z)")
								if(usr.zenni>=100000&&usr.techskill>=30)
									Choices.Add("Energy Capacitor ([100000]z)")
								if(usr.zenni>=8000000&&usr.techskill>=90)
									Choices.Add("Reconstruction Core ([8000000]z)")
								if(usr.zenni>=8000000&&(usr.techskill>=90||(usr.pitted&&usr.Race=="Tsujin")))
									Choices.Add("Body Takeover Module ([8000000]z)")
								var/A=input("Create what?") in Choices
								if(A=="Cancel") return
								if(A=="Solar Cell ([10000]z)")
									usr<<"This device is usually pre-installed in androids. Solar Cells are pretty shit, they only charge you up to 80% stamina."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=10000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Solar_Cell(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Researcher AI ([500000]z)")
									usr<<"A Researcher AI allows you to research tech on the fly, giving you small amounts of tech XP."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Researcher_AI(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Basic Repair Core ([5000]z)")
									usr<<"A not very good repair core used as a supplement for normal celluar regeneration processes."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=5000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Basic_Repair_Core(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Time Stop Inhibitor ([5000000]z)")
									usr<<"A time stop inhibitor prevents you from being frozen from localized timestop and global timestops. Takes shitloads of energy."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=5000000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Time_Stop_Inhibitor(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Infinite Energy Core ([100000]z)")
									usr<<"An infinite energy core gives you just that, infinite energy. It can hold shittons of energy, and power you forever."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Infinite_Energy_Core(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Repair Core ([10000]z)")
									usr<<"Repair cores use energy to periodically heal you."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=10000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Repair_Core(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Energy Core ([10000]z)")
									usr<<"A lower tier, fission powered micro-reactor capable of generating near-lifelike amounts of Ki."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=10000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Energy_Core(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Metabolic Interchange ([15000]z)")
									usr<<"Rapid degradation of organic matter in the system for direct conversion into usable energy, in a compact package. Digestive apparatus not included."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=15000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Metabolic_Interchange(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Metabolic Autonomer ([15000]z)")
									usr<<"Will automatically consume food in your inventory for a hefty energy pricetag. Will only activate at low stamina, and low nutrition. Will sometimes need to be maually reset (via body tab.)"
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=15000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Metabolic_Autonomer(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Repair Nanobots ([95000]z)")
									usr<<"A fleet of tiny dormant robots. While activated they will flit about your body, repairing damage. Install in torso cavity."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=95000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Repair_Nanobots(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Rebreather Module ([10000]z)")
									usr<<"Many tanks of oxygen and a judicious application of capsule technology ensure you will never run out of air in inhospitable conditions. Install in torso cavity."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=10000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Rebreather_Module(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Levitation Systems ([100000]z)")
									usr<<"Defy gravity for FREE*. Install in an artificial leg. *Note: Not actually free, uses energy from the module."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Levitation_Systems(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Advanced Targeting Systems ([1000000]z)")
									usr<<"Enhance your sensory pathways with cybernetic technology, enabling a built-in set of scanning functions."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=1000000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Advanced_Targeting_Systems(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Hydraulic Force Multiplier ([1000000]z)")
									usr<<"Improve the force your muscles can output with advanced hydraulics originating from your abdomen. Requires artifical abdominal support to function. Also makes your body more fragile by exposing limbs to greater force transfer."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=1000000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Hydraulic_Force_Multiplier(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Forcefield Generator ([4000000]z)")
									usr<<"Generate a field that shields you from energy attacks. Requires energy for each deflection. Too much usage can overload the module, destroying it and the limb it is embedded within."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=4000000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Forcefield_Generator(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Matter Assimilator ([4000000]z)")
									usr<<"Deconstruct the matter of whomever you are grabbing, converting that matter into energy for yourself."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=4000000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Matter_Assimilator(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Limiter Overload ([1000000]z)")
									usr<<"Remove the limiters on your artificial limbs, greatly increasing your power at the cost of damaging your limbs and modules from the increased load. Installed in the torso."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=1000000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Limiter_Overload(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Energy Capacitor ([100000]z)")
									usr<<"Convert the energy from ki-based attacks into usable energy for your body. WARNING: Module can overload if too much energy is absorbed, and will explode. Install in a hand."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Energy_Capacitor(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reconstruction Core ([8000000]z)")
									usr<<"A microprocessor installed in an artificial brain that is connected to various systems. On destruction of vital body systems, will attempt to rebuild those systems using their scraps. Requires prolonged maintenance after usage."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=8000000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reconstruction_Core(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Body Takeover Module ([8000000]z)")
									usr<<"The Body Takeover Module is a advanced module capable of letting the user take over a angered or knocked out opponent's body. However, their items, zenni, and skills are not usuable in this state. (Baby from GT's Module.)"
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=8000000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reibi_Module(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								usr<<"Cost: [cost]z"
								usr.zenni-=cost
								goto thechoices
							if("Cybernetic Limbs")
								thechoices
								if(usr.KO) return
								var/cost=0
								var/list/Choices=new/list
								Choices.Add("Cancel")
								if(usr.zenni>=100000&&usr.techskill>=25)
									Choices.Add("Cybernetic Torso Upgrade([100000]z)")
									Choices.Add("Cybernetic Abdomen Upgrade([100000]z)")
									Choices.Add("Cybernetic Left Hand Upgrade([100000]z)")
									Choices.Add("Cybernetic Right Hand Upgrade([100000]z)")
									Choices.Add("Cybernetic Left Arm Upgrade([100000]z)")
									Choices.Add("Cybernetic Right Arm Upgrade([100000]z)")
									Choices.Add("Cybernetic Left Leg Upgrade([100000]z)")
									Choices.Add("Cybernetic Right Leg Upgrade([100000]z)")
									Choices.Add("Cybernetic Left Foot Upgrade([100000]z)")
									Choices.Add("Cybernetic Right Foot Upgrade([100000]z)")
									Choices.Add("Prosthetic Limb ([30000]z)")
								var/A=input("Create what?") in Choices
								if(A=="Cancel") return
								if(A=="Cybernetic Torso Upgrade([100000]z)")
									usr<<"Enhance your organic musculature with mechanical upgrades. Comes at a small cost to ki-based abilities."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Cybernetic_Upgrade/Torso(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Cybernetic Abdomen Upgrade([100000]z)")
									usr<<"Enhance your organic musculature with mechanical upgrades. Comes at a small cost to ki-based abilities."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Cybernetic_Upgrade/Abdomen(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Cybernetic Left Hand Upgrade([100000]z)")
									usr<<"Enhance your organic musculature with mechanical upgrades. Comes at a small cost to ki-based abilities."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Cybernetic_Upgrade/HandL(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Cybernetic Right Hand Upgrade([100000]z)")
									usr<<"Enhance your organic musculature with mechanical upgrades. Comes at a small cost to ki-based abilities."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Cybernetic_Upgrade/HandR(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Cybernetic Left Arm Upgrade([100000]z)")
									usr<<"Enhance your organic musculature with mechanical upgrades. Comes at a small cost to ki-based abilities."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Cybernetic_Upgrade/ArmL(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Cybernetic Right Arm Upgrade([100000]z)")
									usr<<"Enhance your organic musculature with mechanical upgrades. Comes at a small cost to ki-based abilities."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Cybernetic_Upgrade/ArmR(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Cybernetic Left Leg Upgrade([100000]z)")
									usr<<"Enhance your organic musculature with mechanical upgrades. Comes at a small cost to ki-based abilities."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Cybernetic_Upgrade/LegL(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Cybernetic Right Leg Upgrade([100000]z)")
									usr<<"Enhance your organic musculature with mechanical upgrades. Comes at a small cost to ki-based abilities."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Cybernetic_Upgrade/LegR(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Cybernetic Left Foot Upgrade([100000]z)")
									usr<<"Enhance your organic musculature with mechanical upgrades. Comes at a small cost to ki-based abilities."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Cybernetic_Upgrade/FootL(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Cybernetic Right Foot Upgrade([100000]z)")
									usr<<"Enhance your organic musculature with mechanical upgrades. Comes at a small cost to ki-based abilities."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Cybernetic_Upgrade/FootR(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Prosthetic Limb ([30000]z)")
									usr<<"Replace a lost limb with an inferior version. Reduces the limb's stats."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=30000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Prosthetic_Limb(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								usr<<"Cost: [cost]z"
								usr.zenni-=cost
								goto thechoices
							if("Robotic Limbs")
								thechoices
								if(usr.KO) return
								var/cost=0
								var/list/Choices=new/list
								Choices.Add("Cancel")
								if(usr.zenni>=500000&&usr.techskill>=70)
									Choices.Add("Reinforced Head Upgrade([500000]z)")
									Choices.Add("Reinforced Torso Upgrade([500000]z)")
									Choices.Add("Reinforced Abdomen Upgrade([500000]z)")
									Choices.Add("Reinforced Left Hand Upgrade([500000]z)")
									Choices.Add("Reinforced Right Hand Upgrade([500000]z)")
									Choices.Add("Reinforced Left Arm Upgrade([500000]z)")
									Choices.Add("Reinforced Right Arm Upgrade([500000]z)")
									Choices.Add("Reinforced Left Leg Upgrade([500000]z)")
									Choices.Add("Reinforced Right Leg Upgrade([500000]z)")
									Choices.Add("Reinforced Left Foot Upgrade([500000]z)")
									Choices.Add("Reinforced Right Foot Upgrade([500000]z)")
									Choices.Add("Reinforced Functional Extension Upgrade([500000]z)")
								var/A=input("Create what?") in Choices
								if(A=="Cancel") return
								if(A=="Reinforced Head Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/Head(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reinforced Torso Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/Torso(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reinforced Abdomen Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/Abdomen(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reinforced Left Hand Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/HandL(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reinforced Right Hand Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/HandR(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reinforced Left Arm Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/ArmL(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reinforced Right Arm Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/ArmR(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reinforced Left Leg Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/LegL(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reinforced Right Leg Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/LegR(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reinforced Left Foot Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/FootL(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reinforced Right Foot Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/FootR(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Reinforced Functional Extension Upgrade([500000]z)")
									usr<<"Upgraded frame for androids. Further enhances body durability, but further limits the flow of ki. WARNING: You cannot uninstall this part, choose wisely."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Reinforced_Frame/Reproductive_Organs(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								usr<<"Cost: [cost]z"
								usr.zenni-=cost
								goto thechoices
							if("Weapons")
								thechoices
								if(usr.KO) return
								var/cost=0
								var/list/Choices=new/list
								Choices.Add("Cancel")
								if(usr.zenni>=100000&&usr.techskill>=25)
									Choices.Add("Mega Buster([100000]z)")
								if(usr.zenni>=1000000&&usr.techskill>=70)
									Choices.Add("Refractor Upgrade ([1000000]z)")
								if(usr.zenni>=65000&&usr.techskill>=35)
									Choices.Add("Rocket Punch([65000]z)")
								if(usr.zenni>=100000&&usr.techskill>=40)
									Choices.Add("Abdominal Machinegun ([100000]z)")
								if(usr.zenni>=500000&&usr.techskill>=50)
									Choices.Add("Portable Missile Launcher ([500000]z)")
								var/A=input("Create what?") in Choices
								if(A=="Cancel") return
								if(A=="Mega Buster([100000]z)")
									usr<<"An energy cannon that replaces the user's hand. Reduces the durability of that hand, but enables the user to fire blasts at a target."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Mega_Buster(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Rocket Punch([65000]z)")
									usr<<"A man's romance! No one is safe from your mighty fist. Reinforced to withstand the rigors of high speed collisions."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=65000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Rocket_Punch(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Refractor Upgrade ([1000000]z)")
									usr<<"Install a refractor into your buster, enabling you to fire a concentrated beam of energy."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=1000000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Refractor_Upgrade(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
												C.techcost+=cost
								if(A=="Abdominal Machinegun ([100000]z)")
									usr<<"German science is the greatest in the world! Installs a machinegun into your abdomen, allowing you to open fire!"
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=100000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Abdominal_Machinegun(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								if(A=="Portable Missile Launcher ([500000]z)")
									usr<<"Install a portable homing missile system, complete with self-replenishing missiles."
									var/B=input("Are you sure?") in list("Yes","No")
									switch(B)
										if("Yes")
											cost=500000
											if(usr.zenni<cost)
												usr<<"You do not have enough money ([cost]z)"
											else
												usr<<"Created!"
												var/obj/C=new/obj/Modules/Portable_Missile_Launcher(locate(usr.x,usr.y,usr.z))
												C.techcost+=cost
								usr<<"Cost: [cost]z"
								usr.zenni-=cost
								goto thechoices
			verb/Craft_Book()
				set category=null
				set src in view(1)
				if(!Bolted)
					usr << "You need to bolt [name] before you can use it!"
					return
				if(usr.zenni>=50*usr.techskill)
					usr.zenni-=50*usr.techskill
					var/obj/items/Research_Book/A=new/obj/items/Research_Book(locate(usr.x,usr.y,usr.z))
					A.IntPower = usr.techskill
					A.techcost+=50*usr.techskill
				else usr<<"You dont have enough money ([50*usr.techskill] zenni required.)"