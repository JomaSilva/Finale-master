// ============================================================================
// GUARDA-ROUPA COSMETICO -- qualquer .dmi de Icons/Clothes (e subpastas).
//   * SEM efeito mecanico nenhum: as pecas sao so overlays (mesmo canal visual
//     das roupas normais, /obj/overlay/clothes/clothes_handler).
//   * Na CRIACAO: o personagem pode escolher comecar vestido (prompt no fim).
//   * Depois: verb "Roupas" (aba Other) abre a MESMA tela, com PREVIEW em
//     imagem de cada .dmi (1o state, virado pro SUL, ampliado), filtro por
//     nome e ate WARDROBE_MAX pecas ao mesmo tempo.
//   * Persiste por CAMINHO do arquivo (outfit_list) e re-aplica no login
//     (overlays de vis_contents morrem no logout).
// TODOS os numeros de ajuste ficam neste bloco.
// ============================================================================
#define WARDROBE_DIR "Icons/Clothes/"  // pasta-raiz varrida (recursivo) no disco do host
#define WARDROBE_MAX 4                 // maximo de pecas vestidas ao mesmo tempo
#define WARDROBE_PREV 64               // tamanho (px) do preview na tela

mob/var/list/outfit_list = null        // caminhos das pecas vestidas (persiste no save)
client/var/wardrobe_rsc_sent = 0       // ja enviei os previews pra este client nesta sessao

var/list/wardrobe_files = null         // cache global: todos os .dmi achados na pasta
var/list/wardrobe_prev = list()        // cache global: caminho -> /icon de preview

// ---------------------------------------------------------------------------
// scan da pasta (lazy, 1x por boot) -- flist le o DISCO do host em runtime
// ---------------------------------------------------------------------------
proc/wardrobe_list()
	if(isnull(wardrobe_files))
		wardrobe_files = list()
		wardrobe_scan(WARDROBE_DIR)
	return wardrobe_files

proc/wardrobe_scan(path)
	for(var/f in flist(path))
		if(copytext(f, length(f)) == "/") //subpasta: recursao
			wardrobe_scan("[path][f]")
		else if(length(f) > 4 && lowertext(copytext(f, length(f) - 3)) == ".dmi")
			wardrobe_files += "[path][f]"

//nome de exibicao: so o arquivo, sem pasta e sem .dmi
proc/wardrobe_name(path)
	var/nm = path
	var/slash = 0
	for(var/i = length(nm), i >= 1, i--)
		if(copytext(nm, i, i + 1) == "/") { slash = i; break }
	if(slash) nm = copytext(nm, slash + 1)
	if(lowertext(copytext(nm, length(nm) - 3)) == ".dmi") nm = copytext(nm, 1, length(nm) - 3)
	return nm

//preview: 1o state do .dmi virado pro SUL, ampliado pra WARDROBE_PREV (cache global)
proc/wardrobe_preview(path)
	if(wardrobe_prev[path]) return wardrobe_prev[path]
	var/F = file(path)
	var/st = ""
	var/list/sts = icon_states(F)
	if(islist(sts) && sts.len && !("" in sts)) st = "[sts[1]]"
	var/icon/I = new(F, st, SOUTH, 1)
	I.Scale(WARDROBE_PREV, WARDROBE_PREV)
	wardrobe_prev[path] = I
	return I

// ---------------------------------------------------------------------------
// aplicar/tirar as pecas (overlays cosmeticos, IDs "wardrobe1..N")
// ---------------------------------------------------------------------------
mob/proc/wardrobe_strip() //tira TODAS as pecas do guarda-roupa (sincrono -- o removeOverlayID generico usa spawn e daria corrida com o re-apply)
	for(var/obj/overlay/clothes/clothes_handler/C in vis_contents)
		if(findtextEx("[C.ID]", "wardrobe") == 1) C.removeOverlay()

mob/proc/outfit_apply()
	wardrobe_strip()
	if(!islist(outfit_list)) return
	var/n = 0
	for(var/path in outfit_list)
		if(!fexists(path)) continue //o .dmi sumiu da pasta desde o save
		n++
		updateOverlaycID(/obj/overlay/clothes/clothes_handler, file(path), null, null, null, "wardrobe[n]")

//login: o save tem pecas mas os overlays de vis_contents morreram no logout -> re-veste
mob/proc/outfit_login_check()
	if(islist(outfit_list) && outfit_list.len) spawn(10) outfit_apply()

// ---------------------------------------------------------------------------
// a TELA (grade com preview + filtro por nome; scroll preservado)
// ---------------------------------------------------------------------------
mob/proc/wardrobe_send_rsc() //envia os previews 1x por sessao (223 pnginhas; pausa a cada 20 pra nao engasgar o tick)
	if(!client || client.wardrobe_rsc_sent) return
	client.wardrobe_rsc_sent = 1
	var/list/L = wardrobe_list()
	for(var/i = 1 to L.len)
		src << browse_rsc(wardrobe_preview(L[i]), "wrd[i].png")
		if(i % 20 == 0) sleep(1)

mob/proc/wardrobe_open()
	set waitfor = 0
	if(!client) return
	wardrobe_send_rsc()
	wardrobe_render()

mob/proc/wardrobe_render()
	if(!client) return
	if(!islist(outfit_list)) outfit_list = list()
	var/list/L = wardrobe_list()
	var/list/h = list()
	h += {"<html><head><meta http-equiv='X-UA-Compatible' content='IE=edge'><style>
 *{box-sizing:border-box} body{margin:0;background:#0f1115;color:#c8cdd6;font-family:'Segoe UI',Tahoma,sans-serif;font-size:12px;padding:10px}
 h1{font-size:16px;color:#e8b64c;letter-spacing:2px;margin:0 0 2px 0}
 .sub{color:#8b919c;font-size:11px;margin-bottom:8px}
 .btn{display:inline-block;padding:4px 12px;background:#1b1e25;color:#c8cdd6;border:1px solid #2b303a;border-radius:6px;text-decoration:none;font-weight:bold;margin-right:6px}
 .btn:hover{background:#2b303a}
 .btn.red{color:#ff8a8a;border-color:#5a2b2b}
 .vsearch{width:100%;background:#0b0d11;color:#e6e9ef;border:1px solid #2b303a;border-radius:6px;padding:6px 9px;font-size:12px;outline:none;margin:8px 0}
 .grid{display:flex;flex-wrap:wrap;gap:6px}
 .card{width:96px;background:#151820;border:1px solid #262b35;border-radius:8px;padding:7px 4px;text-align:center;text-decoration:none;color:#c8cdd6}
 .card:hover{border-color:#4a5262;background:#1b2029}
 .card.sel{border-color:#e8b64c;background:#241f12;box-shadow:0 0 8px rgba(232,182,76,0.25)}
 .card img{width:[WARDROBE_PREV]px;height:[WARDROBE_PREV]px}
 .nm{display:block;font-size:10px;margin-top:4px;line-height:1.2;word-wrap:break-word}
 .sel .nm{color:#e8b64c;font-weight:bold}
 .tnone{color:#8b919c;padding:14px;text-align:center}
</style>
<script>
function wflt(){
 var b=document.getElementById('ws'); var g=document.getElementById('grid'); if(!b||!g){return;}
 var q=b.value.toLowerCase(); var a=g.getElementsByTagName('a'); var n=0;
 for(var i=0;i<a.length;i++){ var el=a.item(i); var t=(el.innerText||el.textContent||'').toLowerCase();
  var show=(t.indexOf(q)>=0); el.style.display=show?'':'none'; if(show){n++;} }
 var none=document.getElementById('wnone'); if(none){none.style.display=(n==0)?'':'none';}
}
</script></head><body>"}
	h += "<h1>GUARDA-ROUPA</h1>"
	h += "<div class='sub'>Pecas puramente COSMETICAS. Vestindo [outfit_list.len]/[WARDROBE_MAX] -- clique pra vestir/tirar.</div>"
	h += "<a class='btn red' href='byond://?src=\ref[src];wardrobeclear=1'>Tirar tudo</a><a class='btn' href='byond://?src=\ref[src];wardrobeclose=1'>Fechar</a>"
	h += "<input id='ws' class='vsearch' type='text' autocomplete='off' placeholder='Filtrar [L.len] roupas...' oninput='wflt()' onkeyup='wflt()'>"
	h += "<div id='grid' class='grid'>"
	for(var/i = 1 to L.len)
		var/path = L[i]
		var/sel = (path in outfit_list)
		h += "<a class='card[sel ? " sel" : ""]' href='byond://?src=\ref[src];wardrobepick=[i]'><img src='wrd[i].png'><span class='nm'>[html_encode(wardrobe_name(path))]</span></a>"
	h += "</div><div id='wnone' class='tnone' style='display:none'>Nenhuma roupa com esse nome.</div>"
	h += "[ui_scroll_js("wardrobe")]</body></html>"
	src << browse(jointext(h, ""), "window=wardrobe;size=560x540")

// ---------------------------------------------------------------------------
// acoes (chamadas do mob/Topic em HtmlUI.dm)
// ---------------------------------------------------------------------------
mob/proc/wardrobe_pick(i)
	var/list/L = wardrobe_list()
	if(!i || i < 1 || i > L.len) return
	var/path = L[i]
	if(!islist(outfit_list)) outfit_list = list()
	if(path in outfit_list)
		outfit_list -= path
		to_chat(src, "Voce tira [wardrobe_name(path)].")
	else
		if(outfit_list.len >= WARDROBE_MAX)
			to_chat(src, "Voce ja esta vestindo [WARDROBE_MAX] pecas -- tire alguma primeiro.")
			return
		outfit_list += path
		to_chat(src, "Voce veste [wardrobe_name(path)].")
	outfit_apply()
	wardrobe_render()

mob/proc/wardrobe_clearall()
	if(islist(outfit_list)) outfit_list.Cut()
	outfit_apply()
	wardrobe_render()

// ---------------------------------------------------------------------------
// entradas: verb (aba Other) + prompt da criacao de personagem
// ---------------------------------------------------------------------------
mob/verb/Roupas()
	set category = "Other"
	set name = "Roupas"
	wardrobe_open()

mob/proc/outfit_creation_prompt() //fim da criacao: quer ja nascer vestido?
	set waitfor = 0
	if(!client) return
	if(alert(src, "Deseja escolher uma ROUPA inicial? (pecas puramente cosmeticas -- da pra trocar a qualquer momento pelo verb 'Roupas' na aba Other)", "Guarda-Roupa", "Sim", "Agora nao") != "Sim") return
	wardrobe_open()
