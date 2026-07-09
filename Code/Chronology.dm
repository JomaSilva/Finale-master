//GUIA DO JOGO (verb "Guia do Jogo" na aba Other -- Communication.dm faz browse(Guide)).
//Reescrito 2026-07-08 pro estado atual do jogo (o antigo era da base original, em ingles,
//e descrevia mecanicas que nao existem mais). Texto sem acentos (padrao das strings DM).

var/Guide={"
<html>
<head><title>Guia do Jogo</title></head>
<body bgcolor="#0d0f14" text="#cfd6e4" link="#6ab0f3">
<font face="Segoe UI" size=2>
<center><font color="#e8842c" size=5><b>DRAGONBALL JANDIRUS</b></font><br>
<font color="#8a93a8" size=2>Guia rapido de mecanicas -- leia, explore, descubra</font></center>
<hr color="#2a2f3a">

<font color="#e8842c" size=3><b>1. Interface</b></font>
<p>Quase tudo vive no <b>painel de Status</b> (abas: Stats, Items, Equip, Body, Forms, Ki, People, World, Skills, Learning, Other...) e no <b>chat com abas</b>. A barra superior esconde muita coisa -- explore com calma. Dash = <b>Shift</b> (mais rapido e libera golpes pesados).</p>

<font color="#e8842c" size=3><b>2. Criacao e envelhecimento</b></font>
<p>Cada raca tem forcas, formas e <b>expectativa de vida propria</b>: o auge (peak) varia de 50 anos (Humano) a milhares (Frost Demon 2000, Kai/Demonio 75000) -- Majin nao envelhece. Depois do auge o corpo decai e a morte por velhice chega perto de <b>1.5x o peak</b>. Classes (Elite, Legendary...) sao sorteadas por raridade. A historia (backstory) e obrigatoria.</p>

<font color="#e8842c" size=3><b>3. Como ficar forte</b></font>
<p>O ganho de BP e <b>LINEAR e individual</b>: uma base fixa multiplicada pelo seu BPMod e pelos seus <b>marcos</b> (virar SSJ, forma perfeita, God Ki... cada raca tem sua escada). Nada de media do servidor.</p>
<p><b>Lutar &gt; treinar.</b> Treino AFK rende pouco. Sparring, cacar inimigos e sobreviver a lutas de verdade e o caminho. Ao ser <b>derrotado</b> voce recebe <b>Zenkai na hora</b> (proporcional ao BP do inimigo -- para de valer perto do BP de SSJ3). Combate desliga sua regeneracao: leve comida.</p>

<font color="#e8842c" size=3><b>4. Gravidade</b></font>
<p>Treinar em gravidade alta multiplica os ganhos, e o ganho conta a gravidade <b>absoluta</b> do lugar. MAS: acima da sua <b>maestria de gravidade</b> o planeta te esmaga -- voce anda muito mais devagar e TODO o corpo toma dano crescente (estilo Kaioken). Muito acima: desmaio... e desmaiar sozinho na gravidade mata. Absurdamente acima: o corpo <b>explode</b>. O Nav System mostra a gravidade dos planetas antes de pousar.</p>

<font color="#e8842c" size=3><b>5. Nutricao, Stamina e Ki</b></font>
<p>Nutricao e stamina alimentam TUDO: a regeneracao passiva de vida/Ki so funciona alimentado e descansado. Coma (pesca, frutas, plantas colhiveis, cozinhar em fogueira melhora a comida). Ki sobe usando Ki -- cargas, ataques, tecnicas. Stamina define quanto tempo voce aguenta uma luta.</p>

<font color="#e8842c" size=3><b>6. Combate</b></font>
<p>Golpes leves/pesados, bloqueio, esquiva e <b>mira por zonas do corpo</b>: cada membro tem HP proprio (o HP mostrado e uma media -- da pra quebrar por dentro). Membro vital quebrado = KO; destruido = morte; decepado e permanente. <b>KO'd fica exposto</b> (finalizacao). Raiva so cresce contra <b>inimigos de verdade</b> e explode em power boost. Beams em rota de colisao entram em <b>BeamClash</b> (disputa de forca com empurrao). Dois lutadores com Afterimage trocando golpes ao mesmo tempo = <b>ZanzoClash</b>. Fusao existe: BP = (A+B)x2, KO separa, 1h de cooldown.</p>

<font color="#e8842c" size=3><b>7. Transformacoes</b></font>
<p>Formas destravam por <b>BP BASE + gatilhos</b> (furia, morte, treino...). A maestria de forma vai de 0 a 100% em degraus: dominar reduz o dreno e libera o proximo estagio. Cada raca tem sua arvore (SSJ ate SSJ4, Lendario, formas do Frost, evolucao Bio, Majin puro, God Ki e alem) -- descobrir os gatilhos faz parte do jogo. Seu BP fica <b>oculto ("???")</b> pra quem nao tem scouter ou Sense.</p>

<font color="#e8842c" size=3><b>8. Skills e Stats</b></font>
<p>Aba <b>Learning &gt; Learn Skill</b> abre as arvores (Core, avancadas, raciais). Compra-se com <b>Milestones</b> (ganhos por marcos de BP e por tempo de jogo; podem tambem ser ALOCADOS em Styles sem gastar). Skills podem ser <b>ensinadas</b> a outros jogadores.</p>
<p><font color="#8a93a8">Resumo: <b>Physoff/Physdef</b> dano/defesa fisica - <b>Speed</b> movimento e cooldowns - <b>Kioff/Kidef</b> dano/defesa de Ki - <b>Kiskill</b> tecnica de Ki - <b>Technique</b> acerto/esquiva - <b>Esoteric</b> magia - <b>Intelligence</b> teto de Tech - <b>Willpower</b> stamina/vontade.</font></p>

<font color="#e8842c" size=3><b>9. O espaco e a galaxia infinita</b></font>
<p>Alem dos planetas conhecidos (Terra, Vegeta, Namek...) existe uma <b>GALAXIA PROCEDURAL</b>: voando ate a borda do espaco voce cruza pra setores novos, cada um com planetas proprios -- bioma, gravidade, minerios nas colinas, plantas colhiveis e criaturas nativas (mata-las da karma positivo). Encoste a nave no planeta pra pousar. <b>As bordas de um planeta dao a volta nele</b> (e redondo!) -- sair e SO decolando de nave. O <b>Nav System</b> mostra o setor, os planetas (com gravidade e bioma!) e o mapa da galaxia.</p>
<p><font color="#e8b64c"><b>Super Dragon Balls:</b></font> 7 esferas do tamanho de planetoides estao espalhadas pela galaxia. O Nav acusa um <b>sinal dourado</b> a ate 2 setores. Com as 7, invoque o <b>Super Shenron</b> (riqueza... ou trazer alguem de volta). As esferas comuns tambem existem e concedem desejos.</p>

<font color="#e8842c" size=3><b>10. Karma e o Outro Mundo</b></font>
<p>Matar inocentes e civis <b>suja seu karma</b>; derrotar viloes, bosses e criaturas selvagens limpa. Ao morrer, <b>Enma te julga</b>: os dignos aguardam (ou treinam com o <b>Sr. Kaioh</b>, que ensina Kaio-ken e Genkidama a quem merece); os sujos cumprem pena no <b>Inferno</b> proporcional ao karma. Reviver: esferas, ou pagando Zeni ao Enma (com enfraquecimento temporario). Os planetas tambem tem memoria: <b>reputacao local</b> -- testemunhas fofocam, povo se vinga, herois sao celebrados.</p>

<font color="#e8842c" size=3><b>11. O servidor vivo</b></font>
<p><b>Sagas de boss</b> (Freeza, androides/Cell, Boo) despertam conforme o servidor fica forte -- anuncios em banner avisam com antecedencia real, e planeta ameacado explode DE VERDADE se ninguem lutar. <b>Torneio de Artes Marciais</b> mensal (chave de 16, ring-out, premios). <b>Sala do Tempo</b>: 40 min por dia real a 280x (envelhece!). <b>Dimensao Mental</b> via meditacao profunda. <b>Dungeons</b> temporarias com loot (ache uma dungeon needle). E da pra <b>casar</b> com outro jogador e <b>ter filhos</b> -- o bebe hibrido vira um novo personagem jogavel da conta.</p>

<font color="#e8842c" size=3><b>12. Dicas finais</b></font>
<p>- O jogo se inspira no anime, mas NAO e uma copia: descobrir o que mudou e parte da graca.<br>
- Racas mais fortes progridem mais devagar -- equilibrio.<br>
- Spacepod conta como voo (da pra cruzar agua e lava com ele).<br>
- Uma mente curiosa e uma mente poderosa.</p>

<hr color="#2a2f3a">
<center><font color="#8a93a8" size=1>Duvidas? Fale com a staff ou consulte o Guia de Mecanicas completo (PDF) com o host.</font></center>
</font>
</body></html>"}
