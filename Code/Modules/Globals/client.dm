client
	//fps = 20 //a different client fps makes calculating glides impossible (see post 2241289)
	fps = 100

mob/verb/examine(var/atom/A as anything)
	set hidden = 1
	set category = null
	usr << "[A.name]: [A.desc]"


atom/proc/GetArea()
area/GetArea() return src
turf/GetArea() return loc
atom/movable/GetArea()
	if(loc)
		if(isarea(loc)) return loc
		else
			return loc:GetArea()
	else return null
atom/proc/GetTurf()
area/GetTurf() return null
turf/GetTurf() return src
atom/movable/GetTurf()
	set background=1
	if(loc)
		if(isturf(loc))
			return loc
		else
			return loc:GetTurf()
	else return null

//Gets the turf this atom inhabits
/proc/get_turf(atom/A)
	if (!istype(A))
		return
	for(A, A && !isturf(A), A=A.loc); //semicolon is for the empty statement
	return A

datum/client_saver
	var
		identification = null
		save_list[7]//tick this up every time we add a new save item (or like, create a new method or something kek)
var/list/client_save_list = list()

client
	var/charcreationSpecial=0 //var that increments every time you create a new character, only reset by 1 sometimes on logging on. Higher this number is,
	//the lower the chance for you to be able to get shit like Uchiha.
	New()
		..()
		client_list += src
		if(prob(10)&&charcreationSpecial) charcreationSpecial -= 1
		spawn client_var_restore()
		spawn HPtoggle()
	Del()
		client_list -= src
		if(mob)
			mob.Save()
		spawn client_var_save()
		..()
	proc/HPtoggle()
		set background = 1
		set waitfor = 0
		if(HPWindowToggle==1)
			HPWindowToggle=2
			winset(src, "lpane.lpanechild", "left=")
			winshow(src, "HealthWindow", 1)
		else if(HPWindowToggle==2)
			HPWindowToggle=1
			winset(src, "lpane.lpanechild", "left=hppane")
			winshow(src, "HealthWindow", 0)
	proc
		client_var_restore()
			if(client_save_list.len)
				var/datum/client_saver/cs
				for(var/s in client_save_list)
					var/datum/client_saver/ts = s
					if(ts.identification == key)
						cs = ts
						break
				ReincarnationBonus = cs.save_list[1]
				HPWindowToggle = cs.save_list[2]
				clientvolume = cs.save_list[3]
				clientsoundvolume = cs.save_list[4]
				TitleMusicOn = cs.save_list[5]
				mute_list = cs.save_list[6]
				unstucktimer = cs.save_list[7]

		client_var_save()
			var/datum/client_saver/cs
			if(client_save_list.len)
				for(var/s in client_save_list)
					var/datum/client_saver/ts = s
					if(ts.identification == key)
						cs = ts
						break
			if(isnull(cs))
				cs = new/datum/client_saver
				client_save_list += cs
			cs.identification = key
			cs.save_list[1] = ReincarnationBonus
			cs.save_list[2] = HPWindowToggle
			cs.save_list[3] = clientvolume
			cs.save_list[4] = clientsoundvolume
			cs.save_list[5] = TitleMusicOn
			cs.save_list[6] = mute_list
			cs.save_list[7] = unstucktimer
client
	AllowUpload(filename,filelength)
		if(filelength >= 524288 && uploadlimted) //512k (0.5M)
			if(mob)
				if(mob.Admin)
					return 1
			src << "[filename] is too big to upload!"
			return 0
		return 1

var/uploadlimted=0
mob/Admin3/verb/Toggle_Upload_Limits()
	set category="Admin"
	switch(alert(usr,"Upload limits?","","Yes","No"))
		if("Yes")
			uploadlimted=1
		if("No")
			uploadlimted=0


/client/Topic(href, href_list, hsrc)
	if(!usr || usr != mob)	//stops us calling Topic for somebody else's client. Also helps prevent usr=null
		return

	//Admin PM
	if(href_list["priv_msg"])
		if (href_list["ahelp_reply"])
			mob.cmd_ahelp_reply(href_list["priv_msg"])
			return
		mob.cmd_admin_pm(href_list["priv_msg"],null)
		return
	switch(href_list["_src_"])
		if("usr")		hsrc = mob
	..() /* just stealing admin code shamelessly from ss13, comes with this topic code. */

/proc/key_name(var/whom, var/include_link = null, var/include_name = 1)
	var/mob/M
	var/client/C
	var/key
	var/ckey

	if(!whom)	return "*null*"
	if(istype(whom, /client))
		C = whom
		M = C.mob
		key = C.key
		ckey = C.ckey
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
		ckey = M.ckey
	else if(istext(whom))
		key = whom
		ckey = ckey(whom)
		C = ckey
		if(C)
			M = C.mob
	else
		return "*invalid*"

	. = ""

	if(!ckey)
		include_link = 0

	if(key)
		if(include_link)
			. += "<a href='?priv_msg=[ckey]'>"
		. += key
		if(!C)
			. += "\[DC\]"

		if(include_link)
			. += "</a>"
	else
		. += "*no key*"

	if(include_name && M)
		if(M.name)
			. += "/([M.name])"

	return .

/proc/key_name_admin(var/whom, var/include_name = 1)
	return key_name(whom, 1, include_name)

/proc/get_mob_by_ckey(var/key)
	if(!key)
		return
	var/list/mobs = sortmobs()
	for(var/mob/M in mobs)
		if(M.ckey == key)
			return M

/proc/sortmobs()
	var/list/moblist = list()
	var/list/sortmob = sortNames(mob_list)
	for(var/mob/M in sortmob)
		moblist.Add(M)

	return moblist


//quick rundown on CSS:
//always stick a ' ; ' at the end of every selector definition- not doing so is just bad formatting and you should feel bad.
//to call any of these in a output() or << "" shit, do <span class="yourclasshere"> text here </span> (case matters.)
//you can also use #asdf for a define but that's only if you're going to use it once (i.e. it's useless to you.)

client/script = {"<style>
body					{background: #000000; color: #413784; font-size: 1; font-weight: bold; font-family: 'Franklin Gothic Book';}

h1, h2, h3, h4, h5, h6	{color: #0000ff;	font-family: Georgia, Verdana, sans-serif;}

em						{font-style: normal;	font-weight: bold;}

.motd					{color: #638500;	font-family: Verdana, sans-serif;}
.motd h1, .motd h2, .motd h3, .motd h4, .motd h5, .motd h6
	{color: #638500;	text-decoration: underline;}
.motd a, .motd a:link, .motd a:visited, .motd a:active, .motd a:hover
	{color: #638500;}

.prefix					{					font-weight: bold;}

.ooc					{					font-weight: bold;}
.adminobserverooc		{color: #0099cc;	font-weight: bold;}
.adminooc				{color: #b82e00;	font-weight: bold;}

.adminobserver			{color: #996600;	font-weight: bold;}
.admin					{color: #386aff;	font-weight: bold;}

.name					{					font-weight: bold;}

.say					{}
.deadsay				{color: #5c00e6;}
.radio					{color: #008000;}
.sciradio				{color: #993399;}
.comradio				{color: #aca82d;}
.secradio				{color: #b22222;}
.medradio				{color: #337296;}
.engradio				{color: #fb5613;}
.suppradio				{color: #a8732b;}
.servradio				{color: #6eaa2c;}
.syndradio				{color: #6d3f40;}
.dsquadradio			{color: #686868;}
.centcomradio			{color: #686868;}
.aiprivradio			{color: #ff00ff;}

.yell					{					font-weight: bold;}

.alert					{color: #ff0000;}
h1.alert, h2.alert		{color: #000000;}

.emote					{					font-style: italic;}
.selecteddna			{color: #ffffff; 	background-color: #001B1B}

.attack					{color: #ff0000;}
.disarm					{color: #990000;}
.passive				{color: #660000;}

.italics				{					font-style: italic;}
.ancient                                {color: #008B8B;        font-style: italic;}
.sinister                               {color: #800080;        font-weight: bold;      font-style: italic;}
.userdanger				{color: #ff0000;	font-weight: bold; font-size: 3;}
.danger					{color: #ff0000;}
.warning				{color: #ff0000;	font-style: italic;}
.announce 				{color: #228b22;	font-weight: bold;}
.rose					{color: #ff5050;}
.info					{color: #0000CC;}
.notice					{color: #000099;}
.boldnotice				{color: #000099;	font-weight: bold;}
.boldannounce                  {color: #ff0000;        font-weight: bold;}
.adminnotice			{color: #0000ff; font-weight: bold; font-size: 2; }
.unconscious			{color: #0000ff;	font-weight: bold;}
.suicide				{color: #ff5050;	font-style: italic;}
.green					{color: #03ff39;}
.shadowling				{color: #311648;}

.newscaster				{color: #800000;}
.ghostalert				{color: #5c00e6;	font-style: italic; font-weight: bold;}

.alien					{color: #543354;}
.noticealien			{color: #00c000;}
.alertalien				{color: #00c000;	font-weight: bold;}

.interface				{color: #330033;}

.sans					{font-family: "Comic Sans MS", cursive, sans-serif;}
.papyrus				{font-family: Papyrus, fantasy, cursive, sans-serif;}
.robot					{font-family: "Courier New", cursive, sans-serif;}
.mommi					{color: navy;}

.big					{font-size: 3;}
.greentext				{color: #00FF00;	font-size: 3;}
.redtext				{color: #FF0000;	font-size: 3;}

BIG IMG.icon 			{width: 32px; height: 32px;}

</style>"}