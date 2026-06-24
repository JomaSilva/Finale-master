obj/overlay/hairs/ssj
	name = "ssjhair"
	plane = HAIR_LAYER
	ID = 6
	gdki_me()
		icon -= rgb(100,100,100)
		icon += rgb(13, 73, 238)
		icon += rgb(13, 73, 238)
		icon += rgb(13, 73, 238)
	ungdki_me()
		EffectStart()

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
		added_color[2] += 75
		added_color[3] += 161
	ungdki_me()
		added_color[2] -= 75
		added_color[3] -= 161

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
	var/pssj
	EffectStart()
		..()
		icon+=rgb(container.HairR/2,container.HairG/2,container.HairB/2)
		if(container.ssj) icon += rgb(218, 218, 38)
		
	EffectLoop()
		..()
		if((container.ssj && !pssj) || (!container.ssj && pssj)) if(prob(50))
			EffectStart()
			gdkid=0
			if(!container.ssj)
				pssj=0
			else
				pssj=1
				icon += rgb(218, 218, 38)
		if(!container.Tail) alpha = 0
		else alpha = 255
	gdki_me()
		icon -= rgb(30,30,30)
		if(pssj)
			icon += rgb(13, 73, 238)
			icon += rgb(13, 73, 238)
		else
			if(container.godki.tier == godki_cap)
				added_color[1] += 245
				added_color[2] += 245
				added_color[3] += 245
				prevgdki=3
			else if(container.godki.tier == godki_cap - 1)
				added_color[1] += 163
				added_color[3] += 136
				prevgdki=2
			else
				added_color[1] += 226
				added_color[2] += 51
				added_color[3] += 28
				prevgdki=1
	ungdki_me()
		EffectStart()


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