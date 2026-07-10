//SELETOR DE PERSONAGEM EM HTML (a janela .dmf "characterpane" foi aposentada):
//3 cards com retrato composto do save (icone + under/overlays achatados), Load/New,
//excluir com confirmacao e botao de Info -- mesmo tema dark das outras telas.

mob/lobby/proc/getSaveNameandIcon(Path)
	if(fexists(Path))
		var savefile/save = new (Path)
		var/list/nameicon[4]
		save["name"] >> nameicon[1]
		save["icon"] >> nameicon[2]
		save["overlays"] >> nameicon[3]
		save["underlays"] >> nameicon[4]
		return nameicon

//retrato do slot: achata icone + underlays + overlays num PNG (tecnica do creation_photo)
mob/lobby/proc/lobby_slot_photo(N)
	if(!fexists(GetSavePath(N))) return null
	var/list/ni = getSaveNameandIcon(GetSavePath(N))
	if(!islist(ni) || !ni[2]) return null
	var/icon/P = new(ni[2], dir = SOUTH, frame = 1)
	for(var/pass = 1 to 2) //1 = underlays (por baixo), 2 = overlays (por cima)
		var/list/L = (pass == 1) ? ni[4] : ni[3]
		if(!islist(L)) continue
		for(var/o in L)
			if(!o) continue
			var/oic = null
			var/ost = ""
			try
				oic = o:icon
				ost = "[o:icon_state]"
			catch
				continue //entrada de overlay sem icon legivel: pula (retrato fica sem essa peca)
			if(!oic) continue
			var/icon/OV = new(oic, ost, SOUTH, 1)
			P.Blend(OV, (pass == 1) ? ICON_UNDERLAY : ICON_OVERLAY)
	P.Scale(96, 96)
	return P

mob/lobby/proc/OpenLobbyUI()
	var/list/h = list()
	h += {"<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'><style>
 *{box-sizing:border-box} html,body{margin:0;padding:0;height:100%}
 body{background:#0f1115;color:#c8cdd6;font-family:'Segoe UI',Tahoma,sans-serif;font-size:12px}
 #wrap{padding:16px}
 h1{font-size:17px;color:#e8b64c;letter-spacing:2px;margin:0;text-align:center}
 .sub{color:#8b919c;text-align:center;font-size:11px;margin:2px 0 14px 0;letter-spacing:1px}
 .card{display:flex;align-items:center;gap:14px;background:#151820;border:1px solid #262b35;border-radius:12px;padding:10px 14px;margin-bottom:10px}
 .foto{width:76px;height:76px;flex-shrink:0;background:#0b0d12;border:1px solid #2b303a;border-radius:10px;display:flex;align-items:center;justify-content:center}
 .foto img{width:64px;height:64px}
 .empty{color:#3a4150;font-size:26px;font-weight:bold}
 .info{flex-grow:1;min-width:0}
 .nm{font-size:14px;font-weight:bold;color:#f2f4f8;white-space:nowrap;overflow:hidden}
 .st{color:#8b919c;font-size:10px;letter-spacing:1px}
 .acts{flex-shrink:0;text-align:right}
 a.go{display:inline-block;padding:8px 22px;background:#0f4f2f;color:#8effb8;border:1px solid #2f8f5f;border-radius:7px;text-decoration:none;font-weight:bold}
 a.new{display:inline-block;padding:8px 18px;background:#1b1e25;color:#e8b64c;border:1px solid #5a4a2b;border-radius:7px;text-decoration:none;font-weight:bold}
 a.del{display:inline-block;padding:8px 10px;background:#1b1e25;color:#ff8a8a;border:1px solid #5a2b2b;border-radius:7px;text-decoration:none;font-weight:bold;margin-left:6px}
 .foot{text-align:center;margin-top:12px}
 a.inf{color:#6ab0f3;text-decoration:none;font-size:11px;letter-spacing:1px}
</style></head><body><div id='wrap'>
<h1>DRAGONBALL JANDIRUS</h1><div class='sub'>ESCOLHA SEU GUERREIRO</div>"}
	for(var/i = 1 to 3)
		if(fexists(GetSavePath(i)))
			var/list/ni = getSaveNameandIcon(GetSavePath(i))
			var/nm = (islist(ni) && ni[1]) ? html_encode("[ni[1]]") : "???"
			var/icon/P = lobby_slot_photo(i)
			if(P) src << browse_rsc(P, "lsel[i].png")
			h += "<div class='card'><div class='foto'>[P ? "<img src='lsel[i].png'>" : "<span class='empty'>?</span>"]</div>"
			h += "<div class='info'><div class='nm'>[nm]</div><div class='st'>SLOT [i]</div></div>"
			h += "<div class='acts'><a class='go' href='byond://?src=\ref[src];lselload=[i]'>Entrar</a><a class='del' href='byond://?src=\ref[src];lseldel=[i]' title='Excluir'>&#10006;</a></div></div>"
		else
			h += "<div class='card'><div class='foto'><span class='empty'>+</span></div>"
			h += "<div class='info'><div class='nm' style='color:#5a6170'>Slot vazio</div><div class='st'>SLOT [i]</div></div>"
			h += "<div class='acts'><a class='new' href='byond://?src=\ref[src];lselnew=[i]'>Criar</a></div></div>"
	h += "<div class='foot'><a class='inf' href='byond://?src=\ref[src];lselinfo=1'>&#9432; Informacoes do servidor</a></div>"
	h += "</div></body></html>"
	src << browse(jointext(h, ""), "window=lobbysel;size=430x420;can_resize=0;title=Selecao de Personagem")

mob/lobby/Topic(href, href_list)
	..()
	if(href_list["lselload"])
		src << browse(null, "window=lobbysel")
		load(text2num(href_list["lselload"]))
		return
	if(href_list["lselnew"])
		var/n = text2num(href_list["lselnew"])
		if(n < 1 || n > 3 || fexists(GetSavePath(n))) return
		src << browse(null, "window=lobbysel")
		create(n)
		return
	if(href_list["lseldel"])
		deletecharacter(text2num(href_list["lseldel"]))
		return
	if(href_list["lselinfo"])
		showinfopane()
		return

mob/lobby/verb
	loadchar1()
		set hidden = 1
		load(1)

	loadchar2()
		set hidden = 1
		load(2)

	loadchar3()
		set hidden = 1
		load(3)

	delete1()
		set hidden = 1
		deletecharacter(1)

	delete2()
		set hidden = 1
		deletecharacter(2)

	delete3()
		set hidden = 1
		deletecharacter(3)


mob/lobby/proc/deletecharacter(var/N)
	switch(alert("Delete this file?","","Yes","No"))
		if("Yes")
			if(fexists(GetSavePath(N)))
				fdel(GetSavePath(N))
				savefiles[N] = FALSE
				to_chat(client, "Delete successful.")
				//delete_Custom_Proto("[ckey]",N)
				spawn(2) OpenLobbyUI() //re-renderiza o seletor HTML com o slot liberado
				if(fexists(GetSavePath(1)))
					savefiles[1] = TRUE
				else savefiles[1] = FALSE
				if(fexists(GetSavePath(2)))
					savefiles[2] = TRUE
				else savefiles[2] = FALSE
				if(fexists(GetSavePath(3)))
					savefiles[3] = TRUE
				else savefiles[3] = FALSE
				return
			to_chat(client, "Delete failed! Contact server admin for manual deletion! (Or the savefile doesn't exist anyway.)")
