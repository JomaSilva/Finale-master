mob/var
	MysticMod=2.5
	hasmystic
	tmp/mysticing
	mystified=0
	MysticPcnt=1
	MysticAdded = 0

mob/keyable/verb/Mystic()
	set category="Skills"
	if(!usr.mysticing)
		usr.mysticing=1
		if(isBuffed(/obj/buff/Mystic))
			stopbuff(/obj/buff/Mystic)
		else
			startbuff(/obj/buff/Mystic)
		sleep(20)
		usr.mysticing=0

obj/overlay/effects/MysticEffect
	name = "Mystic Electricty effect"
	ID = 13
	icon = 'Electric_Mystic.dmi'

/obj/buff/Mystic
	name = "Mystic"
	icon='Electric_Blue.dmi'
	slot=sFORM
	var/storedpower
	Buff()
		..()
		to_chat(container, "<font color=yellow> You unleash your godly Mystic form.")
		container.Revert()
		container.RemoveHair()
		if(!container.Apeshit)
			container.updateOverlay(/obj/overlay/hairs/hair)
		container.updateOverlay(/obj/overlay/effects/MysticEffect)
		if(container.hasssj)
			container.MysticMod = container.ssjmult
		if(container.hasssj2)
			container.MysticMod = 1.1*container.ssj2mult
		container.MysticPcnt=container.MysticMod
		container.MysticAdded = container.hiddenpotential
		container.BPadd += container.MysticAdded
		container.emit_Sound('chargeaura.wav')
	Loop()
		//PRODIGIAL com God Ki LIGADO: o multiplicador do Mistico e assumido pelo god_form_mult
		//(22x, 32x aos 33% de maestria -- base.dm) -- zera o canal aditivo pra nao contar 2x.
		//Fora do God Ki (ou pra qualquer outro), o Mistico volta ao multiplicador normal.
		if(container.Class == "Prodigial" && container.godki && container.godki.usage)
			container.MysticPcnt = 1
		else
			container.MysticPcnt = container.MysticMod
	DeBuff()
		to_chat(container, "<font color=yellow> You stop using your Mystic power.")
		container.removeOverlay(/obj/overlay/effects/MysticEffect)
		container.MysticPcnt=1
		container.BPadd -= container.MysticAdded
		..()

// ============================================================================
// BEAST -- o despertar Prodigial (rework God Ki 2026-07-18, estilo Gohan em
// Super Hero). A linhagem Prodigial NAO tem SSG/Blue/Royale: o ki divino flui
// pelo MISTICO (god_form_mult 22x -> 32x aos GODKI_BLUE_PCT%) e culmina AQUI.
// DESPERTAR: raiva "Very Angry" (mesmo processo do SSJ1/SSJ2 -- gatilho no
// effector da SaiyanFormMastery, supersaiyan.dm) com Mistico aprendido, God Ki
// LIGADO e maestria GODKI_ROYALE_PCT (50%)+. Depois vira toggle (verb Beast).
// PODER: god_form_mult = 56x (base.dm) enquanto o God Ki estiver ligado.
// VISUAL: o cabelo SSJ2 DO JOGADOR em branco-gelo + aura azul/roxa + raios.
// ============================================================================
mob/var
	hasbeast = 0 //despertou o Beast (persiste no save)
	tmp/beast_form = 0 //forma ativa AGORA (vive no buff)
	tmp/icon/beast_hair_cache = null //cabelo SSJ2 embranquecido (construido 1x por login)

proc/beast_hair_icon(mob/M)
	if(!M) return null
	if(!M.beast_hair_cache)
		var/src_hair = M.ssj2hair ? M.ssj2hair : M.hair
		if(!src_hair) return null
		var/icon/I = new(src_hair)
		I.MapColors(0.34,0.34,0.34, 0.34,0.34,0.34, 0.34,0.34,0.34) //mata o loiro: grayscale
		I.Blend(rgb(70, 74, 84), ICON_ADD) //e clareia pro branco-gelo do Beast
		M.beast_hair_cache = I
	return M.beast_hair_cache

obj/overlay/hairs/beastwhite //o cabelo SSJ2 do proprio jogador, branco (fora de /hairs/ssj: o tint de God Ki nao suja)
	name = "beast hair"
	EffectStart()
		icon = beast_hair_icon(container)
		..()

obj/overlay/effects/beast_aura //aura do Beast: azul e roxo misturados (molde da ue_aura_pas)
	icon = 'god - grey.dmi'
	color = rgb(125, 90, 240)
	temporary = 0

mob/proc/beast_apply_hair() //chamado pelo AddHair() quando beast_form esta ativo (HairObject.dm)
	if(!hair && !ssj2hair) return //careca continua careca
	updateOverlay(/obj/overlay/hairs/beastwhite)

/obj/buff/BeastForm
	name = "Beast"
	icon='Electric_Blue.dmi'
	slot=sFORM
	Buff()
		..()
		container.beast_form = 1
		container.RemoveHair()
		container.AddHair() //AddHair ve o beast_form e aplica o cabelo branco (beast_apply_hair)
		container.updateOverlay(/obj/overlay/effects/beast_aura)
		container.updateOverlay(/obj/overlay/effects/MysticEffect) //os raios do Mistico continuam no Beast
		container.emit_Sound('chargeaura.wav')
		to_chat(view(container), "<font color=#b9a6ff><b>*O cabelo de [container] se ergue num branco-gelo e uma aura entre o azul e o roxo EXPLODE ao seu redor -- o BEAST desperta!*</b></font>")
	Loop()
		if(!container.godki || !container.godki.usage) //o Beast e a expressao maxima do ki divino: sem God Ki ligado, a forma cai
			to_chat(container, "<font color=#b9a6ff>Sem o ki divino, o Beast se recolhe...")
			container.stopbuff(/obj/buff/BeastForm)
			return
		if(container.KO || container.dead)
			container.stopbuff(/obj/buff/BeastForm)
			return
	DeBuff()
		container.beast_form = 0
		container.removeOverlay(/obj/overlay/effects/beast_aura)
		container.removeOverlay(/obj/overlay/effects/MysticEffect)
		container.RemoveHair()
		container.AddHair()
		..()

mob/proc/BeastUp()
	if(beast_form || !hasbeast) return
	if(KO || dead || transing) return
	if(!godki || !godki.usage)
		to_chat(src, "<font color=#b9a6ff>O Beast so responde com o ki divino LIGADO.")
		return
	stopbuff(/obj/buff/Mystic) //o Beast toma o lugar do Mistico (mesmo slot de forma; startbuff recusa slot ocupado)
	Revert() //derruba SSJ e outras formas
	startbuff(/obj/buff/BeastForm)
	emit_Sound('powerup.wav')
	spawn Quake()
	createShockwavemisc(loc,3)
	createCrater(loc,5)

mob/keyable/verb/Beast()
	set category = "Skills"
	if(!usr.hasbeast || usr.Class != "Prodigial") return
	if(usr.beast_form || usr.isBuffed(/obj/buff/BeastForm))
		usr.stopbuff(/obj/buff/BeastForm)
		return
	usr.BeastUp()