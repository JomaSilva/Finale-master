proc
	FullNum(var/eNum,var/ShowCommas=1)
		eNum=num2text(round(eNum),99)
		if(ShowCommas && length(eNum)>3)
			for(var/i=1;i<=round(length(eNum)/4);i++)
				var/CutLoc=length(eNum)+1-(i*3)-(i-1)
				eNum="[copytext(eNum,1,CutLoc)]'[copytext(eNum,CutLoc)]"
		return eNum
mob/verb/View_Self()
	set category="Other"
	usr<<"Race / Racial-Class,[Race]-[Class]"
	usr<<"*Extra Character Info*"
	usr<<"Physical Age: [round(Age)]"
	usr<<"True Age: [round(SAge)]"
	usr<<"You can lift [FullNum(round((expressedBP*Ephysoff*10)))] pounds maximum"
	usr<<"Technology: [techskill] ([round(techxp)] / [round((4*(techskill**2))/techmod)])"

mob/verb/Toggle_Tabs()
	set category="Other"
	var/list/tablist = list("contacts","items","equipment","body","sense","scan","misc","party","masterylevels","cancel")
	returnhere
	var/choice = input(usr,"Choose what tab to toggle.") in tablist
	if(choice!="cancel")
		if(choice in tabson)
			tabson -= choice
		else
			tabson += choice
		goto returnhere

mob/var/tabson = list("items","equipment","body","sense","scan","misc","contacts")
//in Statistics.dm, select lines 33 to 254, and erase them, (including line 33 and 254, erase) and paste this in its place. then see what happens
//im just trying to fix your performance problems without completely rethinking the system you made
//because im not trying to alter how your system works only make it perform better as it is

//if(!statpanel("Something")) return, is a trick where it simultaneously creates the statpanel and does run the code in it unless the player is currently viewing it

//if i made any errors just fix them because this is gonna perform way better

mob/Stat()
	//you dont want set background = 1 here trust me i put that here originally as a mistake in the Finale source ive been thru it already it makes things worse
	if(statstab && Created && client)
		StatsTab()
		statStyles() //i cant find this statStyles() proc in the source but you should go to it, and do what i did to all the other statpanel code, //
			//which is put "if(!statpanel("Styles")) return" at the top to stop its code from running if they arent even on that tab...i put "Styles" as example because //
			//i dont know what the actual tabs name is since i didnt find it in the source
		StatsContacts()
		if("misc" in tabson)
			StatsFactions()
		if("items" in tabson)
			StatsItems()
		if("equipment" in tabson)
			StatEquipment()
		StatBody()
		if(scouteron) StatScouter()
		else if(gotsense) StatSense()
		StatNav()
		StatWorld()
		StatParty()
		StatKi()
		sleep(4)

mob/var/tmp/list/panels = new //the tabs that should be displayed to the player. it is calculated in TabDeciderLoop() below

//Contributed by Tens of DU

mob/proc
	//you need to use this proc somewhere, like when a player logs in, so that it will start looping, otherwise its gonna do nothing
	//i only defined it i didnt put it to use
	TabDeciderLoop() //this checks which tabs need to be on or off
		set waitfor=0
		while(src)
			if(client)
				panels = new/list
				if(currentStyle) panels += "Styles"
				panels += "Body"
				if(known_contact_list.len) panels += "Contacts"
				if(locate(/obj/Faction) in contents) panels += "Factions"
			sleep(15)

	//i divided every tab into its own proc because in the cpu profiler it will be more detailed about which tab is lagging the worst so you can fix it better
	//but also because its just easier to understand and fix and expand upon and rearrange and organize
	StatsTab()
		if(!statpanel("Stats")) return //if the user is not even on the Stats tab, then dont run any of this code, because theyre not even looking at it
		stat(src)
		if(Ekiskill >= 6) stat("Ki Signature","[signature]")
		stat("Battle Power"," [FullNum(round(expressedBP,1),100)] ([FullNum(round(BP,1),100)]) ([round(netBuff,0.01) * 100]%) || Cap: [FullNum(relBPmax)]")
		if(powerMod>1) stat("Health"," [FullNum(round(HP))]%    Power Mod Target: ([round(powerMod * 100,0.01)])%")
		else if(powerMod<1) stat("Health"," [FullNum(round(HP))]%    Energy Reduction (PWR CTRL): ([round(powerMod * 100,0.01)])%")
		else stat("Health"," [FullNum(round(HP))]%")
		stat("Energy"," [FullNum(Ki*1)] / [FullNum(MaxKi*1)]   ([KiMod]x) [round((Ki/MaxKi)*100,0.1)]%")
		if(godki && godki.energy > 0 && godki.max_energy > 0) stat("Godki"," [FullNum(godki.energy*1)] / [FullNum(godki.max_energy*1)]   ([godki.efficiency]x) [round((godki.energy/godki.max_energy)*100,0.1)]%")
		stat("Stamina"," [FullNum(stamina)] / [FullNum(maxstamina)] ([round(staminapercent*100)]%)   BP Gain: [round(100*StamBPGainMod)]%")
		if(!dashing) stat("Emotions / State","[Emotion] / [relaxedstate]")
		else stat("Emotions / State","[Emotion] / [relaxedstate] , \[Running\]")
		if(StoredAnger > 25) stat("Anger Capability: [StoredAnger]%")
		stat("")
		if(IsAVampire) stat("Vampire Multiplier:","[ParanormalBPMult]")
		if(IsAWereWolf) stat("Werewolf Multiplier:","[ParanormalBPMult]")
		if(Emagiskill>1) stat("Magic:","[FullNum(round(Magic,1))]")
		stat("Nutrition:","[round((currentNutrition/maxNutrition)*100)]%")
		stat("Willpower","[Ewillpower]")
		stat("Physical Offense","[Rphysoff * 10] ([physoffMod * 10])")
		stat("Physical Defense","[Rphysdef * 10] ([physdefMod * 10])")
		stat("Ki Offense","[Rkioff * 10] ([kioffMod * 10])")
		stat("Ki Defense","[Rkidef * 10] ([kidefMod * 10])")
		stat("Technique","[Rtechnique * 10] ([techniqueMod * 10])")
		stat("Ki Skill","[Rkiskill * 10] ([kiskillMod * 10])")
		stat("Esoteric Skill","[Rmagiskill * 10] ([magiMod * 10])")
		stat("Speed","[Rspeed * 10] ([speedMod * 10])")
		stat("Intelligence","[techmod * 10]")
		stat("Gravity","[Planetgrav+gravmult] ([round(GravMastered)] Mastered)")
		stat("Unassigned Skillpoints","[skillpoints]/[totalskillpoints]")
		stat("")
		stat("Buff:","[buffoutput[1]]")
		stat("Aura:","[buffoutput[2]]")
		stat("Form:","[buffoutput[3]]")
		if(currentStyle) stat("Current Style:","[currentStyle.name]")
		stat("")
		stat("Inventory Space:","[inven_min]/[inven_max]")
		stat("Location","( [x] )( [y] )( [z] )")
		stat("Lag-O-Meter","[world.cpu]%")

	StatsContacts()
		if(("contacts" in tabson) && ("Contacts" in panels))
			if(!statpanel("Contacts")) return //simultaneously create the tab but dont run any code below if they arent looking at it
			for(var/obj/Contact/c in known_contact_list)
				stat(c)
				stat("Relation: [c.relation[signature]]","Familiarity: [c.familiarity[signature]]")


	StatsFactions()
		if("Factions" in panels)
			if(!statpanel("Factions")) return
			for(var/obj/Faction/f in src) stat(f)

	StatsItems()
		if(!statpanel("Items")) return
		stat("Inventory Space: [inven_min]/[inven_max]")
		stat("")
		for(var/obj/Zenni/z in src)
			z.suffix = "[FullNum(zenni)]"
			stat(z)
		var/list/l = new
		for(var/obj/o in src)
			//i would instead recommend to all these types of items, to add a var called "isItem", so that you can simply do if(o.isItem) here, and elsewhere in the future
			if(istype(o, /obj/items) || istype(o, /obj/Trees) || istype(o, /obj/Artifacts) || istype(o, /obj/DB) || istype(o, /obj/Spacepod) || istype(o, /obj/Boat))
				l += o
			if(istype(o, /obj/bodyparts))
				l += o
			if(istype(o, /obj/items/Equipment))
				if(o.equipped)
					l -= o
			if(istype(o, /obj/Modules))
				var/obj/Modules/m = o
				if(!m.isequipped) l += o
		for(var/obj/o in l) stat(o)

	StatBody()
		if(("body" in tabson) && ("Body" in panels))
			if(!statpanel("Body")) return
			for(var/datum/Body/b in src.body)
				if(b.status!="Missing")
					if(b.targetable)
						b.suffix = "[b.limbstatus]"
						if(b.artificial)
							stat("Capacity: [b.capacity] <font color=gray>Type: Artificial</font>", b)
						else
							stat("Capacity: [b.capacity] <font color=yellow>Type: Organic</font>", b)
			for(var/obj/Modules/m in src.EquippedModules)
				if(!m.isequipped) continue //skip this object
				stat("Limb: [m.parent_limb.name]",m)

	StatScouter()
		if(!statpanel("Scan")) return
		for(var/mob/E in current_area.contents)
			if(!istype(E,/mob/npc/Enemy/Bosses) && E.isNPC) continue
			if(E.expressedBP > 5)
				stat(E)
				stat("Battle Power","[FullNum(round(E.expressedBP,1),100)]  ([E.x], [E.y])")
				switch(get_dir(src,E))
					if(NORTH) stat("Distance","[get_dist(src,E)] (North)")
					if(SOUTH) stat("Distance","[get_dist(src,E)] (South)")
					if(EAST) stat("Distance","[get_dist(src,E)] (East)")
					if(NORTHEAST) stat("Distance","[get_dist(src,E)] (Northeast)")
					if(SOUTHEAST) stat("Distance","[get_dist(src,E)] (Southeast)")
					if(WEST) stat("Distance","[get_dist(src,E)] (West)")
					if(NORTHWEST) stat("Distance","[get_dist(src,E)] (Northwest)")
					if(SOUTHWEST) stat("Distance","[get_dist(src,E)] (Southwest)")

	StatNav()
		if(hasnav)
			if(Planet=="Space")
				if(!statpanel("Navigation")) return
				for(var/obj/Planets/F in planet_list)
					if(F.z==z)
						stat(F)
						if(get_dir(usr,F)==1)
							stat("Distance","[get_dist(usr,F)] (North)")
						if(get_dir(usr,F)==2)
							stat("Distance","[get_dist(usr,F)] (South)")
						if(get_dir(usr,F)==4)
							stat("Distance","[get_dist(usr,F)] (East)")
						if(get_dir(usr,F)==5)
							stat("Distance","[get_dist(usr,F)] (Northeast)")
						if(get_dir(usr,F)==6)
							stat("Distance","[get_dist(usr,F)] (Southeast)")
						if(get_dir(usr,F)==8)
							stat("Distance","[get_dist(usr,F)] (West)")
						if(get_dir(usr,F)==9)
							stat("Distance","[get_dist(usr,F)] (Northwest)")
						if(get_dir(usr,F)==10)
							stat("Distance","[get_dist(usr,F)] (Southwest)")

	StatWorld()
		if(Admin)
			if(!statpanel("World")) return
			stat("BP Cap","[FullNum(BPCap)]|<REAL-HARDCAP>|[FullNum(HardCap)]")
			stat("Year:","[Year] ([Yearspeed]x")
			for(var/mob/M in player_list)
				if(M.BPRank==1&&!istype(M,/mob/lobby))
					stat("Highest BP","[M.name]([M.displaykey])     [FullNum(round(M.expressedBP,1),100)]  /  [FullNum(round(M.BP,1),100)]  ([M.BPMod])")
				if(M.Fastest==1&&!istype(M,/mob/lobby))
					stat("Highest Speed","[M.name]([M.displaykey])     [FullNum(M.Espeed)]  ([M.speedMod]x)")
				if(M.Smartest==1&&!istype(M,/mob/lobby))
					stat("Highest Intel","[M.name]([M.displaykey])     [FullNum(M.techskill)]  ([M.techmod])")
			stat("CPU","[world.cpu]%")
			if(Assessing)
				stat("Total Players:","Currently [player_list.len] || All time: [BPList.len]")
				stat("Total NPCS:","[NPC_list.len]")
				stat("Average BP:","[FullNum(AverageBP*AverageBPMod)]")
				stat("BP Standard Deviation:","[BPSD]")
				stat("BP Skew:","[BPSkew]")
				stat("Average Ki Level","[AverageKiLevel]")
				for(var/mob/M in player_list)
					if(!istype(M,/mob/lobby))
						stat("[FullNum(round(M.BP,1),100)]   ([M.BPMod]) {[M.displaykey]}",M)

	StatParty()
		if(("party" in tabson))
			if(!statpanel("Party")) return
			var/pcount=0
			for(var/A in Party)
				if(A)
					for(var/mob/p in player_list)
						if(p.name==A)
							stat(p)
							stat("Health"," [num2text(round(p.HP))]%")
							stat("Energy"," [round(p.Ki*1)]     ([round((p.Ki/p.MaxKi)*100,0.1)])%")
							stat("Location","([p.x],[p.y],[p.z]")
							pcount++
					if(!pcount)
						Party-=A

	StatKi()
		if(("masterylevels" in tabson))
			if(!statpanel("Mastery")) return
			stat("=Ki Stats=")
			stat("Total Ki Level: [KiTotal()]")
			stat("Ki Exp Rate: [max(2+((AverageKiLevel-KiTotal())/(AverageKiLevel+1)),0.25)*100]%")
			stat("Ki Capacity: [(kicapacity/MaxKi)*100]%")
			stat("Absolute Ki Capacity Cap: [powerupcap*100]%")
			stat("Drain Mod: [DrainMod*100]%")
			stat("")
			stat("=Ki Ability Levels=")
			stat("Awareness: [kiawarenessskill]","Effusion: [kieffusionskill]")
			stat("Circulation: [kicirculationskill]","Control: [kicontrolskill]")
			stat("Efficiency: [kiefficiencyskill]","Gathering: [kigatheringskill]")
			stat("")
			stat("=Ki Skill Levels=")
			stat("Blast: [blastskill]","Beam: [beamskill]")
			stat("Kiai: [kiaiskill]","Charged: [chargedskill]")
			stat("Guided: [guidedskill]","Homing: [homingskill]")
			stat("Targeted: [targetedskill]","Volley: [volleyskill]")
			stat("Buff: [kibuffskill]","Debuff: [kidebuffskill]")
			stat("Defense: [kidefenseskill]")
			stat("")
			stat("=Misc. Ki Levels=")
			stat("Flight: [flightability]")
			stat("")
			stat("=Other Ki Stats=")
			stat("Beam Mult.: [wavemult*100]%")
			stat("Beam Cost: [lastbeamcost*BaseDrain] Ki")
			stat("")
			stat("=Melee Ability Levels=")
			stat("Tactics: [tactics]","Weaponry: [weaponry]")
			stat("")
			stat("=Wielding Skills=")
			stat("Unarmed: [unarmedskill]","One Handed: [onehandskill]")
			stat("Two Handed: [twohandskill]","Dual Wield: [dualwieldskill]")
			stat("")
			stat("=Weapon Skills=")
			stat("Sword: [swordskill]","Axe: [axeskill]")
			stat("Staff: [staffskill]","Spear: [spearskill]")
			stat("Club: [clubskill]","Hammer: [hammerskill]")
			if(godki && (godki.energy || godki.tier))
				stat("")
				stat("=God Ki Stats=")
				stat("Energy: [godki.energy]","Max Energy: [godki.max_energy]")
				stat("Efficiency: [godki.efficiency] ([godki.b_efficiency])","Efficiency Stats: Buff: +[godki.t_efficiency], Mod: [godki.m_efficiency]x")
				stat("God Ki Mult: [godki.godki_mult]","Tier: [godki.tier]")
				stat("Exp: [godki.exp_buffer]","To Levelup: [godki.max_exp]")
				stat("Points: [godki.points]","Focus: [godki.focus]")
				if(godki.naturalization == TRUE) stat("God Ki is natural.")
	StatEquipment()
		if(!statpanel("Equipment")) return
		stat("==Equipment Stats==")
		stat("Damage: [damage] Penetration: [penetration]")
		stat("Accuracy: [accuracy] Deflection: [deflection]")
		stat("Attack Delay: [hitspeedMod*100]%")
		if(weaponeq==2)
			stat("Dual Wielding")
			stat("Mult: [100*(dwmult+(dualwieldskill/200))]% Penetration: [penetration]")
		else if(twohanding)
			stat("Two Handed")
			stat("Mult: [100*(thmult+(twohandskill/200))]% Penetration: [penetration]")
		else if(weaponeq==1)
			stat("One Handed")
			stat("Mult: [100*(ohmult+(onehandskill/200))]% Penetration: [penetration]")
		else if(unarmed)
			stat("Unarmed")
			stat("Mult: [100*(1+(unarmedskill/100))]% Penetration: [unarmedpen+penetration]")
		stat("")
		stat("==Damage==")
		stat("Physical: [DamageTypes["Physical"]]","<font color=lime>Energy: [DamageTypes["Energy"]]</font>")
		stat("<font color=red>Fire: [DamageTypes["Fire"]]</font>","<font color=blue>Ice: [DamageTypes["Ice"]]</font>")
		stat("<font color=teal>Shock: [DamageTypes["Shock"]]</font>","<font color=green>Poison: [DamageTypes["Poison"]]")
		stat("<font color=yellow>Holy: [DamageTypes["Holy"]]</font>","<font color=purple>Dark: [DamageTypes["Dark"]]</font>")
		stat("<font color=silver>Almighty: [DamageTypes["Almighty"]]</font>")
		stat("")
		stat("==Resistances==")
		stat("Physical: [100*(1-(1/Resistances["Physical"]))]%","<font color=lime>Energy: [100*(1-(1/Resistances["Energy"]))]%</font>")
		stat("<font color=red>Fire: [100*(1-(1/Resistances["Fire"]))]%</font>","<font color=blue>Ice: [100*(1-(1/Resistances["Ice"]))]%</font>")
		stat("<font color=teal>Shock: [100*(1-(1/Resistances["Shock"]))]%</font>","<font color=green>Poison: [100*(1-(1/Resistances["Poison"]))]%</font>")
		stat("<font color=yellow>Holy: [100*(1-(1/Resistances["Holy"]))]%</font>","<font color=purple>Dark: [100*(1-(1/Resistances["Dark"]))]%</font>")
		stat("<font color=silver>Almighty: [100*(1-(1/Resistances["Almighty"]))]%</font>")
		stat("")
		var/acount = 0
		stat("==Accessories==")
		for(var/obj/items/Equipment/Accessory/A in src.contents)
			if(A.equipped)
				stat(A)
				acount++
		while(acount<maxaslots)
			stat("----------")
			acount++
		for(var/datum/Body/B in src.body)
			if(!B.maxeslots&&!B.maxwslots)
				continue
			B.suffix = "Armor:[B.armor]/Res:[B.resistance]%"
			stat("")
			stat(B)
			var/ecount = 0
			var/wcount = 0
			if(B.maxeslots) stat("==Armor==")
			for(var/obj/items/Equipment/Armor/E in B.Equipment)
				stat(E)
				ecount++
			while(ecount<B.maxeslots)
				stat("----------")
				ecount++
			if(B.maxwslots) stat("==Weapons==")
			for(var/obj/items/Equipment/Weapon/W in B.Equipment)
				stat(W)
				wcount++
			while(wcount<B.maxwslots)
				stat("----------")
				wcount++
			stat("")