mob/proc/CheckOverlays()
	set waitfor = 0
	set background = 1
	if(!loggedin) return
	if(!client&&!target)
		return
	if(overlaychanged == 1)
		overlaychanged = 0
		/*//vis_contents = overlayList was the future, but I decided to delay it a bit.
		//overlays=overlayList
		var/list/dlist = list()
		dlist = overlayList
		vis_contents.Cut()
		for(var/obj/a in overlayList)
			vis_contents |= list(a)
			dlist -= a*/
		overlays.Cut()
		overlays += overlayList + copiedoverlayList
	//if(overlayupdate == 1) //Just for vis_contents overlays. This does not need to be updated whenever we change something, just when we add or remove.
	//	overlayupdate = 0

mob/var/list/overlayList = list()
mob/var/tmp/list/copiedoverlayList = list()
//overlayList is used to keep track of overlays...
//
//same thing, but it was changed for some reason i'm being lazy okay?
mob/var/tmp
	overlayupdate = 0
	overlaychanged = 0
	overlay_x = 0
	overlay_y = 0
//
//
mob/proc/addOverlay(var/dmi)
	overlayList += dmi
	overlayupdate = 1

mob/proc/updateOverlay(obj/overlay/X,var/I as icon,var/R as num,var/G as num, var/B as num) //and ofc, rip most of this code off of the buff.dm
	var/obj/overlay/nB = new X
	nB.container = src
	for(var/obj/overlay/check in vis_contents)
		if(istype(check,nB))
			del(nB)
			check.Update(I,R,G,B)
			return
	if(!(nB in vis_contents))
		nB.addOverlay(I,R,G,B)
		nB.Update()

mob/proc/overlayStats(obj/overlay/B,ed,p,px,py)
	for(var/obj/overlay/check in vis_contents)
		if(istype(check,B) && check.ID == ed)
			if(!isnull(p)) check.plane = p
			if(!isnull(px)) check.o_px = px
			if(!isnull(py)) check.o_py = py
			return TRUE
	return

mob/proc/updateOverlaycID(obj/overlay/X,var/I as icon,var/R as num,var/G as num, var/B as num,ed)
	var/obj/overlay/nB = new X
	nB.container = src
	for(var/obj/overlay/check in vis_contents)
		if(istype(check,nB) && check.ID == ed)
			del(nB)
			check.Update(I,R,G,B)
			check.ID = ed
			return
	if(!(nB in vis_contents))
		nB.addOverlay(I,R,G,B)
		nB.Update()
		nB.ID = ed

mob/proc/removeOverlay(var/obj/overlay/B)
	for(var/obj/overlay/check in vis_contents)
		if(istype(check,B))
			check.removeOverlay()
			return TRUE
	return

mob/proc/removeOverlayID(var/obj/overlay/B,ed)
	spawn
		for(var/obj/overlay/check in vis_contents)
			if(istype(check,B) && check.ID == ed)
				check.removeOverlay()
				return TRUE
		return

mob/proc/fastRemoveOverlay(var/obj/overlay/B)
	spawn
		for(var/obj/overlay/check in vis_contents)
			if(istype(check,B))
				check.fastRemoveOverlay()
				return TRUE
		return

mob/proc/removeOverlays(var/list/L)
	if(isnull(L))
		return
	if(L.len<1)
		return
	for(var/obj/overlay/check in L)
		if(istype(check,/obj/overlay))
			check.removeOverlay()

mob/proc/clearOverlays()
	for(var/obj/overlay/B in src.vis_contents)
		B.EffectEnd()

mob/proc/HasOverlays(var/mob/M,obj/overlay/X)
	var/list/targetoverlays = list()
	if(!X||!M)
		return
	for(X in M.vis_contents)
		targetoverlays += X
	return targetoverlays

mob/proc/GetOverlay(obj/overlay/X)
	for(var/obj/overlay/check in vis_contents)
		if(istype(check,X))
			return check
mob/proc/HasOverlay(obj/overlay/X)
	if(!X)
		return FALSE
	for(X in vis_contents)
		return TRUE
	return FALSE

mob/proc/updateOverlays(var/list/L)
	if(isnull(L))
		return
	if(L.len<1)
		return
	for(var/obj/overlay/B in L)
		if(istype(B,/obj/overlay))
			var/obj/overlay/nB = new B
			nB.container = src
			for(var/obj/overlay/check in vis_contents)
				if(istype(check,nB))
					del(nB)
					check.Update()
					return
			if(!(nB in vis_contents))
				nB.addOverlay()

mob/proc/duplicateOverlays(var/list/L,obj/overlay/X,var/overridetemp)
	if(!isnull(X)&&!istype(X,/obj/overlay))
		return
	if(isnull(X))
		for(var/obj/overlay/A in L)
			var/obj/overlay/nA = new A
			nA.container = src
			nA.icon = A.icon
			nA.icon_state = A.icon_state
			nA.Update()
			if(A.temporary&&!overridetemp)
				nA.EffectEnd()
	else
		for(X in L)
			var/obj/overlay/nA = new X
			nA.container = src
			nA.icon = X.icon
			nA.icon_state = X.icon_state
			nA.Update()
			if(X.temporary&&overridetemp)
				nA.EffectEnd()
//Originally I wasn't going to include this- as you can probably just accomplish anything that can be done below inside a buff, but it's nice to have.
mob/var/tmp
	overlayloopdelay
mob/proc/OverlayLoop()
	overlayloopdelay++
	if(overlayloopdelay>=5)
		overlayloopdelay=0
		for(var/obj/overlay/B in src.vis_contents)B.EffectLoop()

mob/verb
	Overlay_Remove_List()
		set name ="Remove a Overlay"
		set category ="Other"
		set hidden=1
		/*loop through everything in overlays, though typecast
the var as /image for easy access, even though what's inside
isn't really images*/
		var/overlaycount
		src<<"Listing Overlays:"
		for(var/image/X as anything in src.overlays)
			overlaycount++
			src << "Overlay [overlaycount]: [X]([X.icon])([X.icon_state])[X.tag]"
		var/Choice=alert(usr,"show objoverlay list?","","Yes","No")
		switch(Choice)
			if("Yes")
				var/overlaycount2
				for(var/atom/X as anything in src.vis_contents)
					overlaycount2+=1
					if(istype(X,/obj/overlay))
						var/obj/overlay/nX = X
						src << "Overlay ID [overlaycount2]: [nX].[nX.ID]([nX.icon])[nX.tag]"
					else
						src << "Overlay [overlaycount]: [X]([X.icon])([X.icon_state])[X.tag]"
		src<<"Select a Overlay"
		overlaycount=0
		for(var/image/X as anything in src.overlays)
			overlaycount+=1
			src << "Overlay [overlaycount]: [X]([X.icon])([X.icon_state])[X.tag]"
			if(alert(src,"Remove this overlay?",,"Yes","No") == "Yes")
				src.overlays -= X
		var/Choice2=alert(usr,"delete from overlays list?","","Yes","No")
		switch(Choice2)
			if("Yes")
				overlaycount=0
				src<<"Listing Overlays (2)"
				for(var/obj/overlay/X as anything in src.vis_contents)
					overlaycount+=1
					src << "Overlay ID [overlaycount]: [X].[X.ID]([X.icon])[X.tag]"
				src<<"Select a Overlay (2)"
				overlaycount=0
				for(var/obj/overlay/X as anything in src.vis_contents)
					overlaycount+=1
					src << "Overlay [overlaycount]: [X]([X.icon])([X.icon_state])[X.tag]"
					if(alert(src,"Remove this overlay?",,"Yes","No") == "Yes")
						src.overlays -= X
		overlaychanged = 1
//above is a hard-reset for overlays, cycles through ALL overlays and is able to belete them.
	Clear_Overlays()
		set category="Other"
		clearOverlays()
		overlayList-=overlayList
		vis_contents-=vis_contents
		overlays-=overlays
		AddHair()
		if(!hascustomeye) updateOverlay(/obj/overlay/eyes/default_eye)
		if(has_Tail()) get_Tail().Refresh_Overlay()
		if(ssj==4)
			updateOverlay(/obj/overlay/body/saiyan/saiyan4body)
		if(ssj==5)
			updateOverlay(/obj/overlay/body/saiyan/saiyan5body)
		underlays-=underlays
		overlaychanged = 1
		var/matrix/nM = new
		src.transform = nM
		color = null
		if(IsInFight)
			sense_hud_softinit()

mob/var/hascustomeye = 0
mob/Admin3/verb/Clear_All_Overlays()
	set category="Admin"
	for(var/mob/M in mob_list)
		M.Clear_Overlays()
		M.overlaychanged = 1

obj/overlay/eyes/default_eye
	ID = 31459
	name = "eyeballs"
	EffectStart()
		icon = container.eyeicon
		..()
