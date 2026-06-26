mob
	
	var
		tmp/move = 1
		statstab=1
		immortal=0
		AgeStatus="Young"
		Age=1
		SAge=1
		InclineAge=25
		DeclineAge=50
		Body=1
		image/hair
		image/ssjhair
		image/ssjfphair
		image/ussjhair
		image/ssj2hair
		image/ssj3hair
		hairtypeSaved //remembers the chosen hairstyle name so RefreshHair() can re-apply SetHair on load, letting hair-icon changes in code reach already-created characters
		AuraR=0
		AuraG=0
		AuraB=0
		HairR=0
		HairG=0
		HairB=0
		Race="None"
		Class="None"
		Emotion="Calm"
		Build="None"
		Height="None"
	//	MaxBP=100
	//	Base_BP=100 //YOU'RE NEXT
	//	BP=100
		HP=100
	/*	Pow=1
	//	Str=1 aaaand STR is down.
		Spd=1
		End=1 //Resistance to physical attacks
		Res=1 //Resistance to spiritual attacks
		Offense=1
		Defense=1*/
		GravMastered=1
		maxPowerPcnt=110
		Anger=100
		MaxAnger=120
	/*---------------------------------------------------------------------*/
		PowMod=1
		StrMod=1
		SpdMod=1
		EndMod=1
		ResMod=1
		OffenseMod=1
		DefenseMod=1
		GravMod=1
		ZenkaiMod=1
		Zenkai=1.2 //The going multiplication rate for Zenkai.
		MedMod=1
		TrainMod=1
		SparMod=1
		swimmastery = 0.01
	/*---------------------------------------------------------------------*/
		displaykey //The key that will be displayed in OOC and Who
		Apeshit=0
		gain=0.0000001
		zenni=0
		Player=0
		monster=0
		attackable=1
		talk=1
		pgender="None"
		oicon
		observing=0
		Admin=0
		blastR=0
		blastG=0
		blastB=0
		Tail=0
		//
		oBP=0
		ooverlays
		ounderlays
		//
		GotReibi
		ReibiX=0
		ReibiY=0
		ReibiZ=0
		ReibiActivated
		ReibiAbsorber
		//
		hairred
		hairblue
		hairgreen
		newrgb
		oldrgb[]
		//
		eyered
		eyeblue
		eyegreen
		eyeicon = 'Eyes_Black.dmi'
	
		oname=""
		IM=0
		invisskill=1
		holdname=""
		isimitate=0

		mob_size = MOB_SIZE_HUMAN //will eventually be worked into attack calcs, grabbing, etc. Small is anywhere from 30 cm to 1 meter, or (1 foot to 3 feet). Normal is 4-6 feet, or 1 meter to 1.4 meters. Large is 1.4 meter+
mob/var/tmp/r_race = null //scratch var: resolved race name used during icon/skin building

mob/var/freeflight = 0 //free-flight mode (declaration restored after removing DevilTrigger.dm)

mob/var
	eyeBuff = 1            //declaration restored after removing ThirdEye.dm (neutral, used in base.dm buff math)
	thirdeye = 0           //vision flag (aliens' see-invisible); restored after removing ThirdEye.dm
	third_eye_icon = null  //cosmetic slot restored after removing ThirdEye.dm
	hamon_skill = 0        //dormant after Hamon removal
	hamon_skill_buffer = 0 //dormant after Hamon removal
