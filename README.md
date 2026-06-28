<div align="center">

# 🐉 DragonBall Jandirus

**MMORPG de ação Dragon Ball feito em [BYOND](https://www.byond.com/) (DreamMaker).**
Crie seu guerreiro, escolha entre dezenas de raças, evolua seu Battle Power, domine transformações lendárias e lute em tempo real com outros jogadores — tudo numa interface moderna em HTML/CSS embutida no cliente.

![BYOND](https://img.shields.io/badge/engine-BYOND%20516-blue)
![Linguagem](https://img.shields.io/badge/linguagem-DreamMaker%20(DM)-orange)
![Código](https://img.shields.io/badge/c%C3%B3digo-483%20.dm%20%7C%20~90k%20linhas-success)
![UI](https://img.shields.io/badge/UI-HTML%2FCSS%20embutido-9cf)
![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)

</div>

---

## 📖 Sobre

DragonBall Jandirus é um jogo multiplayer top-down (estilo MMORPG) baseado no universo Dragon Ball, escrito em **DM (DreamMaker)** da plataforma BYOND. Todo o progresso do jogador — atributos, transformações, habilidades, idade, ranks — é simulado por sistemas reais no código (genética/raças, Battle Power, buffs de transformação, combate por zonas do corpo, Ki, árvores de habilidade etc.).

A interface do jogador (painel de status, HUD, árvores de skill, chat, inventário) é renderizada em **HTML/CSS dentro de controles `browser` do BYOND**, dando um visual limpo e moderno por cima da engine.

> 📘 **Guia de Mecânicas:** o arquivo [`Dragonball Jandirus - Guia de Mecanicas.pdf`](./Dragonball%20Jandirus%20-%20Guia%20de%20Mecanicas.pdf) (gerado a partir do código) explica **como jogar** — criação, raças, BP, combate, Ki, transformações, skills e progressão. Este README foca na **documentação do código**.

---

## 🗂️ Índice

- [Destaques](#-destaques)
- [Como rodar](#-como-rodar)
- [Compilando do código-fonte](#-compilando-do-código-fonte)
- [Estrutura do projeto](#-estrutura-do-projeto)
- [Arquitetura do código](#-arquitetura-do-código)
  - [Interface (HTML/CSS embutido)](#8-interface-htmlcss-embutido)
- [Sistemas de destaque](#-sistemas-de-destaque)
- [Convenções e armadilhas do DreamMaker](#-convenções-e-armadilhas-do-dreammaker)
- [Contribuindo](#-contribuindo)
- [Créditos e aviso legal](#-créditos-e-aviso-legal)

---

## ✨ Destaques

- **20+ raças jogáveis** (Saiyajin + Primal, Namekuseijin, Frost Demon, **Majin / Corrupted Majin**, Bio-Android, Heran, Kai, **Demônio**, Demigod, Gray, Alien personalizável…), cada uma com multiplicadores próprios, BP inicial, regeneração e transformações.
- **Sistema de genética** — raças/classes são `/datum/genetics` que semeiam os atributos do mob; classes sorteadas por raridade (`Class_Spread`); herança por reprodução.
- **Battle Power individual** com teto pessoal (sem média de servidor) e **retornos decrescentes** no topo (bilhões+) pra domar o crescimento exponencial.
- **Transformações** completas: linha Super Saiyajin (SSJ1 → USSJ → SSJ2 → SSJ3 → SSJ4 e mestria por estágios), **Lendário** + Wrathful, Oozaru, **God Ki / Formas Divinas** (Blue/Rosé/Evolved) e formas próprias de cada raça — gatadas pelo **BP base** (não pelo BP inflado).
- **Saga do Majin** — absorção que manda a vítima pra uma **dimensão de bolso** (viva), dá 10% do BP + skills + roupas dela ao Majin; cadeia de 4 formas do Corrupted Majin + **Pure Form**.
- **Combate em tempo real** com golpes leve/pesado, barragens, bloqueio, esquiva, stamina, **mira por zonas do corpo**, saúde de membros (até decepamento), KO/coma, finalização e **Zenkai** ao ser derrotado por alguém mais forte.
- **Ki & energia**: beams contínuos, blasts/projéteis, discos, kiai, sense, voo — com custo de Ki por fórmulas de drain.
- **Árvores de habilidade** (Core, avançadas e raciais) com pontos, tiers e ensino entre jogadores.
- **Mundo vivo**: calendário/idade, ranks, morte, Outro Mundo (Céu/Inferno), ressurreição, **cidade de Vegeta** procedural, **naves capitais** construíveis (com interior próprio), gravidade treinável e **trilha sonora de batalha** dinâmica.
- **Economia e crafting**: Zenni, banco, lojas, equipamento, profissões, alquimia.

---

## ▶️ Como rodar

### Requisitos
- **BYOND** instalado (versão **516** ou compatível) — inclui DreamSeeker (cliente) e DreamMaker (IDE/compilador).

### Jogar (single-player / hospedar)
1. Compile o projeto (veja abaixo) para gerar **`Dragonball Jandirus.dmb`**.
2. Dê duplo-clique no `.dmb` (abre o **DreamSeeker**) ou rode pela IDE com **Run**.
3. Para hospedar em rede, use o **DreamDaemon** apontando para o `.dmb`. O nome/hub/status do mundo ficam em [`Code/Modules/Globals/World.dm`](./Code/Modules/Globals/World.dm).

---

## 🛠️ Compilando do código-fonte

O projeto é definido por **`Dragonball Jandirus.dme`** (480 `#include`s + o bloco `FILE_DIR` que registra as pastas de recursos).

**Opção A — linha de comando (recomendada):** dê duplo-clique em **[`compilar.bat`](./compilar.bat)**, ou chame o compilador direto:

```bat
"E:\BYOND\bin\dm.exe" "Dragonball Jandirus.dme"
```

Exija **`0 errors`** no fim. (Há **1 warning** inofensivo — uma variável não usada no HUD.)

**Opção B — IDE:** abra `Dragonball Jandirus.dme` no **DreamMaker** e use **Build → Compile**.

> ⚠️ **Importante:** prefira o `compilar.bat`. A IDE do DreamMaker tende a **reescrever o bloco `FILE_DIR`** ao salvar, reduzindo-o a `#define FILE_DIR .` e quebrando a busca de todos os recursos em subpastas (ícones/sons). Veja [Convenções e armadilhas](#-convenções-e-armadilhas-do-dreammaker).

---

## 📁 Estrutura do projeto

```
Dragonball Jandirus.dme      # Projeto BYOND (480 #includes + FILE_DIR)
skin.dmf                     # Skin: janelas + controles BROWSER que hospedam a UI HTML
compilar.bat                 # Compila via dm.exe (não mexe no FILE_DIR)
Dragonball Jandirus - Guia de Mecanicas.pdf

Code/Modules/                # TODO o código-fonte (.dm), por sistema:
├─ Globals/                  # World.dm (nome/hub/status), VegetaCity.dm (cidade procedural), vars globais
├─ Login/                    # Lobby, criação de personagem, OnLogin/OnLogout, save
├─ Races/                    # Raças e genética
│  ├─ Genetics/              # /datum/genetics (genoma), build_stats, protótipos, decide_Class
│  ├─ RaceStats/             # 1 arquivo por raça (multiplicadores, BP, Class_Spread)
│  └─ Transformation_Datum/
├─ Stats/                    # Atributos e poder
│  ├─ Level/master.dm        # fórmulas de BP/MaxKi por tick
│  ├─ BP/                    # base.dm (BP expresso + teto pessoal + softcap), Gravity.dm, softcap.dm
│  ├─ Godki/godki.dm         # Ki Divino / Formas Divinas
│  ├─ Training/              # treino, gravidade, zenkai
│  └─ mobparts.dm / mobvars.dm
├─ Skills/                   # Habilidades
│  ├─ Buffs/racial/          # /obj/buff de transformação (supersaiyanbuff, lssj, CellForm, Majin…)
│  ├─ Skill Trees/           # /datum/skill/tree (Core/avançadas/raciais) + Race Trees/
│  ├─ Ki/                    # beams, blasts, sense, flight
│  └─ CustomAttacks/ Masteries/ Physical/ Misc/
├─ CombatMechanics/          # Combate corpo a corpo
│  ├─ attacking/             # golpes, barragens, dash, combatgains.dm (zenkai)
│  ├─ combat_effects/        # crateras, knockback, lightning, dust, shockwaves
│  └─ calcs.dm KO.dm Injuries.dm Murder.dm LimbHPIndicator.dm Styles/
├─ cinematics/               # Cinemáticas de transformação (SSJ/SSJ2/SSJ3/USSJ, DemonEvolve…)
├─ Character Customization/  # Aparência: body_custom.dm, Genetic_Icons.dm, OverlayMobHandlers, HairObject
├─ Magic/                    # Absorção, Majin/MajinSaga, rituais, dragonballs, fusão
├─ User Interface/           # *** A UI em HTML/CSS *** (HtmlUI.dm, ChatUI.dm, HUD.dm, janelas)
├─ Players/                  # Talking (chat), Friendship, BattleMusic.dm, Voting
├─ Tech/                     # ShipVessel.dm (nave + interior z-level), androids, cyborgs, consumíveis
├─ Godki/  Crafting/  Equipment/  Ranks/  NPCs/  Dungeons/  Death/
├─ Movement Improvement/  Stamina/  Sound/  Turfs/ (incl. Weather)  Admin/  Procs/  DLC/

Icons/        # 1856 .dmi (sprites de mobs, formas, efeitos, UI, mapas)
Sounds/       # 250 efeitos e músicas (Sounds/Music — temas de transformação/batalha)
Maps/         # 1to26.dmm, 2728.dmm, 2930.dmm, 3141.dmm (z-levels) + dungeons/
lib/          # bibliotecas de terceiros (ex.: dmm_suite)
Save/         # saves dos jogadores (ignorado no git)
cfg/          # configuração do servidor (admin, etc.)
```

---

## 🏗️ Arquitetura do código

Visão de alto nível de como os sistemas se conectam. Tudo gira em torno do **mob do jogador** e de uma malha de *datums* e *buffs* que modificam seus atributos.

### 1. Entrada e ciclo de vida
- **`Globals/World.dm`** define `world.name`, fps, view e o hub. `world/New()` constrói coisas procedurais (ex.: a cidade de Vegeta) e carrega configs persistentes.
- **`Login/Lobby.dm`** → decide entre **`New_Character()`** (criação) e **`OnLogin()`** (carregar save).
- **`Login/Login.dm`** restaura body parts, skills, árvores, equipamento, God Ki e **re-cria buffs de transformação persistentes** no login (para o jogador não voltar "careca"/sem forma).
- **Saves** ficam numa pasta **`Save/`** fixa (independem do nome do `.dmb`), então renomear o build é seguro.

### 2. Genética & Raças
- Cada raça/classe é um **`/datum/genetics`**; protótipos vivem em `original_genome_list`. `build_stats()`/`apply_stats()` semeiam os multiplicadores no mob; `decide_Class()` sorteia a classe pelo **`Class_Spread`** (menor peso = mais rara). Números por raça em **`Races/RaceStats/<raça>.dm`**.

### 3. Stats, Ki & Battle Power
- **`Stats/Level/master.dm`** recalcula a cada tick (`MaxKi` deriva de `trueKiMod` da forma atual; **não é guardado**).
- **`Stats/BP/base.dm`** calcula o BP "expresso" e o teto pessoal `relBPmax = BP * (1 + UPMod) * relcaprate * BPMod`. O ganho de BP é proporcional ao `relBPmax`, com **retornos decrescentes** acima de `bpGainSoftcap` (`Stats/BP/softcap.dm`) pra não explodir nos bilhões.
- **Gravidade** (`Stats/BP/Gravity.dm`): treino rastreia a gravidade **absoluta** + um buff de aclimatação; ajustável no admin Balance Settings.

### 4. Transformações & Buffs
- Formas são **`/obj/buff`** com `Buff()`/`Loop()`/`DeBuff()`, via `startbuff()`/`stopbuff()`.
- **`Skills/Buffs/racial/supersaiyanbuff.dm`** controla a linha Saiyajin (`ssj`, mults por estágio, mestria 0–100%, bloco *form-change* que aplica cabelo/overlays/icones). Os **requisitos de forma usam BP base** (`BP >= limite / mult-da-forma-anterior`), imunes a buffs/rage. USSJ troca o corpo pra versão musculosa por tom de pele.
- Outros buffs raciais: `lssjbuff` (Lendário/Wrathful), `CellFormBuff`, `Super_Namek`, `HeranBuff`, `Alien_Transformations`, `Oozaru`. **`Godki/godki.dm`** soma o Ki Divino e gera as Formas Divinas.

### 5. Aparência & Overlays
- Sprites compostos usam **`vis_contents`** com `/obj/overlay`. **`OverlayMobHandlers.dm`** expõe `updateOverlay()`/`removeOverlay()`. **`HairObject.dm`** + **`Races/SaiyanObjects.dm`** desenham cabelo/cauda (cores SSJ/Blue/Rosé são *tints*). A **escolha de corpo na criação** está em `body_custom.dm Skin()` (casos por raça) — Majin/Demônio têm skins próprias + seletor de cor.

### 6. Combate
- **`CombatMechanics/`**: golpes em `attacking/`, cálculos em `calcs.dm`, lesões/decepamento em `Injuries.dm`, KO em `KO.dm`, finalização em `Murder.dm`. **Zenkai** (combatgains.dm) dispara ao ser nocauteado/morto por alguém mais forte. A saúde por membro e a mira por zona vêm de `mobparts.dm` + `LimbHPIndicator.dm` (HP/Ki são **privados**; leitura alheia só via **Sense**). **Em combate a regeneração passiva é desligada** (exceto raças de regen alta).

### 7. Habilidades
- **`Skills/Skill Trees/`** define **`/datum/skill/tree`** (Core/avançadas/raciais) com tiers, custo e pré-requisitos. O mob guarda `learned_skills`/`possessed_trees`; skills podem ser **ensinadas** a quem está por perto. Algumas skills são **verbs em objetos** carregados (ex.: SplitForm, Buu Absorb).

### 8. Interface (HTML/CSS embutido)
A UI do jogador é renderizada em **HTML/CSS dentro de controles `BROWSER`** do skin (`skin.dmf`), não nos controles nativos. Ficam em **`Code/Modules/User Interface/`**:

- **`HtmlUI.dm`** — o **painel de Status** com abas (Stats, Items, Equip, Body, Forms, Ki, People, World, Skills, Other, Learning, Admin), o **HUD embutido** (barras de HP/Ki/Stamina/BP), a **janela de árvores de skill** e a sub-janela de skills. Tema central em `UI_CSS`. Cliques voltam via `byond://?src=\ref[mob];chave=valor` → **`mob/Topic`**. As abas de verbs viram **botões clicáveis** com **barra de filtro** ao vivo; itens expõem **Equip/Drop/Destroy/Upgrade**; skills baseadas em objeto também aparecem.
- **`ChatUI.dm`** — **chat HTML com abas** (All/Say/OOC/LOOC/RP/Combat/System/Events), estilo por categoria, *append* ao vivo (`output(..., "browser:funçãoJS")`) e **buffer/replay** (mensagens enviadas antes da página carregar — como a dica de classe no spawn — são reproduzidas quando ela fica pronta).
- **`to_chat(target, msg, category)`** (ChatUI.dm) — proc central que manda **toda** mensagem pro painel nativo (fallback) **e** pro chat HTML. A maior parte dos `<<` de texto do jogo passa por aqui.
- O HUD/painel re-renderizam só quando o conteúdo muda (sem flicker). Atualizações chegam ao navegador via `src << browse(...)` (página) e `src << output(...)` (append/JS).

---

## 🌟 Sistemas de destaque

Recursos maiores que valem um mapa rápido (todos no código, todos compilam):

| Sistema | Onde | Resumo |
|---|---|---|
| **UI HTML/CSS** | `User Interface/HtmlUI.dm`, `ChatUI.dm` | Status + HUD + árvores + chat, embutidos em `browser`; roteamento por `mob/Topic`. |
| **Saga do Majin** | `Magic/MajinSaga.dm`, `Absorption.dm` | Absorção manda a vítima pra um **z-level de bolso** viva; Majin ganha 10% BP + skills + roupas. Corrupted Majin: Kai→Form1, raiva→Form2+clone, absorve clone→Form3, 3 players→Form4; **Pure Form** (18x). |
| **Demon Evolve** | `cinematics/DemonEvolve.dm` | Demônio com DemonForm1 + 1M BP libera o verb **Evolve** → cinemática lenta (raios/ondas) → forma permanente + 1M BP. |
| **Cidade de Vegeta** | `Globals/VegetaCity.dm` | Cidade construída por código no boot; prédios marcados como **indoor** (sem clima dentro). |
| **Nave capital** | `Tech/ShipVessel.dm` | Starship construível com **interior gerado em z-level próprio**, computador de bordo, pilotagem e pouso. |
| **Trilha de batalha** | `Players/BattleMusic.dm` | Playlist de batalha local que **abaixa** pra tocar temas de transformação. |
| **Cinemáticas** | `cinematics/` | Receita reutilizável: trava o jogador, dispara raios/dust/quakes/ondas e toca a música (`emit_TransformMusic`). |
| **Zenkai** | `attacking/combatgains.dm` | Boost ao ser derrotado por alguém mais forte; mensagem escala com o quanto ganhou (sem revelar número). |

---

## ⚙️ Convenções e armadilhas do DreamMaker

Pontos não-óbvios aprendidos no projeto (úteis ao contribuir):

- **`FILE_DIR` (recursos):** o bloco `// BEGIN_FILE_DIR … // END_FILE_DIR` no `.dme` registra **toda** pasta com recursos. A **IDE pode resetá-lo** ao salvar, quebrando ícones/sons. Compile pelo **`compilar.bat`** (não toca no bloco) ou reconstrua-o varrendo a árvore por `.dmi/.png/.ogg/.wav/.mp3/...`.
- **Cache `.rsc` travado:** enquanto o jogo está aberto, ele **trava** `Dragonball Jandirus.rsc` e o compilador não importa recursos novos ("cannot find file"). Feche o jogo e recompile.
- **"Compilou mas nada mudou":** a IDE roda o **último `.dmb` válido** se a compilação falhar. Sempre confirme **`0 errors`**.
- **`browser` + HTML/JS:** use `<meta http-equiv="X-UA-Compatible" content="IE=edge">` ou o flexbox quebra. Dentro de string `{"..."}` do DM, `[expr]` é **embedding** — escreva `lista.item(i)` em JS, não `lista[i]` (vira "undefined var i").
- **`\icon[mob]` num navegador** mostra a **sprite-sheet inteira** — monte as mensagens do chat **sem** `\icon` (o painel nativo OUTPUT renderiza o ícone certo; o navegador não).
- **`in` não faz substring** em texto: `"Tail" in "Saiyan Tail"` é **falso** — use `findtext()`.
- **Re-declarar lista com prefixo `list/`** **não** sobrescreve o default herdado; omita o `list/`.
- **`usr` é nulo** em contextos de engine (login, saves) — não dependa dele fora de verbos.
- **`alternate_icon_flags`** vem do **protótipo genético**, não do datum da raça — pra restringir skins por raça, trate em `body_custom.dm Skin()` (e não só em `Genetic_Icons.dm`).
- **BYOND 516** reservou `caller`/`callee`/`sign` — não use como identificadores.

---

## 🤝 Contribuindo

1. Crie uma branch a partir de `main`.
2. Edite os `.dm` no módulo apropriado em `Code/Modules/`.
3. **Compile com `compilar.bat` e garanta `0 errors`** (e teste em jogo / DreamDaemon).
4. Abra um Pull Request descrevendo a mudança.

Mantenha o estilo do código vizinho (tabs, nomes, densidade de comentários). Mudanças de mecânica devem refletir-se no Guia de Mecânicas quando relevante.

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
