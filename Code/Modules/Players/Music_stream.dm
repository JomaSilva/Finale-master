mob/verb/Stream_Music()
	set category = "Other"
	switch(input(usr,"This lets you stream music. First, choose if you want to use a saved song you've already played, or play a new one. Also, if ads are playing in youtube, you can check skipability by going into the Debug menu, and pressing Show/hide invisible browser.") in list("New Song","Old Song","Cancel"))
		if("New Song")
			var/styping
			switch(input(usr,"Add a Youtube or Vocaroo song?") in list("Youtube","Vocaroo","Cancel"))
				if("Youtube") styping = 1
				if("Vocaroo") styping = 2
				if("Cancel") return
			var/name
			switch(input(usr,"Save it?") in list("Yes","No"))
				if("Yes")
					name = input(usr,"Name?") as text
					name += "."
			var/address = input(usr,"Address/URL of the song. In Youtube's case, only copy the stuff after the v=. In Vocaroo's case, only copy the stuff after i/. Make sure to copy nothing but the ID.")
			if(name)
				saved_streams.len++
				saved_streams[saved_streams.len] = name
				saved_streams[name] = list(styping,address)
			var/snd = prepare_brows(styping,address)
			switch(input(usr,"Broadcast song to all players in view?") in list("Yes","No"))
				if("Yes")
					for(var/mob/M in player_list)
						if(get_dist(src,M) <= 30) M.playsong(snd,key) 
				else usr << browse(snd, "window=InvisibleBrowser.invisiblebrowser")
		if("Old Song")
			var/list/tmplist = saved_streams
			tmplist+= "Cancel"
			var/song = input(usr,"Choose a song to do something with.","Songs","Cancel") in tmplist
			if(song != "Cancel")
				switch(input(usr,"Do what with [song]?","Songs","Play") in list("Play","Remove","Cancel"))
					if("Play")
						var/list/info_list = saved_streams[song]
						var/snd = prepare_brows(info_list[1],info_list[2])
						switch(input(usr,"Broadcast song to all players in view?") in list("Yes","No"))
							if("Yes")
								for(var/mob/M in player_list)
									if(get_dist(src,M) <= 30) M.playsong(snd,key) 
							else usr << browse(snd, "window=InvisibleBrowser.invisiblebrowser")
					if("Remove")
						saved_streams -= song
					if("Cancel") return
proc/prepare_brows(stype,link)
	switch(stype)
		if(2)
			return {"<!DOCTYPE html>
<HTML><HEAD><META http-equiv="X-UA-Compatible" content="IE=edge"></HEAD>
<BODY><iframe width="640" height="360" src="https://vocaroo.com/i/[link]&amp;autoplay=1" frameborder="0" allowfullscreen></iframe></BODY></HTML>"}
		if(1)
			return {"<!DOCTYPE html>
<HTML><HEAD><META http-equiv="X-UA-Compatible" content="IE=edge"></HEAD>
<BODY><iframe width="640" height="360" src="https://www.youtube.com/embed/[link]?rel=0&autoplay=1&loop=1&playlist=" frameborder="0" allowfullscreen></iframe></BODY></HTML>"}

mob/verb/Stop_Streamed_Music()
	set category = "Other"
	usr << browse(null, "window=InvisibleBrowser.invisiblebrowser")

//ex"<script>window.location='https://vocaroo.com/i/s0rZHR4XToAI&amp;autoplay=1';</script>", "window=InvisibleBrowser.invisiblebrowser"
//ex"<script>window.location='https://www.youtube.com/watch?v=_bLRaGo-Qwc';</script>", "window=InvisibleBrowser.invisiblebrowser"
client/verb/Mute_ckey()
	set category="Other"
	set hidden = 1
	var/list/c_list = list()
	for(var/client/c in client_list)
		c_list+=c
	c_list+="Cancel"
	var/client/mc = input(usr,"Pick a client to mute/unmute. As of right now, all this does is mean they can't stream music for you.") in c_list
	if(mc != "Cancel")
		if(mc.key in mute_list) mute_list -= mc.key
		else mute_list -= mc.key
		usr << browse("<script>window.location='';</script>", "window=InvisibleBrowser.invisiblebrowser")

mob/proc/playsong(snd,bkey)
	set waitfor=0
	set background = 1
	if(client)
		client.playsong(snd,bkey)

client/proc/playsong(snd,bkey)
	if(bkey in mute_list) return
	src << browse(snd, "window=InvisibleBrowser.invisiblebrowser")

client/var
	list/mute_list = list()
mob/var
	list/saved_streams = list()