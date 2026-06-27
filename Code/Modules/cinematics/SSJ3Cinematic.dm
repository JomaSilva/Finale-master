//Cinematics folder is there to put long ass sequences into. ONE CINEMATIC PER .DM NO FUCKING EXCEPTIONS. ONE FUCKING CINEMATIC ALONE IS ENOUGH TO TAKE UP 700+ LINES.
//This does not neccessarily mean SSJ transformations, but if yours is long enough, consider making a cinematic file here.
mob/proc/SSJ3Cinematic()
	if((ssj3firsttime&&hair=='Hair_Goku.dmi'&&Race=="Saiyan")||(ssj3firsttime==2)) //ssj3firsttime is a variable manipulated by the player thru the settings menu.
		move=0
		//Flashy stuff
		sleep(10)
		RemoveHair()
		overlayList-='Elec.dmi'
		overlaychanged=1
		updateOverlay(/obj/overlay/hairs/hair)
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: You're going to love this, trust me. What you're seeing now is my normal state."
		sleep(60)
		removeOverlay(/obj/overlay/hairs/hair)
		updateOverlay(/obj/overlay/hairs/ssj/ssj1)
		ssj=1
		updateOverlay(/obj/overlay/auras/aura)
		emit_Sound('chargeaura.wav')
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: This is a Super Saiyan."
		emit_TransformMusic('ssj3theme.ogg', 1682) //SSJ3 theme (~2.8min): plays to everyone nearby + ducks listeners' battle music
		sleep(50)
		removeOverlay(/obj/overlay/hairs/ssj/ssj1)
		updateOverlay(/obj/overlay/hairs/ssj/ssj2)
		ssj=2
		overlayList+='Elec.dmi'
		overlaychanged=1
		emit_Sound('chargeaura.wav')
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: And this... this is what as known as a Super Saiyan that has ascended past a Super Saiyan."
		sleep(20)
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: Or you can just call this a Super Saiyan 2."
		sleep(50)
		var/list/localmobs[3]
		for(var/mob/M in view(src))
			if(!(M==src)&&localmobs[1]==null)
				localmobs[1] = M
			else if(!(M==src)&&localmobs[2]==null)
				localmobs[2] = M
			else if(!(M==src)&&localmobs[3]==null)
				localmobs[3] = M
		if(localmobs[1])
			var/mob/M = localmobs[1]
			view(8)<<"<font size=[M.TextSize]><[M.SayColor]>[M]: Has [src] really done it!? Has [src] really found a way to surpass an ascended Saiyan? Is that possible!?"
		if(localmobs[2])
			var/mob/M = localmobs[2]
			view(8)<<"<font size=[M.TextSize]><[M.SayColor]>[M]: [src] must be bluffing. I mean, what would that make [src]? Double ascended?"
		sleep(40)
		view(8)<<"<font size=[src.TextSize]><[SayColor]>[src]: AND THIS..."
		view(6)<<"<font color=yellow>*[src] leans inward and pumps their fists next to their sides!!*"
		if(localmobs[3])
			var/mob/M = localmobs[3]
			view(8)<<"<font size=[M.TextSize]><[M.SayColor]>[M]: What's [src] doing!?"
		sleep(50)
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: IS TO GO..."
		sleep(20)
		view(6)<<"<font size=[TextSize]><font color=yellow>*[src] leans foward!!*"
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: EVEN FURTHER BEYOND"
		sleep(30)
		removeOverlay(/obj/overlay/auras/aura)
		view(6)<<"<font color=yellow>*A great wave of power emanates from [src] as a yellow aura bursts around them!*"
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!!!"
		view(6)<<"<font color=yellow>*[src] screams as [src] releases a unbelievable amount of energy!*"
		spawn for(var/mob/M in view(src))
			M.Quake()
		for(var/turf/T in view(24,src))
			if(prob(20)) createDustmisc(T,2)
			if(prob(1)) createDustmisc(T,3)
			if(prob(1)) createLightningmisc(T,9)
			if(prob(1)) createLightningmisc(T,5)
		sleep(50)
		Quake()
		sleep(50)
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!!!"
		sleep(100)
		spawn for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		spawn for(var/mob/M in view(src))
			M.Quake()
		overlayList-='SSj Aura.dmi'
		overlaychanged=1
		var/image/I=image(icon='Aurabigcombined.dmi')
		I.plane = 7
		overlayList+=I
		overlaychanged=1
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!!!"
		sleep(100)
		spawn for(var/mob/M in view(src))
			M.Quake()
		sleep(100)
		for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		view(8)<<"<font color=yellow>*[src]'s voice grows very hoarse!*"
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!!!!"
		spawn SSj2GroundGrind()
		sleep(130)
		spawn for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		overlayList-=I
		overlaychanged=1
		var/image/I3 = image(icon=('ss3transformaurafinal.dmi'))
		I3.pixel_x-=49
		overlayList-=I3
		overlayList+=I3
		overlaychanged=1
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHH!!!!"
		view(6)<<"<font color=yellow>*[src] is shaking the entire planet!!!*"
		spawn for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		sleep(100)
		spawn for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		sleep(140)
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHHHHHH!!!!"
		view(6)<<"<font color=yellow>*[src] is causing earthquakes everywhere!!!*"
		spawn for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		sleep(100)
		spawn for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		sleep(100)
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHHHHHHHHHH!!!!"
		view(6)<<"<font color=yellow>*The ocean itself is curling away from [src]'s immense power!!!*"
		spawn for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		sleep(100)
		spawn for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		overlayList-=I3
		overlaychanged=1
	else if(ssj3firsttime)
		emit_Sound('rockmoving.wav')
		move=0
		//Flashy stuff
		emit_TransformMusic('BF - Super Saiyan 3 Transformation.mp3', 568) //SSJ3 transformation theme (~57s)
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!!!"
		sleep(30)
		view(6)<<"<font color=yellow>*A great wave of power emanates from [src] as a yellow aura bursts around them!*"
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!!!"
		view(6)<<"<font color=yellow>*[src] screams as [src] releases a unbelievable amount of energy!*"
		spawn for(var/mob/M in view(src))
			M.Quake()
		for(var/turf/T in view(24,src))
			if(prob(20)) createDustmisc(T,2)
			if(prob(1)) createDustmisc(T,3)
			if(prob(1)) createLightningmisc(T,9)
			if(prob(1)) createLightningmisc(T,5)
		for(var/mob/M in view(src))
			M.Quake()
		var/image/I=image(icon='Aurabigtop.dmi')
		I.pixel_y+=32
		overlayList+=I
		overlayList+='Aurabigbottom.dmi'
		overlaychanged=1
		sleep(240)
		spawn for(var/mob/M in view(src))
			M.Quake()
		sleep(100)
		spawn for(var/mob/M in view(src))
			M.Quake()
		sleep(100)
		spawn for(var/mob/M in view(src))
			M.Quake()
		view(6)<<"<font color=yellow>*[src]'s voice grows very hoarse!*"
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!!!!"
		spawn SSj2GroundGrind()
		sleep(100)
		spawn for(var/mob/M in view(src))
			M.Quake()
		sleep(100)
		spawn for(var/mob/M in view(src))
			M.Quake()
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA!!!"
		sleep(100)
		spawn for(var/mob/M in view(src))
			M.Quake()
		sleep(150)
		spawn for(var/mob/M in view(src))
			M.Quake()
		spawn(100) overlays-=I
		overlaychanged=1
		spawn(100) overlays-='Aurabigbottom.dmi'
		overlaychanged=1
		var/image/I3 = image(icon=('ss3transformaurafinal.dmi'))
		I3.pixel_x-=49
		overlayList-=I3
		overlayList+=I3
		overlaychanged=1
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHH!!!!"
		view(6)<<"<font color=yellow>*[src] is shaking the entire planet!!!*"
		for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		sleep(150)
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHHHHHH!!!!"
		view(6)<<"<font color=yellow>*[src] is causing earthquakes everywhere!!!*"
		for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		sleep(150)
		view(8)<<"<font size=[TextSize]><[SayColor]>[src]: AAAAAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHHHHHHHHHH!!!!"
		view(6)<<"<font color=yellow>*The ocean itself is curling away from [src]'s immense power!!!*"
		for(var/mob/M in player_list)
			if(M.Planet == src.Planet)
				M.Quake()
		overlayList-=I3
		overlaychanged=1