obj/overlay/hairs/ssj
	name = "ssjhair"
	plane = HAIR_LAYER
	ID = 6
	gdki_me()
		return //God Ki tint for SSJ hair is applied in EffectStart() (re-derived every call) so it can't be lost to the EffectStart/EffectLoop ordering race
	ungdki_me()
		return
	EffectStart()
		. = ..()
		if(container.godki && container.godki.usage==1)
			icon -= rgb(100,100,100) //darken first so the new color reads strongly, then push the hair toward the God-Ki form color
			if(container.godki_mod > 1) //Super Saiyan Rose (pink)
				icon += rgb(238, 51, 130)
				icon += rgb(238, 51, 130)
				icon += rgb(238, 51, 130)
			else //Super Saiyan Blue
				icon += rgb(13, 73, 238)
				icon += rgb(13, 73, 238)
				icon += rgb(13, 73, 238)
	EffectLoop()
		if(container.Apeshit) alpha = 1
		else alpha = 255
		if(container.godki)
			if(container.godki.usage==1 && !gdkid)
				gdkid = 1
				EffectStart() //God Ki active on a freshly-added SSJ hair (the Blue bug) -> set icon + color now
			else if(gdkid && container.godki.usage==0)
				gdkid = 0
				EffectStart() //God Ki turned off -> re-derive the plain SSJ hair
		pixel_x = container.overlay_x + o_px
		pixel_y = container.overlay_y + o_py

obj/overlay/hairs/ssj/ssj1
	name = "ssj1 hair"
obj/overlay/hairs/ssj/ssj1/EffectStart()
	icon = container.ssjhair
	..()

obj/overlay/hairs/ssj/ssj1fp
	name = "mastered ssj1 hair"
obj/overlay/hairs/ssj/ssj1fp/EffectStart()
	icon = container.ssjhair
	icon += rgb(100,100,100)
	..()

obj/overlay/hairs/ssj/ssj2
	name = "ssj2 hair"
obj/overlay/hairs/ssj/ssj2/EffectStart()
	icon = container.ssj2hair
	..()

obj/overlay/hairs/ssj/ssj3
	name = "ssj3 hair"
obj/overlay/hairs/ssj/ssj3/EffectStart()
	icon = container.ssj3hair
	..()

obj/overlay/hairs/ssj/ssj4
	name = "ssj4 hair"
obj/overlay/hairs/ssj/ssj4/EffectStart()
	icon=container.ssj4hair
	..()

obj/overlay/hairs/ssj/ussj
	name = "ussj hair"

	gdki_me()
		return //God Ki coloring is handled by the shared SSJ EffectStart (see /obj/overlay/hairs/ssj)
	ungdki_me()
		return

obj/overlay/hairs/ssj/ussj/EffectStart()
	icon=container.ussjhair
	..()

obj/overlay/hairs/ssj/rlssjhair
	name = "restrained lssjhair"
obj/overlay/hairs/ssj/rlssjhair/EffectStart()
	icon+= rgb(0,0,100)
	..()

obj/overlay/hairs/ssj/lssjhair
	name = "legendary super saiyan hair"
obj/overlay/hairs/ssj/lssjhair/EffectStart()
	icon+= rgb(0,110,0)
	..()

obj/overlay/hairs/tails/saiyantail
	name = "saiyan tail"
	plane = BODY_LAYER
	layer = MOB_LAYER + BODY_LAYER //inherits from /hairs; pin layer back to body level so the tail isn't lifted above the hair
	var/pssj
	gdki_me()
		return //God Ki tint is applied directly in EffectStart (re-derived every call) so the tail keeps its color after relog/refresh, mirroring the SSJ hair
	ungdki_me()
		return
	EffectStart()
		..()
		icon+=rgb(container.HairR/2,container.HairG/2,container.HairB/2)
		if(container.ssj) //transformed -> tint the tail to match the form
			if(container.godki && container.godki.usage==1) //Super Saiyan + God Ki = Blue (or Rose)
				icon -= rgb(100,100,100)
				if(container.godki_mod > 1)
					icon += rgb(238, 51, 130)
					icon += rgb(238, 51, 130)
					icon += rgb(238, 51, 130)
				else
					icon += rgb(13, 73, 238)
					icon += rgb(13, 73, 238)
					icon += rgb(13, 73, 238)
			else
				icon += rgb(218, 218, 38) //plain Super Saiyan gold
		else if(container.lssj) //Legendary: C-Type dourado, Full Power verde; Wrathful mantem a cor base do cabelo
			if(container.lssj==2)
				icon += rgb(218, 218, 38) //C-Type (cabelo SSJ loiro) -> rabo dourado
			else if(container.lssj>=3)
				icon += rgb(0, 110, 0) //Full Power (cabelo verde) -> rabo verde
	EffectLoop()
		var/curform = container.ssj ? container.ssj : container.lssj //rastreia o NIVEL da forma (SSJ ou LSSJ) p/ pegar troca de tier (ssj1->2, lssj1->2, etc.)
		if(curform != pssj) //a forma mudou -> re-deriva a cor do rabo
			pssj = curform
			gdkid = (container.godki && container.godki.usage==1) ? 1 : 0
			EffectStart()
		else if(container.godki) //God Ki toggled while ssj stayed -> re-derive the tail color
			if(container.godki.usage==1 && !gdkid)
				gdkid = 1
				EffectStart()
			else if(gdkid && container.godki.usage==0)
				gdkid = 0
				EffectStart()
		..()
		if(!container.Tail) alpha = 0
		else if(container.ssj >= 4) alpha = 0 //SSJ4/FPLB: o corpo ja tem rabo proprio; esconde o overlay do rabo
		else alpha = 255


obj/overlay/body
	name = "body overlay"
	plane = BODY_LAYER
	ID = 2

obj/overlay/body/saiyan/saiyan4body
	name = "saiyan ssj4 body"
	icon='SSj4_Body.dmi'
	ID = 4

obj/overlay/body/saiyan/saiyan5body
	name = "saiyan ssj4 body"
	icon='SSj4_Body.dmi'
	ID = 4
	New()
		..()
		color = rgb(170,170,170)

obj/overlay/hairs/ssj/ssj5
	name = "ssj5 hair"
	EffectStart()
		..()
		icon = container.ssj3hair
		added_color[1] = 170
		added_color[2] = 170
		added_color[3] = 170

obj/overlay/body/saiyan/saiyan4body/EffectStart()
	icon=container.defaultSSJ4icon
	..()
mob/var
	defaultSSJ4icon ='SSj4_Body.dmi'