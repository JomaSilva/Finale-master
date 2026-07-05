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
			if(!winexists(src, "uichoose")) src << browse(page, "window=uichoose;size=660x560") //SO reabre se o jogador FECHOU a janela (re-browse com ela aberta recarregava e zerava filtro/scroll)
	src << browse(null, "window=uichoose")
	ui_choose_opts = null
	return ui_choose_result

//icone de corpo REPRESENTATIVO da raca pro card de genero (Majin mostra corpo Majin etc.;
//so cai no humano palido quando a raca realmente usa os corpos humanos)
mob/proc/creation_gender_icon(g)
	var/r = Race
	if(Parent_Race && genome) r = Parent_Race
	switch(r)
		if("Majin") return (g == "Female") ? 'Female Majin.dmi' : 'Majin.dmi'
		if("Frost Demon") return 'Changling - Form 1.dmi' //sem dimorfismo visual
		if("Demon") return 'Demon - Form 1.dmi'
		if("Bio-Android") return 'Bio Android 1.dmi'
		if("Saiyan", "Human", "Half-Saiyan", "Heran", "Demigod", "Kai", "Tsujin", "Android", "Legendary Saiyan")
			return (g == "Female") ? 'NewPaleFemale.dmi' : 'NewPaleMale.dmi'
	if(genome) //raca com corpos proprios via genoma: primeiro corpo disponivel
		var/list/gi = genome.returnIcons()
		if(islist(gi) && gi.len) return gi[1]
	return (g == "Female") ? 'NewPaleFemale.dmi' : 'NewPaleMale.dmi'

// ============================================================================
// FORMULARIO DE TEXTO DA CRIACAO (nome + idade + historia) numa janela HTML +
// RESUMO FINAL com a foto do personagem montado e o botao CONFIRMAR (canto
// inferior direito). O botao Recomecar (inferior esquerdo) volta pro lobby.
// ============================================================================
#define CTFORM_BS_MAX 500 //teto de caracteres da historia no formulario (o envio viaja numa URL byond:// -- o limite de URL do IE e ~2083 chars e acentos codificam 3x)

mob/var/tmp
	ctform_done = 0
	ctsum_result = null

mob/proc/ctform_render(err)
	var/list/h = list()
	h += {"<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'><style>
 *{box-sizing:border-box} body{margin:0;background:#0f1115;color:#c8cdd6;font-family:'Segoe UI',Tahoma,sans-serif;font-size:12px;padding:14px}
 h1{font-size:17px;color:#e8b64c;letter-spacing:2px;margin:0 0 2px 0}
 .sub{color:#8b919c;font-size:11px;margin-bottom:12px}
 label{display:block;color:#9fb2c4;font-weight:bold;font-size:11px;margin:10px 0 4px 0;letter-spacing:1px}
 input,textarea{width:100%;background:#0b0d11;color:#e6e9ef;border:1px solid #2b303a;border-radius:6px;padding:7px 9px;font-size:12px;outline:none;font-family:inherit}
 input:focus,textarea:focus{border-color:#e8b64c}
 textarea{height:150px;resize:none}
 .err{color:#ff8a8a;font-size:11px;margin-top:8px}
 .foot{margin-top:14px;text-align:right}
 .go{display:inline-block;padding:9px 26px;background:#0f4f2f;color:#8effb8;border:1px solid #2f8f5f;border-radius:7px;text-decoration:none;font-weight:bold;cursor:pointer}
 .go:hover{background:#166b41}
</style>
<script>
function navByond(u){ try{ var a=document.createElement('a'); a.href=u; document.body.appendChild(a); if(a.click){ a.click(); document.body.removeChild(a); return; } }catch(e){} try{ window.location=u; }catch(e2){} }
function sendForm(){
 var n=document.getElementById('nm').value, a=document.getElementById('age').value, b=document.getElementById('bs').value;
 navByond('byond://?src=__REF__;ctform=1;nm='+encodeURIComponent(n)+';age='+encodeURIComponent(a)+';bs='+encodeURIComponent(b));
}
</script></head><body>"}
	h += "<h1>QUEM E VOCE?</h1><div class='sub'>Preencha a identidade do personagem. Tudo pode ser lido depois pelo verb Backstory.</div>"
	h += "<label>NOME (ate 29 letras)</label><input id='nm' maxlength='29' value='[html_encode(name && name != "player" ? name : "")]'>"
	if(!cansetage)
		h += "<label>IDADE (1 a 130)</label><input id='age' maxlength='3' value='[Age > 0 ? Age : 18]'>"
	else
		h += "<label>IDADE</label><div class='sub'>Definida pela sua raca.</div><input id='age' type='hidden' value='0'>"
	h += "<label>HISTORIA / BACKSTORY (obrigatoria; ate [CTFORM_BS_MAX] caracteres)</label><textarea id='bs' maxlength='[CTFORM_BS_MAX]'>[html_encode(backstory)]</textarea>"
	if(err) h += "<div class='err'>[err]</div>"
	h += "<div class='foot'><a class='go' onclick='sendForm()'>CONTINUAR &raquo;</a></div>"
	h += "</body></html>"
	var/page = replacetext(jointext(h, ""), "__REF__", "\ref[src]")
	src << browse(page, "window=ctform;size=520x480")

mob/proc/creation_text_form()
	ctform_done = 0
	ctform_render()
	var/t = 0
	while(client && !ctform_done)
		sleep(2)
		t += 2
		if(t >= UIC_REOPEN)
			t = 0
			if(!winexists(src, "ctform")) ctform_render() //SO se a janela foi FECHADA (re-render com ela aberta APAGAVA o que o jogador estava digitando)

//valida e aplica o formulario (chamado do mob/Topic em HtmlUI.dm); re-renderiza com erro se invalido
mob/proc/ctform_submit(nm, agetxt, bs)
	if(ctform_done) return
	nm = copytext("[nm]", 1, 30)
	//regras do Name() antigo: nao-vazio, sem espaco-solitario, sem espaco duplo
	if(!length(nm) || (findtext(nm, " ") && length(nm) == 1) || findtext(nm, "  "))
		ctform_render("Nome invalido: nao pode ser vazio nem ter espacos duplos.")
		return
	if(!bs || length(bs) < 10)
		ctform_render("Escreva pelo menos uma frase de historia (10+ caracteres).")
		return
	var/tempfirst = uppertext(copytext(nm, 1, 2))
	name = "[tempfirst][copytext(nm, 2, 30)]" //primeira letra sempre maiuscula (regra do Name() antigo)
	if(!signature) //o Name() antigo (deletado) tambem gerava a SIGNATURE -- a identidade permanente do personagem
		var/pt1=num2text(rand(1,999),3)
		var/insert1=num2text(rand(50,99),2)
		var/pt2=num2text(rand(1,999),3)
		var/insert2=num2text(rand(20,30),2)
		signature=addtext(pt1,insert1,pt2,insert2)
	backstory = copytext("[bs]", 1, CTFORM_BS_MAX + 1)
	if(!cansetage)
		var/setage = text2num("[agetxt]")
		if(!setage || setage < 1 || setage > 130) setage = 18
		Age = setage
		Body = setage
		SAge = setage
	ctform_done = 1

//foto do personagem MONTADO (corpo + overlays + cabelo/olhos do vis_contents)
mob/proc/creation_photo()
	var/icon/P
	if(icon) P = new(icon, "", SOUTH, 1)
	else P = new('NewPaleMale.dmi', "", SOUTH, 1)
	for(var/o in overlays)
		var/image/im = o
		if(!im || !im.icon) continue
		var/icon/OI = new(im.icon, "[im.icon_state]", SOUTH, 1)
		P.Blend(OI, ICON_OVERLAY)
	for(var/obj/overlay/O in vis_contents)
		if(!O.icon) continue
		var/icon/OV = new(O.icon, "[O.icon_state]", SOUTH, 1)
		P.Blend(OV, ICON_OVERLAY)
	P.Scale(96, 96)
	return P

//RESUMO FINAL: tudo que foi escolhido + a foto; retorna 1 = confirmou, 0 = recomecar
mob/proc/creation_summary()
	ctsum_result = null
	src << browse_rsc(creation_photo(), "ctsum.png")
	var/lineage = ""
	if(SaiyanLineage && SaiyanLineage != "") lineage = SaiyanLineage
	else if(FutureLineage) lineage = "Future"
	var/list/h = list()
	h += {"<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'><style>
 *{box-sizing:border-box} html,body{margin:0;padding:0;height:100%}
 body{background:#0f1115;color:#c8cdd6;font-family:'Segoe UI',Tahoma,sans-serif;font-size:12px}
 #wrap{display:flex;flex-direction:column;height:100%;padding:14px}
 h1{font-size:17px;color:#e8b64c;letter-spacing:2px;margin:0 0 10px 0}
 .top{display:flex;gap:14px}
 .foto{width:120px;text-align:center;flex-shrink:0}
 .foto img{width:96px;height:96px;background:#0b0d11;border:1px solid #e8b64c;border-radius:10px;padding:6px;box-shadow:0 0 12px rgba(232,182,76,0.25)}
 .info{flex:1}
 .row{display:flex;justify-content:space-between;padding:5px 8px;border-bottom:1px solid #1b1f27}
 .k{color:#8b919c;font-weight:bold;font-size:11px;letter-spacing:1px}
 .v{color:#f2f4f8;font-weight:bold}
 .bs{flex:1;overflow-y:auto;background:#0b0d11;border:1px solid #2b303a;border-radius:7px;padding:9px;margin-top:10px;color:#c8cdd6;line-height:1.45;min-height:70px}
 .foot{display:flex;justify-content:space-between;align-items:center;margin-top:12px}
 .re{display:inline-block;padding:8px 18px;background:#1b1e25;color:#ff8a8a;border:1px solid #5a2b2b;border-radius:7px;text-decoration:none;font-weight:bold}
 .ok{display:inline-block;padding:11px 34px;background:#0f4f2f;color:#8effb8;border:1px solid #2f8f5f;border-radius:8px;text-decoration:none;font-weight:bold;font-size:14px;letter-spacing:1px;box-shadow:0 0 10px rgba(47,143,95,0.35)}
 .ok:hover{background:#166b41}
</style></head><body><div id='wrap'>"}
	h += "<h1>SEU PERSONAGEM</h1>"
	h += "<div class='top'><div class='foto'><img src='ctsum.png'></div><div class='info'>"
	h += "<div class='row'><span class='k'>NOME</span><span class='v'>[html_encode(name)]</span></div>"
	h += "<div class='row'><span class='k'>RACA</span><span class='v'>[html_encode(Race)][Parent_Race && Parent_Race != Race ? " <span style='color:#8b919c'>([html_encode(Parent_Race)])</span>" : ""]</span></div>"
	if(lineage) h += "<div class='row'><span class='k'>LINHAGEM</span><span class='v'>[html_encode(lineage)]</span></div>"
	h += "<div class='row'><span class='k'>GENERO</span><span class='v'>[html_encode("[pgender ? pgender : "?"]")]</span></div>"
	h += "<div class='row'><span class='k'>IDADE</span><span class='v'>[round(Age)]</span></div>"
	h += "<div class='row'><span class='k'>PLANETA</span><span class='v'>[html_encode("[spawnPlanet ? spawnPlanet : Planet]")]</span></div>"
	h += "</div></div>"
	h += "<div class='bs'>[html_encode(backstory)]</div>"
	h += "<div class='foot'><a class='re' href='byond://?src=\ref[src];ctconfirm=0'>&laquo; Recomecar do zero</a><a class='ok' href='byond://?src=\ref[src];ctconfirm=1'>CONFIRMAR &#10004;</a></div>"
	h += "</div></body></html>"
	var/page = jointext(h, "")
	src << browse(page, "window=ctsum;size=560x520")
	var/t = 0
	while(client && isnull(ctsum_result))
		sleep(2)
		t += 2
		if(t >= UIC_REOPEN)
			t = 0
			if(!winexists(src, "ctsum")) src << browse(page, "window=ctsum;size=560x520") //SO reabre se fechou
	src << browse(null, "window=ctsum")
	return (ctsum_result == 1)

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
	rIcon["Saiyan"] = 'NewPaleMale.dmi' //card do Saiyajin usa o corpo-base padrao (o icone do /obj/race destoava)
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
