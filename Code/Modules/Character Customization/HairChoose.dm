obj/DummyHair
	var
		hairtype
		icon/hairicon
	icon = 'BaseWhiteMale.dmi'
	proc/checkoverlays()
		if(!name||name=="DummyHair")
			overlays -= hairicon
			overlays += hairicon
			name = hairtype
			spawn(1) checkoverlays()
obj/DummyHair/New()
	..()
	checkoverlays()

obj/DummyHair/Click()
	usr.hair = hairtype
	//usr << "Debug: Clicked (If you see this message, everything is working fine! Report it if next time this doesn't show!)"
obj/hairwindowverbs
	verb/DoneButton()
		set category = null
		set hidden = 1
		usr.selecthair()
		winshow(usr,"miscwindow", 0)
		usr.inAwindow = 0
		usr.WindowRemoveVerbs()//causes a infinite cross reference loop otherwise
		del(src)
		usr.dummyhairlist = list(null)
		//usr << "Debug: Clicked (If you see this message, everything is working fine! Report it if next time this doesn't show!)"
mob/var/tmp
	list/dummyhairlist = list()
mob/proc/WindowRemoveVerbs()
	src.contents -= /obj/hairwindowverbs
	usr.contents -= /obj/hairwindowverbs
mob/proc/HairChoice()
	winshow(usr,"miscwindow", 1)
	inAwindow = 1
	dummyhairlist = list()
	contents += new/obj/hairwindowverbs
	hair = null
	//var/W = "miscwindow"
	var/obj/DummyHair/Bald = new/obj/DummyHair
	Bald.hairtype = "Bald"
	Bald.hairicon = null
	dummyhairlist += Bald
	var/obj/DummyHair/Goku = new/obj/DummyHair
	Goku.hairtype = "Goku"
	Goku.hairicon = 'Hair_Goku.dmi'
	dummyhairlist +=Goku
	var/obj/DummyHair/Raditz = new/obj/DummyHair
	Raditz.hairtype = "Raditz"
	Raditz.hairicon = 'Hair_Raditz.dmi'
	dummyhairlist +=Raditz
	var/obj/DummyHair/Vegeta = new/obj/DummyHair
	Vegeta.hairtype = "Vegeta"
	Vegeta.hairicon = 'Hair_Vegeta.dmi'
	dummyhairlist +=Vegeta
	var/obj/DummyHair/FutureGohan = new/obj/DummyHair
	FutureGohan.hairtype = "Future Gohan"
	FutureGohan.hairicon = 'Hair_FutureGohan.dmi'
	dummyhairlist +=FutureGohan
	var/obj/DummyHair/TeenGohan = new/obj/DummyHair
	TeenGohan.hairtype = "Teen Gohan"
	TeenGohan.hairicon = 'Hair_Gohan.dmi'
	dummyhairlist +=TeenGohan
	var/obj/DummyHair/Long = new/obj/DummyHair
	Long.hairtype = "Long"
	Long.hairicon = 'Hair_Long.dmi'
	dummyhairlist +=Long
	var/obj/DummyHair/KidGohan = new/obj/DummyHair
	KidGohan.hairtype = "Kid Gohan"
	KidGohan.hairicon = 'Hair_KidGohan.dmi'
	dummyhairlist +=KidGohan
	//
	var/obj/DummyHair/KidGohan2 = new/obj/DummyHair
	KidGohan2.hairtype = "Cell Gohan"
	KidGohan2.hairicon = 'Hair_KidGohan2.dmi'
	dummyhairlist += KidGohan2
	// This too.
	var/obj/DummyHair/FemaleLong = new/obj/DummyHair
	FemaleLong.hairtype = "Female Long"
	FemaleLong.hairicon = 'Hair_FemaleLong.dmi'
	dummyhairlist +=FemaleLong
	var/obj/DummyHair/FemaleLong2 = new/obj/DummyHair
	FemaleLong2.hairtype = "Female Long 2"
	FemaleLong2.hairicon = 'Hair_FemaleLong2.dmi'
	dummyhairlist +=FemaleLong2
	//
	var/obj/DummyHair/GTTrunks = new/obj/DummyHair
	GTTrunks.hairtype = "GT Trunks"
	GTTrunks.hairicon = 'Hair_GTTrunks.dmi'
	dummyhairlist +=GTTrunks
	var/obj/DummyHair/GTVegeta = new/obj/DummyHair
	GTVegeta.hairtype = "GT Vegeta"
	GTVegeta.hairicon = 'Hair_GTVegeta.dmi'
	dummyhairlist +=GTVegeta
	var/obj/DummyHair/Mohawk = new/obj/DummyHair
	Mohawk.hairtype = "Mohawk"
	Mohawk.hairicon = 'Hair_Mohawk.dmi'
	dummyhairlist +=Mohawk
	//
	var/obj/DummyHair/Spike = new/obj/DummyHair
	Spike.hairtype = "Spike"
	Spike.hairicon = 'Hair_Spike.dmi'
	dummyhairlist +=Spike
	var/obj/DummyHair/Lan = new/obj/DummyHair
	Lan.hairtype = "Lan"
	Lan.hairicon = 'Hair Lan.dmi'
	dummyhairlist +=Lan
	var/obj/DummyHair/Yamcha = new/obj/DummyHair
	Yamcha.hairtype = "Yamcha"
	Yamcha.hairicon = 'Hair_Yamcha.dmi'
	dummyhairlist +=Yamcha
// This is where you need to start to put stuff in the super sayain thing.
	var/obj/DummyHair/Alucard = new/obj/DummyHair
	Alucard.hairtype = "Alucard"
	Alucard.hairicon = 'Hair Alucard.dmi'
	dummyhairlist +=Alucard
	var/obj/DummyHair/Cloud = new/obj/DummyHair
	Cloud.hairtype = "Cloud"
	Cloud.hairicon = 'Hair_Cloud.dmi'
	dummyhairlist +=Cloud
	var/obj/DummyHair/Cloud2 = new/obj/DummyHair
	Cloud2.hairtype = "Also Cloud"
	Cloud2.hairicon = 'Hair_Cloud2.dmi'
	dummyhairlist +=Cloud2
	var/obj/DummyHair/Lyndis = new/obj/DummyHair
	Lyndis.hairtype = "Lyndis"
	Lyndis.hairicon = 'Hair_Lyndis.dmi'
	dummyhairlist +=Lyndis
	var/obj/DummyHair/Messy = new/obj/DummyHair
	Messy.hairtype = "Messy"
	Messy.hairicon = 'Hair_Messy.dmi'
	dummyhairlist +=Messy
	var/obj/DummyHair/Ponytail = new/obj/DummyHair
	Ponytail.hairtype = "Ponytail"
	Ponytail.hairicon = 'Hair_Ponytail.dmi'
	dummyhairlist +=Ponytail
	var/obj/DummyHair/Raim = new/obj/DummyHair
	Raim.hairtype = "Raim"
	Raim.hairicon = 'Hair_Raim.dmi'
	dummyhairlist +=Raim
	var/obj/DummyHair/Raphtalia = new/obj/DummyHair
	Raphtalia.hairtype = "Raphtalia"
	Raphtalia.hairicon = 'Hair_Raphtalia.dmi'
	dummyhairlist +=Raphtalia
	var/obj/DummyHair/Ronin = new/obj/DummyHair
	Ronin.hairtype = "Ronin"
	Ronin.hairicon = 'Hair_Ronin.dmi'
	dummyhairlist +=Ronin
	var/obj/DummyHair/Roxas = new/obj/DummyHair
	Roxas.hairtype = "Roxas"
	Roxas.hairicon = 'Hair_Roxas.dmi'
	dummyhairlist +=Roxas
	var/obj/DummyHair/Spiked2 = new/obj/DummyHair
	Spiked2.hairtype = "Spiked2"
	Spiked2.hairicon = 'Hair_Spiked2right.dmi'
	dummyhairlist +=Spiked2
	var/obj/DummyHair/Stylish = new/obj/DummyHair
	Stylish.hairtype = "Stylish"
	Stylish.hairicon = 'Hair_Stylish.dmi'
	dummyhairlist +=Stylish
	var/obj/DummyHair/Toushiro = new/obj/DummyHair
	Toushiro.hairtype = "Toushiro"
	Toushiro.hairicon = 'Hair_Toushiro.dmi'
	dummyhairlist +=Toushiro
	var/obj/DummyHair/Trump = new/obj/DummyHair
	Trump.hairtype = "Trump"
	Trump.hairicon = 'Hair_Trump.dmi'
	dummyhairlist +=Trump
	var/obj/DummyHair/Wavy = new/obj/DummyHair
	Wavy.hairtype = "Wavy"
	Wavy.hairicon = 'Hair_Wavy.dmi'
	dummyhairlist +=Wavy
	var/obj/DummyHair/Zelos = new/obj/DummyHair
	Zelos.hairtype = "Zelos"
	Zelos.hairicon = 'Hair_Zelos.dmi'
	dummyhairlist +=Zelos
	var/obj/DummyHair/itscyan = new/obj/DummyHair
	itscyan.hairtype = "Blue"
	itscyan.hairicon = 'HairBlueMale.dmi'
	dummyhairlist +=itscyan
	var/obj/DummyHair/FemalePonytail = new/obj/DummyHair
	FemalePonytail.hairtype = "Female Ponytail"
	FemalePonytail.hairicon = 'HairFemalePonytail.dmi'
	dummyhairlist +=FemalePonytail
	var/obj/DummyHair/Kidd = new/obj/DummyHair
	Kidd.hairtype = "Kidd"
	Kidd.hairicon = 'HairKidd.dmi'
	dummyhairlist +=Kidd
	var/obj/DummyHair/Kylin = new/obj/DummyHair
	Kylin.hairtype = "Kylin"
	Kylin.hairicon = 'HairKylin1.dmi'
	dummyhairlist +=Kylin
	var/obj/DummyHair/Kylin2 = new/obj/DummyHair
	Kylin2.hairtype = "Side-tail"
	Kylin2.hairicon = 'HairKylin2.dmi'
	dummyhairlist +=Kylin2
	var/obj/DummyHair/Kylin3 = new/obj/DummyHair
	Kylin3.hairtype = "Bangless"
	Kylin3.hairicon = 'HairKylin3.dmi'
	dummyhairlist +=Kylin3
	var/obj/DummyHair/Muse = new/obj/DummyHair
	Muse.hairtype = "Muse"
	Muse.hairicon = 'HairMuse.dmi'
	dummyhairlist +=Muse
	var/obj/DummyHair/Notblue = new/obj/DummyHair
	Notblue.hairtype = "Anime"
	Notblue.hairicon = 'HairPonytail.dmi'
	dummyhairlist +=Notblue
	var/obj/DummyHair/Ren = new/obj/DummyHair
	Ren.hairtype = "Ren"
	Ren.hairicon = 'HairRen.dmi'
	dummyhairlist +=Ren
	var/obj/DummyHair/LIKEUHOHSCOOBLOOKSLIKECELLFINALLYABSORBEDANDROID18 = new/obj/DummyHair
	LIKEUHOHSCOOBLOOKSLIKECELLFINALLYABSORBEDANDROID18.hairtype = "Shaggy"
	LIKEUHOHSCOOBLOOKSLIKECELLFINALLYABSORBEDANDROID18.hairicon = 'HairShaggy.dmi'
	dummyhairlist +=LIKEUHOHSCOOBLOOKSLIKECELLFINALLYABSORBEDANDROID18
	var/obj/DummyHair/Chie = new/obj/DummyHair
	Chie.hairtype = "Chie"
	Chie.hairicon = 'HairShortFemale.dmi'
	dummyhairlist +=Chie
	var/obj/DummyHair/Hope = new/obj/DummyHair
	Hope.hairtype = "Hope"
	Hope.hairicon = 'Hope FFXIII Hair.dmi'
	dummyhairlist +=Hope
	var/obj/DummyHair/Inferno = new/obj/DummyHair
	Inferno.hairtype = "Inferno"
	Inferno.hairicon = 'Inferno Hair.dmi'
	dummyhairlist +=Inferno
	var/obj/DummyHair/Mezu = new/obj/DummyHair
	Mezu.hairtype = "Mezu"
	Mezu.hairicon = 'Mezu Hair.dmi'
	dummyhairlist +=Mezu//these are temp objs, so I add it to this list

	//
	var/obj/DummyHair/Caulifla = new/obj/DummyHair
	Caulifla.hairtype = "Caulifla"
	Caulifla.hairicon = 'Hair_Caulifla.dmi'
	dummyhairlist +=Caulifla
	var/obj/DummyHair/Broly = new/obj/DummyHair
	Broly.hairtype = "Broly"
	Broly.hairicon = 'HairBroly.dmi'
	dummyhairlist +=Broly
	var/obj/DummyHair/FemBroly = new/obj/DummyHair
	FemBroly.hairtype = "FemBroly"
	FemBroly.hairicon = 'Hair_FemBroly.dmi'
	dummyhairlist +=FemBroly
	var/obj/DummyHair/Kale = new/obj/DummyHair
	Kale.hairtype = "Kale"
	Kale.hairicon = 'Hair_Kale.dmi'
	dummyhairlist +=Kale
	var/obj/DummyHair/Vegito = new/obj/DummyHair
	Vegito.hairtype = "Vegito"
	Vegito.hairicon = 'VegitoHairPVP.dmi'
	dummyhairlist +=Vegito
	var/obj/DummyHair/Super = new/obj/DummyHair
	Super.hairtype = "Super"
	Super.hairicon = 'BlackSSJhair.dmi'
	dummyhairlist +=Super
	var/obj/DummyHair/Afro = new/obj/DummyHair
	Afro.hairtype = "Afro"
	Afro.hairicon = 'Hair Afro.dmi'
	dummyhairlist +=Afro
	var/obj/DummyHair/Hitsugaya = new/obj/DummyHair
	Hitsugaya.hairtype = "Hitsugaya"
	Hitsugaya.hairicon = 'Hair Hitsugaya.dmi'
	dummyhairlist +=Hitsugaya
	var/obj/DummyHair/S17 = new/obj/DummyHair
	S17.hairtype = "S17"
	S17.hairicon = 'Hair Super 17.dmi'
	dummyhairlist +=S17
	var/obj/DummyHair/Headband = new/obj/DummyHair
	Headband.hairtype = "Headband"
	Headband.hairicon = 'Hair Headband.dmi'
	dummyhairlist +=Headband
	var/obj/DummyHair/Bushy = new/obj/DummyHair
	Bushy.hairtype = "Bushy"
	Bushy.hairicon = 'Hair Bushy.dmi'
	dummyhairlist +=Bushy
	var/obj/DummyHair/Bedhead = new/obj/DummyHair
	Bedhead.hairtype = "Bedhead"
	Bedhead.hairicon = 'Hair Bedhead.dmi'
	dummyhairlist +=Bedhead
	//
	sleep(4)
	var/dummyhairs = 0
	for(var/obj/DummyHair/S in dummyhairlist)
		S.hairicon += rgb(hairred,hairgreen,hairblue)
		S.overlays -= S.overlays
		S.overlays += S.hairicon
		src<<output(S,"miscwindow.maingrid: [++dummyhairs]")
	while(inAwindow)
		sleep(5)
mob/proc/selecthair()
	//usr << "Debug: Done (If you see this message, everything is working fine! Report it if next time this doesn't show!)"
	switch(hair)
		if("Goten")
			SetHair('Hair_Goten.dmi','Hair_GokuSSj.dmi','Hair_GokuUSSj.dmi','Hair_GokuSSj.dmi','Hair_GokuSSj3.dmi')
		if("Bald")
			SetHair()
		if("Alucard")
			SetHair('Hair Alucard.dmi','Inferno SSJ.dmi','Inferno SSJFP.dmi','Inferno USSJ.dmi','Hair_RaditzSSjFP.dmi')
		if("Cell Gohan")
			SetHair('Hair_KidGohan2.dmi','HairPonyTailSSJ.dmi','HairPonyTailSSJ.dmi','Hair_KidGohanSSj2.dmi','Hair_GokuSSj3.dmi')
		if("Female Long")
			SetHair('Hair_FemaleLong.dmi','Hair_FemaleLongSSj.dmi','Hair_LongUSSj.dmi','Hair_FemaleLongSSj.dmi','Hair_GokuSSj3.dmi')
		if("Female Long 2")
			SetHair('Hair_FemaleLong2.dmi','Hair_FemaleLongSSj.dmi','Hair_LongUSSj.dmi','Hair_FemaleLongSSj.dmi','Hair_GokuSSj3.dmi')
		if("GT Trunks")
			SetHair('Hair_GTTrunks.dmi','Hair_LongSSj.dmi','Hair_LongSSj.dmi','Hair_LongSSj.dmi','Hair_GokuSSj3.dmi')
		if("GT Vegeta")
			SetHair('Hair_GTVegeta.dmi','Hair_GTVegetaSSj.dmi','Hair_GTVegetaSSj.dmi','Hair_GTVegetaSSj.dmi','Hair_GokuSSj3.dmi')
		if("Mohawk")
			SetHair('Hair_Mohawk.dmi','Hair_MohawkSSj.dmi','Hair_MohawkSSj.dmi','Hair_MohawkSSj.dmi','Hair_GokuSSj3.dmi')
		if("Raditz")
			SetHair('Hair_Raditz.dmi','Hair_GokuSSj3.dmi','Hair_GokuSSj3.dmi','Hair_GokuSSj3.dmi','Hair_GokuSSj3.dmi')
		if("Spike")
			SetHair('Hair_Spike.dmi','Hair_SpikeSSj.dmi','Hair_SpikeSSj.dmi','Hair_SpikeSSj.dmi','Hair_GokuSSj3.dmi') //which defaults to 'Spike' for some reason.
		if("Yamcha")
			SetHair('Hair_Yamcha.dmi','Hair_FutureGohanSSj.dmi','Hair_GohanUSSj.dmi','Hair_FutureGohanSSj.dmi','Hair_GokuSSj3.dmi')
		if("Kid Gohan")
			SetHair('Hair_KidGohan.dmi','Hair_KidGohanSSj.dmi','Hair_KidGohanUSSj.dmi','Hair_KidGohanSSj.dmi','Hair_GokuSSj3.dmi')
		if("Lan")
			SetHair('Hair Lan.dmi','Hair_KidGohanSSj.dmi','Hair_KidGohanUSSj.dmi','Hair_KidGohanSSj.dmi','Hair_GokuSSj3.dmi')
		if("Goku")
			SetHair('Hair_Goku.dmi','Hair_GokuSSj.dmi','Hair_GokuUSSj.dmi','Hair_GokuSSj.dmi','Hair_GokuSSj3.dmi')
		if("Vegeta")
			SetHair('Hair_Vegeta.dmi','Hair_VegetaSSj.dmi','Hair_VegetaUSSj.dmi','Hair_VegetaSSj.dmi','Hair_GokuSSj3.dmi')
		if("Vegeta Junior")
			SetHair('Hair Vegeta Junior.dmi','Hair_VegetaSSj.dmi','Hair_VegetaUSSj.dmi','Hair_VegetaSSj.dmi','Hair_GokuSSj3.dmi')
		if("Future Gohan")
			SetHair('Hair_FutureGohan.dmi','Hair_FutureGohanSSj.dmi','Hair_GohanUSSj.dmi','Hair_FutureGohanSSj.dmi','Hair_GokuSSj3.dmi')
		if("Teen Gohan")
			SetHair('Hair_Gohan.dmi','Hair_GohanSSj.dmi','Hair_GohanUSSj.dmi','Hair_GohanSSj.dmi','Hair_GokuSSj3.dmi')
		if("Long")
			SetHair('Hair_Long.dmi','Hair_LongSSj.dmi','Hair_LongSSj.dmi','Hair_GokuSSj.dmi','Hair_GokuSSj3.dmi')
		if("Caulifla")
			SetHair('Hair_Caulifla.dmi','Caulifla_Hair_SSJ.dmi','Caulifla_Hair_USSJ.dmi','Caulifla_Hair_SSJ2.dmi','Hair_GokuSSj3.dmi')
		if("Broly")
			SetHair('HairBroly.dmi','Hair_Karoly.dmi','HairBrolyLssj.dmi','HairBrolyLssj.dmi','Hair_GokuSSj3.dmi')
		if("FemBroly")
			SetHair('Hair_FemBroly.dmi','Hair_Karoly.dmi','HairBrolyLssj.dmi','HairBrolyLssj.dmi','Hair_GokuSSj3.dmi')
		if("Kale")
			SetHair('Hair_Kale.dmi','Kale Hair SSJ.dmi','Kale Hair LSSJ.dmi','Kale Hair SSJ.dmi','Hair_GokuSSj3.dmi')
		if("Vegito")
			SetHair('VegitoHairPVP.dmi','VegitoHairPVPSSjFP.dmi','VegitoHairPVPSSjFP.dmi','VegitoHairPVPSSj2.dmi','Hair_GokuSSj3.dmi')
		if("Super")
			SetHair('BlackSSJhair.dmi','Hair_GokuSSj.dmi','Hair_GokuUSSj.dmi','Hair_GokuSSj.dmi','Hair_GokuSSj3.dmi')
		if("Afro")
			SetHair('Hair Afro.dmi','Hair AfroSSJ.dmi','Hair AfroSSJ.dmi','Hair AfroSSJ.dmi','Hair AfroSSJ.dmi')
		if("Hitsugaya")
			SetHair('Hair Hitsugaya.dmi','Hair_GokuSSj.dmi','Hair_GokuUSSj.dmi','Hair_GokuSSj.dmi','Hair_GokuSSj3.dmi')
		if("S17")
			SetHair('Hair Super 17.dmi','Hair_GokuSSj.dmi','Hair_GokuUSSj.dmi','Hair_GokuSSj.dmi','Hair_GokuSSj3.dmi')
		if("Headband")
			SetHair('Hair Headband.dmi','Hair_FutureGohanSSj.dmi','Hair_GohanUSSj.dmi','Hair_FutureGohanSSj.dmi','Hair_GokuSSj3.dmi')
		if("Bushy")
			SetHair('Hair Bushy.dmi','Hair_KidGohanSSj.dmi','Hair_KidGohanUSSj.dmi','Hair_KidGohanSSj.dmi','Hair_GokuSSj3.dmi')
		if("Bedhead")
			SetHair('Hair Bedhead.dmi','Hair_GokuSSj.dmi','Hair_GokuUSSj.dmi','Hair_GokuSSj.dmi','Hair_GokuSSj3.dmi')
		if("Cloud")
			SetHair('Hair_Cloud.dmi','Hair_CloudSSJ.dmi','Hair_CloudSSJ.dmi','Hair_CloudSSJ.dmi','Hair_GokuSSj3.dmi')
		if("Also Cloud")
			SetHair('Hair_Cloud2.dmi','Hair_CloudSSJ.dmi','Hair_CloudSSJ.dmi','Hair_CloudSSJ.dmi','Hair_GokuSSj3.dmi')
		if("Lyndis")
			SetHair('Hair_Lyndis.dmi','Hair_Long_PonytailSSJ.dmi','Hair_Long_PonytailSSJ.dmi','Hair_Long_PonytailSSJ.dmi','Hair_GokuSSj3.dmi')
		if("Messy")
			SetHair('Hair_Messy.dmi','LongFemaleHairssj.dmi','LongFemaleHairssj.dmi','LongFemaleHairssj.dmi','Hair_GokuSSj3.dmi')
		if("Ponytail")
			SetHair('Hair_Ponytail.dmi','Hair_FemaleLongSSj.dmi','Hair_FemaleLongSSj.dmi','Hair_FemaleLongSSj.dmi','Hair_GokuSSj3.dmi')
		if("Raim")
			SetHair('Hair_Raim.dmi','Hair_RaditzSSj.dmi','Hair_RaditzSSjFP.dmi','Hair_RaditzSSjFP.dmi','Hair_GokuSSj3.dmi')
		if("Raphtalia")
			SetHair('Hair_Raphtalia.dmi','Hair_GokuSSj3.dmi','Hair_GokuSSj3.dmi','Hair_GokuSSj3.dmi','Hair_GokuSSj3.dmi')
		if("Ronin")
			SetHair('Hair_Ronin.dmi','Kale Hair SSJ.dmi','Kale Hair SSJ.dmi','Kale Hair SSJ.dmi','Hair_GokuSSj3.dmi')
		if("Roxas")
			SetHair('Hair_Roxas.dmi','Hair_TotallyRoxasSSJNotJustFlippedGohanSSJ.dmi','Hair_TotallyRoxasSSJNotJustFlippedGohanSSJ.dmi','Hair_TotallyRoxasSSJNotJustFlippedGohanSSJ.dmi','Hair_GokuSSj3.dmi')
		if("Spiked2")
			SetHair('Hair_Spiked2right.dmi','LongFemaleHairssj.dmi','LongFemaleHairssj.dmi','LongFemaleHairssj.dmi','Hair_GokuSSj3.dmi')
		if("Stylish")
			SetHair('Hair_Stylish.dmi','Hair_LongSSJ.dmi','Hair_TrunksUSSj.dmi','Hair_TrunksUSSj.dmi','Hair_GokuSSj3.dmi')
		if("Toushiro")
			SetHair('Hair_Toushiro.dmi','Hair_GTVegetaSSj.dmi','Hair_GTVegetaSSj.dmi','Hair_GTVegetaSSj.dmi','Hair_GokuSSj3.dmi')
		if("Trump")
			SetHair('Hair_Trump.dmi','Hair_Trump.dmi','Hair_Trump.dmi','Hair_Trump.dmi','Hair_Trump.dmi')
		if("Wavy")
			SetHair('Hair_Wavy.dmi','HairBrolySSj.dmi','HairBrolySSj.dmi','HairBrolySSj.dmi','Hair_GokuSSj3.dmi')
		if("Zelos")
			SetHair('Hair_Zelos.dmi','SSJ Zelos.dmi','SSJ Zelos.dmi','SSJ Zelos.dmi','Hair_GokuSSj3.dmi')
		if("Blue")
			SetHair('HairBlueMale.dmi','Hair_VegitoSSj.dmi','Hair_VegitoSSj.dmi','Hair_VegitoSSj.dmi','Hair_GokuSSj3.dmi')
		if("Female Ponytail")
			SetHair('HairFemalePonyTail.dmi','HairFemalePonytailSSj.dmi','HairFemalePonytailSSj.dmi','HairFemalePonytailSSj.dmi','Hair_GokuSSj3.dmi')
		if("Kidd")
			SetHair('HairKidd.dmi','HairKidd.dmi','HairKidd.dmi','HairKidd.dmi','Hair_GokuSSj3.dmi')
		if("Kylin")
			SetHair('HairKylin1.dmi','HairKylin1.dmi','HairKylin1.dmi','HairKylin1.dmi','Hair_GokuSSj3.dmi')
		if("Side-tail")
			SetHair('HairKylin2.dmi','HairKylin2.dmi','HairKylin2.dmi','HairKylin2.dmi','Hair_GokuSSj3.dmi')
		if("Bangless")
			SetHair('HairKylin3.dmi','Hair_LongSSJ.dmi','Hair_TrunksUSSj.dmi','Hair_TrunksUSSj.dmi','Hair_GokuSSj3.dmi')
		if("Muse")
			SetHair('HairMuse.dmi','HairMuse.dmi','HairMuse.dmi','HairMuse.dmi','Hair_GokuSSj3.dmi')
		if("Anime")
			SetHair('HairPonytail.dmi','Hair_VegitoSSj.dmi','Hair_VegitoSSj.dmi','Hair_VegitoSSj.dmi','Hair_GokuSSj3.dmi')
		if("Ren")
			SetHair('HairRen.dmi','Inferno SSJ.dmi','Inferno SSJFP.dmi','Inferno USSJ.dmi','Hair_GokuSSj3.dmi')
		if("Shaggy")
			SetHair('HairShaggy.dmi','Hair_Karoly.dmi','Hair_Karoly.dmi','Hair_Karoly.dmi','Hair_GokuSSj3.dmi')
		if("Chie")
			SetHair('HairShortFemale.dmi','Caulifla_Hair_SSJ.dmi','Caulifla_Hair_SSjFP.dmi','Caulifla_Hair_SSJ2.dmi','Hair_GokuSSj3.dmi')
		if("Hope")
			SetHair('Hope FFXIII Hair.dmi','Hope FFXIII Hair.dmi','Hope FFXIII Hair.dmi','Hope FFXIII Hair.dmi','Hair_GokuSSj3.dmi')
		if("Inferno")
			SetHair('Inferno Hair.dmi','Inferno SSJ.dmi','Inferno SSJFP.dmi','Inferno USSJ.dmi','Hair_GokuSSj3.dmi')
		if("Mezu")
			SetHair('Mezu Hair.dmi','Hair_RaditzSSj.dmi','Hair_RaditzSSjFP.dmi','Hair_RaditzSSjFP.dmi','Hair_GokuSSj3.dmi')




mob/proc/SetHair(var/icon/Hair1,var/icon/SSJhair1,var/icon/USSJhair1,var/icon/SSJ2hair,var/icon/SSJ3hair)
	if(Hair1 == null)
		hair=null
		ssjhair=null
		ussjhair=null
		ssj2hair=null
		ssj3hair=null
		return
	hair=Hair1
	hair += rgb(hairred,hairgreen,hairblue)
	HairR=hairred
	HairG=hairgreen
	HairB=hairblue
	ssjhair=SSJhair1
	ussjhair=USSJhair1
	ssj2hair=SSJ2hair
	if(!SSJ3hair)
		ssj3hair = pick('Hair_GokuSSj3.dmi')
	ssj3hair=SSJ3hair
	if(pgender=="male") ssj4hair=pick('Hair_SSj4.dmi','Hair_SSJ4Gogeta.dmi','Hair VegetaSSJ4.dmi')//more SSJ4 hairs here
	if(pgender=="female") ssj4hair=pick('Hair_SSj4.dmi','Hair_SSJ4Female.dmi','Hair VegetaSSJ4.dmi')//