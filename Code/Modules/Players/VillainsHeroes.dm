//Heroes: Gains increased in general, sparring gains increased against Villains.
//Villains: Static increase in something, either to gains or actual BP. In the case of the former, it will only last until the BP of the villain is
//2x times the original base, (admin configurable per villain) and the latter, gains will completely halt until someone has passed the villains base
//bp.
//
//Main takeaway is that both are dynamic, multi-player ranks that are admin configurable per player, and are generally admin ONLY.
//
//If demand is demand and demand demands, possibly a RP council feature will be added for hands-off style servers.


mob/var
	isHV=0

	//gainsboost
	BoostActive=0 //admin configurable
	BoostMult=1 //admin configurable
	BoostTarget //admin configurable, can label someone as a target, in which case the sparring gains will only be increased against a specific target
	//boostTarget is signature BASED (signature IS misspelled. could make it 'signature' but eh. Use the signature var to compare.)
	BoostTargMultiple=0 //otherwise it can also be all other parties or everyone in general. (controlled by this var)

	HVBPAdd=0 //base BP add
	HVBPExpAdd=0 //exp BP add
	HVBPAddEnd=0 //when another player hits this, Add is slowly converted into actual gains.
	HVBPExpAddEnd=0 //when another player hits this, Add is slowly converted into actual gains (but smaller).
	//notice that the hero/villain system has no actual reference to 'villains', we be flexible.
	HVAlign=0
	//1 = hero, 2 = villain, can be actually higher for third/fourth parties.
	HVAlignName="Neutral"//player configurable. Independent of alignment, so you can be called a "Anti-Hero" or something at your leisure.
	//donezo
	HVcooldown = 0
	//for verbage

mob/verb
	HV_Align()
		set name = "Alignment"
		set category = "Other"
		HVAlignName=input(usr,"Set your alignment name. Independent of your actual alignment.") as text
		if(HVAlignName=="")
			HVAlignName="Neutral"
		HVAlign = input(usr,"What is your alignment? If neutral, 0, otherwise make it a unique number per faction.") as num
		HVAlign = round(HVAlign)
		HVcooldown = 432000

mob/proc
	HVBPBoost()
		if(HVcooldown)
			HVcooldown -= 1
			HVcooldown = max(HVcooldown,0)
		if(HVBPAdd && HVBPAddEnd)
			if(AverageBP * 2 > HVBPAddEnd)
				HVBPAddEnd = 0
		else if(HVBPAdd && 0 < capcheck(abs((0.01*HVBPAdd))))
			BP += capcheck(abs((0.01*HVBPAdd)))
			HVBPAdd-=(0.01*HVBPAdd)
			HVBPAdd = max(HVBPAdd,0)
			HVBPAdd = min(HVBPAdd,BPCap)
		if(HVBPExpAdd && HVBPExpAddEnd)
			if(AverageBP * 2 > HVBPAddEnd)
				HVBPAddEnd = 0
		else if(HVBPExpAdd && 0 < capcheck(abs((0.01*HVBPAdd))))
			BP += capcheck(abs((0.01*HVBPAdd)))
			HVBPAdd-=(0.01*HVBPAdd)
			HVBPAdd = max(HVBPAdd,0)
			HVBPAdd = min(HVBPAdd,BPCap)
// BPBoost
mob/Admin2/verb
	Give_HV_Boost()
		set category = "Admin"
		switch(input(usr,{"Alright, so the HV system is a WIP system dedicated to providing a free form way of getting people stronk nonsensically.
Using this can, and will, accelerate gameplay. There's two types of boosts, a gains boost, and a flat BP increase.
The boost affects everything but blasting, and can be configured so that the player can only get the increased sparring gains from fighting others or specific people.
The flat BP increase is the opposite. It completely halts most forms of gains, but the player's BP is set to a certain level. When the average passes a threshold,
that player's 'fake BP' is slowly converted into real BP, and the nogains period ends.
You can also choose to 'flag' people as HV, but not give them anything. Just put 0 for everything past the initial option."},"","Cancel") in list("Cancel","Gains","BP Flat"))
			if("Gains")
				var/mob/M = input(usr,"Choose a player.") as null|mob in player_list
				if(!isnull(M))
					M.isHV=input(usr,"Make this player's gains affected by the HV system? 1 == TRUE, 0 == FALSE","",M.isHV) as num
					M.isHV = round(M.isHV)
					if(M.isHV >= 1) M.isHV = 1
					else M.isHV = 0
					if(M.isHV)
						M.BoostActive=input(usr,"Make this player's gains affected by the HV 'Boost Gains' system? This will act indefinitely! 1 == TRUE, 0 == FALSE","",M.BoostActive) as num
						M.BoostActive = round(M.BoostActive)
						if(M.BoostActive >= 1) M.BoostActive = 1
						else M.BoostActive = 0
						if(M.BoostActive)
							M.BoostMult=input(usr,"Boost mult?","",M.BoostActive) as num
							M.BoostMult = round(M.BoostMult)
							if(M.BoostMult <= 1) M.BoostMult = 1
							var/mob/C = input(usr,"If you wish for the sparring gains to not be in general, choose a player.") as null|mob in player_list
							if(!isnull(C)) M.BoostTarget = C.signature
							M.BoostTargMultiple = input(usr,"If you wish the sparring gains to be against only enemy factions, set this to true. Targets overrides this.","",M.BoostTargMultiple)
							M.BoostTargMultiple = round(M.BoostTargMultiple)
							if(M.BoostTargMultiple >= 1) M.BoostTargMultiple = 1
							else M.BoostTargMultiple = 0
						usr << "The player can choose their own alignment freely, once every 12 hours."
						M << "Your HV system has been updated!"
			if("BP Flat")
				var/mob/M = input(usr,"Choose a player. BP flat gives a set amount of BP as 'base' BP. Alternatively, you can make the added BP as expressed BP instead.") as null|mob in player_list
				if(!isnull(M))
					M.isHV=input(usr,"Make this player's gains affected by the HV system? 1 == TRUE, 0 == FALSE","",M.isHV) as num
					M.isHV = round(M.isHV)
					if(M.isHV >= 1) M.isHV = 1
					else M.isHV = 0
					if(M.isHV)
						switch(input(usr,"Add BP as expressed or base? When adding base, please consider multipliers! BP will be converted to base naturally.","HV - BP Add","Base") in list("Base","Expressed","Cancel"))
							if("Base")
								M.HVBPAdd=input(usr,"BP to add?","",M.HVBPAdd) as num
								M.HVBPAdd = round(M.HVBPAdd)
								if(M.HVBPAdd<=0)
									M.HVBPAdd=0
									return
								if(M.HVBPAdd <= 1) M.HVBPAdd = 1
								M.HVBPAddEnd=input(usr,"When can this player gain again? This will trigger only when another player hits this number in raw BP.","",M.HVBPAddEnd) as num
								if(M.HVBPAddEnd <= M.HVBPAdd) M.HVBPAddEnd = BP + HVBPAdd * 0.01
							if("Expressed")
								M.HVBPExpAdd=input(usr,"BP to add?","",M.HVBPExpAdd) as num
								M.HVBPExpAdd = round(M.HVBPExpAdd)
								if(M.HVBPExpAdd<=0)
									M.HVBPExpAdd=0
									return
								if(M.HVBPExpAdd <= 1) M.HVBPExpAdd = 1
								M.HVBPExpAddEnd=input(usr,"When can this player gain again? This will trigger only when another player hits this number in raw BP.","",M.HVBPAddEnd) as num
								if(M.HVBPExpAddEnd <= M.BP) M.HVBPExpAddEnd = BP + HVBPExpAdd * 0.01 / BPBoost
					usr << "The player can choose their own alignment freely, once every 12 hours."
					M << "Your HV system has been updated!"
			if("Cancel") return