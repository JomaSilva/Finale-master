// ============================================================================
// CREATION UI -- seletor HTML generico no estilo do guarda-roupa (cards com
// preview, filtro, borda dourada) usado pelas telas da CRIACAO DE PERSONAGEM
// (planeta/raca, genero, corpo/pele, cabelo, tipo de corpo).
//   * ui_choose() BLOQUEIA igual input(): mostra a tela, espera o clique e
//     retorna o label escolhido -- da pra trocar qualquer menu por ela sem
//     mexer no fluxo. Clique roteado pelo mob/Topic (HtmlUI.dm, "uichoose").
//   * Se o jogador fechar a janela sem escolher, ela REABRE sozinha (~10s).
// TODOS os numeros de ajuste ficam neste bloco.
// ============================================================================
#define UIC_PREV 72            // tamanho (px) do preview nos cards
#define UIC_REOPEN 100         // ticks sem resposta ate reabrir a janela fechada

mob/var/tmp
	ui_choose_result = null
	list/ui_choose_opts = null

//preview de uma opcao: aceita /icon pronto, 'literal.dmi', "caminho/arquivo.dmi" ou null
proc/ui_choose_preview(ic)
	if(isnull(ic)) return null
	var/icon/I
	if(isicon(ic))
		I = new(ic)
	else
		var/F = istext(ic) ? file(ic) : ic
		var/st = ""
		var/list/sts = icon_states(F)
		if(islist(sts) && sts.len && !("" in sts)) st = "[sts[1]]"
		I = new(F, st, SOUTH, 1)
	I.Scale(UIC_PREV, UIC_PREV)
	return I

//o seletor: labels (obrigatorio), icons e descs paralelos (opcionais; use null)
mob/proc/ui_choose(title, sub, list/labels, list/icons, list/descs)
	if(!client || !islist(labels) || !labels.len) return null
	ui_choose_result = null
	ui_choose_opts = labels
	//previews -> client (nomes reaproveitados a cada tela)
	for(var/i = 1 to labels.len)
		var/ic = (islist(icons) && icons.len >= i) ? icons[i] : null
		if(isnull(ic)) continue
		var/icon/P = ui_choose_preview(ic)
		if(P) src << browse_rsc(P, "uic[i].png")
		if(i % 15 == 0) sleep(1)
	//pagina
	var/list/h = list()
	h += {"<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'><style>
 *{box-sizing:border-box} body{margin:0;background:#0f1115;color:#c8cdd6;font-family:'Segoe UI',Tahoma,sans-serif;font-size:12px;padding:12px}
 h1{font-size:17px;color:#e8b64c;letter-spacing:2px;margin:0 0 2px 0}
 .sub{color:#8b919c;font-size:11px;margin-bottom:10px}
 .vsearch{width:100%;background:#0b0d11;color:#e6e9ef;border:1px solid #2b303a;border-radius:6px;padding:6px 9px;font-size:12px;outline:none;margin:0 0 10px 0}
 .grid{display:flex;flex-wrap:wrap;gap:7px}
 .card{width:148px;background:#151820;border:1px solid #262b35;border-radius:8px;padding:9px 6px;text-align:center;text-decoration:none;color:#c8cdd6}
 .card:hover{border-color:#e8b64c;background:#1d1a12;box-shadow:0 0 8px rgba(232,182,76,0.25)}
 .card img{width:[UIC_PREV]px;height:[UIC_PREV]px}
 .nm{display:block;font-size:12px;font-weight:bold;margin-top:5px;line-height:1.2;word-wrap:break-word}
 .ds{display:block;font-size:10px;color:#8b919c;margin-top:4px;line-height:1.3;word-wrap:break-word}
 .tnone{color:#8b919c;padding:14px;text-align:center}
</style>
<script>
function uflt(){
 var b=document.getElementById('us'); var g=document.getElementById('grid'); if(!b||!g){return;}
 var q=b.value.toLowerCase(); var a=g.getElementsByTagName('a'); var n=0;
 for(var i=0;i<a.length;i++){ var el=a.item(i); var t=(el.innerText||el.textContent||'').toLowerCase();
  var show=(t.indexOf(q)>=0); el.style.display=show?'':'none'; if(show){n++;} }
 var none=document.getElementById('unone'); if(none){none.style.display=(n==0)?'':'none';}
}
</script></head><body>"}
	h += "<h1>[title]</h1>"
	if(sub) h += "<div class='sub'>[sub]</div>"
	if(labels.len > 12) h += "<input id='us' class='vsearch' type='text' autocomplete='off' placeholder='Filtrar [labels.len] opcoes...' oninput='uflt()' onkeyup='uflt()'>"
	h += "<div id='grid' class='grid'>"
	for(var/i = 1 to labels.len)
		var/has = (islist(icons) && icons.len >= i && !isnull(icons[i]))
		var/d = (islist(descs) && descs.len >= i && descs[i]) ? descs[i] : ""
		h += "<a class='card' href='byond://?src=\ref[src];uichoose=[i]'>[has ? "<img src='uic[i].png'>" : ""]<span class='nm'>[html_encode("[labels[i]]")]</span>[d ? "<span class='ds'>[d]</span>" : ""]</a>"
	h += "</div><div id='unone' class='tnone' style='display:none'>Nada com esse nome.</div>"
	h += "</body></html>"
	var/page = jointext(h, "")
	src << browse(page, "window=uichoose;size=660x560")
	//espera o clique (reabre se o jogador fechar a janela sem escolher)
	var/t = 0
	while(client && isnull(ui_choose_result))
		sleep(2)
		t += 2
		if(t >= UIC_REOPEN)
			t = 0
			src << browse(page, "window=uichoose;size=660x560")
	src << browse(null, "window=uichoose")
	ui_choose_opts = null
	return ui_choose_result

// ============================================================================
// TELA DE PLANETA + RACA (substitui a janela nativa race_pick_act)
// ============================================================================
//racas disponiveis por planeta (mesma tabela do initialize_race_window antigo)
//mob proc: Halfie_Year (e possiveis toggles can*) sao vars de mob
mob/proc/creation_races_for(planet)
	var/list/A = list()
	if(android_creator_list && android_creator_list.len) A += "Android"
	if(spirit_creator_list && spirit_creator_list.len) A += "Spirit Doll"
	if(bio_creator_list && bio_creator_list.len) A += "Bio-Android"
	switch(planet)
		if("Earth")
			if(canhuman) A += "Human"
			if(canshape) A += "Shapeshifter"
			if(canDemigod) A += "Demigod"
			if(canmajin) A += "Majin"
			if(canalien) A += "Alien"
			if(candroid) A += "Android"
			if(candoll) A += "Spirit Doll"
			if(canbio) A += "Bio-Android"
		if("Vegeta")
			if(cansai) A += "Saiyan"
			if(Halfie_Year >= 1 && cansai) A += "Half-Saiyan"
			if(canintel) A += "Tsujin"
			if(cansaib) A += "Saibamen"
			if(canheran) A += "Heran"
			if(canmeta) A += "Meta"
			if(canchangie) A += "Frost Demon"
			if(canalien) A += "Alien"
		if("Namek")
			if(cannamek) A += "Namekian"
			if(canarl) A += "Arlian"
			if(canmakyo) A += "Makyo"
			if(cangray) A += "Gray"
			if(canalien) A += "Alien"
			if(cankan) A += "Kanassa-Jin"
			if(canyardrat) A += "Yardrat"
		if("Heaven")
			if(canDemigod) A += "Demigod"
			if(cankai) A += "Kai"
		if("Hell")
			if(candemon) A += "Demon"
			if(canDemigod) A += "Demigod"
	return A

mob/proc/html_race_pick()
	//contagem de meio-saiyajins liberados (regra herdada da janela antiga)
	for(var/mob/M) if(M.client)
		if(M.Race == "Human" && M.Age >= 16 && M.SAge >= 16) Halfie_Year += 0.5
		if(M.Race == "Saiyan" && M.Age >= 16 && M.SAge >= 16) Halfie_Year += 0.5
	//catalogo de /obj/race (nome -> icone/descricao)
	var/list/rIcon = list()
	var/list/rDesc = list()
	for(var/race_type in (typesof(/obj/race) - /obj/race))
		var/obj/race/nR = new race_type
		if(!rIcon["[nR.racename]"])
			rIcon["[nR.racename]"] = nR.icon
			rDesc["[nR.racename]"] = "[nR.desc]"
	var/list/pIcon = list()
	for(var/ptype in list(/obj/Planets/Earth, /obj/Planets/Namek, /obj/Planets/Vegeta, /obj/Planets/Heaven, /obj/Planets/Hell))
		var/obj/Planets/nP = new ptype(null, 1)
		var/icon/PV = new(nP.planetIcon, nP.planetState)
		pIcon["[nP.planetType]"] = PV
	while(client)
		//---- 1) planeta ----
		var/list/plabels = list("Earth","Namek","Vegeta","Heaven","Hell","Nascer de Gravidez/Ovo")
		var/list/picons = list(pIcon["Earth"], pIcon["Namek"], pIcon["Vegeta"], pIcon["Heaven"], pIcon["Hell"], 'Egg.dmi')
		var/list/pdescs = list("O lar dos Humanos.","O planeta verde dos Namekuseijins.","O mundo-berco dos Saiyajins.","O plano celestial.","O submundo.","Nasca como FILHO de um casal do servidor (ou de um ovo).")
		var/planet = ui_choose("ONDE VOCE NASCE?", "O planeta define as racas disponiveis.", plabels, picons, pdescs)
		if(isnull(planet)) return
		//---- gravidez/ovo ----
		if(planet == "Nascer de Gravidez/Ovo")
			var/list/mlabels = list()
			var/list/micons = list()
			var/list/mdescs = list()
			var/list/mrefs = list()
			for(var/mob/M in player_list)
				if(M.Pregnant)
					mlabels += "[M.name]"
					micons += M.icon
					mdescs += "Filho(a) de [M.name] e [M.Husband]."
					mrefs += M
			for(var/mob/Egg/M in mob_list)
				mlabels += "[M.name]"
				micons += M.icon
				mdescs += "Nascer deste ovo."
				mrefs += M
			mlabels += "« Voltar"
			micons += null
			mdescs += "Escolher outro comeco."
			var/mpick = ui_choose("NASCER DE QUEM?", "Bebes a caminho neste servidor agora.", mlabels, micons, mdescs)
			if(isnull(mpick)) return
			if(mpick == "« Voltar") continue
			var/idx = mlabels.Find(mpick)
			var/mob/m = (idx && idx <= mrefs.len) ? mrefs[idx] : null
			if(!m) continue
			genome = return_new_genome(m.womb)
			if(m.Egg) eggpar(m)
			else parentpar(m)
			Race("Pregnant")
			return
		//---- 2) raca ----
		var/list/av = creation_races_for(planet)
		if(!av.len)
			to_chat(src, "Nenhuma raca disponivel nesse comeco agora.")
			continue
		var/list/rlabels = list()
		var/list/ricons = list()
		var/list/rdescs = list()
		for(var/rn in av)
			rlabels += rn
			ricons += rIcon[rn]
			rdescs += (rDesc[rn] ? rDesc[rn] : "")
		rlabels += "« Voltar"
		ricons += null
		rdescs += "Escolher outro planeta."
		var/rpick = ui_choose("ESCOLHA SUA RACA", "Nascendo em: [planet]", rlabels, ricons, rdescs)
		if(isnull(rpick)) return
		if(rpick == "« Voltar") continue
		spawnPlanet = planet
		Race(rpick)
		return
