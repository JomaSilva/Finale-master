/datum/skill/rank/SpiritBomb
	skilltype = "Ki"
	name = "Spirit Bomb"
	desc = "Create a ball of good energy, and either launch a extremely powerful attack at your foe, or absorb it for a passive, temporary, and powerful boost in strength. The former only works if the afflicted is evil-hearted, and the latter only works if you are kind-hearted."
	level = 0
	expbarrier = 100
	maxlevel = 2
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	enabled=0

/datum/skill/rank/SpiritBomb/after_learn()
	assignverb(/mob/keyable/verb/SpiritBomb)
	to_chat(savant, "You can fire an [name]!")

/datum/skill/rank/SpiritBomb/before_forget()
	unassignverb(/mob/keyable/verb/SpiritBomb)
	to_chat(savant, "You've forgotten how to fire an [name]!?")
/datum/skill/rank/SpiritBomb/login(var/mob/logger)
	..()
	assignverb(/mob/keyable/verb/SpiritBomb)

obj/var/mega
mob/var/SpiritBombicon='SpiritBomb22017.png'
obj/Spirit
	icon='Spirit.dmi'
obj/proc/spin()
	var/icon/I = new(src.icon)
	I.Turn(45)
	src.icon = I
	spawn(1) spin()
/mob/keyable/verb/SpiritBomb()
	set category ="Skills"
	var/cost = (usr.MaxKi*0.9)
	if(!usr.KO&&!usr.med&&!usr.train&&!usr.blasting)
		if(usr.Ki>=(cost))
			usr.Ki -= cost
			usr.blasting=1
			usr.icon_state="Planet Destroyer"
			emit_Sound('spiritbomb.wav')
			spawn(50) usr.icon_state=""
			usr.move=0
			if(usr.baseKi<=usr.baseKiMax)usr.baseKi+=usr.kicapcheck(0.05*BPrestriction*usr.KiMod)
			var/icon/I=icon(SpiritBombicon)
			var/obj/attack/blast/A=new/obj/attack/blast/
			A.name = "Spirit Bomb"
			usr.beamisrunning = 1
			A.pixel_x = round(((32 - I.Width()) / 2),1)
			A.pixel_y = round(((32 - I.Height()) / 2),1)
			A.murderToggle=1
			A.density=1
			A.loc=locate(usr.x,(usr.y+1),usr.z)
			A.icon=I
			A.spin()
			A.plane = 6
			to_chat(usr, "You feel the life force of the planet flood into the Spirit Bomb!")
			flick("Forming",A)
			A.icon_state="Formed"
			sleep(30)
			usr.Blast_Gain()
			usr.Blast_Gain()
			usr.Blast_Gain()
			A.deflectable=0
			A.shockwave=1
			A.density=1
			A.basedamage=30
			A.BP=expressedBP
			A.mods=Ekioff*Ekiskill
			var/SpiritsGivenPower = 10
			var/PeopleGivenPower = 0
			var/powergiven
			var/stage
			var/prevscale = 1
			var/holding = 1
			var/matrix/nM = new
			spawn
				for(var/mob/M in player_list)
					if(M.client&&M.med&&M.z==usr.z&&M!=usr)
						sleep(1)
						var/choice = alert("Give power? It'll drain 10% of your Ki.","","Yes","No")
						if(choice=="Yes"&&holding==1&&A)
							M.overlayList+='SBombGivePower.dmi'
							M.overlaychanged=1
							A.BP+=M.expressedBP*(M.Ki*0.1)
							M.Ki*=0.9
							to_chat(M, "You feel a tenth of your energy slip away.")
							to_chat(usr, "You just got some more energy from accross the planet!")
							PeopleGivenPower += 1
							spawn(30) M.overlayList-='SBombGivePower.dmi'
							M.overlaychanged=1
							spawn
								var/obj/Spirit/Z=new/obj
								Z.loc=locate(M.x,M.y,M.z)
								powergiven += 16
								step_rand(Z)
								walk(Z,NORTH)
								spawn(50) if(Z) del(Z)
								sleep(1)
					sleep(1)
			A.murderToggle=usr.murderToggle
			A.proprietor=usr
			A.move_delay = 0.1
			A.ownkey=usr.displaykey
			spawn
				var/presetiterations=3
				while(presetiterations)
					presetiterations -= 1
					SpiritsGivenPower+=10
					while(SpiritsGivenPower>=1&&A&&holding)
						var/obj/Z=new/obj
						Z.icon='Spirit.dmi'
						Z.density = 0
						Z.plane = 6
						Z.loc=locate(usr.x + rand(-6,6),usr.y + rand(-6,6),usr.z)
						walk_towards(Z,A)
						spawn(15) if(Z) del(Z)
						sleep(15)
						prevscale += 0.1
						nM.Scale(prevscale,prevscale)
						A.transform = nM
						A.BP+=(A.BP*0.01)
						SpiritsGivenPower-=1
					stage+=1
					switch(presetiterations)
						if(3)
							sleep(300)
							to_chat(usr, "You've just got energy from the entire solar system's worth of plants and animals!")
						if(2)
							sleep(1100)
							to_chat(usr, "You've just got energy from the entire universe's worth of plants and animals! You can't grow the Bomb any further!")
			spawn while(holding&&A)
				sleep(10)
				if(PeopleGivenPower>=1)
					var/obj/Z=new/obj
					Z.icon='Spirit.dmi'
					Z.density = 0
					Z.plane = 6
					Z.loc=locate(usr.x + rand(-6,6),usr.y + rand(-6,6),usr.z)
					walk_towards(Z,A)
					spawn(15) if(Z) del(Z)
					sleep(15)
					prevscale += 0.1
					nM.Scale(prevscale,prevscale)
					A.transform = nM
					PeopleGivenPower-=1
					if(holding) A.loc=locate(usr.x,(usr.y+(prevscale/32)),usr.z)
			switch(alert(usr,"Fire it when ready!","","Yes","No"))
				if("Yes")
					holding = 0
				if("No")
					del(A)
					spawn(10)
						usr.move = 1
						holding=0
						usr.blasting = 0
						usr.icon_state=""
						usr.beamisrunning = 0
			spawn while(A)
				if(A.mega)
					for(var/turf/T in view(1,A))
						if(prob(30))
							if(BP>=(T.Resistance+10)*100)
								createDust(T,1)
								usr.emit_Sound('kiplosion.wav')
								T.Destroy()
				sleep(usr.Eactspeed/2)
			if(prevscale >= 12) A.mega=1
			sleep(20)
			A.BP = expressedBP
			A.loc = get_step(usr,usr.dir)
			walk(A,usr.dir)
			usr.emit_Sound('spiritbombfire.wav')
			sleep(30)
			usr.blasting=0
			usr.move=1
			spawn
				A.Burnout(1000)
				usr.beamisrunning = 0
		else to_chat(usr, "You need 90% Energy to do this.")
// ============================================================================
// APOSENTADA: a Genkidama nova (carga sobre a cabeca + esfera rolante) foi
// descartada -- a Spirit Bomb ACIMA voltou a ser a tecnica unica, tanto do rank
// de Kaio do Norte quanto do que o Sr. Kaioh ensina. O typepath sobrevive INERTE
// (sem verb, sem effector, fora de arvore) porque o savefile de quem a aprendeu
// guarda o datum: sem o tipo, o personagem nao carrega.
// ============================================================================
/datum/skill/ki/Genkidama
	skilltype = "Ki"
	name = "Genkidama (aposentada)"
	desc = "Tecnica antiga: deu lugar a Spirit Bomb."
	can_forget = TRUE
	common_sense = FALSE
	enabled = 0

//Roda em TODO login: troca a Genkidama aposentada pela Spirit Bomb e, como rede de
//seguranca, devolve a tecnica a quem OCUPA o cargo de Kaio do Norte e ficou sem ela
//(a migracao anterior tirava a Spirit Bomb antes de dar a Genkidama, e um runtime no
//meio do caminho deixava o portador sem nenhuma das duas).
mob/var/sb_kai_restored = 0 //resgate do Kaio do Norte JA foi feito (persiste: sem o latch, esquecer a skill e relogar cunhava 1 Marco por login)

mob/proc/sb_restore_check()
	if(!signature) return
	var/tinha = 0
	for(var/obj/hotkey/H in Hotkeys) //hotkey SALVO apontando pro verb da Genkidama deletada: a tecla ficaria morta e o card mentindo
		if(H && H.id == "Genkidama") del(H)
	for(var/datum/skill/tree/T in possessed_trees) //devolve o Marco gasto na skill morta
		for(var/datum/skill/S in T.investedskills)
			if(S.type != /datum/skill/ki/Genkidama) continue
			T.invested -= S.skillcost
			T.investedskills -= S
			break
	for(var/datum/skill/S in learned_skills)
		if(S.type != /datum/skill/ki/Genkidama) continue
		tinha = 1
		S.logout() //para o "spawn while(savant)" antes de descartar -- senao sobra loop orfao
		S.savant = src //o logout() ACABOU de zerar o savant e o forget() escreve em savant.skillpoints: sem isto e runtime que derruba o OnLogin inteiro
		S.forget() //forget() PURO: o forget(1) roda o bloco forcado E cai no can_forget de novo (reembolso duplo)
		break
	//quem PORTA o cargo de Kaio do Norte tem direito a tecnica, tendo perdido como perdeu --
	//mas UMA vez so: a copia entra fora da arvore (sem Marco cobrado), entao repetir todo
	//login deixaria "esquecer na arvore + relogar" cunhando 1 Marco por vez.
	if(!tinha)
		if(North_Kai != signature || sb_kai_restored) return
		sb_kai_restored = 1
	if(HasSkill(/datum/skill/rank/SpiritBomb)) return
	learnSkill(new/datum/skill/rank/SpiritBomb, 0)
	to_chat(src, "<font color=#66ccff>A <b>SPIRIT BOMB</b> e sua de novo -- a mesma tecnica do Sr. Kaioh e do Kaio do Norte.</font>")
