mob/proc/CheckStomach()
	set waitfor = 0
	maxNutrition = 50*Metabolism
	currentNutrition = max(0,currentNutrition)
	if(currentNutrition>maxNutrition)
		currentNutrition=maxNutrition
		usr<<"You ate too much... and you throw up a little. It isn't visible, but it might be a good idea to eat a little lighter next time."
	if(stamina / (max(1,maxstamina)) <= 0.25 && Hunger == 0)
		view()<<"[usr]'s belly growls. [usr] needs food!"
		usr<<"<font color=red> You need food BAD!!!"
		Hunger=1
	if(currentNutrition==0&&Hunger==0&&stamina<maxstamina*0.6)
		view()<<"[usr]'s belly growls. [usr] could probably eat more!"
		usr<<"<font color=red> You might wanna eat."
		Hunger=1
	if(stamina<maxstamina*0.96)
		NutritionFilled = 0

	if(currentNutrition&&!dead&&stamina<maxstamina&&!NutritionFilled&&!IsInFight&&Planet!="Sealed"&&z!=25)
		spawn(30/(max(0.1,Metabolism)))
			if(currentNutrition) currentNutrition = max(currentNutrition - log(1.5,max(currentNutrition,1)) * (maxNutrition / 100) * 0.005,0)
			if(stamina<(max(1,maxstamina))) stamina+=(0.005*globalfoodmod*maxstamina)/(max(0.1,Metabolism)) //important to keep higher stamina bois who've trained the resource into being stronk
			if(currentNutrition>=(0.025*globalfoodmod*maxstamina/100)/max(0.1,Metabolism))//Nutrition drains 5x more than stamina gains, could be changed, but keep this note there so that others can contribute properly.
				currentNutrition-=(0.025*globalfoodmod*maxstamina/100)/max(0.1,Metabolism)
			else
				stamina+=(currentNutrition*satiationMod*(maxstamina/100))//the '/x' is the # of the mutliple difference between currentNutrition reduction and stamina gain.
				currentNutrition-=currentNutrition
			if(Ki<MaxKi)
				if(currentNutrition>=(0.035*globalfoodmod)/max(0.1,Metabolism))//Nutrition drains 5x more than stamina gains, could be changed, but keep this note there so that others can contribute properly.
					currentNutrition-=(0.035*globalfoodmod)/max(0.1,Metabolism)
					Ki += ((0.035*globalfoodmod*MaxKi/100)/max(0.1,Metabolism))
				else
					Ki+=(currentNutrition*satiationMod*(MaxKi/100))//the '/x' is the # of the mutliple difference between currentNutrition reduction and stamina gain.
					currentNutrition-=currentNutrition
			spawn(30/max(0.1,Metabolism))
				if(stamina>=maxstamina*0.96) NutritionFilled = 1