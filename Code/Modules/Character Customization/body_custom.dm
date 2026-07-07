mob
	proc
		Skin()
			r_race = Race
			if(Parent_Race && genome)
				r_race = Parent_Race
			if(r_race=="Frost Demon"||r_race=="Bio-Android") return
			if(r_race=="Namekian")
				//cards com o tom de verde JA aplicado no preview
				var/icon/nLight = new('Namek Young.dmi', "", SOUTH, 1)
				nLight.Blend(rgb(30,30,30), ICON_ADD)
				var/icon/nDark = new('Namek Young.dmi', "", SOUTH, 1)
				nDark.Blend(rgb(30,30,30), ICON_SUBTRACT)
				var/npick = ui_choose("COR DE PELE", "O tom do seu Namekuseijin.", list("Light Green","Green","Dark Green","Albino"), list(nLight, 'Namek Young.dmi', nDark, 'Albino Namek.dmi'), null)
				var/nicon='Namek Young.dmi'
				switch(npick)
					if("Light Green")
						nicon+=rgb(30,30,30)
						icon=nicon
					if("Dark Green")
						nicon-=rgb(30,30,30)
						icon=nicon
					if("Albino")
						nicon='Albino Namek.dmi'
						icon=nicon
					else icon=nicon //Green (ou queda de client)
				return
			var/list/skin_list = list()
			//see Genetic_Icons.dm
			if(Race == "Majin") //proper Majin bodies (genome flags don't reliably carry "Majin")
				if(pgender == "Female")
					skin_list += 'Female Majin.dmi'
					skin_list += 'female majin base (small).dmi'
				else
					skin_list += 'Majin.dmi'
					skin_list += 'Majin1.dmi'
			else if(Race == "Kai") //corpos proprios do Kaioshin, um por sexo
				if(pgender == "Female") skin_list += 'Alien 10.dmi'
				else skin_list += 'Konatsu.dmi'
			else if(Race == "Demon")
				skin_list += 'Base_Skully.dmi'
				skin_list += 'Demon - Form 1.dmi'
				skin_list += 'Demon4.dmi'
				skin_list += 'DemonForm1.dmi'
				skin_list += 'Satan.dmi'
			else if(Race == "Saiyan" || Race == "Human") //Saiyans and Humans are limited to the five approved base bodies
				switch(pgender)
					if("Male")
						skin_list += 'NewPaleMale.dmi'
						skin_list += 'NewTanMale.dmi'
						skin_list += 'NewBlackMale.dmi'
					if("Female")
						skin_list += 'NewPaleFemale.dmi'
						skin_list += 'NewTanFemale.dmi'
						skin_list += 'NewBlackFemale.dmi'
					else
						skin_list += 'NewPaleMale.dmi'
						skin_list += 'NewTanMale.dmi'
						skin_list += 'NewBlackMale.dmi'
						skin_list += 'NewPaleFemale.dmi'
						skin_list += 'NewTanFemale.dmi'
						skin_list += 'NewBlackFemale.dmi'
			else if(genome)
				skin_list += genome.returnIcons()
			if(!skin_list.len) //sem genoma/sem corpos (era o "Cannot execute null.returnIcons()"): fallback nos corpos base
				skin_list += 'NewPaleMale.dmi'
				skin_list += 'NewPaleFemale.dmi'
			//tela HTML: um card com preview pra cada corpo disponivel (CreationUI.dm)
			var/list/blabels = list()
			var/list/bicons = list()
			for(var/a in skin_list)
				var/bn = "[a]"
				if(lowertext(copytext(bn, max(length(bn) - 3, 1))) == ".dmi") bn = copytext(bn, 1, length(bn) - 3)
				//nomes duplicados quebrariam o Find() -> numera
				if(bn in blabels) bn = "[bn] ([blabels.len + 1])"
				blabels += bn
				bicons += a
			var/bpick = ui_choose("CORPO", "Escolha a base do seu personagem.", blabels, bicons, null)
			var/bidx = bpick ? blabels.Find(bpick) : 0
			if(bidx) icon = skin_list[bidx]
			else if(skin_list.len) icon = skin_list[1] //client caiu no meio: usa a primeira base
			if(Class=="Genie"||Class=="Ogre"||Race=="Majin"||Race=="Kai") //Kaioshin escolhe a cor de pele igual um Majin
				alert("Now choose your body colour — it tints the body you just selected.")
				var/rgbsuccess
				rgbsuccess=input("Choose a color.","Color",0) as color
				var/list/oldrgb=0
				oldrgb=hrc_hex2rgb(rgbsuccess,1)
				while(!oldrgb)
					sleep(1)
					oldrgb=hrc_hex2rgb(rgbsuccess,1)
				var/red=oldrgb[1]
				var/blue=oldrgb[3]
				var/green=oldrgb[2]
				var/Playericon=icon
				Playericon += rgb(red,green,blue)
				icon=Playericon
				if(Race=="Majin") majin_color = rgb(red,green,blue) //keep this colour on every saga form
			if(r_race=="Heran")
				var/red=HairR
				var/green=HairG
				var/blue=HairB
				var/Playericon='Hair_Raditz.dmi'
				Playericon+=rgb(red,green,blue)
				truehair=Playericon
			if(!icon) switch(pgender)
				if("Male") icon='White Male.dmi'
				if("Female") icon='Whitefemale.dmi'
			oicon=icon
//(a janela nativa race_pick de skin -- Dummy_Race_Icon/racewindowverbs/racedone_remove -- foi DELETADA: a escolha virou ui_choose)

mob/proc/formchoose(rtype)
	var/list/skin_list = list()
	to_chat(usr, "Choose your form icons. You have a maximum of six forms. (Don't ask about the sixth.). If you're a biodroid, you don't need any more than 3. You start in form 1 if Biodroid, form 4 if Frost Demon.")
	if("Biodroid" == rtype)
		truehair=null
		skin_list += 'Bio Android 1.dmi'
		skin_list += 'Bio Android 2.dmi'
		skin_list += 'Bio Android 3.dmi'
		skin_list += 'Bio Android 4.dmi'
		skin_list += 'Bio Android - Form 5.dmi'
		skin_list += 'Bio Android 6.dmi'
		skin_list += 'BaseAndroid1.dmi'
		skin_list += 'BaseAndroid2.dmi'
		skin_list += 'BioAndroid1(Spore).dmi'
		skin_list += 'BioExperiment.dmi'
		skin_list += 'Cell Jr.dmi'
		skin_list += 'Female Bioandroid.dmi'
		skin_list += 'Female BioandroidDorado.dmi'
		skin_list += 'Female Bioandroidform2.dmi'
		skin_list += 'Frieza-Cell.dmi'
	if("Frost Demon" == rtype)
		skin_list+='Changeling Frieza 2.dmi'
		skin_list+='Changling - Form 2.dmi'
		skin_list+='Frostdemon Form 3.dmi'
		skin_list+='Frostdemon Form 4.dmi'
		skin_list+='Changeling 5 Kold.dmi'
		skin_list+='GoldIcer.dmi'
		skin_list += 'BaseCooler.dmi'
		skin_list += 'Changeling 1 Large.dmi'
		skin_list += 'Changeling 5 Frieza.dmi'
		skin_list += 'Changeling Form 3.dmi'
		skin_list += 'Changeling Form 4 Orange.dmi'
		skin_list += 'Changeling Form 4.dmi'
		skin_list += 'Changeling Frieza 100% 2.dmi'
		skin_list += 'Changeling Frieza 100% 3.dmi'
		skin_list += 'Changeling Frieza 100%.dmi'
		skin_list += 'Changeling Frieza Form 2, 2.dmi'
		skin_list += 'Changeling Frieza Form 2.dmi'
		skin_list += 'Changeling Frieza Form 3, 2.dmi'
		skin_list += 'Changeling Frieza Form 3.dmi'
		skin_list += 'Changeling Frieza Form 4, 2.dmi'
		skin_list += 'Changeling Frieza Form 4, 3.dmi'
		skin_list += 'Changeling Frieza Form 4.dmi'
		skin_list += 'Changeling Frieza.dmi'
		skin_list += 'Changeling Full Power.dmi'
		skin_list += 'Changeling Kold 2.dmi'
		skin_list += 'Mecha Frieza.dmi'
		skin_list += 'Changeling Kold Form 2.dmi'
		skin_list += 'Changeling Kold.dmi'
		skin_list += 'Changeling Koola 2.dmi'
		skin_list += 'Changeling Koola Expand 2.dmi'
		skin_list += 'Changeling Koola Expand.dmi'
		skin_list += 'Changeling Koola Form 2.dmi'
		skin_list += 'Changeling Koola Form 3, 2.dmi'
		skin_list += 'Changeling Koola Form 3.dmi'
		skin_list += 'Changeling Koola Form 4, 3.dmi'
		skin_list += 'Changeling Koola Form 4.dmi'
		skin_list += 'Changeling Koola.dmi'
		skin_list += 'Changeling Kuriza.dmi'
		skin_list += 'Changeling.dmi'
		skin_list += 'Changling - Form 1.dmi'
		skin_list += 'Changling - Form 2 Orange.dmi'
		skin_list += 'Changling - Form 3 Orange.dmi'
		skin_list += 'Changling - Form 3.dmi'
		skin_list += 'Changling - Form 6 - Orange.dmi'
		skin_list += 'Changling - Form 6.dmi'
		skin_list += 'ChanglingForm7.dmi'
		skin_list += 'ChanglingMetal.dmi'
		skin_list += 'Cooler Form 4.dmi'
		skin_list += 'Frostdemon Form 3.dmi'
		skin_list += 'Frostdemon Form 4.dmi'
		skin_list += 'Frostdemon Kold.dmi'
		skin_list += 'Frostdemon Koola.dmi'
		skin_list += 'Frostdemon.dmi'
		skin_list += 'Mecha Frieza.dmi'
		skin_list += 'King Kold Form 2 Orange.dmi'
		skin_list += 'King Kold Form 2.dmi'
		skin_list += 'Koola Final Form.dmi'

	//---- tela HTML (substitui a grade nativa race_pick + Dummy_Form_Icon, deletados):
	//chips FORMA 1..6 clicaveis mostram QUAL slot esta sendo escolhido; o card escolhido
	//ganha borda dourada + badge "F[n]" -- nao tem mais como se perder na sequencia
	form_pick_icons = skin_list
	form_pick_sel = list(0,0,0,0,0,0)
	form_pick_slot = 1
	form_pick_done = 0
	form_pick_race = rtype
	for(var/i = 1 to skin_list.len) //previews (padrao do guarda-roupa/ui_choose)
		var/icon/P = ui_choose_preview(skin_list[i])
		if(P) src << browse_rsc(P, "fp[i].png")
		if(i % 15 == 0) sleep(1)
	form_pick_render()
	var/t = 0
	while(client && !form_pick_done) //bloqueia igual input(); reabre so se a janela foi FECHADA
		sleep(2)
		t += 2
		if(t >= 100)
			t = 0
			if(!winexists(src, "formpick")) form_pick_render()
	src << browse(null, "window=formpick")
	//aplica: slot vazio cai no padrao da raca
	switch(rtype)
		if("Frost Demon")
			form1icon = form_pick_res(1, 'Changeling Frieza 2.dmi')
			form2icon = form_pick_res(2, 'Changling - Form 2.dmi')
			form3icon = form_pick_res(3, 'Frostdemon Form 3.dmi')
			form4icon = form_pick_res(4, 'Frostdemon Form 4.dmi')
			form5icon = form_pick_res(5, 'Changeling 5 Kold.dmi')
			form6icon = form_pick_res(6, 'GoldIcer.dmi')
			icon = form4icon
			originalicon = form4icon
		if("Biodroid") //era "Bio-Android" no switch antigo: NUNCA batia com o arg "Biodroid" -> bio ficava sem defaults
			form1icon = form_pick_res(1, 'Bio Android 1.dmi')
			form2icon = form_pick_res(2, 'Bio Android 2.dmi')
			form3icon = form_pick_res(3, 'Bio Android 3.dmi')
			form4icon = form_pick_res(4, 'Bio Android 4.dmi')
			form5icon = form_pick_res(5, 'Bio Android - Form 5.dmi')
			form6icon = form_pick_res(6, 'Bio Android 6.dmi')
			icon = form1icon
			originalicon = form1icon
	oicon=icon
	form_pick_icons = null
	form_pick_sel = null

mob/var/tmp
	list/form_pick_icons = null //catalogo de .dmi da tela de formas aberta
	list/form_pick_sel = null   //form_pick_sel[slot 1..6] = indice escolhido no catalogo (0 = vazio)
	form_pick_slot = 1          //slot sendo escolhido agora
	form_pick_done = 0
	form_pick_race = ""

//icone escolhido do slot, ou o padrao da raca se ficou vazio
mob/proc/form_pick_res(slot, dflt)
	if(!islist(form_pick_sel) || !islist(form_pick_icons)) return dflt
	var/i = form_pick_sel[slot]
	return (i && i <= form_pick_icons.len) ? form_pick_icons[i] : dflt

mob/proc/form_pick_render()
	if(!client || !islist(form_pick_icons)) return
	var/list/h = list()
	h += {"<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'><style>
 *{box-sizing:border-box} body{margin:0;background:#0f1115;color:#c8cdd6;font-family:'Segoe UI',Tahoma,sans-serif;font-size:12px;padding:12px}
 h1{font-size:17px;color:#e8b64c;letter-spacing:2px;margin:0 0 2px 0}
 .sub{color:#8b919c;font-size:11px;margin-bottom:8px}
 .slots{margin:0 0 10px 0}
 .slot{display:inline-block;background:#151820;border:1px solid #262b35;border-radius:14px;padding:4px 10px;margin:0 4px 4px 0;color:#8b919c;text-decoration:none;font-weight:bold;font-size:11px}
 .slot.ok{color:#7ec87e;border-color:#3a5c3a}
 .slot.cur{border-color:#e8b64c;color:#e8b64c;box-shadow:0 0 6px rgba(232,182,76,0.35)}
 .vsearch{width:100%;background:#0b0d11;color:#e6e9ef;border:1px solid #2b303a;border-radius:6px;padding:6px 9px;font-size:12px;outline:none;margin:0 0 10px 0}
 .grid{display:flex;flex-wrap:wrap;gap:7px}
 .card{width:112px;background:#151820;border:2px solid #262b35;border-radius:8px;padding:8px 5px;text-align:center;text-decoration:none;color:#c8cdd6;position:relative}
 .card:hover{border-color:#e8b64c;background:#1d1a12}
 .card.on{border-color:#e8b64c;background:#241d0e;box-shadow:0 0 10px rgba(232,182,76,0.4)}
 .badge{position:absolute;top:-9px;right:-5px;background:#e8b64c;color:#15130a;font-weight:bold;font-size:10px;border-radius:9px;padding:2px 6px}
 .card img{width:72px;height:72px}
 .nm{display:block;font-size:10px;margin-top:4px;line-height:1.2;word-wrap:break-word;color:#8b919c}
 .done{display:inline-block;background:#2e7d32;color:#fff;font-weight:bold;border-radius:8px;padding:8px 18px;text-decoration:none;margin-top:10px}
 .clr{display:inline-block;background:#1b1e25;color:#c8cdd6;border:1px solid #2b303a;border-radius:8px;padding:8px 14px;text-decoration:none;margin:10px 0 0 8px}
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
	h += "<h1>FORMAS DO [form_pick_race == "Biodroid" ? "BIO-ANDROID" : "FROST DEMON"]</h1>"
	h += "<div class='sub'>Escolhendo a <b>FORMA [form_pick_slot]</b> -- clique um corpo pra ela. Os chips abaixo trocam a forma sendo escolhida; o numero dourado no card mostra onde cada corpo ja foi usado.[form_pick_race == "Frost Demon" ? " (Voce COMECA na forma 4; a 6a e a forma Golden.)" : " (Bio-Android comeca na forma 1.)"]</div>"
	h += "<div class='slots'>"
	for(var/s = 1 to 6)
		var/cls = "slot"
		if(s == form_pick_slot) cls += " cur"
		else if(form_pick_sel[s]) cls += " ok"
		h += "<a class='[cls]' href='byond://?src=\ref[src];fpslot=[s]'>FORMA [s][form_pick_sel[s] ? " &#10003;" : ""]</a>"
	h += "</div>"
	if(form_pick_icons.len > 12) h += "<input id='us' class='vsearch' type='text' autocomplete='off' placeholder='Filtrar [form_pick_icons.len] corpos...' oninput='uflt()' onkeyup='uflt()'>"
	h += "<div id='grid' class='grid'>"
	for(var/i = 1 to form_pick_icons.len)
		var/list/tags = list()
		for(var/s = 1 to 6)
			if(form_pick_sel[s] == i) tags += "F[s]"
		var/nm = "[form_pick_icons[i]]" //'X.dmi' vira "X.dmi" em string
		nm = copytext(nm, 1, max(length(nm) - 3, 1)) //tira o ".dmi"
		h += "<a class='card[tags.len ? " on" : ""]' href='byond://?src=\ref[src];fpick=[i]'>[tags.len ? "<span class='badge'>[jointext(tags, " ")]</span>" : ""]<img src='fp[i].png'><span class='nm'>[html_encode(nm)]</span></a>"
	h += "</div><div id='unone' class='tnone' style='display:none'>Nada com esse nome.</div>"
	h += "<a class='done' href='byond://?src=\ref[src];fpdone=1'>CONCLUIR</a><a class='clr' href='byond://?src=\ref[src];fpclear=1'>Limpar tudo</a>"
	h += "</body></html>"
	src << browse(jointext(h, ""), "window=formpick;size=720x600")