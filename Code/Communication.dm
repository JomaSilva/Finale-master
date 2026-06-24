mob/verb/Chronology()
	set category="Other"
	set name ="Game Guide"
	usr<<browse(Guide,"window=Guide;size=500x500")
var/OOC=1
mob/var
	OOCing=0
	OOCon=1
	Assessing=1
	Leeching=1
	Recieved=0
	comboon=1
	OOCchannel=1
	list/Ignore=new
mob/var
	TextSize=2
	seetelepathy=1
	Spying=0
mob/proc/EnergyCalibrate()
	var/image/A=image(icon='Flight Aura.dmi')
	A.icon+=rgb(AuraR,AuraG,AuraB)
	overlayList-=FLIGHTAURA
	overlaychanged=1
	FLIGHTAURA=A
mob/verb
	Countdown()
		set category="Other"
		var/CDTime=input("Input the amount you wish to countdown. (i.e; 60 for 1 minute, or 30 for 30 seconds.") as num
		for(var/mob/M in view(screenx,usr)) M<<output("<font size=[M.TextSize]><[SayColor]>[name] is counting down for [CDTime] seconds","Chatpane.Chat")
		WriteToLog("rplog","[src] is counting down for [CDTime]    ([time2text(world.realtime,"Day DD hh:mm")])")
		sleep(CDTime*10)
		for(var/mob/M in view(screenx,usr)) M<<output("<font size=[M.TextSize]><[SayColor]>[name] has waited [CDTime] seconds","Chatpane.Chat")
		WriteToLog("rplog","[src] counted down for [CDTime]    ([time2text(world.realtime,"Day DD hh:mm")])")
	Goto_Spawn()
		set category="Other"
		set hidden=1
		var/spawncooldown
		if(!spawncooldown)
			src.Locate()
			spawncooldown=9000
			spawn while(spawncooldown)
				spawncooldown-=1
				sleep(1)
		else usr<<"You must wait [spawncooldown/10] seconds before using this again."
mob/keyable/verb/Telepathy(mob/M in player_list)
	set category="Skills"
	if(M==usr)
		return
	if(M.isconcealed||M.Race=="Android"||M.expressedBP <= 5)
		usr<<"You can't find their energy!"
		return
	if(M.seetelepathy)
		var/message=input("Say what in telepathy?") as text
		if(M) M<<output("<font size=[M.TextSize]><font face=Old English Text MT><font color=red>[usr] says in telepathy, '[html_encode(message)]'","Chatpane.Chat")
		usr<<output("<font face=Old English Text MT><font color=red>[usr] says in telepathy, '[html_encode(message)]'","Chatpane.Chat")
		WriteToLog("rplog","(Telepathy to [M])[src]: [message]   ([time2text(world.realtime,"Day DD hh:mm")])")
	else usr<<"They have their telepathy turned off."
mob/var/Who={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=2><font color="#0099FF"><b><i>
</body><html>"}
mob/verb/Who()
	set category="Other"
	var/amount=0
	for(var/mob/M) if(M.client) amount+=1
	Who+={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=2><font color="#0099FF"><b><i>
<br>Players: [amount]
</body><html>"}
	for(var/mob/M) if(M.client) Who+={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=2><font color="#0099FF"><b><i>
<br><font color=[rand(2,9)][rand(2,9)][rand(2,9)][rand(2,9)][rand(2,9)][rand(2,9)]>[M.displaykey]
</body><html>"}
	usr<<browse(Who,"window=Who;size=400x400")
	Who={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=2><font color="#0099FF"><b><i>
</body><html>"}