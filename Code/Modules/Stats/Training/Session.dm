//system for tracking gains in a given training session
mob/var/tmp
	startingbp=0
	insession=0

mob/verb/Training_Session()
	set category = "Other"
	var/choice=alert(usr,"Would you like to start a new session, or view the current session?","","New Session","View Session")
	switch(choice)
		if("New Session")
			usr.startingbp=usr.BP
			usr.insession=1
			to_chat(usr, "Sessao de treino iniciada.")
		if("View Session")
			if(!usr.insession)
				to_chat(usr, "Comece uma sessao primeiro.")
				return
			var/ganho = usr.BP - usr.startingbp
			//sem SCOUTER ninguem le o proprio BP em numero (mesma regra do painel de Stats):
			//o relatorio da a DIFERENCA em porcentagem, que nao entrega o valor absoluto
			if(usr.scouteron)
				to_chat(usr, "<font color=yellow>Nesta sessao voce ganhou <b>[FullNum(round(ganho))]</b> de poder base ([FullNum(round(usr.startingbp))] -> [FullNum(round(usr.BP))]).")
			else if(usr.startingbp > 0)
				to_chat(usr, "<font color=yellow>Voce esta cerca de <b>[round((ganho / usr.startingbp) * 100, 0.1)]% mais forte</b> do que quando comecou esta sessao.")
			else
				to_chat(usr, "<font color=yellow>Voce sente que evoluiu nesta sessao, mas nao tem como medir o quanto.")