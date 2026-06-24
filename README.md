<div align="center">

# 🐉 DragonBall Jandirus

**MMORPG de ação Dragon Ball feito em [BYOND](https://www.byond.com/) (DreamMaker).**
Crie seu guerreiro, escolha entre dezenas de raças, evolua o seu Battle Power, domine transformações lendárias e lute em tempo real com outros jogadores.

![BYOND](https://img.shields.io/badge/engine-BYOND%20516-blue)
![Linguagem](https://img.shields.io/badge/linguagem-DreamMaker%20(DM)-orange)
![Arquivos](https://img.shields.io/badge/c%C3%B3digo-475%20.dm%20%7C%20~86k%20linhas-success)
![Status](https://img.shields.io/badge/status-em%20desenvolvimento-yellow)

</div>

---

## 📖 Sobre

DragonBall Jandirus é um jogo multiplayer top-down (estilo MMORPG) baseado no universo Dragon Ball, escrito na linguagem **DM (DreamMaker)** da plataforma BYOND. Todo o progresso do jogador — atributos, transformações, habilidades, idade, ranks — é simulado a partir de sistemas reais no código (genética/raças, Battle Power, buffs de transformação, combate por zonas do corpo, Ki, árvores de habilidade etc.).

> 📘 **Guia de Mecânicas:** o arquivo [`Dragonball Jandirus - Guia de Mecanicas.pdf`](./Dragonball%20Jandirus%20-%20Guia%20de%20Mecanicas.pdf) (79 páginas, gerado a partir do código atual) explica em detalhe **como jogar** — criação, raças, BP, combate, Ki, transformações, skills e progressão. Este README foca na **documentação do código**.

---

## 🗂️ Índice

- [Destaques](#-destaques)
- [Como rodar](#-como-rodar)
- [Compilando do código-fonte](#-compilando-do-código-fonte)
- [Estrutura do projeto](#-estrutura-do-projeto)
- [Arquitetura do código](#-arquitetura-do-código)
- [Convenções e armadilhas do DreamMaker](#-convenções-e-armadilhas-do-dreammaker)
- [Contribuindo](#-contribuindo)
- [Créditos e aviso legal](#-créditos-e-aviso-legal)

---

## ✨ Destaques

- **20+ raças jogáveis** (Saiyajin, Namekuseijin, Frost Demon, Majin, Bio-Android, Heran, Kai, Demigod, Gray, Alien personalizável…), cada uma com multiplicadores de atributo, BP inicial, regeneração e transformações próprias.
- **Sistema de genética** — raças e classes são `/datum/genetics` que semeiam os atributos do mob; herança por reprodução (Half/Quarter-Saiyajin, ovos, criadores).
- **Battle Power individual** com teto pessoal (sem média de servidor), suavizado para o combate.
- **Transformações** completas: linha Super Saiyajin (SSJ1 → USSJ → SSJ2 → SSJ3 → SSJ4), Lendário + Wrathful, Oozaru, **God Ki / Formas Divinas** (Blue/Rosé/Evolved) e formas próprias de cada raça.
- **Combate em tempo real** com golpes leve/pesado, barragens, bloqueio, esquiva, stamina, **mira por zonas do corpo**, saúde de membros (até decepamento), KO/coma e finalização.
- **Ki & energia**: beams contínuos, blasts/projéteis, discos, kiai, sense, voo — com custo de Ki baseado em fórmulas de drain.
- **Árvores de habilidade** (Core, avançadas e raciais) com pontos, tiers e ensino entre jogadores.
- **Progressão de mundo**: calendário/idade, ranks, morte, Outro Mundo (Céu/Inferno), ressurreição e reencarnação.
- **Economia e crafting**: Zenni, banco, lojas, equipamento, profissões, alquimia.

---

## ▶️ Como rodar

### Requisitos
- **BYOND** instalado (versão **516** ou compatível) — inclui DreamSeeker (cliente) e DreamMaker (IDE/compilador).

### Jogar (single-player / hospedar)
1. Compile o projeto (veja abaixo) para gerar **`Dragonball Jandirus.dmb`**.
2. Dê duplo-clique no `.dmb` (abre o **DreamSeeker**) ou rode pela IDE com **Run**.
3. Para hospedar em rede, use o **DreamDaemon** apontando para o `.dmb`. O jogo se anuncia no hub `Kingzombiethe1st.DragonballJandirus` (configurável em [`Code/Modules/Globals/World.dm`](./Code/Modules/Globals/World.dm)).

---

## 🛠️ Compilando do código-fonte

O projeto é definido por **`Dragonball Jandirus.dme`** (472 `#include`s + o bloco `FILE_DIR` que registra as pastas de recursos).

**Opção A — linha de comando (recomendada):** dê duplo-clique em **[`compilar.bat`](./compilar.bat)**, que chama o compilador diretamente:

```bat
"E:\BYOND\bin\dm.exe" "Dragonball Jandirus.dme"
```

Exija **`0 errors`** no fim. (Os 2 warnings de variável não usada são inofensivos.)

**Opção B — IDE:** abra `Dragonball Jandirus.dme` no **DreamMaker** e use **Build → Compile**.

> ⚠️ **Importante:** prefira o `compilar.bat`. A IDE do DreamMaker tende a **reescrever o bloco `FILE_DIR`** ao salvar, reduzindo-o a `#define FILE_DIR .` e quebrando a busca de todos os recursos em subpastas (ícones/sons). Veja [Convenções e armadilhas](#-convenções-e-armadilhas-do-dreammaker).

---

## 📁 Estrutura do projeto

```
Dragonball Jandirus.dme      # Projeto BYOND (#includes + FILE_DIR)
skin.dmf                     # Interface/skin (janelas, HUD, menus)
compilar.bat                 # Compila via dm.exe (não mexe no FILE_DIR)
Dragonball Jandirus - Guia de Mecanicas.pdf

Code/Modules/                # TODO o código-fonte (.dm), por sistema:
├─ Globals/                  # world/New, variáveis globais, World.dm (nome/hub/status)
├─ Login/                    # Lobby, criação de personagem, OnLogin/OnLogout, save
├─ Races/                    # Raças e genética
│  ├─ Genetics/              # /datum/genetics (genoma), build_stats, protótipos
│  ├─ RaceStats/             # 1 arquivo por raça (multiplicadores, BP, classes)
│  └─ Transformation_Datum/
├─ Stats/                    # Atributos e poder
│  ├─ Level/                 # master.dm — fórmulas de BP/MaxKi
│  ├─ BP/                    # base.dm, Power Control, Revert
│  ├─ Godki/                 # godki.dm — Ki Divino / Formas Divinas
│  ├─ Training/              # treino, gravidade, zenkai
│  └─ mobparts.dm / mobvars.dm / Ki.dm
├─ Skills/                   # Habilidades
│  ├─ Buffs/                 # /obj/buff (transformações e estados) → racial/
│  ├─ Skill Trees/           # /datum/skill/tree (árvores Core/avançadas/raciais)
│  ├─ Ki/                    # beams, blasts, sense, flight
│  ├─ CustomAttacks/         # projéteis/golpes customizados
│  └─ Masteries/ Physical/ Misc/
├─ CombatMechanics/          # Combate corpo a corpo
│  ├─ attacking/             # golpes, barragens, dash
│  ├─ combat_effects/        # crateras, knockback, etc.
│  ├─ calcs.dm KO.dm Injuries.dm Murder.dm  Damage Types.dm  LimbHPIndicator.dm
│  └─ Styles/
├─ Character Customization/  # Aparência e overlays
│  ├─ Races/                 # SaiyanObjects.dm (cabelo/cauda SSJ), Tails.dm
│  ├─ HairObject.dm          # sistema de cabelo via vis_contents (AddHair)
│  ├─ OverlayMobHandlers.dm  # updateOverlay/removeOverlay
│  └─ body_custom.dm changeicon.dm CharacterCreation.dm
├─ Godki/  Magic/  Crafting/  Equipment/  Tech/  Ranks/
├─ NPCs/  Dungeons/  Death/  Movement Improvement/  Stamina/
├─ Sound/  Turfs/  User Interface/  Admin/  Players/  Procs/  DLC/

Icons/        # 1853 .dmi (sprites de mobs, formas, efeitos, UI, mapas)
Sounds/       # efeitos e músicas (Sounds/Music)
Maps/         # 1to26.dmm, 2728.dmm, 2930.dmm, 3141.dmm (z-levels) + dungeons/
lib/          # bibliotecas de terceiros (ex.: dmm_suite, interface edit)
Save/         # saves dos jogadores (ignorado no git)
cfg/          # configuração do servidor (admin, etc.)
```

---

## 🏗️ Arquitetura do código

Visão de alto nível de como os sistemas se conectam. Tudo gira em torno do **mob do jogador** e de uma malha de *datums* e *buffs* que modificam seus atributos.

### 1. Entrada e ciclo de vida
- **`Globals/World.dm`** define `world.name = "Dragonball Jandirus"`, fps, view e o hub.
- **`Login/Lobby.dm`** → `loginProc()` decide entre **`New_Character()`** (criação) e **`OnLogin()`** (carregar save existente).
- **`Login/Login.dm`** contém `OnLogin()` / `OnLogout()` / `DoLogoutStuff()`. O login restaura body parts, skills, árvores, equipamento, God Ki e **re-cria os buffs de transformação persistentes** (para o jogador não voltar "careca"/sem forma).
- **Saves** são arquivos numa pasta **`Save/`** fixa (não dependem do nome do `.dmb`), por isso renomear o build é seguro.

### 2. Genética & Raças
- Cada raça/classe é um **`/datum/genetics`**. Os protótipos vivem em `original_genome_list`; `racial_protos` aponta para o genoma da raça.
- `build_stats()` / `apply_stats()` semeiam os multiplicadores no mob; `class_stats` / `Class_Spread` aplicam a classe sorteada/escolhida; `assign_starting_BP()` define o BP inicial.
- Os números por raça ficam em **`Races/RaceStats/<raça>.dm`** (ex.: `statsaiyan.dm`). Ao nascer, `PlanetGravity()` já aclimata o personagem à gravidade do planeta natal.

### 3. Stats, Ki & Battle Power
- **`Stats/Level/master.dm`** recalcula a cada tick: `MaxKi = baseKi * KiMod * kiAmp * trueKiMod * … * TMaxKi`. **MaxKi não é guardado** — deriva de `trueKiMod` (multiplicador da forma atual).
- **`Stats/BP/base.dm`** calcula o BP "expresso" e o teto pessoal `relBPmax = BP * (1 + UPMod) * relcaprate * BPMod` (**individual**, a média de servidor foi removida da progressão).
- `Power Control.dm` (esconder poder) e `Revert.dm` (reverter formas) ajustam `trueKiMod`/`ssjBuff` — e preservam a **proporção de Ki** ao trocar de forma.

### 4. Transformações & Buffs
- Estados e formas são **`/obj/buff`** com `Buff()` (entrada), `Loop()` (a cada tick) e `DeBuff()` (saída), registrados em `bufflist` via `startbuff()` / `stopbuff()` / `clearbuffs()`.
- **`Skills/Buffs/racial/supersaiyanbuff.dm`** controla a linha Saiyajin: a variável `ssj`, os multiplicadores `ssjmult`/`ssj2mult`/… (poder) e `ssjenergymod`/… (Ki). O bloco *form-change* do `Loop()` aplica cabelo, overlays e stats quando a forma muda.
- Outros buffs raciais: `lssjbuff.dm` (Lendário/Wrathful), `CellFormBuff.dm`, `Super_Namek.dm`, `HeranBuff.dm`, `Alien_Transformations.dm`, `Oozaru.dm`.
- **`Stats/Godki/godki.dm`** adiciona o **Ki Divino** (tiers, `god_form_mult`, cap de SSJ) que, combinado com SSJ, gera as Formas Divinas (Blue/Rosé/Evolved).

### 5. Aparência & Overlays
- Sprites compostos usam **`vis_contents`** com `/obj/overlay` (não a lista `overlays` clássica).
- **`Character Customization/OverlayMobHandlers.dm`** expõe `updateOverlay()` / `removeOverlay()`; cada overlay tem `EffectStart()` (monta o ícone) e `EffectLoop()` (atualiza por tick).
- **`HairObject.dm`** (`AddHair`/`RemoveHair`) e **`Races/SaiyanObjects.dm`** desenham cabelo e cauda; cores de SSJ/Blue/Rosé são *tints* aplicados no `EffectStart`. Membros do corpo (incl. cauda Saiyajin) são **`/datum/Body`** em `Stats/mobparts.dm`.

### 6. Combate
- **`CombatMechanics/`**: golpes em `attacking/`, cálculos em `calcs.dm`, lesões/decepamento em `Injuries.dm`, nocaute em `KO.dm`, finalização em `Murder.dm`.
- A **saúde dos membros** (de "Saudável" a "Quebrado") e a **mira por zona** vêm de `Stats/mobparts.dm` + `CombatMechanics/LimbHPIndicator.dm`. HP e Ki são **privados** (sem barra sobre a cabeça); leitura de vida alheia só via **Sense**.

### 7. Habilidades
- **`Skills/Skill Trees/`** define **`/datum/skill/tree`** (Core, avançadas e raciais), com tiers, custo e pré-requisitos. O mob guarda `learned_skills`, `allowed_trees` e `possessed_trees`; skills podem ser **ensinadas** a quem está por perto.

---

## ⚙️ Convenções e armadilhas do DreamMaker

Pontos não-óbvios aprendidos no projeto (úteis ao contribuir):

- **`FILE_DIR` (recursos):** o bloco `// BEGIN_FILE_DIR … // END_FILE_DIR` no `.dme` registra **toda** pasta com recursos. A **IDE do DreamMaker pode resetá-lo** ao salvar, quebrando ícones/sons. Compile pelo **`compilar.bat`** (não toca no bloco) ou reconstrua o bloco varrendo a árvore por `.dmi/.png/.ogg/.wav/.mp3/...`.
- **Cache `.rsc` travado:** enquanto o jogo (DreamSeeker/DreamDaemon) está aberto, ele **trava** `Dragonball Jandirus.rsc`, e o compilador não consegue importar recursos novos ("cannot find file"). Feche o jogo e recompile.
- **"Compilou mas nada mudou":** a IDE roda o **último `.dmb` válido** se a compilação falhar. Sempre confirme **`0 errors`** antes de concluir que um fix não funcionou.
- **`in` não faz substring** em texto: `"Tail" in "Saiyan Tail"` é **falso** — use `findtext()`.
- **Re-declarar uma lista com o prefixo `list/`** (ex.: `list/class_stats = list(...)`) **não** sobrescreve o default herdado; omita o `list/`.
- **`for(var/datum/X in args)`** descarta argumentos que são *paths* (o filtro de tipo exclui paths).
- **`usr` é nulo** em contextos de engine (login, saves) — não dependa dele fora de verbos.
- **BYOND 516** reservou palavras como `caller`/`callee`/`sign`; evite usá-las como identificadores.

---

## 🤝 Contribuindo

1. Crie uma branch a partir de `main`.
2. Edite os `.dm` no módulo apropriado em `Code/Modules/`.
3. **Compile com `compilar.bat` e garanta `0 errors`** (e teste em jogo / DreamDaemon).
4. Abra um Pull Request descrevendo a mudança.

Mantenha o estilo do código vizinho (tabs, nomes, densidade de comentários). Mudanças de mecânica devem refletir-se também no Guia de Mecânicas quando relevante.

---

## 📜 Créditos e aviso legal

- Projeto-fork/continuação de um jogo Dragon Ball da plataforma **BYOND** (créditos aos autores originais da base).
- **Dragon Ball** é propriedade de **Akira Toriyama / Bird Studio / Toei Animation / Shueisha**. Este é um **projeto de fã, sem fins lucrativos**, feito por amor à franquia — sem qualquer afiliação oficial.
- Bibliotecas de terceiros em `lib/` pertencem aos seus respectivos autores.

> _Defina uma licença (ex.: um arquivo `LICENSE`) caso pretenda abrir o código formalmente. Por padrão, sem licença explícita, todos os direitos são reservados ao autor do repositório._

---

<div align="center">

**Que comece o verdadeiro torneio. 🥋🔥**

</div>
