mob/var
	list/Hotkeys=list(new/obj/hotkey/tgs,\
		new/obj/hotkey/attk,\
		new/obj/hotkey/ooc,\
		new/obj/hotkey/mdt,\
		new/obj/hotkey/tran{id="Train";key="K";storeverb=list(/mob/default/verb/Train);down=1},\
		new/obj/hotkey/obw{id="Build Window";key="M";storeverb=list(/mob/verb/OpenBuildWindow);down=1},\
		new/obj/hotkey/rpl{id="Roleplay";key="N";storeverb=list(/mob/verb/Roleplay2);down=1},\
		new/obj/hotkey/fly{id="Fly";key="R";storeverb=list(/mob/keyable/verb/Fly);down=1},\
		new/obj/hotkey/swm{id="Swim";key="I";storeverb=list(/mob/verb/Swim);down=1},\
		new/obj/hotkey/grb{id="Grab";key="T";storeverb=list(/mob/verb/Grab);down=1},\
		new/obj/hotkey/dre{id="Start Draw Energy";key="C";storeverb=list(/mob/default/verb/Draw_Energy);down=1},\
		new/obj/hotkey/sde{id="Stop Draw Energy";key="C";storeverb=list(/mob/default/verb/Stop_Draw_Energy);down=0},\
		new/obj/hotkey/say{id="Say";key="V";storeverb=list(/mob/verb/Say2);down=1},\
		new/obj/hotkey/slt{id="Select Target";key="Y";storeverb=list(/mob/verb/Set_Target);down=1},\
		new/obj/hotkey/kyb{id="Keyables";key="/";storeverb=list(/mob/verb/keyables);down=1},\
		new/obj/hotkey/blk{id="Hold Block";key="Alt";storeverb=list(/mob/verb/holdblock);down=1},\
		new/obj/hotkey/dsh{id="Start Dash";key="Shift";storeverb=list(/mob/verb/SttDash);down=1},\
		new/obj/hotkey/ssh{id="Stop Dash";key="Shift";storeverb=list(/mob/verb/StopDash);down=0},\
		new/obj/hotkey/sbk{id="Stop Block";key="Alt";storeverb=list(/mob/verb/stopblock);down=0},\
		new/obj/hotkey/std{id="Dodge";key="Q";storeverb=list(/mob/verb/start_dodge);down=0})
//two methods of initializing shit: keep in mind that these have preset types to reference it. (I don't think you need preset types, as you could just do new/obj/hotkey{setvar1;setvar2 ...}) but it's useful for initial()-ing
obj/hotkey
	tgs{id="Toggle Strafe";key="Tab";storeverb=list(/mob/verb/Toggle_Strafe);down=0}
	attk{id="Attack";key="Space";storeverb=list(/mob/verb/Attack);down=0}
	ooc{id="OOC";key="B";storeverb=list(/mob/verb/OOC2);down=0}
	mdt{id="Meditate";key="J";storeverb=list(/mob/default/verb/Meditate);down=1}
	tran
	obw
	rpl
	fly
	swm
	grb
	dre
	sde
	say
	slt
	kyb
	blk
	dsh
	ssh
	sbk
	std