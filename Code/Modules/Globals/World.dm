var/gameversion="0.9.6"
world
	visibility = 1 //determines if this shows up on the hub pager.
	icon_size = 32
	fps = 12 //Okay, we don't need 60 FPS.
	turf=/turf/Other/Blank
	area=/area/Outside
	version=31
	cache_lifespan=0
	loop_checks=1
	name="Dragonball Climax"
//status="<font color=#000000><b><font size=1>" Hate old formatting. hate it so much.
	hub = "Kingzombiethe1st.DragonballClimax" //determines if this even shows up in the same hub. (change to format yourname.hubname, make sure if you change to set a hub at byond.com)
var/server_desc = "Godki!"

world
	New()
		..()
		log = file("DEBUG.log")
		world.status="<font color=#000000 size=1><b> Dragonball Climax: Hosting: [world.host], Main Fork version [gameversion] | [server_desc]</b></font>"
		spawn(10) Initialize()
		spawn(50) AutoRevive()
/*
		spawn pixelproccess()
*/

mob/Admin3/verb/World_FPS()
	set category = "Admin"
	world.fps = input(usr,"Set the world FPS. Default is 12.","",world.fps) as num

obj/DBVTitle
	icon='DBV.dmi'
	Savable=0
	New()
		var/asdf = rand(0,1)
		if(asdf)
			icon = 'dbvalternate.dmi'
		..()

proc/SaveWorld()
	world<<"<font color=red><b><font size=3>Saving and Processing all Files"
	SaveAdmins()
	SaveYear()
	Save_Gains()
	Save_Rank()
	Save_Illegal()
	SaveItems()
	MapSave()
	AreaSave()
	Save_Settings()
	SaveMobs()
	sleep(10)
	world<<"<b><font color=yellow>Processing Complete."

var/tmp/worldloading=0

proc/Initialize()
	set waitfor = 0
	set background = 1
	worldloading = 1
	world<<"Initializing all files..."
	firstcleaner=1
	generateTXT()
	LoadYear()
	sleep(1)
	world<<"Loaded Years"
	LoadAdmins()
	sleep(1)
	world<<"Loaded (b)Admins"
	Load_Ban()
	sleep(1)
	world<<"Loaded Idio- I mean Bans"
	Load_Illegal()
	sleep(1)
	world<<"Loaded Illegals"
	Load_Gains()
	sleep(1)
	world<<"Loaded Muh Gains"
	LoadStory()
	sleep(1)
	world<<"Loaded Lol Story"
	LoadRules()
	sleep(1)
	world<<"Loaded Admin Excuses"
	Load_Rank()
	sleep(1)
	world<<"Loaded Skill Hoarders"
	Init_Masteries()
	sleep(1)
	world<<"Loaded Masteries"
	LoadIntro()
	sleep(1)
	world<<"Loaded The Introduction"
	Load_Settings()
	sleep(1)
	world<<"Loaded the optimized settings for maxmimum gaming potential"
	Init_Genome()
	sleep(1)
	world<<"Initialized Genomes"
	LoadItems()
	Init_Alchemy()
	sleep(1)
	world<<"YOU CANNOT HANDLE MY POTIONS. Potions loaded."
	Init_Recipes()
	sleep(1)
	world<<"It's a piece of cake to bake a pretty cake, WHAT, (If the way is hazy!) Recipes loaded."
	MapLoad()
	sleep(1)
	world<<"Nah Final Destination was cool. Map loaded."
	AreaLoad()
	sleep(1)
	world<<"Loading ATMOSPHERE"
	LoadMobs()
	sleep(1)
	Cleaner()
	sleep(1)
	world<<"Cleaning lady on board."
	WorldTime()
	sleep(1)
	world<<"I just put the 'Morning' in Morning-Wood. World Timer loaded."
	spawn(10)
		WorldClock()
		WorldSubClocks()
	spawn World_Ticker()
	world<<"Time to charge the clock, you cock."
	spawn(10) Years()
	world<<"Old... age... kicking... in..."
	spawn(10) Dungeon_Timer()
	world<<"Dungeons rolling up!"
	spawn Restart_Handler()
	world<<"All files loaded."
	spawn jokecheck()
	worldloading = 0
	spawn generate_spells()

proc/World_Ticker() //Use this for your shit that doesn't need to be resource intensive or before anything.
	set waitfor = 0
	set background = 1
	CHECK_TICK
	if(TimeStopped)
		TimeStopDuration-=1
		if(TimeStopDuration<=0)
			TimeStopped = 0
			TimeStopDuration=0
	sleep(1)
	CHECK_TICK
	spawn World_Ticker()

proc/Restart_Handler()
	set waitfor = 0
	sleep(324000)
	Restart()


//have been having issues with save files not deleting defunct shit? use this.
/datum
	var/plsdelete=0
	/*Body/Head/Brain/plsdelete = 1 example*/
	New()
		..()
		if(plsdelete) del(src)

/atom
	New()
		..()
		/*if(lightme)
			light = new(src, lightradius, lightintensity)*/
		if(plsdelete) del(src)

var/aprilfoolson = 0

proc/jokecheck()
	var/monthcheck = time2text(world.realtime,"MM")
	var/daycheck = time2text(world.realtime,"DD")
	if(monthcheck == "04" && daycheck == "01")
		aprilfoolson = 1
		world << "<font color=red size=3>SELF DESTRUCT SEQUENCE INITIATED"
		sleep(10)
		world << "<font color=red size=3>TIME TO DESTRUCTION: 5"
		sleep(10)
		world << "<font color=red size=3>TIME TO DESTRUCTION: 4"
		sleep(10)
		world << "<font color=red size=3>TIME TO DESTRUCTION: 3"
		sleep(10)
		world << "<font color=red size=3>TIME TO DESTRUCTION: 2"
		sleep(10)
		world << "<font color=red size=3>TIME TO DESTRUCTION: 1"
		sleep(10)
		world << "<font color=white size=3>Shaggy:</font><font color=purple size=4> Hakai.</font>"
		sleep(15)
		world << "..."
		sleep(30)
		world << "APRIL FOOLS! Super Saiyan 5 is available for saiyans today only. For the Admin's sake, don't abuse this please."