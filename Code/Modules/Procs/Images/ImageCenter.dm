image/var
	centerpoint
	oldX
	oldY
	wasChanged
	defaultCenterX
	defaultCenterY
image/proc/center(var/C as text)
	//world << "[pixel_x],[pixel_y]" /* diagonsis procs, meant to clarify WTF is going on. enable to let them gib output to figure out all the variables.*/
	if(!C)
		C="center-bottom" /*so that you don't have to remember annoying ass strings- just call I.center and set pixel-x/pixel-y in your parent proc*/
	var/icon/I = icon(icon)
	var/W = I.Width()
	var/H = I.Height()
	//world << "prev W: [W], H: [H]."
	if(centerpoint==C)
		return
	else
		pixel_x+=oldX
		pixel_y+=oldY
	switch(C)
		if("center")
			W=-(W/2+16)
			H=H/2
		if("center-left")
			H=H/2
			W=0
		if("center-right")
			W=-W+16
			H=H/2
		if("center-top")
			W=-(W/2)+16
			H=H
		if("center-bottom")
			W=-(W/2)+16
			H=0
		if("top-left")
			H=H
			W=0
		if("top-right")
			H=H
			W=-(W)+16
		if("bottom-left")
			W=0
			H=0
		if("bottom-right")
			W=-(W)+16
			H=0
		if("old")
			W=0
			H=0
	if(H||W)
		centerpoint=C
		wasChanged=1
	else if(oldX==W&&oldY==H)
		wasChanged=0
	if(wasChanged)
		oldX= W
		oldY= H
	if(!defaultCenterX&&!defaultCenterY)
		defaultCenterX=W
		defaultCenterY=H
	if(!W&&!H)
		pixel_x-=defaultCenterX
		pixel_y-=defaultCenterY
	pixel_x+=W
	pixel_y+=H
	//world << "[pixel_x],[pixel_y] #2, [centerpoint], [C], [H], [W]. [defaultCenterX]. [defaultCenterY]. [wasChanged]. [oldX]. [oldY]."
	var/pixelList = list(0,0)
	pixelList[1]=pixel_x
	pixelList[2]=pixel_y
	return pixelList /*returns a list, 1 is X, 2 is Y.
	Make sure to assign the pixelList output to a corrosponding output so data isn't fucked up (e.g. make a tmp list, set that tmp list to this output.)*/
image/proc/adjust(var/X as num,var/Y as num)
	pixel_x+=X
	pixel_y+=Y