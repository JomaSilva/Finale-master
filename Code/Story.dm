var/Story={"<html>
<head><title>Story</head></title><body>
<center><body bgcolor="#000000"><font size=2><font color="#0099FF"><b><i>



</body><html>"}
var/WritingStory=0
mob/verb/Story()
	set category="Other"
	set hidden = 0
	usr<<browse(Story,"window=Story;size=500x500")
mob/Admin2/verb/EditStory()
	set category="Admin"
	set hidden = 0
	for(var/mob/M) if(M.Admin) M<<"[usr] is editing the story..."
	Story=input(usr,"Edit!","Edit Story",Story) as message
	for(var/mob/F) if(F.Admin) F<<"[usr] is done editing the story..."
	SaveStory()
	LoadStory()
proc/SaveStory()
	var/savefile/S=new("STORY")
	S["Storyline"]<<Story
proc/LoadStory() if(fexists("STORY"))
	var/savefile/S=new("STORY")
	S["Storyline"]>>Story
var/Rules={"<html>
<head><title>Rules</head></title><body>
<body bgcolor="#000000"><font size=2><font color="#FFFFFF"><b>
<center><b><u>Rules</b></u></center>
<hr>
<hr>
<center><b>Change the rules, dumbass.</b></center>
<br>
</body><html>"}
var/WritingRules=0
mob/verb/Rules()
	set category="Other"
	usr<<browse(Rules,"window=Rules;size=500x500")
mob/Admin3/verb/EditRules()
	set category="Admin"
	if(!WritingRules)
		WritingRules=1
		for(var/mob/M) if(M.Admin) M<<"[usr] is editing the rules..."
		Rules=input(usr,"Edit!","Edit Rules",Rules) as message
		for(var/mob/F) if(F.Admin) F<<"[usr] is done editing the rules..."
		WritingRules=0
		SaveRules()
		LoadRules()
	else usr<<"<b>Someone is already editing the rules."
proc/SaveRules()
	var/savefile/S=new("Rules")
	S["Rules"]<<Rules
proc/LoadRules() if(fexists("Rules"))
	var/savefile/S=new("Rules")
	S["Rules"]>>Rules