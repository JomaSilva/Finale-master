mob/var/hug=0
mob/var/tmp/WANTOUT=0

proc/vectorize(var/x,var/x2,var/y,var/y2)
	var/nuX=x-x2
	var/nuY=y-y2
	return (abs(nuX)+abs(nuY))

proc/breakhug(var/mob/slider,var/mob/holdm,var/dist)
	if(dist>5*slider.Espeed)
		slider.WANTOUT=0
		slider.hug=0
		slider << "You got too far away and lost the hug."
		return
	if(slider.move==0||slider.canmove==0||slider.omegastun==1)
		slider.WANTOUT=0
		slider.hug=0
		slider << "You got stunned and lost the hug."
		return
	if(slider.stepAction()&&slider.stepAction()!=get_dir(slider,holdm)) slider.WANTOUT++
	else if(slider.WANTOUT>0) slider.WANTOUT--
	if((slider.WANTOUT > 3)||slider.target!=holdm)
		slider.WANTOUT=0
		slider.hug=0
		slider << "You let go of the hug."
		return

proc/closedistance(var/slide,var/mob/slider,var/mob/holdm)
	prioritywar(slider,holdm)
	var/dist=slide
	breakhug(slider,holdm,dist)
	while(dist>1)
		spawn(5/slider.Espeed)
			breakhug(slider,holdm,dist)
			step(slider,get_dir(slider,holdm))
			dist--
	spawn(1) combathug(holdm,slider)
	return

proc/combathug(var/mob/target,var/mob/priority)
	breakhug(priority,target)
	if(!priority.hug)
		return
	var/slidedist=vectorize(priority.x,target.x,priority.y,target.y)
	priority.dir=get_dir(target,priority)
	spawn(1) closedistance(slidedist,priority,target)
	return

proc/prioritywar(var/mob/priority,var/mob/contender)
	if(contender.target==priority&&priority.hug)
		if(rand((priority.Espeed-contender.Espeed)*50))
			contender << "You have gained priority!"
			contender.hug=1
			priority.hug=0
			priority.WANTOUT=0

//when we create WRESTLING and CQC this will be useful- essentially helper procs to determine whats going on.