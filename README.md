<div align="center">

# 🐉 DragonBall Jandirus

**MMORPG de ação Dragon Ball feito em [BYOND](https://www.byond.com/) (DreamMaker).**
Crie seu guerreiro, escolha entre dezenas de raças, evolua seu Battle Power, domine transformações lendárias, explore uma **galáxia procedural infinita** e lute em tempo real com outros jogadores — tudo numa interface moderna em HTML/CSS embutida no cliente.

![BYOND](https://img.shields.io/badge/engine-BYOND%20516-blue)
![Linguagem](https://img.shields.io/badge/linguagem-DreamMaker%20(DM)%20%2B%20C%20(DLL)-orange)
![Código](https://img.shields.io/badge/c%C3%B3digo-496%20.dm%20%7C%20~99k%20linhas-success)
![UI](https://img.shields.io/badge/UI-HTML%2FCSS%20embutido-9cf)
![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)

</div>

---

## 📖 Sobre

DragonBall Jandirus é um jogo multiplayer top-down (estilo MMORPG) baseado no universo Dragon Ball, escrito em **DM (DreamMaker)** da plataforma BYOND. Todo o progresso do jogador — atributos, transformações, habilidades, idade, ranks, karma — é simulado por sistemas reais no código (genética/raças, Battle Power, buffs de transformação, combate por zonas do corpo, Ki, árvores de habilidade, eventos de boss, galáxia procedural etc.).

A interface do jogador (painel de status, HUD, criação de personagem, árvores de skill, chat, inventário, navegação espacial) é renderizada em **HTML/CSS dentro de controles `browser` do BYOND**, dando um visual limpo e moderno por cima da engine. A geração de terreno dos planetas procedurais roda em **C nativo via DLL** (`call_ext`).

> 📘 **Guia de Mecânicas:** o arquivo [`Dragonball Jandirus - Guia de Mecanicas.pdf`](./Dragonball%20Jandirus%20-%20Guia%20de%20Mecanicas.pdf) (gerado a partir do código) explica **como jogar** — criação, raças, BP, combate, Ki, transformações, skills e progressão. Este README foca na **documentação do código**.

---

## 🗂️ Índice

- [Destaques](#-destaques)
- [Como rodar](#-como-rodar)
- [Compilando do código-fonte](#-compilando-do-código-fonte)
- [Estrutura do projeto](#-estrutura-do-projeto)
- [Arquitetura do código](#-arquitetura-do-código)
  - [Interface (HTML/CSS embutido)](#9-interface-htmlcss-embutido)
  - [Galáxia procedural](#10-galáxia-procedural--dll-nativa)
- [Sistemas de destaque](#-sistemas-de-destaque)
- [Convenções e armadilhas do DreamMaker](#-convenções-e-armadilhas-do-dreammaker)
- [Contribuindo](#-contribuindo)
- [Créditos e aviso legal](#-créditos-e-aviso-legal)

---

## ✨ Destaques

- **20+ raças jogáveis** (Saiyajin + Primal, Namekuseijin, Frost Demon, **Majin / Corrupted Majin**, Bio-Android, Heran, Kai + Golden Apple, **Demônio**, Demigod, Gray, Alien personalizável…), cada uma com multiplicadores próprios, BP inicial, regeneração, transformações e **expectativa de vida** (peak age por raça; Majin não envelhece; Bio-Android herda o maior peak dos DNAs).
- **Criação de personagem 100% em HTML** — planeta/raça/gênero/corpo/cabelo em cards com preview, formulário de identidade com validação por campo, seletor de formas do Frost Demon/Bio com numeração e highlight, guarda-roupa cosmético (223 roupas) e **resumo final com foto do personagem montado**.
- **Sistema de genética** — raças/classes são `/datum/genetics` que semeiam os atributos do mob; classes sorteadas por raridade (`Class_Spread`, um único roll ancorado); herança por reprodução — **casamento entre amigos e filhos híbridos** que nascem como novos personagens na criação.
- **Battle Power linear + marcos**: o ganho de BP usa uma **base fixa × BPMod × marcos de personagem** (virar SSJ, forma perfeita, God Ki… cada raça tem sua escada `BP_MILESTONES`) em vez de compor sobre o próprio BP — crescimento sob controle até nos bilhões.
- **Transformações** completas: linha Super Saiyajin (SSJ1 → USSJ → SSJ2 → SSJ3 → SSJ4 e maestria por estágios), **Lendário** + Wrathful, Oozaru, **God Ki / Formas Divinas** (Blue/Rosé), formas próprias de cada raça — gatadas pelo **BP base**.
- **Galáxia procedural infinita** — encostar na borda do espaço cruza pra setores gerados por seed com **planetas pousáveis de 500x500** (relevo por noise em C: lagos/lava, praias, planícies, colinas com minérios, montanhas), 6 biomas com kit de terreno próprio, inimigos nativos que escalam, mapa da galáxia no Nav e **7 Super Dragon Balls** escondidas (radar dourado + Super Shenron).
- **Eventos de boss sequenciais** — sagas do Freeza (Vegeta/Namek), Cell (androides + absorções) e Majin Boo disparadas por marcos de BP, com anúncios em banner na tela, ultimatos com contagem real e planet destroy de verdade.
- **Saga do Majin** — absorção que manda a vítima pra uma **dimensão de bolso** (viva, com clone-guardião pra lutar), dá 10% do BP + skills + roupas dela; cadeia de 4 formas do Corrupted Majin + **Pure Form** (18x).
- **Combate em tempo real** com golpes leve/pesado, barragens, bloqueio, esquiva, stamina, **mira por zonas do corpo**, saúde de membros (até decepamento), KO/coma, finalização, **Zenkai instantâneo** ao ser derrotado (teto no BP final), **BeamClash** com disputa de espaço e fase de empurrão, fusão (BP = (A+B)×2) e ZanzoClash.
- **Mundo vivo**: calendário/idade com **morte por velhice** (lifespan = 1.5× o peak da raça), karma + **Outro Mundo** (Enma julga: Inferno proporcional ao karma / revive por Zeni; Sr. Kaioh ensina Kaio-ken e Genkidama), **reputação por planeta** (NPCs fofocam e se vingam), **torneio mensal** (bracket 16 com ring-out), Sala do Tempo, Dimensão Mental, cidade de Vegeta procedural com **população de NPCs** (Rei/Príncipe/Guru), naves capitais com interior próprio, **esmagamento por gravidade** acima da maestria (estilo Kaioken: lento → dano → desmaio → explosão) e trilha sonora de batalha dinâmica.
- **Economia e crafting**: Zenni, banco, lojas, equipamento, profissões, alquimia, **mineração** (veios de minério/gemas nos planetas procedurais).

---

## ▶️ Como rodar

### Requisitos
- **BYOND** instalado (versão **516** ou compatível) — inclui DreamSeeker (cliente) e DreamMaker (IDE/compilador).

### Scripts do servidor (raiz do projeto)
| Script | O que faz |
|---|---|
| [`compilar.bat`](./compilar.bat) | Compila via `dm.exe` (sem quebrar o `FILE_DIR`). Exija `0 errors`. |
| [`servidor.bat`](./servidor.bat) | Sobe o servidor no console (`dd.exe -trusted`, porta 30000). |
| [`parar-servidor.bat`](./parar-servidor.bat) | Derruba o servidor na hora. |
| [`wipe-servidor.bat`](./wipe-servidor.bat) | **Wipe completo**: apaga saves de players, sagas de boss, reputação, galáxia, banco, ranks e relógio — sem tocar em config de admin. Pede confirmação e recusa rodar com o servidor aberto. |
| [`compilar-dll.bat`](./compilar-dll.bat) | Recompila a `jandirus_noise.dll` (terreno procedural) em **32-bit** via Zig. |

> ⚠️ A **`jandirus_noise.dll`** deve ficar na raiz (junto do `.dmb`). Se faltar, o jogo cai automaticamente pro gerador de terreno em DM (mais lento, mas funcional). O servidor precisa de `-trusted` (o `servidor.bat` já usa).

### Jogar (single-player / hospedar)
1. Compile o projeto (veja abaixo) para gerar **`Dragonball Jandirus.dmb`**.
2. Dê duplo-clique no `.dmb` (abre o **DreamSeeker**) ou rode `servidor.bat` para hospedar. O nome/hub/status do mundo ficam em [`Code/Modules/Globals/World.dm`](./Code/Modules/Globals/World.dm).

---

## 🛠️ Compilando do código-fonte

O projeto é definido por **`Dragonball Jandirus.dme`** (493 `#include`s + o bloco `FILE_DIR` que registra as pastas de recursos).

**Opção A — linha de comando (recomendada):** dê duplo-clique em **[`compilar.bat`](./compilar.bat)**, ou chame o compilador direto:

```bat
"E:\BYOND\bin\dm.exe" "Dragonball Jandirus.dme"
```

Exija **`0 errors`** no fim. (Há **1 warning** inofensivo — uma variável não usada no HUD.)

**Opção B — IDE:** abra `Dragonball Jandirus.dme` no **DreamMaker** e use **Build → Compile**.

> ⚠️ **Importante:** prefira o `compilar.bat`. A IDE do DreamMaker tende a **reescrever o bloco `FILE_DIR`** ao salvar, quebrando a busca de recursos — e se a IDE estiver aberta salvando o `.dme` durante um compile externo, aparece um erro fantasma ("unexpected character in include directive"); é só recompilar.

### DLL de terreno (opcional, recomendada)

O relevo dos planetas procedurais é gerado por **`jandirus_noise.dll`** (fonte em [`Tools/jandirus_noise.c`](./Tools/jandirus_noise.c)) — fBm de 4 oitavas que classifica o mapa inteiro (250k tiles) numa única chamada `call_ext` (~15ms). Para recompilar após editar o `.c`, rode **`compilar-dll.bat`** (usa o [Zig](https://ziglang.org/) como compilador C: `zig cc -target x86-windows-gnu`). **A DLL precisa ser 32-bit** — o `dd.exe` do BYOND é x86.

---

## 📁 Estrutura do projeto

```
Dragonball Jandirus.dme      # Projeto BYOND (493 #includes + FILE_DIR)
skin.dmf                     # Skin: janelas + controles BROWSER que hospedam a UI HTML
compilar.bat / servidor.bat / parar-servidor.bat / wipe-servidor.bat / compilar-dll.bat
jandirus_noise.dll           # Terreno procedural em C (32-bit; fonte em Tools/)
Dragonball Jandirus - Guia de Mecanicas.pdf

Code/Modules/                # TODO o código-fonte (.dm), por sistema:
├─ Globals/                  # World.dm (nome/hub/status), VegetaCity.dm, PlanetPopulation.dm,
│                            # PlanetReputation.dm, Tournament.dm, TimeChamber.dm, WorldClock.dm
├─ Login/                    # Lobby, OnLogin/OnLogout, save (Save/), cadeia de login-fixes
├─ Races/                    # Raças e genética
│  ├─ Genetics/              # /datum/genetics (genoma), build_stats, protótipos, decide_Class
│  ├─ RaceStats/             # 1 arquivo por raça (multiplicadores, BP, Class_Spread)
│  └─ Mating.dm              # casamento (amigos), filhos híbridos, ovos
├─ Stats/                    # Atributos e poder
│  ├─ Level/master.dm        # fórmulas de BP/MaxKi por tick
│  ├─ BP/                    # base.dm (BP expresso + teto), LinearGain.dm (ganho linear + marcos),
│  │                         # Gravity.dm (treino + ESMAGAMENTO acima da maestria), softcap.dm
│  ├─ Godki/godki.dm         # Ki Divino / Formas Divinas
│  └─ Training/              # treino, meditação, Dimensão Mental (MindMeditate.dm)
├─ Skills/                   # Habilidades (Buffs raciais, Skill Trees, Ki, CustomAttacks…)
├─ CombatMechanics/          # Combate: golpes, calcs, Injuries, KO, Murder, BeamClash.dm, Styles/
├─ cinematics/               # Cinemáticas de transformação (SSJ/SSJ2/SSJ3/USSJ, DemonEvolve…)
├─ Character Customization/  # CreationUI.dm (criação em HTML), Wardrobe.dm (guarda-roupa),
│                            # body_custom.dm (corpos + formas Frost/Bio), HairChoose.dm
├─ Magic/                    # Absorção, MajinSaga, rituais, Dragonballs, fusão, UnlockPotential
├─ User Interface/           # *** A UI em HTML/CSS *** (HtmlUI.dm, ChatUI.dm, HUD)
├─ Players/                  # Talking (chat), Friendship, BattleMusic.dm, Contacts
├─ Tech/                     # ProceduralSpace.dm (GALÁXIA + Super Dragon Balls), Planets.dm,
│                            # ShipVessel.dm (nave capital), PlanetTech.dm (pods/bases)
├─ NPCs/                     # NPCAI.dm (IA), BossEvents.dm (sagas Freeza/Cell/Boo), SkyNPCs.dm
│                            # (karma/Enma/Outro Mundo), NPCspawner, CopyMaker (clones)
├─ Death/  Dungeons/  Crafting/  Equipment/  Ranks/  Aging (Code/Aging.dm: peak age por raça)
├─ Movement Improvement/  Stamina/  Sound/  Turfs/ (incl. Weather)  Admin/  Procs/  DLC/

Tools/        # jandirus_noise.c (fonte da DLL de terreno)
Icons/        # 1858 .dmi (sprites de mobs, formas, efeitos, UI, SuperDragonball.dmi)
Sounds/       # 250+ efeitos e músicas (Sounds/Music — temas de transformação/batalha/menu)
Maps/         # 1to26.dmm, 2728.dmm, 2930.dmm, 3141.dmm (z-levels 500x500) + dungeons/
lib/          # bibliotecas de terceiros (ex.: dmm_suite)
Save/         # saves dos jogadores (ignorado no git; wipe-servidor.bat limpa)
cfg/          # configuração do servidor (admin, etc.)
```

---

## 🏗️ Arquitetura do código

Visão de alto nível de como os sistemas se conectam. Tudo gira em torno do **mob do jogador** e de uma malha de *datums* e *buffs* que modificam seus atributos.

### 1. Entrada e ciclo de vida
- **`Globals/World.dm`** define `world.name`, fps, view e o hub. `world/New()` constrói coisas procedurais (cidade de Vegeta, população de NPCs, boss events) e carrega configs persistentes.
- **`Login/Lobby.dm`** → decide entre **`New_Character()`** (criação em HTML) e **`OnLogin()`** (carregar save).
- **`Login/Login.dm`** restaura body parts, skills, árvores, equipamento, God Ki, re-cria buffs de transformação persistentes e roda a **cadeia de login-fixes** (Sala do Tempo, torneio, guarda-roupa, marcos de BP, raça/classe de filhos, tabela de idade).
- **Saves** ficam em **`Save/`** (caminho por ckey normalizado; um save inválido nunca é gravado — proteção contra o clássico "buffer ." corrompido).

### 2. Genética & Raças
- Cada raça/classe é um **`/datum/genetics`**; protótipos vivem em `original_genome_list`. `build_stats()`/`apply_stats()` semeiam os multiplicadores no mob; `decide_Class()` é o **único sorteio de classe** (spread do protótipo, classes explícitas ancoradas via `old_class`). Números por raça em **`Races/RaceStats/<raça>.dm`**.
- **Reprodução**: casais casados (sistema de amizade → `Mating.dm`) geram um genoma híbrido (`return_new_genome`) que vira opção de nascimento na criação de personagem.
- **Idade**: `race_peak_age()` (**`Code/Aging.dm`**) define o auge por raça; o declínio é calibrado para a morte por velhice cair em **1.5× o peak**. Majin não envelhece; Unlock Potential estende a vida em +15%.

### 3. Stats, Ki & Battle Power
- **`Stats/Level/master.dm`** recalcula a cada tick (`MaxKi` deriva de `trueKiMod` da forma atual; **não é guardado**).
- **`Stats/BP/LinearGain.dm`** — o coração do progresso: todo ganho de treino usa `bp_gain_base() = base fixa × BPMod × marco` em vez de compor sobre o BP atual. **Marcos** (`BP_MILESTONES`) são conquistas por raça (SSJ = 2x, SSJ2 = 3x, God Ki = 5x, Blue = 6x…), idempotentes e anunciados uma única vez.
- **`Stats/BP/base.dm`** calcula o BP "expresso" e o teto pessoal `relBPmax`, com retornos decrescentes no topo (`softcap.dm`).
- **Gravidade** (`Stats/BP/Gravity.dm`): treino rastreia a gravidade **absoluta** + buff de aclimatação; **acima da maestria a gravidade esmaga** — lentidão multiplicativa, dano em todos os membros escalando ao quadrado, desmaio e (muito acima) explosão do corpo. Knobs `GRAVCRUSH_*` em `Code/1A Defines.dm`.

### 4. Transformações & Buffs
- Formas são **`/obj/buff`** com `Buff()`/`Loop()`/`DeBuff()`, via `startbuff()`/`stopbuff()`.
- **`Skills/Buffs/racial/supersaiyanbuff.dm`** controla a linha Saiyajin (`ssj`, mults por estágio, maestria 0–100% em degraus, form-change de cabelo/overlays). Requisitos usam **BP base**.
- Outros buffs raciais: `lssjbuff` (Lendário/Wrathful/Primal-Legendary), `CellFormBuff`, `Super_Namek`, `Oozaru` (só BP, sem Ki), formas do Majin (saga), Golden Form dos Frost. **`Godki/godki.dm`** soma o Ki Divino.

### 5. Aparência & Overlays
- Sprites compostos usam **`vis_contents`** com `/obj/overlay` (`updateOverlay()`/`removeOverlay()`); cabelo/cauda em `HairObject.dm` com tints por forma. A criação escolhe corpo/cabelo em **cards HTML** (`CreationUI.dm`/`body_custom.dm`/`HairChoose.dm`), e o **guarda-roupa** (`Wardrobe.dm`) veste roupas cosméticas de `Icons/Clothes/**` via overlays.

### 6. Combate
- **`CombatMechanics/`**: golpes em `attacking/`, cálculos em `calcs.dm`, lesões/decepamento em `Injuries.dm`, KO em `KO.dm` (KO'd = exposto), finalização em `Murder.dm`. **Zenkai** paga **na hora da derrota** (10% do BP do inimigo, teto no BP final, aposenta perto do BP de SSJ3). **`BeamClash.dm`**: disputa de beams por ESPAÇO com vantagem por BP e fase de empurrão do vencedor.
- **Karma** (`NPCs/SkyNPCs.dm`): matar inocentes/-civis é mau, vilões/bosses/inimigos selvagens é bom; **Enma julga os mortos** (Inferno com pena proporcional, revive por Zeni com debuff, treino com o Sr. Kaioh — que ensina **Kaio-ken** e **Genkidama** aos dignos).

### 7. Habilidades
- **`Skills/Skill Trees/`** define **`/datum/skill/tree`** (Core/avançadas/raciais) com tiers, custo e pré-requisitos; skills podem ser **ensinadas**. Ataques customizados têm ícones por categoria e gritos configuráveis.

### 8. NPCs & Eventos
- **`NPCs/NPCAI.dm`** — IA com paridade de jogador (Ki/stamina, escolha de habilidade por personalidade, blocking, recarga), watchdog anti-freeze e higiene de loops (mob morto nunca segura referência — anti-lag).
- **`NPCs/BossEvents.dm`** — sagas **sequenciais** (Freeza em Vegeta → Freeza em Namek → androides + Cell → Boo) disparadas por marcos de BP, com contagem em dias in-game anunciada em minutos reais, banner de tela + trovão nos anúncios, ultimatos de paciência e planet destroy real (interrompível).
- **`Globals/PlanetPopulation.dm`** — cidadãos por planeta (fábrica de NPC sem client), Rei/Príncipe de Vegeta com trono conquistável, Guru em Namek (Unlock Potential 1x).
- **`Globals/PlanetReputation.dm`** — reputação por planeta: testemunhas gritam, povo se vinga, heróis são celebrados.
- **`Globals/Tournament.dm`** — Torneio de Artes Marciais mensal (bracket de 16 com NPCs, ring-out, prêmios, verb de assistir com câmera).

### 9. Interface (HTML/CSS embutido)
A UI do jogador é renderizada em **HTML/CSS dentro de controles `BROWSER`** do skin (`skin.dmf`). Ficam em **`Code/Modules/User Interface/`**:

- **`HtmlUI.dm`** — o **painel de Status** com abas (Stats, Items, Equip, Body, Forms, Ki, People, World, **Nav**, Skills, Other, Learning, Admin + abas de skill como Sense/Scan), o **HUD de barras** (HP/Ki/Stamina/Nutrição com gradientes e updates via JS `setBar`), roteamento por `mob/Topic`.
- **`CreationUI.dm`** — criação de personagem inteira em HTML: seletor genérico bloqueante `ui_choose()` (cards com preview), formulário nome/idade/história com validação por campo, resumo final com foto do personagem.
- **`ChatUI.dm`** — **chat HTML com abas** (All/Say/OOC/LOOC/RP/Combat/System/Events), roda **desde a conexão** (o backlog vive no client e sobrevive à troca de mob na criação). `to_chat(target, msg, category)` é o funil central; sends nativos precisam do espelho `chatcast`.
- **Regra de ouro**: o statpanel nativo morreu com a skin — toda feature nova de leitura vira **aba HTML** (padrão `ui_tab_<nome>`).

### 10. Galáxia procedural & DLL nativa
**`Tech/ProceduralSpace.dm`** (+ `Tools/jandirus_noise.c`):

- **Setores infinitos**: encostar na borda do espaço (z26) cruza pra um grid `(sx, sy)` de setores gerados por **seed determinística** (savefile `Galaxy` — wipe = galáxia nova). Cada setor tem 2-4 **planetas procedurais** (nome, bioma, gravidade com cauda pesada, cor).
- **Planetas pousáveis 500x500**: relevo por **fBm de 4 oitavas em C** (uma chamada `call_ext` classifica os 250k tiles em ~15ms; fallback em DM se a DLL faltar) → lagos (ou **lava**), praias, planícies com flora colhível, colinas com **minérios** (`Raw_Material`), montanhas. **Kit de terreno por planeta** (famílias de turf reais + tint opcional + cross-mix de água) pra cada mundo ter identidade. Bordas dão a **volta no planeta** (wrap); sair é só de nave.
- **Pools recicláveis de z-levels** (BYOND não deleta z): setores e superfícies reutilizam andares LRU sem jogadores, com latches anti-corrida (nunca reciclar/gerar duas vezes o mesmo z).
- **Super Dragon Balls**: 7 esferas gigantes espalhadas em setores aleatórios, radar dourado no Nav (≤2 setores), e com as 7 o portador invoca **Super Shenron** (riqueza ou reviver) — as esferas se re-espalham.
- **Nav System** (item + aba HTML): planetas do setor com gravidade/bioma, vizinhos explorados e **mapa da galáxia 7x7**.

---

## 🌟 Sistemas de destaque

Recursos maiores que valem um mapa rápido (todos no código, todos compilam):

| Sistema | Onde | Resumo |
|---|---|---|
| **Galáxia procedural** | `Tech/ProceduralSpace.dm` + `Tools/jandirus_noise.c` | Setores infinitos por seed, planetas 500x500 com biomas/minérios, pools de z reciclados, mapa no Nav, terreno em C nativo. |
| **Super Dragon Balls** | `Tech/ProceduralSpace.dm` | 7 esferas na galáxia, radar dourado, Super Shenron (riqueza/reviver) e re-scatter pós-desejo. |
| **Boss Events** | `NPCs/BossEvents.dm` | Sagas sequenciais Freeza→Cell→Boo por marco de BP; anúncios em banner + trovão; ultimatos reais; planet destroy interrompível. |
| **Karma & Outro Mundo** | `NPCs/SkyNPCs.dm` | Enma julga os mortos (Inferno ∝ karma / Zeni-revive); Sr. Kaioh ensina Kaio-ken e Genkidama; Snake Way com barreira espiritual. |
| **UI HTML/CSS** | `User Interface/` | Status + HUD + criação + árvores + chat + Nav, tudo em `browser`; roteamento por `mob/Topic`. |
| **Saga do Majin** | `Magic/MajinSaga.dm`, `Absorption.dm` | Absorção com dimensão de bolso + clone-guardião; 4 formas do Corrupted; clone hostil na Fase 2; **Pure Form** (18x). |
| **Casamento & filhos** | `Races/Mating.dm` | Amigos casam (botão direito), casais têm filhos — o bebê híbrido nasce como novo personagem na criação. |
| **Ganho linear + marcos** | `Stats/BP/LinearGain.dm` | `bp_gain_base()` com escada de marcos por raça — fim da explosão exponencial (HTC 280x segura). |
| **Esmagamento por gravidade** | `Stats/BP/Gravity.dm` | Acima da maestria: lentidão multiplicativa + dano quadrático em todos os membros + desmaio + explosão (estilo Kaioken). |
| **Torneio mensal** | `Globals/Tournament.dm` | Bracket 16 com NPCs, ring-out, trava anti-invasão, prêmios e modo espectador. |
| **Sala do Tempo & Dimensão Mental** | `Globals/TimeChamber.dm`, `Training/MindMeditate.dm` | 40min/dia real com 280x e envelhecimento; meditação profunda num plano mental com clone. |
| **Nave capital** | `Tech/ShipVessel.dm` | Starship construível com **interior gerado em z-level próprio**, ponte, pilotagem e pouso. |
| **Trilha de batalha** | `Players/BattleMusic.dm` | Playlist local de combate que abaixa pra tocar temas de transformação. |
| **Zenkai** | `attacking/combatgains.dm` | Paga na hora da derrota (10% do BP do inimigo, teto no BP final); aposenta perto do BP de SSJ3. |

---

## ⚙️ Convenções e armadilhas do DreamMaker

Pontos não-óbvios aprendidos no projeto (úteis ao contribuir):

- **`FILE_DIR` (recursos):** o bloco `// BEGIN_FILE_DIR … // END_FILE_DIR` no `.dme` registra **toda** pasta com recursos. A **IDE pode resetá-lo** ao salvar. Compile pelo **`compilar.bat`**.
- **Cache `.rsc` travado:** com o jogo aberto, o compilador não importa recursos novos ("cannot find file"). Feche e recompile.
- **"Compilou mas nada mudou":** a IDE roda o **último `.dmb` válido** se a compilação falhar. Sempre confirme **`0 errors`** — e lembre que um servidor já aberto **não recarrega** o `.dmb` novo (reinicie).
- **`#define` compartilhado entre arquivos** vai para `Code/1A Defines.dm` — o DreamMaker **reordena os includes alfabeticamente** e defines são sensíveis à ordem.
- **`usr` é nulo/errado** em contextos de engine (login, loops, morte, IA) — use `src` e passe mobs explicitamente. Broadcasts de combate/skill usam `src`, nunca `usr`.
- **Chat:** todo send novo usa `to_chat()` (ou o par `output` + `chatcast`) — `output(...,"Chatpane.Chat")` sozinho é **invisível** (o painel nativo morreu com a skin HTML).
- **Loops de NPC** precisam de `&& loc` no `while` — um mob soft-deletado (`loc = null` + `deleteMe`) preso numa referência viva **nunca é coletado** e vira lag progressivo. `mobDeath()` desliga a IA antes de deletar.
- **Nunca pré-setar `target`** antes de `foundTarget()` — o guard `!target` faz o proc retornar sem ligar a IA (NPC estátua).
- **`null == 0` é FALSO** em DM (use `!var`); **`try`** é palavra reservada (try/catch); **`\:` não é escape válido** em string; `for(var/i, i<=n, i++)` sem inicializar lê `list[null]`.
- **`new A` onde A é instância** falha ("new() called with an object") — use `new A.type`. `for(X in L)` com var pré-declarada **não filtra tipo**.
- **`file("nome.dmi")` em runtime** resolve caminho literal do disco — `FILE_DIR` é só em compile-time. Preview de ícone em runtime = literal compilado ou caminho real (`flist`).
- **`browser` + HTML/JS:** use `<meta http-equiv="X-UA-Compatible" content="IE=edge">`; dentro de string `{"..."}`, `[expr]` é embedding — em JS escreva `lista.item(i)`. URLs `byond://` estouram em ~2083 chars (formulários grandes precisam de cap).
- **`\icon[mob]` num navegador** mostra a sprite-sheet inteira — monte mensagens do chat HTML sem `\icon`.
- **DLLs via `call_ext`**: a DLL precisa ter **a mesma bitness do `dd.exe` (32-bit!)**, ABI string-in/string-out, e roda síncrona (DLL lenta congela o mundo). Fallback em DM sempre.
- **BYOND 516** reservou `caller`/`callee`/`sign`/`run` — não use como identificadores.
- **Savefiles:** nunca serializar datums com referências vivas (área/obj/mob) — codifique flat. Um caminho de save vazio grava "buffer ." e corrompe.

---

## 🤝 Contribuindo

1. Crie uma branch a partir de `main`.
2. Edite os `.dm` no módulo apropriado em `Code/Modules/`.
3. **Compile com `compilar.bat` e garanta `0 errors`** (e teste em jogo / DreamDaemon).
4. Abra um Pull Request descrevendo a mudança.

Mantenha o estilo do código vizinho (tabs, nomes, comentários em português sem acentos, números ajustáveis em blocos de config no topo dos arquivos). **Código substituído se deleta** — nada de `*_legacy_unused`. Mudanças de mecânica devem refletir-se no Guia de Mecânicas quando relevante.

---

## 📜 Créditos e aviso legal

- Projeto-fork/continuação de um jogo Dragon Ball da plataforma **BYOND** (créditos aos autores originais da base).
- **Dragon Ball** é propriedade de **Akira Toriyama / Bird Studio / Toei Animation / Shueisha**. Este é um **projeto de fã, sem fins lucrativos**, feito por amor à franquia — sem afiliação oficial.
- Bibliotecas de terceiros em `lib/` pertencem aos seus respectivos autores.

> _Defina uma licença (ex.: arquivo `LICENSE`) caso pretenda abrir o código formalmente. Sem licença explícita, todos os direitos são reservados ao autor do repositório._

---

<div align="center">

**Que comece o verdadeiro torneio. 🥋🔥**

</div>
