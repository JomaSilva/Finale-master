// ============================================================================
// CASAMENTO & FILHOS -- versao consensual (reescrita completa).
// O conteudo antigo deste arquivo (mecanica de "rape" + mensagens de odio) foi
// REMOVIDO por completo. O que existe agora:
//   1. Propose_Marriage: dois personagens que JA SAO AMIGOS (sistema de amizade)
//      podem se casar (com consentimento).
//   2. Have_Child: um casal CASADO de sexos opostos pode tentar ter um filho.
//      A gravidez usa a MESMA base de sempre (Pregnant + womb/genoma): o bebe
//      vira a opcao de hibrido/half-breed na criacao de personagem, como antes.
//   3. Lay_Egg: inalterado (racas de ovo, ex.: Namekuseijin).
// ============================================================================

mob/var
	isBorn = 0
	CanMate = 1
	Reproduce_Biologically=1
	N_Breed = 1
	E_Breed = 0
	Mature_Age=16
	// ---- casamento ----
	married_to = ""      // signature do conjuge ("" = solteiro). Persiste no save.
	married_name = ""    // nome do conjuge (para exibicao)

mob/var
	Egg=0
	Husband=""
	Father=""
	Father_BP=0
	Husband_Class=""
	Father_Class=""

// helper: os dois estao presentes, vivos e conscientes?
proc/mate_pair_ok(mob/A, mob/B)
	if(!A || !B || A == B) return 0
	if(!A.client || !B.client) return 0
	if(A.KO || A.dead || B.KO || B.dead) return 0
	if(get_dist(A, B) > 1) return 0
	return 1

// ---------------------------------------------------------------------------
// CASAMENTO
// ---------------------------------------------------------------------------
mob/verb/Propose_Marriage()
	set category = "Other"
	//a OPCAO so aparece pra quem ja e AMIGO: a lista de escolha e filtrada por is_friend
	//(a validacao por tras continua -- re-checa depois do input, que bloqueia)
	var/list/cands = list()
	for(var/mob/T in oview(1, usr))
		if(T == usr || !T.client || T.isNPC || !T.signature) continue
		if(!usr.is_friend(T)) continue
		if(T.married_to) continue
		cands += T
	if(!cands.len)
		to_chat(usr, "Nenhum AMIGO solteiro ao seu lado. Casamento e coisa de amigos: envie um pedido de amizade primeiro e fique a 1 tile.")
		return
	var/mob/M = null
	if(cands.len == 1) M = cands[1]
	else M = input(usr, "Pedir quem em casamento?", "Casamento") as null|anything in cands
	if(!M) return
	if(!mate_pair_ok(usr, M))
		to_chat(usr, "Voces precisam estar lado a lado, vivos e conscientes.")
		return
	if(usr.married_to)
		to_chat(usr, "Voce ja e casado(a) com [usr.married_name].")
		return
	if(M.married_to)
		to_chat(usr, "[M] ja e casado(a).")
		return
	if(!usr.is_friend(M))
		to_chat(usr, "Voces precisam ser AMIGOS antes de pensar em casamento. (Envie um pedido de amizade primeiro.)")
		return
	switch(input(M, "[usr] te pediu em casamento! Aceita?", "Casamento") in list("Sim","Nao"))
		if("Sim")
			usr.married_to = M.signature
			usr.married_name = M.name
			M.married_to = usr.signature
			M.married_name = usr.name
			usr.emit_Sound('powerup.wav')
			to_chat(view(9), "<font color=#FFB6C1><b>[usr] e [M] se casaram!</b></font>")
			chatcast(world, "<font color=#FFB6C1><b>[usr] e [M] se casaram!</b></font>", "announce")
		if("Nao")
			to_chat(usr, "[M] recusou o pedido.")
			to_chat(M, "Voce recusou o pedido de [usr].")

mob/verb/Divorce()
	set category = "Other"
	if(!usr.married_to)
		to_chat(usr, "Voce nao e casado(a).")
		return
	switch(input(usr, "Divorciar-se de [usr.married_name]?", "Divorcio") in list("Nao","Sim"))
		if("Sim")
			var/exname = usr.married_name
			// avisa/limpa o conjuge se estiver online
			for(var/mob/P in player_list)
				if(P.client && P.signature == usr.married_to)
					P.married_to = ""
					P.married_name = ""
					to_chat(P, "<font color=#FFB6C1>[usr] se divorciou de voce.</font>")
					break
			usr.married_to = ""
			usr.married_name = ""
			to_chat(usr, "Voce se divorciou de [exname].")

// ---------------------------------------------------------------------------
// FILHO (somente casal casado de sexos opostos)
// ---------------------------------------------------------------------------
//a OPCAO de ter filho so "aparece" pro CONJUGE (casado ja passou pelo funil de amizade)
mob/proc/find_spouse_nearby()
	if(!married_to) return null
	for(var/mob/T in oview(1, src))
		if(T.client && T.signature == married_to) return T
	return null

mob/verb/Have_Child()
	set category = "Other"
	var/mob/spouse = usr.find_spouse_nearby()
	if(!spouse)
		to_chat(usr, usr.married_to ? "Seu conjuge ([usr.married_name]) precisa estar do seu lado." : "Ter um filho e coisa de CASAL: case-se primeiro (Propose Marriage -- e casamento e so entre AMIGOS).")
		return
	usr.try_have_child(spouse)

// o antigo verb de "Mate" (obj) agora usa o MESMO fluxo consensual de casal casado
obj/Mate1/verb/Breed()
	set name = "Mate"
	set category = "Other"
	var/mob/spouse = usr.find_spouse_nearby()
	if(!spouse)
		to_chat(usr, usr.married_to ? "Seu conjuge ([usr.married_name]) precisa estar do seu lado." : "Isto e coisa de CASAL casado (e casamento e so entre AMIGOS).")
		return
	usr.try_have_child(spouse)

mob/proc/try_have_child(var/mob/M)
	if(!mate_pair_ok(src, M))
		to_chat(src, "Voces precisam estar lado a lado, vivos e conscientes.")
		return
	if(!married_to || married_to != M.signature)
		to_chat(src, "Ter um filho e coisa de CASAL: voces precisam estar casados. (Use Propose Marriage.)")
		return
	if(!CanMate || !M.CanMate)
		to_chat(src, "Um ferimento esta impedindo isso agora.")
		return
	if(!N_Breed || !M.N_Breed)
		to_chat(src, "A biologia de um de voces nao permite gerar um filho assim.")
		return
	if(Race == "Half-Breed" || M.Race == "Half-Breed")
		to_chat(src, "Half-Breeds sao estereis.")
		to_chat(M, "Half-Breeds sao estereis.")
		return
	var/g1 = lowertext("[pgender]")
	var/g2 = lowertext("[M.pgender]")
	if(!((g1 == "male" && g2 == "female") || (g1 == "female" && g2 == "male")))
		to_chat(src, "Um casal precisa ser de sexos opostos para gerar um filho.")
		return
	if(Pregnant || M.Pregnant)
		to_chat(src, "Ja ha um bebe a caminho!")
		return
	switch(input(M, "[src] quer ter um filho com voce. Aceita?", "Filho") in list("Sim","Nao"))
		if("Nao")
			to_chat(src, "[M] prefere esperar.")
			return
	// pai/mae pelo sexo
	var/mob/dad = (g1 == "male") ? src : M
	var/mob/mom = (g1 == "male") ? M : src
	mom.Pregnant = 1
	mom.Husband = "[dad]"
	mom.Husband_Race = "[dad.Race]"
	mom.Husband_Class = "[dad.Class]"
	mom.Husband_BP = dad.BP / 4
	if(mom.Husband_BP >= 10000) mom.Husband_BP = 10000
	mom.womb = return_new_genome(dad.genome, mom.genome) // o genoma do bebe: a MESMA logica de hibridos de sempre
	to_chat(view(9), "<font color=#FFB6C1><b>[mom] esta gravida! O bebe de [dad] e [mom] podera nascer como um novo personagem (hibrido) na criacao.</b></font>")
	to_chat(mom, "<font color=#FFB6C1>Enquanto voce estiver online, um novo jogador (ou voce mesmo em outro slot) podera nascer como o filho do casal na criacao de personagem.</font>")

// ---------------------------------------------------------------------------
// OVO (racas E_Breed, ex.: Namekuseijin) -- inalterado
// ---------------------------------------------------------------------------
obj/Mate2/verb/Lay_Egg()
	set name = "Lay an Egg"
	set category="Other"
	if(!usr.CanMate)
		to_chat(usr, "You can't mate, a injury is preventing it!")
		return
	to_chat(view(9), "<font color=yellow>[usr] lays an egg!")
	sleep(10)
	var/mob/Egg/Z = new(usr.loc)
	Z.name="[usr.name]'s Egg"
	Z.Parent="[usr.name]"
	Z.Father_BP=usr.BP/4
	Z.Father_Race="[usr.Race]"
	Z.Father_Class="[usr.Class]"
	Z.spawnPlanet = usr.Planet
	Z.womb = return_new_genome(usr.genome)
	Z.womb.holder = Z
	Z.SaveMob=1
	Z.isNPC=1
