var/const
	UNDERAURA_LAYER = 0
	UNDERLAYER_LAYER = 0 //underlays don't belong in overlays, technically speaking. Will probably overhaul to allow for underlays to be used too.
	BODY_LAYER = 2
	CLOTHES_LAYER = 3
	HAIR_LAYER = 4
	HAT_LAYER = 5
	//add shit in between for whatever mang
	AURA_LAYER = 7 //aura layer 1 over clothes

	WEATHER_LAYER = 10

obj/overlay
	//parent_type = /obj //figure out how to undo this, buffs are already moved, but overlays need to have their parent_type changed.
	layer = 5
	IsntAItem=1
	canGrab = 0
	mouse_opacity = 0
	vis_flags = VIS_INHERIT_DIR|VIS_INHERIT_ID|VIS_INHERIT_ICON_STATE
	var
		ID=1 //important, when you remove shit, you compare IDs.
		mob/container //mind as well use the same variables from buff.dm - makes it more consistant and future coders can use "container" for all datum-based frameworks.
		SUBID=1
		temporary=FALSE //will this aura remain on duplications, be left on resets, and etc?
	layer = MOB_LAYER
	//no real other use (other than below) for now but ?? in future

//Essentially, the only real way to fuck around with hairs without doing loads of bullshit is to make it a object.
//You can also reorganize/rennovate/overhaul overlays to constantly use a custom list that can be searched and etc through, but thats another thing.

obj/overlay/proc/Update(var/H as icon,var/R as num,var/G as num, var/B as num)
	if(!R&&!G&&!B&&H)
		icon=H
	else if(H)
		icon = H
		icon += rgb(R,G,B)
	container.vis_contents |= src
//obj/overlay/proc/ReaddSelf()
	//Update()
//defined at the atom level for both obj/overlay usage and obj/mob usage.
atom/proc/centerSelf(var/icon/varicon) //Here's the deal: calling Width() and Height() fucking destroys system resources.
	if(!icon) icon = varicon //Call it once, cache it unless the icon changes.
	var/image/I = image(icon) //(So cache both the result AND the 'current' icon, check the 'current' icon every so often, and etc)
	var/icon/A = new(icon)
	if(A.Width()!=32||A.Height()!=32)
		I.center("center")
	icon = I

obj/overlay/proc/addOverlay(var/H as icon,var/R as num,var/G as num, var/B as num)
	if(!R&&!G&&!B&&H)
		src.icon=H
	else if(H)
		icon = H
	else
		icon += rgb(R,G,B)
	//world << "I am [src.name]/[src] reporting for duty, sir! My layer is [layer] and my plane is [plane]!"
	container.vis_contents |= src
	spawn EffectStart()

obj/overlay/proc/removeOverlay()
	src.EffectEnd()
	//for(var/obj/overlay/B in container.overlayList)
		//if(B.ID == src.ID)
			//B.EffectEnd()
			//return
	return

obj/overlay/proc/fastRemoveOverlay()
	src.FastEffectEnd()
	//for(var/obj/overlay/B in container.overlayList)
		//if(B.ID == src.ID)
			//B.EffectEnd()
			//return
	return
//Wasn't going to include these two procs, but after finding out that the New() proc doesn't
obj/overlay/proc/EffectStart()
	container.vis_contents |= src
	return
obj/overlay/var
	o_px =0
	o_py =0
obj/overlay/proc/EffectLoop()
	//ReaddSelf()
	pixel_x = container.overlay_x + o_px
	pixel_y = container.overlay_y + o_py
	return

obj/overlay/proc/EffectEnd()
	if(container)
		container.vis_contents.Remove(src)
	del(src) //calls a deletion, could probably be changed.
	return //do NOTHING else
//so, call updateOverlays((Path to ur overlay)), update overlays. make custom overlay obj to overlays and then ???

obj/overlay/proc/FastEffectEnd()
	if(container)
		container.vis_contents.Remove(src)
	del(src) //calls a deletion, could probably be changed.
	return //do NOTHING else
//so, call updateOverlays((Path to ur overlay)), update overlays. make custom overlay obj to overlays and then ???

//example:
obj/overlay/clothes //global category of clothes
	plane = CLOTHES_LAYER

obj/overlay/clothes/FusionPads //specific item
	name = "FusionPads" //unique name
	ID = 336 //unique ID
	icon = 'Clothes_FusionPads.dmi'
	//icon_state = "yadda"  //icon state if you need it
	EffectStart() //started after all vars are set.
		icon = container.FDanceClothes
		..() //calls the original proc after you do everything.

