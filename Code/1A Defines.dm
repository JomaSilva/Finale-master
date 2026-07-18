//
#define BPTick 0.000056 //TAXA GLOBAL de ganho de BP. 
#define DNL_BIO_LARVA_RESTRICT 100 //LARVA de bio-androide expressa no maximo 1/isto do BP base (100 = 1%, estilo zeni-revive-debuff x0.01). Mora AQUI pois base.dm (teto duro no powerlevel) e DNALabs.dm usam -- e o DreamMaker re-ordena includes.
#define DAY_REAL_MINUTES 20 //quantos minutos REAIS dura 1 dia in-game (relogio em WorldClock.dm; a Sala do Tempo em TimeChamber.dm depende disto -- mora AQUI pq o DreamMaker re-ordena os includes alfabeticamente e defines sao sensiveis a ordem)
//---- ESMAGAMENTO POR GRAVIDADE (acima da maestria; Gravity.dm + movement handler.dm) ----
#define GRAVCRUSH_SLOW      1    //peso do slow multiplicativo no andar: 2x da maestria ~ metade da velocidade, 4x ~ 1/4, 10x ~ 1/10
#define GRAVCRUSH_DMG_BASE  0.5  //dano/seg (SpreadDamage em TODOS os membros) escalando QUADRATICO com o excesso (estilo Kaioken alto)
#define GRAVCRUSH_DMG_CAP   3    //teto de dano/seg: esmagado desmaia rapido mas morre DEVAGAR (da tempo de alguem resgatar)
#define GRAVCRUSH_EXPLODE_R 4    //razao gravidade/maestria a partir da qual o corpo em farrapos EXPLODE (gib, estilo Kaioken x100)
#define GRAVCRUSH_WARN_CD   100  //ticks (10s) entre avisos de esmagamento no chat
#define PSPACE_HOME_Z 26 //z do espaco original (setor 0,0) -- compartilhado: ProceduralSpace.dm + PlanetTech.dm (Launch de planeta destruido)
//---- WEIGHTED CLOTHING x GRAVIDADE (Stats.dm calcula weight_ratio; Gravity.dm esmaga; movement handler freia) ----
#define WEIGHT_GAIN_MAX 8       //teto do multiplicador de ganhos do peso (razao 1 = 2x, razao 2 = 4x, razao 4 = 8x)
#define WEIGHT_ITEM_CAP_MULT 2  //teto do UPGRADE dos pesos = weight_cap_hw x isto (2x o limite do corpo = razao 2.0 = ganhos 4x no maximo)
#define TECH_BENCH_ZENI 250000  //custo em zenni da Research Bench construida pela aba Tech (HtmlUI.dm)
//---- FROST DEMON REWORK (IcerTransform.dm + icer.dm + ascensioncontrols.dm + base.dm -- defines AQUI pela ordem de include) ----
#define FD_FORM6_MULT 10          //1a evolucao (forma 6)
#define FD_FORM7_MULT 20          //evolucao final (forma 7): x FD_ASC_CAP = 56x (paridade com o topo das outras racas)
#define FD_GOLDEN_MULT 28         //Golden Form (skill separada, acima da evolucao final)
#define FD_ASC_CAP 2.8            //teto da Ascensao dos Frost Demons (as formas fazem o grosso agora)
#define FD_FORM6_AT 250000000     //1a evolucao = tier do Golden do Freeza: BP base equivalente ao SSJ God/Blue (godki_at, godkiattain.dm)
#define FD_FORM7_AT 15000000000   //FORMA BLACK: bem alem do Golden, na casa dos 10/20 bilhoes (mesma faixa do SSJ4 pos-rework)
#define FD_MASTERY_PER_MIN 2      //MUTANTE: pontos de maestria da base por minuto em forma 5+ (100% = ~50min)
#define FD_LOSS_SECS_F5 90        //segundos ate PERDER o controle do ki na forma base sem maestria (fd_form_losstime escala as outras; maestria alonga)
#define FD_RELEASE_DECAY_PCT 1.2  //% de liberacao de BP perdida por segundo com o ki descontrolado
#define FD_RELEASE_FLOOR 0.10     //piso da liberacao (fica com 10% do poder)
#define FD_RELEASE_RECOVER_PCT 4  //% de liberacao recuperada por segundo em forma ESTAVEL
#define FD_REGEN_PCT 0.2          //maestria 100: % do MaxKi por segundo POR grau de supressao (forma 1 = 4 graus = 0.8%/s)
#define LSSJ_RAMP_TICKS 600       //Form Rising dos Legendary: ciclos de GlobalStats (~0.3s) com a TAG de combate ate o multiplicador chegar no teto da forma (600 = ~3min; compartilhado Stats.dm + lssjbuff.dm)
#define GOD_HAKAI_REVIVE_MULT 2   //vitima de Hakai paga o revive do Enma x isto (compartilhado: GodOfDestruction.dm + SkyNPCs.dm -- ordem de include)
//---- PATHS DO GOD OF DESTRUCTION (compartilhado: GodOfDestruction.dm + UltraEgo.dm -- ordem de include) ----
#define GOD_PATH_BOOST 0.25       //GoD que trilha a DESTRUICAO: todos os beneficios do Power of Destruction x (1 + isto)
#define GOD_PATH_BORROW 0.25      //GoD que trilha o INSTINTO: ganha o kit da destruicao (sem formas) a esta eficiencia, movido pela precisao do UI
//---- MAESTRIA DE GOD KI (rework 2026-07-18: os TIERS morreram -- a progressao divina e uma maestria 0-100% MUITO lenta)
//---- (compartilhado: godki.dm/godkiattain.dm [Stats/Godki] + supersaiyan.dm/kaioken.dm/UltraInstinct.dm/UltraEgo.dm [Skills] + RankQuests.dm [Ranks] -- ordem de include) ----
#define GODKI_MASTERY_TICK 0.00052   //ganho de maestria por ciclo de GlobalStats (~0.3s) com God Ki LIGADO: 100 / (16h x 3600s / 0.3) -> ~16 HORAS de uso pra 100%
#define GODKI_MASTERY_COMBAT_MULT 2  //em combate (combatTag) o ganho dobra (~8h de luta divina)
#define GODKI_BLUE_PCT 33            //maestria pro SSJ Blue (e pro Mistico 32x do Prodigial; antigo tier 2)
#define GODKI_ROYALE_PCT 50          //maestria pro Super Saiyan Royale (USSJ Blue, SO Elite/Kaio), pro Kaioken-no-Blue (Normal/Low-Class) e pro Beast do Prodigial (antigo tier 3)
#define GODKI_UIUE_LEARN_PCT 70      //maestria minima pra APRENDER Ultra Instinct ou Power of Destruction (corpo pronto pros segredos dos Anjos/Deuses)
#define GODKI_KAIDEMON_START_PCT 33  //sangue divino (Kai/Demon) ja desperta com esta maestria (espelho do antigo tier 2 inicial)
#define GODKI_KAIOKEN_CAP 20         //teto do Kaioken empilhado no Blue (Normal/Low-Class com maestria 50%+)
#define GODKI_POINTS_PER_MILESTONE 37 //pontos de especializacao de God Ki ganhos a cada marco de maestria (33/50/70/100 -- paridade com os 37/tier antigos)
#define GODKI_ENERGY_BASE 100        //pool de energia divina na maestria 0
#define GODKI_ENERGY_PER_PCT 3       //pool extra por 1% de maestria (100% -> 100+300 = 400, paridade com o antigo tier 4)
//---- REPUTACAO PLANETARIA (limiares compartilhados: PlanetConquest.dm + PlanetReputation.dm -- ordem de include) ----
#define REP_VILLAIN -30 //daqui pra baixo o povo fofoca/alerta sobre o player -- e um dono nesta faixa e TIRANO (tomar o planeta dele = libertacao)
#define REP_HERO     50 //daqui pra cima o povo fofoca sobre o heroi -- e aceita a reivindicacao PACIFICA do planeta
#define DOESEXIST if(isnull(src)) return
#define CLIENTEXIST if(isnull(client)) return
#define CHECK_TICK if(world.tick_usage > 75) lagstopsleep()
#define MAX_AGGRO_RANGE 20
//
//For Buffs.dm
#define sNULL 0
#define sBUFF 1
#define sAURA 2
#define sFORM 3
//
//
#define nil null
//
//Movement Handler
#define AREYALOGGINOUT if(LoggingOut) return

//more advanced lagbutton
proc
	lagstopsleep()
		var/tickstosleep = 1
		do
			sleep(world.tick_lag*tickstosleep)
			tickstosleep *= 2 //increase the amount we sleep each time since sleeps are expensive (5-15 proc calls)
		while(world.tick_usage > 70 && (tickstosleep*world.tick_lag) < 32) //stop if we get to the point where we sleep for seconds at a time

#define MIDNIGHT_ROLLOVER		864000	//number of deciseconds in a day

//Select holiday names -- If you test for a holiday in the code, make the holiday's name a define and test for that instead
#define NEW_YEAR				"New Year"
#define VALENTINES				"Valentine's Day"
#define APRIL_FOOLS				"April Fool's Day"
#define EASTER					"Easter"
#define HALLOWEEN				"Halloween"
#define CHRISTMAS				"Christmas"
#define FRIDAY_13TH				"Friday the 13th"


//some arbitrary defines to be used by self-pruning global lists. (see master_controller)
#define PROCESS_KILL 26	//Used to trigger removal from a processing list

#define MANIFEST_ERROR_NAME		1
#define MANIFEST_ERROR_COUNT	2
#define MANIFEST_ERROR_ITEM		4

#define TRANSITIONEDGE			7 //Distance from edge to move to another z-level

//Sizes of mobs, used by mob/living/var/mob_size
#define MOB_SIZE_SMALL 1
#define MOB_SIZE_HUMAN 2
#define MOB_SIZE_LARGE 3
//Could be useful for giant form, but I can't think of anything it'd interact with other than maybe grabs.


//ticker.current_state values
#define GAME_STATE_STARTUP		0
#define GAME_STATE_PREGAME		1
#define GAME_STATE_SETTING_UP	2
#define GAME_STATE_PLAYING		3
#define GAME_STATE_FINISHED		4

//FONTS:
// Used by Paper and PhotoCopier (and PaperBin once a year).
// Used by PDA's Notekeeper.
// Used by NewsCaster and NewsPaper.
#define PEN_FONT "Verdana"
#define CRAYON_FONT "Comic Sans MS"
#define SIGNFONT "Times New Roman"

//things that are funny
#define SLIPPERY_TURF_WATER 1
#define SLIPPERY_TURF_LUBE 2
#define SLIPPERY_TURF_BLUBE 3

//take your time
#define SECONDS * 10
#define MINUTES * 600
#define HOURS   * 36000
//maths
#define floor(x) round(x)
#define ceil(x) (-round(-(x)))
//subtypesof(), typesof() without the parent path
#define subtypesof(typepath) ( typesof(typepath) - typepath )

//testing stuff for VS code
obj/var/canGrab = 1