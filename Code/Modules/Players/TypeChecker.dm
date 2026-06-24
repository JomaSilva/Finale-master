//a simple typing checking script that adds a overlay when you're typing, and removes it when you're not.
//Code below is mostly done (and copied verbatum) by Ss4toby (http://www.byond.com/developer/Ss4toby/TypingChecker), modified for Climax's purposes.

mob/var/tmp/typing = 0//variable
mob/var/tmp/typewindow = 0
mob/var/tmp/updatetype=0

mob/proc/CheckTyping() if(src) if(client)//this was a huge resource suck
	while(client)
		var/checkvar = winget(usr,"Default.Commandbar","focus")
		if(winget(src,"Default.Commandbar","text") == "") checkvar = null
		if(checkvar=="true" || typewindow)
			src.typing = 1
		else
			if(src.typing == 1)
				src.typing = 0
		if(typing||typewindow)
			if(updatetype)
				src.updateOverlay(/obj/overlay/typeicon)
				updatetype=0
		else
			updatetype=1
			src.removeOverlay(/obj/overlay/typeicon)
		sleep(4)

obj/overlay/typeicon
	plane = 7
	name = "aura"
	ID = 5
	icon = 'TypingIcon.dmi'
