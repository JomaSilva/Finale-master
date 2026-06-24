//
proc/WriteToLog(ftype,msg)
	msg = msg + "<br>" //testing log help
	switch(ftype)
		if("bugrep") file("BUGREPORTS.log")<<"[msg]"
		if("admin") file("AdminLog.log")<<"[msg]"
		if("rplog") file("RPLog.log")<<"[msg]"
		if("debug") file("DEBUG.log")<<"[msg]"

mob/verb/Logs()//players should be able to see admin logs
	set category="Other"
	set hidden = 1
	var/View={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=8><font color="#0099FF"><b><i>
<font color=red>**Admin Log**<br><font size=4><font color=green>
</body><html>"}
	var/ISF=file2text("AdminLog.log")
	View+=ISF
	usr<<browse(View,"window=browserwindow")


mob/verb/Report_Bug(msg as text)
	set category="Other"
	usr<<"Report a bug. This will write into the 'bugreports' file, found in the game directory of the hosting computer."
	WriteToLog("bugrep","[usr] said \"[msg]\" [time2text(world.realtime,"Day DD hh:mm")]")
mob/verb/Question(msg as text)
	set category="Other"
	usr<<"This is to submit questions to admins, they may or may not answer it. Only post important stuff."
	Questions+={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=1><font color="#0099FF"><b><i>
**[usr]**<br>
[msg]<br><br>
</body><html>"}
mob/Admin1/verb
	S_Logs()
		set name = "All Logs"
		set category = "Admin"
		switch(input(usr,"Which kind of logs?") in list("Questions","RP Logs","Bug Reports","Admin Logs","Debug Logs","Cancel"))
			if("Questions")
				usr<<browse(Questions,"window=Questions;size=500x500")
			if("RP Logs")
				var/View={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=8><font color="#0099FF"><b><i>
<font color=red>**RP Log**<br><font size=4><font color=green>
</body><html>"}
				var/ISF=file2text("RPLog.log")
				View+=ISF
				usr<<browse(View,"window=browserwindow")
			if("Bug Reports")
				var/View={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=8><font color="#0099FF"><b><i>
<font color=red>**Bug Reports**<br><font size=4><font color=green>
</body><html>"}
				var/ISF=file2text("BUGREPORTS.log")
				View+=ISF
				usr<<browse(View,"window=Log;size=300x450")
			if("Admin Logs")
				var/View={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=8><font color="#0099FF"><b><i>
<font color=red>**Admin Log**<br><font size=4><font color=green>
</body><html>"}
				var/ISF=file2text("AdminLog.log")
				View+=ISF
				usr<<browse(View,"window=browserwindow")
			if("Debug Logs")
				var/View={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=8><font color="#0099FF"><b><i>
<font color=red>**Debug Log**<br><font size=4><font color=green>
</body><html>"}
				var/ISF=file2text("DEBUG.log")
				View+=ISF
				usr<<browse(View,"window=browserwindow")

var/AdminLog=file2text("AdminLog.log")
var/RPLog=file2text("RPLog.log")

var/Questions={"<html>
<head><title></head></title><body>
<body bgcolor="#000000"><font size=1><font color="#0099FF"><b><i>
</body><html>"}

mob/Admin3/verb/Clear_Logs()
	set category = "Admin"
	switch(input(usr,"Which type?") in list("RP Logs","Bug Logs","Admin Logs","Debug Logs","Cancel"))
		if("RP Logs")
			fdel("RPLog.log")
			WriteToLog("admin","[usr]([ckey]) deleted RP logs. [time2text(world.realtime,"Day DD hh:mm")]")
		if("Bug Logs")
			fdel("BUGREPORTS.log")
			WriteToLog("admin","[usr]([ckey]) deleted bug reports. [time2text(world.realtime,"Day DD hh:mm")]")
		if("Admin Logs")
			fdel("AdminLog.log")
			WriteToLog("admin","[usr]([ckey]) deleted admin logs. [time2text(world.realtime,"Day DD hh:mm")]")
		if("Debug Logs")
			fdel("DEBUG.log")
			WriteToLog("admin","[usr]([ckey]) deleted debug logs. [time2text(world.realtime,"Day DD hh:mm")]")