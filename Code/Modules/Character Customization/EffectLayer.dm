obj/overlay/effects
	plane = AURA_LAYER
	name = "aura"
	temporary = 1
	ID = 7
	var/setSSJ
	var/setNJ
	var/centered
obj/overlay/effects/ssjeffects
	name = "SSJ Effect (produced by a transformation verb.)"


obj/overlay/effects/kishockaura
	icon = 'Aura # 4.dmi'

obj/overlay/effects/interfereaura
	icon = 'Aura Electric.dmi'

obj/overlay/effects/chargeaura
	icon = 'SBombGivePower.dmi'

obj/overlay/effects/shield
	icon = 'Shield, Legendary.dmi'

obj/overlay/effects/flickeffects
	var/icon/flickicon
	var/effectduration = 10
	ID = 14
	New()
		..()
		spawn
			sleep(effectduration)
			EffectEnd()
	EffectStart()
		var/icon/I = icon(flickicon)
		if(o_px==0) o_px = round(((32 - I.Width()) / 2),1)
		if(o_py==0) o_py = round(((32 - I.Height()) / 2),1)
		pixel_x = o_px
		pixel_y = o_py
		icon = I
		spawn
			sleep(4)
			EffectEnd()
			del(src)
		..()
obj/overlay/effects/flickeffects/shockwavecustom128
	flickicon= 'Shockwavecustom128.dmi'
	o_px = -48
	o_py = -48
obj/overlay/effects/flickeffects/shockwavecustom512
	flickicon='Shockwavecustom512.dmi'
	o_px = -240
	o_py = -240
obj/overlay/effects/flickeffects/shockwavecustom256
	flickicon= 'Shockwavecustom256.dmi'
	o_px = -112
	o_py = -112

obj/overlay/effects/flickeffects/perfectshield
	EffectStart()
		var/icon/I = icon('shieldWhite_small.png')
		o_px = round(((-32) / 2),1)
		o_py = round(((-32) / 2),1)
		icon = I
		icon += rgb(0,0,50)
		pixel_x = o_px
		pixel_y = o_py

obj/overlay/effects/flickeffects/dodge
	flickicon='Shockwavecustom64.dmi'

obj/overlay/effects/flickeffects/attack
	icon = 'attackspark.dmi'
	pixel_x = -18
	pixel_y = -18
	o_px = -18
	o_py = -18
	EffectStart()
		icon_state = "4"
		var/amount = 4
		spawn
			while(amount >= 0)
				amount--
				pixel_x = o_px
				pixel_y = o_py
				sleep(1)
			EffectEnd()

obj/overlay/effects/flickeffects/forcefield
	flickicon='shield_blue.png'

obj/overlay/effects/flickeffects/blueglow
	icon = null
	EffectStart()
		icon = container.icon
		color = rgb(0,0,115)
		alpha = 134
		..()

obj/overlay/effects/flickeffects/bloodspray/EffectStart()
	var/icon/I = icon('Blood Spray.dmi')
	icon = I
	//flick(I,src)
	spawn
		sleep(5)
		EffectEnd()

obj/overlay/effects/flickeffects/kicharge/EffectStart()
	var/icon/I = icon('Blast Charging 2.dmi')
	icon = I
	//flick(I,src)
	spawn
		sleep(5)
		EffectEnd()

obj/overlay/effects/flickeffects/critical/EffectStart()
	var/icon/I = icon('Critical.dmi')
	icon = I
	//flick(I,src)
	spawn
		sleep(2)
		EffectEnd()

obj/overlay/effects/flickeffects/bladerush/EffectStart()
	var/icon/I = icon('Blade Rush.dmi')
	plane = 8
	icon = I
	//flick(I,src)
	spawn
		sleep(2)
		EffectEnd()

obj/overlay/effects/flickeffects/whirlingblades/EffectStart()
	var/icon/I = icon('Whirling Blades.dmi')
	plane = 8
	icon = I
	//flick(I,src)
	spawn
		sleep(2)
		EffectEnd()

obj/overlay/effects/flickeffects/bleeding/EffectStart()
	var/icon/I = icon('Bleeding.dmi')
	plane = 8
	icon = I
	//flick(I,src)
	spawn
		sleep(2)
		EffectEnd()

obj/overlay/effects/flickeffects/reaver/EffectStart()
	var/icon/I = icon('Reaver.dmi')
	plane = 8
	icon = I
	//flick(I,src)
	spawn
		sleep(2)
		EffectEnd()

obj/overlay/effects/flickeffects/compassrose
	icon = 'Compass Rose.dmi'
	pixel_x = -32
	pixel_y = -32
	o_px = -32
	o_py = -32
	flickicon = 'Compass Rose.dmi'
	EffectStart()
		plane = 8
		var/amount = 3
		while(amount >= 0)
			amount--
			pixel_x = o_px
			pixel_y = o_py
			sleep(1)
		EffectEnd()

obj/overlay/effects/flickeffects/EffectStart()
	if(!container.vis_contents.Find(src)) container.vis_contents.Add(src)
	if(!flickicon)
		sleep(10)
		EffectEnd()
	else
		flick(flickicon,container) //use flick with 32x32 icons, not anything larger. Remember you can overwrite this EffectStart() by simply not writing the ..() (you overwrite the ones in Overlays.dm too.)
		sleep(1)
		EffectEnd()

obj/overlay/effects/flickeffects/attack_indicat_h
	icon = 'Attack strength indicator concept.dmi'
	icon_state = "Heavy"
	effectduration = 4
	EffectStart()
		sleep(effectduration)
		FastEffectEnd()

obj/overlay/effects/flickeffects/attack_indicat_m
	icon = 'Attack strength indicator concept.dmi'
	icon_state = "Medium"
	effectduration = 4
	EffectStart()
		sleep(effectduration)
		FastEffectEnd()

obj/overlay/effects/flickeffects/attack_indicat_l
	icon = 'Attack strength indicator concept.dmi'
	icon_state = "Light"
	effectduration = 4
	EffectStart()
		sleep(effectduration)
		FastEffectEnd()

obj/overlay/effects/flickeffects/attack_indicat_b
	icon = 'Attack strength indicator concept.dmi'
	icon_state = "Block"
	effectduration = 1000