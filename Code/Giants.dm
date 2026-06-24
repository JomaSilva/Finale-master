mob/var
	canbigform
	bigform
	list/bigformoverlays=new/list
	cangivepower
	givepowerchance=1
	oldpixelx
	oldpixely
	tmp/bigforming
mob/DblClick()
	//usr.dblclk+=1
	//spawn(10) usr.dblclk = max(0,usr.dblclk-1)
	if(usr!=src)
		usr.target=src
		usr<<"Your target is now [src].  (Click on yourself twice or press Select Target to stop targeting.)"
	else
		usr.target=null
		usr<<"You don't have a target anymore."
	..()
mob/Click()
	if(Race=="Saiyan") if(usr==src&&!goingssj4)
		goingssj4=1
		if(hasssj4&&!ssj&&!Apeshit&&BP>=rawssj4at*0.9) SSj4()
		spawn(10) goingssj4=0
	..()