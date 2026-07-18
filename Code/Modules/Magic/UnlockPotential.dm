//config: pagamento de BP do Unlock Potential (Guru / Rank)
#define UP_BASE_PCT   0.25 //fracao do BP base ganha POR PONTO de Potential (UPMod) da raca -- Saiyan(3)=+75%, Majin(1)=+25%, Prodigial(5, x1.8)=+225%
#define UP_HIDDEN_PCT 0.5  //fracao do potencial oculto ACUMULADO (idade/treino) convertida em BP na hora (veteranos ganham mais)

mob/var/unlockPotential
mob/var
	hiddenpotential=0
	UPcooldown=0
	UPMod=1
mob/Rank/verb/Unlock_Potential()
	set category="Skills"
	var/mob/M=input("Who?","") as null|mob in view(1)
	if(M) switch(input(M,"[usr] wants to unlock your hidden powers. Do you want to do this?", "",text) in list("No","Yes"))
		if("Yes")
			if(M.unlockPotential!=1)
				to_chat(view(), "[usr] uses Unlock Potential on [M]!")
				M.UnlockPotential(UPMod)
			else to_chat(usr, "They've already had their potential unlocked!")
		if("No") to_chat(usr, "[M] declined your offer.")

mob/proc/UnlockPotential(rUPMod)
	if(!unlockPotential) //null OU 0 = nunca despertou (a var nasce null; ==0 dependia da semantica null==0 do DM)
		rUPMod = max(UPMod,rUPMod)
		emit_Sound('chargeaura.wav')
		unlockPotential=1
		bp_milestone_reach("potential") //MARCO universal: Unlock Potential do Guru
		var/awaken_mult = 1
		if(Class == "Prodigial") awaken_mult = 1.8 //Half-Saiyan Prodigial (ex-Awakened Evolution): payoff muito maior ao liberar o potencial
		//pagamento GARANTIDO: a formula antiga era toda proporcional ao hiddenpotential, que num
		//personagem jovem e ~BP/25 (piso do Train.dm) -> o unlock dava ~+2% de BP, invisivel
		var/gained_base = capcheck(BP * UP_BASE_PCT * max(UPMod, 1) * awaken_mult)
		BP += gained_base
		//bonus do potencial ACUMULADO (idade/treino/absorcoes): quem guardou um pool grande ganha por cima
		var/gained_hidden = 0
		if(hiddenpotential)
			if(BPRank==1) BPadd += capcheck(hiddenpotential*(1/10)*awaken_mult)
			else BPadd += capcheck(hiddenpotential * (BPRank/5)*awaken_mult)
			gained_hidden = capcheck(hiddenpotential * UP_HIDDEN_PCT * awaken_mult)
			BP += gained_hidden
		//a mensagem mostra as DUAS parcelas (so a base confundia: "ganhei 300k mas fui pra +1M")
		var/upmsg = "Seu potencial desperta! +[FullNum(round(gained_base))] de BP base"
		if(gained_hidden) upmsg += " e +[FullNum(round(gained_hidden))] do potencial acumulado (treino/idade)"
		to_chat(src, "<font color=#cda434><b>[upmsg].</b></font>", "system")
		kiskill+= 0.4
		if(Age>=DeclineAge)
			Body=25
		if(Age<=InclineAge)
			Body=25
			InclineAge=(Age/1.1) //Incline is now behind ya!
		//extensao de vida: +15% do peak da raca, PERSISTENTE (o stat "Lifespan" legado nao rege mais a idade)
		up_life_bonus = max(up_life_bonus, 0.15)
		age_table_apply()