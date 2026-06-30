// =============================================================================
// HTML CHAT — modern tabbed chat (All/Say/OOC/LOOC/RP/Combat/Events) with
// per-type styling, rendered in a browser over the Chatpane.Chat output.
// Messages are APPENDED live (no page reload) via
//   src << output("<div class='m c-cat'>...</div>", "Chatpane.chatbrowser:addMsg")
// which calls the page's addMsg() JS. Player chat is categorized through
// sayType/TestListeners (last_chat_cat); combat via OutputAttack; KO/death/
// announce hooked at the source with chatcast(). The native Chatpane.Chat OUTPUT
// stays behind the browser (still receives EVERYTHING) as a complete fallback for
// any line not yet routed.
// =============================================================================

mob/var/tmp
	last_chat_cat = "say"
	chatUIready = 0
	list/chat_log = null //rolling backlog (last ~250 lines) so messages sent before the browser
	                     //finishes loading (e.g. the class hint at spawn) can be replayed once it's ready

// <meta IE=edge> so the embedded browser supports flexbox/modern CSS.
var/CHAT_PAGE = {"
<html><head>
<meta http-equiv='X-UA-Compatible' content='IE=edge'>
<style>
 *{box-sizing:border-box} html,body{margin:0;padding:0;height:100%}
 body{background:#0f1115;color:#c8cdd6;font-family:'Segoe UI',Tahoma,sans-serif;font-size:12px}
 #wrap{display:flex;flex-direction:column;height:100%}
 #tabs{display:flex;gap:4px;padding:5px 6px;background:#15171c;flex-wrap:wrap;flex-shrink:0;border-bottom:1px solid #23262e}
 .tab{background:#1b1e25;color:#8b919c;padding:4px 9px;border-radius:6px;font-size:11px;font-weight:bold;cursor:pointer}
 .tab.on{background:#2b303a;color:#ffffff}
 #log{flex:1;overflow-y:auto;overflow-x:hidden;padding:5px 7px}
 .m{padding:2px 5px;margin:1px 0;border-radius:4px;border-left:3px solid transparent;line-height:1.35}
 .c-ooc{border-left-color:#5a8fd6;background:rgba(90,143,214,0.07)}
 .c-looc{border-left-color:#7a86c4;background:rgba(122,134,196,0.06)}
 .c-rp{border-left-color:#d6c24f;background:rgba(214,194,79,0.06)}
 .c-combat{border-left-color:#d65a5a;background:rgba(214,90,90,0.07)}
 .c-announce{border-left-color:#e0a030;background:rgba(224,160,48,0.10)}
 .c-system{border-left-color:#3a3f47}
 #inbar{display:flex;align-items:center;gap:5px;padding:6px;background:#15171c;border-top:1px solid #23262e;flex-shrink:0;position:relative}
 #emoji{background:#1b1e25;color:#c8cdd6;border:0;border-radius:6px;width:30px;height:28px;font-size:15px;cursor:pointer;flex-shrink:0;line-height:1;padding:0}
 #emoji:hover{background:#2b303a}
 #msg{flex:1;min-width:0;background:#0f1115;color:#e6e9ef;border:1px solid #2b303a;border-radius:6px;padding:6px 8px;font-size:12px;outline:none;font-family:inherit}
 #msg:focus{border-color:#3a4150}
 #chan{background:#1b1e25;color:#c8cdd6;border:1px solid #2b303a;border-radius:6px;padding:5px 4px;font-size:11px;font-weight:bold;cursor:pointer;flex-shrink:0;outline:none}
 #emojibox{display:none;position:absolute;left:6px;bottom:42px;width:212px;max-height:92px;overflow-y:auto;background:#1b1e25;border:1px solid #2b303a;border-radius:8px;padding:6px;z-index:10;box-shadow:0 6px 16px rgba(0,0,0,0.55)}
 #emojibox span{display:inline-block;width:26px;height:25px;text-align:center;font-size:16px;cursor:pointer;border-radius:5px;line-height:25px}
 #emojibox span:hover{background:#2b303a}
</style>
<script>
var curTab='all';
function flt(n){ if(!n||!n.className){return;} if(curTab=='all'){n.style.display='';return;} n.style.display=(n.className.indexOf('c-'+curTab)>=0)?'':'none'; }
function addMsg(h){
 var log=document.getElementById('log'); if(!log){return;}
 var atb=(log.scrollHeight-log.scrollTop-log.clientHeight)<40;
 var w=document.createElement('div'); w.innerHTML=h; var n=w.firstChild;
 if(!n){return;} log.appendChild(n); flt(n);
 while(log.childNodes.length>400){ log.removeChild(log.firstChild); }
 if(atb){ log.scrollTop=log.scrollHeight; }
}
function setTab(t){
 curTab=t;
 var ts=document.getElementById('tabs').childNodes,i,e;
 for(i=0;i<ts.length;i++){ e=ts.item(i); if(e.getAttribute){ e.className=(e.getAttribute('data-t')==t)?'tab on':'tab'; } }
 var ls=document.getElementById('log').childNodes;
 for(i=0;i<ls.length;i++){ flt(ls.item(i)); }
 document.getElementById('log').scrollTop=document.getElementById('log').scrollHeight;
}
function cpToStr(cp){ if(cp>0xFFFF){ cp-=0x10000; return String.fromCharCode(0xD800+(cp>>10),0xDC00+(cp&0x3FF)); } return String.fromCharCode(cp); }
function buildEmoji(){ var b=document.getElementById('emojibox'); if(!b){return;} var parts="128512,128514,129315,128517,128521,128526,128525,128557,128561,128545,129300,128064,128077,128078,128591,128170,128293,128165,9889,10024,10084,128128,127881,128009".split(","), h='', cp; while(parts.length){ cp=parts.shift(); h+="<span onclick='addEmoji("+cp+")'>&#"+cp+";</span>"; } b.innerHTML=h; }
function toggleEmoji(){ var b=document.getElementById('emojibox'); if(!b){return;} b.style.display=(b.style.display=='block')?'none':'block'; }
function addEmoji(cp){ var inp=document.getElementById('msg'); if(!inp){return;} inp.value=inp.value+cpToStr(cp); inp.focus(); var b=document.getElementById('emojibox'); if(b){ b.style.display='none'; } }
function navByond(u){ try{ var a=document.createElement('a'); a.href=u; document.body.appendChild(a); if(a.click){ a.click(); document.body.removeChild(a); return; } }catch(e){} try{ window.location=u; }catch(e2){} }
function sendMsg(){ var inp=document.getElementById('msg'); if(!inp){return;} var txt=inp.value; var t=(txt&&txt.trim)?txt.trim():txt; if(!t){ inp.value=''; return; } var sel=document.getElementById('chan'); var cat=sel?sel.value:'say'; navByond('byond://?src=__REF__;saySend=1;cat='+cat+';msg='+encodeURIComponent(t)); inp.value=''; inp.focus(); }
function onMsgKey(e){ e=e||window.event; var k=e.keyCode||e.which; if(k==13){ if(e.preventDefault){e.preventDefault();} sendMsg(); return false; } return true; }
</script>
</head><body><div id='wrap'>
<div id='tabs'>
<span class='tab on' data-t='all' onclick="setTab('all')">All</span>
<span class='tab' data-t='say' onclick="setTab('say')">Say</span>
<span class='tab' data-t='ooc' onclick="setTab('ooc')">OOC</span>
<span class='tab' data-t='looc' onclick="setTab('looc')">LOOC</span>
<span class='tab' data-t='rp' onclick="setTab('rp')">RP</span>
<span class='tab' data-t='combat' onclick="setTab('combat')">Combat</span>
<span class='tab' data-t='system' onclick="setTab('system')">System</span>
<span class='tab' data-t='announce' onclick="setTab('announce')">Events</span>
</div>
<div id='log'></div>
<div id='inbar'>
<button id='emoji' type='button' onclick='toggleEmoji()' title='Emoji'>&#128512;</button>
<input id='msg' type='text' maxlength='500' autocomplete='off' placeholder='Type a message and press Enter...' onkeydown='return onMsgKey(event)'>
<select id='chan' title='Channel'>
<option value='say'>Say</option>
<option value='emote'>Emote</option>
<option value='ooc'>OOC</option>
<option value='looc'>LOOC</option>
</select>
<div id='emojibox'></div>
</div>
</div>
<script>
buildEmoji();
(function(){
 var done=false, url='byond://?src=__REF__;chatReady=1';
 function ping(){
  if(done){return;} done=true;
  try{ var a=document.createElement('a'); a.href=url; document.body.appendChild(a);
       if(a.click){ a.click(); return; } }catch(e){}
  try{ window.location=url; }catch(e2){} // fallback
 }
 if(window.addEventListener){ window.addEventListener('load',ping,false); }
 else if(window.attachEvent){ window.attachEvent('onload',ping); }
 setTimeout(ping,80); // fire once the page DOM+addMsg are ready so DM can replay the backlog
})();
</script>
</body></html>
"}

mob/proc/OpenChatUI()
	if(!client) return
	chatUIready = 0 //the page reloads from scratch; wait for its ready-ping before live-pushing
	var/page = replacetext(CHAT_PAGE, "__REF__", "\ref[src]") //inject this mob's ref into the ready-ping URL
	src << browse(page, "window=Chatpane.chatbrowser")
	//The page pings byond://?chatReady=1 once its DOM/addMsg are ready -> Topic calls FlushChat()
	//to replay the backlog. Fallback: if that callback never arrives, flush anyway after ~5s so the
	//log is never permanently stuck empty.
	spawn(50) if(!chatUIready) FlushChat()

//Replay the buffered backlog into the freshly-loaded page, then go live.
mob/proc/FlushChat()
	chatUIready = 1
	if(!client || !chat_log) return
	for(var/entry in chat_log)
		src << output(entry, "Chatpane.chatbrowser:addMsg")

mob/proc/to_chat_html(html, category)
	if(!client) return
	if(!category) category = "system"
	var/p = findtext(html, "<") //strip a leading \icon[...] (it renders as the whole sprite-sheet in a browser); messages always start with <font...> after it
	if(p > 1) html = copytext(html, p)
	var/entry = "<div class='m c-[category]'>[html]</div>"
	if(!chat_log) chat_log = list()
	chat_log += entry //always buffer so nothing sent before the browser loads is lost
	if(chat_log.len > 250) chat_log.Cut(1, chat_log.len - 249) //keep the last ~250 lines
	if(chatUIready) src << output(entry, "Chatpane.chatbrowser:addMsg") //DM->JS live append

proc/chatcast(targets, html, category) //mirror a line to recipients' HTML chat; accepts a mob, client, world, or a view()/list
	if(!targets) return
	if(ismob(targets))
		var/mob/M = targets
		if(M.client) M.to_chat_html(html, category)
		return
	if(istype(targets, /client))
		var/client/C = targets
		if(C.mob) C.mob.to_chat_html(html, category)
		return
	if(targets == world)
		for(var/mob/M in world)
			if(M.client) M.to_chat_html(html, category)
		return
	if(islist(targets))
		for(var/mob/M in targets)
			if(M.client) M.to_chat_html(html, category)
		return
	//unknown target type (savefile/atom/etc.) -> no chat mirror, native send already happened

//Central output: do the native send (preserves the is-default Chatpane.Chat behaviour for the
//fallback pane) AND mirror it into the new HTML chat. The game's plain `target << "text"` sends
//are routed through this so the browser chat shows everything the old default-output chat did.
proc/to_chat(target, msg, category)
	target << msg
	if(!category) category = "system"
	chatcast(target, msg, category)
