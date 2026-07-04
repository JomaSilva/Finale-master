//
#define BPTick 0.0000028 //TAXA GLOBAL de ganho de BP. 2026-07-04: dividida por 10 (era 0.000028) -- o servidor estava ganhando BP rapido demais. TODOS os ganhos (soco/blast/treino/meditacao/gravidade/andar/etc) escalam por este define.
#define DNL_BIO_LARVA_RESTRICT 10 //LARVA de bio-androide expressa no maximo 1/isto do BP base (10 = 10%). Mora AQUI pois base.dm (teto duro no powerlevel) e DNALabs.dm usam -- e o DreamMaker re-ordena includes.
#define DAY_REAL_MINUTES 20 //quantos minutos REAIS dura 1 dia in-game (relogio em WorldClock.dm; a Sala do Tempo em TimeChamber.dm depende disto -- mora AQUI pq o DreamMaker re-ordena os includes alfabeticamente e defines sao sensiveis a ordem)
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