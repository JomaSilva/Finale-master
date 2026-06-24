mob/var
	tmp/regen=0
	tmp/healing=0
	healskill=1
	healmod=1

obj/Regenerate/verb/Regenerate()
	set category="Skills"
	if(!usr.regen)
		usr.regen=1
		usr<<"You start to regenerate"
	else
		usr.regen=0
		usr<<"You stop regenerating"