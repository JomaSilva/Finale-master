/client
	parent_type = /datum
		//heil satan
//  /verb/var/verbicon=null IT IS A MYSTERY

mob
	var/list/Keys=list("Q","E","R","T","Y","U","I","O","P","F","G","H","J","K","L","Z","X","C","V","B","N","M","1","2","3","4","5","6","7","8","9","0","Numpad0","Numpad1","Numpad2","Numpad3","Numpad4","Numpad5","Numpad6","Numpad7","Numpad8","Numpad9","Center","Return","Escape","Tab","Space","Back","Insert","Delete","Pause","Snapshot","LWin","RWin","Apps","Multiply","Add","Divide","Separator","Shift","Ctrl","Alt")
	var/tmp/list/Keyableverbs=list()
	var/tmp/showkey=0
	proc/assignVerb(var/mob/verb/V)
		for(var/obj/hotkey/H in Hotkeys)
			if(H.id=="[V]")
				H.initiald = 0
				return
		var/obj/hotkey/au = new/obj/hotkey
	//	if(V.verbicon)au.icon=icontext
		au.id="[V]"
		au.storeverb+=V
		au.possess=src
		au.initiald = 0
		Hotkeys+=au
	proc/assignKey(var/obj/hotkey/au, var/key)
		for(var/obj/hotkey/H in Hotkeys)
			if(H.key==key)
				H.key=null
		au.key=key
		generateGrid()

	proc/generateGrid()
		var/kcol=1
		var/hcol=1
		var/gridtext
		for(var/i in Keys)
			var/test=0
			gridtext+="[i]\n"
			src << output(i, "hotkeys.keygrid:1,[kcol]")
			for(var/obj/hotkey/H in Hotkeys)
				if(H.key==i)
					if(H.id) src << output(H.id, "hotkeys.keygrid:2,[kcol]")
					if(H.icon) src << output(H, "hotkeys.keygrid:3,[kcol]")
					test++
			if(!test)
				src << output("No Verb", "hotkeys.keygrid:2,[kcol]")
				src << output("", "hotkeys.keygrid:3,[kcol]")
			kcol+=1
		for(var/obj/hotkey/H in Hotkeys)
			hcol+=1
			src << output(H.id, "hotkeys.verbgrid:1,[hcol]")
			src << output(H, "hotkeys.verbgrid:2,[hcol]")
			if(H.key) src << output(H.key, "hotkeys.verbgrid:3,[hcol]")
			else src << output("<Click me!", "hotkeys.verbgrid:3,[hcol]")
	verb/clearkeys()
		set category = null
		for(var/obj/hotkey/H in Hotkeys)
			if(H.initiald)
				H.key=initial(H.key)
				H.storeverb=initial(H.storeverb)
			else
				H.key=null
				H.storeverb=list()
			generateGrid()
	verb/Set_Keybinds()
		set category = null
		if(showkey==0)
			Keys=list("Q","E","R","T","Y","U","I","O","P","F","G","H","J","K","L","Z","X","C","V","B","N","M","1","2","3","4","5","6","7","8","9","0","Numpad0","Numpad1","Numpad2","Numpad3","Numpad4","Numpad5","Numpad6","Numpad7","Numpad8","Numpad9","Center","Return","Escape","Tab","Space","Back","Insert","Delete","Pause","Snapshot","LWin","RWin","Apps","Multiply","Add","Divide","Separator","Shift","Ctrl","Alt")
			showkey=1
			for(var/V in Keyableverbs)
				var/icontext
				icontext='ability.jpg'
				assignVerb(V,icontext) //TO ADD AN ICON: name the file (exact verb name)icon.dmi
			generateGrid()
			winset(src,"hotkeys","is-visible=true",)
		else
			showkey=0
			winset(src,"hotkeys","is-visible=false",)
/obj/hotkey
	//this is a really goddamn lazy way to do it but fuck you
	//var/list/Keys=list("Q","E","R","T","Y","U","I","O","P","F","G","H","J","K","L","Z","x","V","B","N","M","1","2","3","4","5","6","7","8","9","0","Numpad0","Numpad1","Numpad2","Numpad3","Numpad4","Numpad5","Numpad6","Numpad7","Numpad8","Numpad9","Center","Return","Escape","Tab","Space","Back","Insert","Delete","Pause","Snapshot","LWin","RWin","Apps","Multiply","Add","Divide","Separator","Shift","Ctrl","Alt")
	var/list/storeverb=list()
	icon = 'ability.jpg' //the icon that shows for the hotkey
	var/modifier=""
	var/down=1
	var/initiald = 1
	var/queue_on_combat
	var/mob/possess
	var/tmp/ispressed = 0
	var/id
	var/locate
	var/key
	//icon='iconless.dmi'
	Click()
		var/Choice=input("Enter any appropriate key. Key list here: http://www.byond.com/docs/ref/#/{skin}/macros. Keep in mind that you'll want to enter letter keys in capitalized.")
		//Keys = initial(Keys)
		if(!istext(Choice)) return
		if(length(Choice) == 1)
			Choice = uppertext(Choice)
		if(Choice in usr.Keys)
			possess.assignKey(src,Choice)

			var/Choice2=input("Will this key only work when it's released?") in list("Yes","No")
			if(Choice2=="Yes") down= FALSE
			else down = TRUE
			Choice2=input("Make this queuable while in combat?") in list("Yes","No")
			if(Choice2=="Yes") queue_on_combat=1
			else queue_on_combat = 0
			possess.generateGrid()
		else key=null

	proc/login(var/mob/M)
		src.possess=M
	proc/logout()
		src.possess=null
	//what have I done
client/verb/UseKey(key="" as text)
	set hidden = 1
	set instant = 1
	if(src.mob&&key)
		var/mob/M=src.mob
		if(key in M.Keys) for(var/obj/hotkey/H in M.Hotkeys)
			if(H.key==key)
				H.ispressed = 1
				M.keypresslist += src
				if(H.down == TRUE)
					if(H.queue_on_combat && M.IsInFight)
						M.queue_hotkey(H,"combat")
					else
						for(var/verb/V in H.storeverb)
							call(M,V)()
							return

client/verb/ReleaseKey(key="" as text)
	set hidden = 1
	set instant = 1
	if(src.mob&&key)
		var/mob/M=src.mob
		if(key in M.Keys) for(var/obj/hotkey/H in M.Hotkeys)
			if(H.key==key)
				H.ispressed=0
				M.keypresslist -= src
				if(H.down == FALSE)
					if(H.queue_on_combat && M.IsInFight)
						M.queue_hotkey(H,"combat")
					else
						for(var/verb/V in H.storeverb)
							call(M,V)()
							return
mob/proc/begin_Hotkey_Loop()
	set waitfor = 0
	set background = 1
	while(defaultKey=="macro")
		sleep(1)
		for(var/obj/hotkey/H in keypresslist)
			if(H.down == TRUE && H.ispressed) //the 'down' var dictates if it activates on pushing it down, ispressed is a temp var that ticks to true when clients push a key down
				if(H.queue_on_combat && IsInFight)
					queue_hotkey(H,"combat")
				else
					for(var/verb/V in H.storeverb)
						call(src,V)()
						return
mob/var/tmp/list/keypresslist = list()
mob/verb/keyables()
	set hidden = 1
	winset(src, "default", "macro = keyable_improved")
	defaultKey="keyables"
mob/verb/predefined()
	set hidden = 1
	winset(src, "default", "macro = macro")
	defaultKey="macro"
	begin_Hotkey_Loop()
mob
	var/defaultKey="macro"
mob/proc/check_hotkeys()
	if(defaultKey=="macro")
		winset(src, "default", "macro = macro")
		begin_Hotkey_Loop()
	else return


mob/var/tmp
	list/combat_queue = list()
mob/proc/queue_hotkey(var/obj/hotkey/H,q_type)
	switch(q_type)
		if("combat")
			combat_queue += H