obj/DummyClothes
	var
		clothingtype
		icon/clothingicon
	icon = 'BaseWhiteMale.dmi'
	proc/checkoverlays()
		if(!name||name=="DummyClothes")
			overlays -= overlays
			overlays += clothingicon
			name = clothingtype
			spawn(1) checkoverlays()
obj/DummyClothes/New()
	..()
	checkoverlays()
obj/DummyClothes/Click()
	usr.selection=clothingtype
	usr.pickclothes()
obj/clothingwindowverbs
	verb/ClothDoneButton()
		set category = null
		set hidden = 1
		winshow(usr,"clothingwindow", 0)
		usr.dummyclothinglist = list()
		usr.ClothWindowRemoveVerbs()//causes a infinite cross reference loop otherwise
		del(src)
mob/proc/ClothWindowRemoveVerbs()
	verbs -= typesof(/obj/clothingwindowverbs/verb)
	contents -= /obj/clothingwindowverbs

mob/var/tmp/list/dummyclothinglist = list()
mob/var/tmp/selection = null

mob/proc/ClothingChoice(var/shoptype)
	winshow(usr,"clothingwindow", 1)
	contents += new/obj/clothingwindowverbs
	selection = null
	var/W = "clothingwindow"
	var/obj/DummyClothes/GiTop = new/obj/DummyClothes
	GiTop.clothingtype = "Gi Top"
	GiTop.clothingicon = 'Clothes_GiTop.dmi'
	dummyclothinglist += GiTop
	var/obj/DummyClothes/GiBottom = new/obj/DummyClothes
	GiBottom.clothingtype = "Gi Bottom"
	GiBottom.clothingicon = 'Clothes_GiBottom.dmi'
	dummyclothinglist += GiBottom
	var/obj/DummyClothes/Wristband = new/obj/DummyClothes
	Wristband.clothingtype = "Wristband"
	Wristband.clothingicon = 'Clothes_Wristband.dmi'
	dummyclothinglist += Wristband
	var/obj/DummyClothes/TankTop = new/obj/DummyClothes
	TankTop.clothingtype = "Tank Top"
	TankTop.clothingicon = 'Clothes_TankTop.dmi'
	dummyclothinglist += TankTop
	var/obj/DummyClothes/ShortSleeveShirt = new/obj/DummyClothes
	ShortSleeveShirt.clothingtype = "Short Sleeve Shirt"
	ShortSleeveShirt.clothingicon = 'Clothes_ShortSleeveShirt.dmi'
	dummyclothinglist += ShortSleeveShirt
	var/obj/DummyClothes/Shoes = new/obj/DummyClothes
	Shoes.clothingtype = "Shoes"
	Shoes.clothingicon = 'Clothes_Shoes.dmi'
	dummyclothinglist += Shoes
	var/obj/DummyClothes/Sash = new/obj/DummyClothes
	Sash.clothingtype = "Sash"
	Sash.clothingicon = 'Clothes_Sash.dmi'
	dummyclothinglist += Sash
	var/obj/DummyClothes/Pants = new/obj/DummyClothes
	Pants.clothingtype = "Pants"
	Pants.clothingicon = 'Clothes_Pants.dmi'
	dummyclothinglist += Pants
	var/obj/DummyClothes/LongSleeveShirt = new/obj/DummyClothes
	LongSleeveShirt.clothingtype = "Long Sleeve Shirt"
	LongSleeveShirt.clothingicon = 'Clothes_LongSleeveShirt.dmi'
	dummyclothinglist += LongSleeveShirt
	var/obj/DummyClothes/Jacket = new/obj/DummyClothes
	Jacket.clothingtype = "Jacket"
	Jacket.clothingicon = 'Clothes_Jacket.dmi'
	dummyclothinglist += Jacket
	var/obj/DummyClothes/Headband = new/obj/DummyClothes
	Headband.clothingtype = "Headband"
	Headband.clothingicon = 'Clothes_Headband.dmi'
	dummyclothinglist += Headband
	var/obj/DummyClothes/Gloves = new/obj/DummyClothes
	Gloves.clothingtype = "Gloves"
	Gloves.clothingicon = 'Clothes_Gloves.dmi'
	dummyclothinglist += Gloves
	var/obj/DummyClothes/Boots = new/obj/DummyClothes
	Boots.clothingtype = "Boots"
	Boots.clothingicon = 'Clothes_Boots.dmi'
	dummyclothinglist += Boots
	var/obj/DummyClothes/Bandana = new/obj/DummyClothes
	Bandana.clothingtype = "Bandana"
	Bandana.clothingicon = 'Clothes_Bandana.dmi'
	dummyclothinglist += Bandana
	var/obj/DummyClothes/Belt = new/obj/DummyClothes
	Belt.clothingtype = "Belt"
	Belt.clothingicon = 'Clothes_Belt.dmi'
	dummyclothinglist += Belt
	var/obj/DummyClothes/Cape = new/obj/DummyClothes
	Cape.clothingtype = "Cape"
	Cape.clothingicon = 'Clothes_Cape.dmi'
	dummyclothinglist += Cape
	var/obj/DummyClothes/Hood = new/obj/DummyClothes
	Hood.clothingtype = "Hood"
	Hood.clothingicon = 'Clothes_Hood.dmi'
	dummyclothinglist += Hood
	var/obj/DummyClothes/WaistRobe = new/obj/DummyClothes
	WaistRobe.clothingtype = "Waist Robe"
	WaistRobe.clothingicon = 'Clothes_WaistRobe.dmi'
	dummyclothinglist += WaistRobe
	var/obj/DummyClothes/Shades = new/obj/DummyClothes
	Shades.clothingtype = "Shades"
	Shades.clothingicon = 'Clothes_Shades.dmi'
	dummyclothinglist += Shades
	var/obj/DummyClothes/NamekianScarf = new/obj/DummyClothes
	NamekianScarf.clothingtype = "Namekian Scarf"
	NamekianScarf.clothingicon = 'Clothes_NamekianScarf.dmi'
	dummyclothinglist += NamekianScarf
	var/obj/DummyClothes/Turban = new/obj/DummyClothes
	Turban.clothingtype = "Turban"
	Turban.clothingicon = 'Clothes_Turban.dmi'
	dummyclothinglist += Turban
	var/obj/DummyClothes/Boba = new/obj/DummyClothes
	Boba.clothingtype = "Boba Helmet"
	Boba.clothingicon = 'Boba Fett.dmi'
	dummyclothinglist += Boba
	var/obj/DummyClothes/BrolyWaistrobe = new/obj/DummyClothes
	BrolyWaistrobe.clothingtype = "Broly Waistrobe"
	BrolyWaistrobe.clothingicon = 'BrolyWaistrobe.dmi'
	dummyclothinglist += BrolyWaistrobe
	var/obj/DummyClothes/ArmPads = new/obj/DummyClothes
	ArmPads.clothingtype = "Arm Pads"
	ArmPads.clothingicon = 'Clothes Arm Pads.dmi'
	dummyclothinglist += ArmPads
	var/obj/DummyClothes/Backpack = new/obj/DummyClothes
	Backpack.clothingtype = "Backpack"
	Backpack.clothingicon = 'Clothes Backpack.dmi'
	dummyclothinglist += Backpack
	var/obj/DummyClothes/Daimaou = new/obj/DummyClothes
	Daimaou.clothingtype = "Daimaou"
	Daimaou.clothingicon = 'Clothes Daimaou.dmi'
	dummyclothinglist += Daimaou
	var/obj/DummyClothes/Guardian = new/obj/DummyClothes
	Guardian.clothingtype = "Guardian"
	Guardian.clothingicon = 'Clothes Guardian.dmi'
	dummyclothinglist += Guardian
	var/obj/DummyClothes/KaioSuit = new/obj/DummyClothes
	KaioSuit.clothingtype = "Kaio Suit"
	KaioSuit.clothingicon = 'Clothes_KaioSuit.dmi'
	dummyclothinglist += KaioSuit
	var/obj/DummyClothes/KungFu = new/obj/DummyClothes
	KungFu.clothingtype = "Kung Fu Shirt"
	KungFu.clothingicon = 'Clothes Kung Fu Shirt.dmi'
	dummyclothinglist += KungFu
	var/obj/DummyClothes/Tux = new/obj/DummyClothes
	Tux.clothingtype = "Tuxedo"
	Tux.clothingicon = 'Clothes Tuxedo.dmi'
	dummyclothinglist += Tux
	var/obj/DummyClothes/DemonArm = new/obj/DummyClothes
	DemonArm.clothingtype = "Demon Arm"
	DemonArm.clothingicon = 'Clothes, Demon Arm.dmi'
	dummyclothinglist += DemonArm
	var/obj/DummyClothes/Kimono = new/obj/DummyClothes
	Kimono.clothingtype = "Kimono"
	Kimono.clothingicon = 'Clothes, Kimono.dmi'
	dummyclothinglist += Kimono
	var/obj/DummyClothes/Neko = new/obj/DummyClothes
	Neko.clothingtype = "Neko"
	Neko.clothingicon = 'Clothes, Neko.dmi'
	dummyclothinglist += Neko
	var/obj/DummyClothes/NinjaMask = new/obj/DummyClothes
	NinjaMask.clothingtype = "Ninja Mask"
	NinjaMask.clothingicon = 'Clothes, Ninja Mask.dmi'
	dummyclothinglist += NinjaMask
	var/obj/DummyClothes/SaiyanGloves = new/obj/DummyClothes
	SaiyanGloves.clothingtype = "Saiyan Gloves"
	SaiyanGloves.clothingicon = 'Clothes, Saiyan Gloves.dmi'
	dummyclothinglist += SaiyanGloves
	var/obj/DummyClothes/SaiyanShoes = new/obj/DummyClothes
	SaiyanShoes.clothingtype = "Saiyan Shoes"
	SaiyanShoes.clothingicon = 'Clothes, Saiyan Shoes.dmi'
	dummyclothinglist += SaiyanShoes
	var/obj/DummyClothes/SaiyanSuit = new/obj/DummyClothes
	SaiyanSuit.clothingtype = "Saiyan Suit"
	SaiyanSuit.clothingicon = 'Clothes_SaiyanSuit.dmi'
	dummyclothinglist += SaiyanSuit
	//START. Oh right, maybe fucking make this menu categorical.
	//Armwear/Headwear/Bodywear. You know?
	var/obj/DummyClothes/Angelwings = new/obj/DummyClothes
	Angelwings.clothingtype = "Angel Wings"
	Angelwings.clothingicon = 'Angel Wings.dmi'
	dummyclothinglist += Angelwings
	var/obj/DummyClothes/Graysuit = new/obj/DummyClothes
	Graysuit.clothingtype = "Gray Ninja Suit"
	Graysuit.clothingicon = 'Gray suit.dmi'
	dummyclothinglist += Graysuit
	var/obj/DummyClothes/Weirdhelmet = new/obj/DummyClothes
	Weirdhelmet.clothingtype = "Tech Helmet"
	Weirdhelmet.clothingicon = 'Clothes Helmet.dmi'
	dummyclothinglist += Weirdhelmet
	var/obj/DummyClothes/Crane = new/obj/DummyClothes
	Crane.clothingtype = "Crane Outfit"
	Crane.clothingicon = 'ClothesTsurusennin.dmi'
	dummyclothinglist += Crane
	var/obj/DummyClothes/Armbands = new/obj/DummyClothes
	Armbands.clothingtype = "Arm Bands"
	Armbands.clothingicon = 'Clothes_ArmBands.dmi'
	dummyclothinglist += Armbands
	var/obj/DummyClothes/Bustier = new/obj/DummyClothes
	Bustier.clothingtype = "Bustier"
	Bustier.clothingicon = 'Clothes_Bustier.dmi'
	dummyclothinglist += Bustier
	var/obj/DummyClothes/Cape2 = new/obj/DummyClothes
	Cape2.clothingtype = "Windblown Cape"
	Cape2.clothingicon = 'Clothes_Cape2.dmi'
	dummyclothinglist += Cape2
	var/obj/DummyClothes/Celes = new/obj/DummyClothes
	Celes.clothingtype = "Celes Robe"
	Celes.clothingicon = 'Clothes_CelesRobe.dmi'
	dummyclothinglist += Celes
	var/obj/DummyClothes/SOLDIER = new/obj/DummyClothes
	SOLDIER.clothingtype = "SOLDIER Suit"
	SOLDIER.clothingicon = 'Clothes_CloudSOLDIER.dmi'
	dummyclothinglist += SOLDIER
	var/obj/DummyClothes/CGi = new/obj/DummyClothes
	CGi.clothingtype = "Cross Gi"
	CGi.clothingicon = 'Clothes_GiCustom.dmi'
	dummyclothinglist += CGi
	var/obj/DummyClothes/Jacketandpants = new/obj/DummyClothes
	Jacketandpants.clothingtype = "Jacket and Pants"
	Jacketandpants.clothingicon = 'Clothes_GokuJacketandPants.dmi'
	dummyclothinglist += Jacketandpants
	var/obj/DummyClothes/Headband2 = new/obj/DummyClothes
	Headband2.clothingtype = "Windblown Headband"
	Headband2.clothingicon = 'Clothes_Headband2.dmi'
	dummyclothinglist += Headband2
	var/obj/DummyClothes/Hitrobe = new/obj/DummyClothes
	Hitrobe.clothingtype = "Hit Robe"
	Hitrobe.clothingicon = 'Clothes_Hit.dmi'
	dummyclothinglist += Hitrobe
	var/obj/DummyClothes/Hoodedcloak = new/obj/DummyClothes
	Hoodedcloak.clothingtype = "Hooded Cloak"
	Hoodedcloak.clothingicon = 'Clothes_Hooded Cloak 2.dmi'
	dummyclothinglist += Hoodedcloak
	var/obj/DummyClothes/Thirteen = new/obj/DummyClothes
	Thirteen.clothingtype = "XIII Hooded Cloak"
	Thirteen.clothingicon = 'Clothes_HoodedCloak.dmi'
	dummyclothinglist += Thirteen
	var/obj/DummyClothes/Thirteennohood = new/obj/DummyClothes
	Thirteennohood.clothingtype = "XIII Cloak"
	Thirteennohood.clothingicon = 'Clothes_HoodlessCloak.dmi'
	dummyclothinglist += Thirteennohood
	var/obj/DummyClothes/Kaisuit2 = new/obj/DummyClothes
	Kaisuit2.clothingtype = "Kai Suit"
	Kaisuit2.clothingicon = 'Clothes_KaioSuit.dmi'
	dummyclothinglist += Kaisuit2
	var/obj/DummyClothes/Vegetacape = new/obj/DummyClothes
	Vegetacape.clothingtype = "Vegeta Cape"
	Vegetacape.clothingicon = 'Clothes_KingVegetaCape.dmi'
	dummyclothinglist += Vegetacape
	var/obj/DummyClothes/Longcoat = new/obj/DummyClothes
	Longcoat.clothingtype = "Long Coat"
	Longcoat.clothingicon = 'ClothesNeroJacket.dmi'
	dummyclothinglist += Longcoat
	var/obj/DummyClothes/Roningi = new/obj/DummyClothes
	Roningi.clothingtype = "Ronin"
	Roningi.clothingicon = 'Clothes_Ronin.dmi'
	dummyclothinglist += Roningi
	var/obj/DummyClothes/Oddmask = new/obj/DummyClothes
	Oddmask.clothingtype = "Red and Blue Mask"
	Oddmask.clothingicon = 'Clothes_SaiyanMask.dmi'
	dummyclothinglist += Oddmask
	var/obj/DummyClothes/Longscarf = new/obj/DummyClothes
	Longscarf.clothingtype = "Long Scarf"
	Longscarf.clothingicon = 'Clothes_Scarf.dmi'
	dummyclothinglist += Longscarf
	var/obj/DummyClothes/Beltbuckle = new/obj/DummyClothes
	Beltbuckle.clothingtype = "Belt Buckle"
	Beltbuckle.clothingicon = 'Clothes_BeltBuckle.dmi'
	dummyclothinglist += Beltbuckle
	var/obj/DummyClothes/Coolglasses = new/obj/DummyClothes
	Coolglasses.clothingtype = "Large Sunglasses"
	Coolglasses.clothingicon = 'Clothes_ShadesCool.dmi'
	dummyclothinglist += Coolglasses
	var/obj/DummyClothes/Tanktopandpants = new/obj/DummyClothes
	Tanktopandpants.clothingtype = "Tank Top and Pants"
	Tanktopandpants.clothingicon = 'Clothes_TankTopandPants.dmi'
	dummyclothinglist += Tanktopandpants
	var/obj/DummyClothes/Turtle = new/obj/DummyClothes
	Turtle.clothingtype = "Turtle Suit"
	Turtle.clothingicon = 'Clothes_TurtleSuit.dmi'
	dummyclothinglist += Turtle
	var/obj/DummyClothes/Timepatrol = new/obj/DummyClothes
	Timepatrol.clothingtype = "Time Patrol Coat"
	Timepatrol.clothingicon = 'Clothes_TimePatrolCoat.dmi'
	dummyclothinglist += Timepatrol
	var/obj/DummyClothes/Warriorpants = new/obj/DummyClothes
	Warriorpants.clothingtype = "Warrior Pants"
	Warriorpants.clothingicon = 'Clothes_WarriorPants.dmi'
	dummyclothinglist += Warriorpants
	var/obj/DummyClothes/Ass = new/obj/DummyClothes
	Ass.clothingtype = "Assassin Suit"
	Ass.clothingicon = 'ClothesAssassin.dmi'
	dummyclothinglist += Ass
	var/obj/DummyClothes/Assass = new/obj/DummyClothes
	Assass.clothingtype = "Assassin Hoodless"
	Assass.clothingicon = 'ClothesAssassinHoodless.dmi'
	dummyclothinglist += Assass
	var/obj/DummyClothes/Book = new/obj/DummyClothes
	Book.clothingtype = "Book"
	Book.clothingicon = 'ClothesBook.dmi'
	dummyclothinglist += Book
	var/obj/DummyClothes/Smallcloak = new/obj/DummyClothes
	Smallcloak.clothingtype = "Small Cloak"
	Smallcloak.clothingicon = 'ClothesCape2.dmi'
	dummyclothinglist += Smallcloak
	var/obj/DummyClothes/Dimeowcape = new/obj/DummyClothes
	Dimeowcape.clothingtype = "Daimaou Cape"
	Dimeowcape.clothingicon = 'ClothesDaimaouCape.dmi'
	dummyclothinglist += Dimeowcape
	var/obj/DummyClothes/Gifemale = new/obj/DummyClothes
	Gifemale.clothingtype = "Female Gi"
	Gifemale.clothingicon = 'ClothesGiFemale.dmi'
	dummyclothinglist += Gifemale
	var/obj/DummyClothes/Yardrat = new/obj/DummyClothes
	Yardrat.clothingtype = "Yardrat"
	Yardrat.clothingicon = 'ClothesFullYardrat.dmi'
	dummyclothinglist += Yardrat
	var/obj/DummyClothes/Shortfemale = new/obj/DummyClothes
	Shortfemale.clothingtype = "Short Shorts"
	Shortfemale.clothingicon = 'ClothesFemaleShorts.dmi'
	dummyclothinglist += Shortfemale
	var/obj/DummyClothes/Shirtfemale = new/obj/DummyClothes
	Shirtfemale.clothingtype = "Short Shirt"
	Shirtfemale.clothingicon = 'ClothesFemaleShirt.dmi'
	dummyclothinglist += Shirtfemale
	var/obj/DummyClothes/Goggles = new/obj/DummyClothes
	Goggles.clothingtype = "Goggles"
	Goggles.clothingicon = 'ClothesGoggles.dmi'
	dummyclothinglist += Goggles
	var/obj/DummyClothes/Horns = new/obj/DummyClothes
	Horns.clothingtype = "Horns"
	Horns.clothingicon = 'ClothesHorns.dmi'
	dummyclothinglist += Horns
	var/obj/DummyClothes/Kaishirt = new/obj/DummyClothes
	Kaishirt.clothingtype = "Kai Shirt"
	Kaishirt.clothingicon = 'ClothesKaioshirt.dmi'
	dummyclothinglist += Kaishirt
	var/obj/DummyClothes/Namekjacket = new/obj/DummyClothes
	Namekjacket.clothingtype = "Namek Jacket"
	Namekjacket.clothingicon = 'ClothesNamekJacket.dmi'
	dummyclothinglist += Namekjacket
	var/obj/DummyClothes/Ninjamask2 = new/obj/DummyClothes
	Ninjamask2.clothingtype = "Ninja Mask2"
	Ninjamask2.clothingicon = 'ClothesNinjaMask2.dmi'
	dummyclothinglist += Ninjamask2
	var/obj/DummyClothes/Bighat = new/obj/DummyClothes
	Bighat.clothingtype = "Big Hat"
	Bighat.clothingicon = 'ClothesPimpHat.dmi'
	dummyclothinglist += Bighat
	var/obj/DummyClothes/Underwear = new/obj/DummyClothes
	Underwear.clothingtype = "Underwear"
	Underwear.clothingicon = 'ClothesUnderwear.dmi'
	dummyclothinglist += Underwear
	var/obj/DummyClothes/Wolf = new/obj/DummyClothes
	Wolf.clothingtype = "Wolf Hermit"
	Wolf.clothingicon = 'ClothesWolfHermit.dmi'
	dummyclothinglist += Wolf
	var/obj/DummyClothes/Drabwolf = new/obj/DummyClothes
	Drabwolf.clothingtype = "Drab Wolf Hermit"
	Drabwolf.clothingicon = 'Crane Hermit Suit.dmi'
	dummyclothinglist += Drabwolf
	var/obj/DummyClothes/Django = new/obj/DummyClothes
	Django.clothingtype = "Dark Jango"
	Django.clothingicon = 'DarkJango.dmi'
	dummyclothinglist += Django
	var/obj/DummyClothes/Elhermano = new/obj/DummyClothes
	Elhermano.clothingtype = "El Hermano"
	Elhermano.clothingicon = 'El Hermano Suit.dmi'
	dummyclothinglist += Elhermano
	var/obj/DummyClothes/EyePatch = new/obj/DummyClothes
	EyePatch.clothingtype = "Left Eye Patch"
	EyePatch.clothingicon = 'EyePatchL.dmi'
	dummyclothinglist += EyePatch
	var/obj/DummyClothes/EyePatch1 = new/obj/DummyClothes
	EyePatch1.clothingtype = "Right Eye Patch"
	EyePatch1.clothingicon = 'EyePatchR.dmi'
	dummyclothinglist += EyePatch1
	var/obj/DummyClothes/anotherfuckingcape = new/obj/DummyClothes
	anotherfuckingcape.clothingtype = "Flowing Cape"
	anotherfuckingcape.clothingicon = 'FlowingCape.dmi'
	dummyclothinglist += anotherfuckingcape
	var/obj/DummyClothes/Hat = new/obj/DummyClothes
	Hat.clothingtype = "Hat"
	Hat.clothingicon = 'Hat.dmi'
	dummyclothinglist += Hat
	var/obj/DummyClothes/Picklecape = new/obj/DummyClothes
	Picklecape.clothingtype = "Piccolo Cape"
	Picklecape.clothingicon = 'ItemPiccoloCape.dmi'
	dummyclothinglist += Picklecape
	var/obj/DummyClothes/Shades3 = new/obj/DummyClothes
	Shades3.clothingtype = "Sunshades"
	Shades3.clothingicon = 'ItemSunGlassess.dmi'
	dummyclothinglist += Shades3
	//var/obj/DummyClothes/JACKET2 = new/obj/DummyClothes
	//JACKET2.clothingtype = "Closed Jacket"
	//JACKET2.clothingicon = 'Jacket 2.dmi'
	//dummyclothinglist += JACKET2
	var/obj/DummyClothes/Jumpsuit = new/obj/DummyClothes
	Jumpsuit.clothingtype = "Jumpsuit"
	Jumpsuit.clothingicon = 'Jumpsuit.dmi'
	dummyclothinglist += Jumpsuit
	var/obj/DummyClothes/Collar = new/obj/DummyClothes
	Collar.clothingtype = "Collar"
	Collar.clothingicon = 'NekoCollar.dmi'
	dummyclothinglist += Collar
	var/obj/DummyClothes/Phoenixfull = new/obj/DummyClothes
	Phoenixfull.clothingtype = "Phoenix Full"
	Phoenixfull.clothingicon = 'PhoenixFull.dmi'
	dummyclothinglist += Phoenixfull
	var/obj/DummyClothes/Phoenixfullmakyo = new/obj/DummyClothes
	Phoenixfullmakyo.clothingtype = "Phoenix Full Makyo"
	Phoenixfullmakyo.clothingicon = 'PhoenixFullMakyo.dmi'
	dummyclothinglist += Phoenixfullmakyo
	var/obj/DummyClothes/Phoenixfullmoon = new/obj/DummyClothes
	Phoenixfullmoon.clothingtype = "Phoenix Full Moon"
	Phoenixfullmoon.clothingicon = 'PhoenixFullMoonlight.dmi'
	dummyclothinglist += Phoenixfullmoon
	var/obj/DummyClothes/Phoenixfullnega = new/obj/DummyClothes
	Phoenixfullnega.clothingtype = "Phoenix Full Negative"
	Phoenixfullnega.clothingicon = 'PhoenixFullNegative.dmi'
	dummyclothinglist += Phoenixfullnega
	var/obj/DummyClothes/Phoenixfullnegamakyo = new/obj/DummyClothes
	Phoenixfullnegamakyo.clothingtype = "Phoenix Full Nega-makyo"
	Phoenixfullnegamakyo.clothingicon = 'PhoenixFullNegativeMakyo.dmi'
	dummyclothinglist += Phoenixfullnegamakyo
	var/obj/DummyClothes/Pridesuit = new/obj/DummyClothes
	Pridesuit.clothingtype = "Pride Trooper"
	Pridesuit.clothingicon = 'Pride Trooper Suit.dmi'
	dummyclothinglist += Pridesuit
	var/obj/DummyClothes/Sidecape = new/obj/DummyClothes
	Sidecape.clothingtype = "Side Cape"
	Sidecape.clothingicon = 'Side Cape.dmi'
	dummyclothinglist += Sidecape
	var/obj/DummyClothes/Tien = new/obj/DummyClothes
	Tien.clothingtype = "Tien Clothes"
	Tien.clothingicon = 'Tien Clothes.dmi'
	dummyclothinglist += Tien
	var/obj/DummyClothes/Toswings = new/obj/DummyClothes
	Toswings.clothingtype = "Energy Wings"
	Toswings.clothingicon = 'ToSWingsBlack.dmi'
	dummyclothinglist += Toswings
	var/obj/DummyClothes/Tuffle = new/obj/DummyClothes
	Tuffle.clothingtype = "Tuffle"
	Tuffle.clothingicon = 'TuffleTux.dmi'
	dummyclothinglist += Tuffle
	var/obj/DummyClothes/Tunic = new/obj/DummyClothes
	Tunic.clothingtype = "Tunic"
	Tunic.clothingicon = 'Tunic.dmi'
	dummyclothinglist += Tunic
	var/obj/DummyClothes/Gauntlet = new/obj/DummyClothes
	Gauntlet.clothingtype = "Gauntlet"
	Gauntlet.clothingicon = 'VVGauntletBlack.dmi'
	dummyclothinglist += Gauntlet
	// This would be a lot easier if there were a parser for the clothes file that just
	// slapped everything into a list for the mannequin to wear but whatever.
	var/dummyclothes = 0
	for(var/obj/DummyClothes/S in dummyclothinglist)
		S.overlays -= S.overlays
		S.overlays += S.clothingicon
		src<<output(S,"clothingwindow.clothgrid: 1, [++dummyclothes]")
	var/checkWindow = winget(usr,"[W]","is-visible")
	while(checkWindow=="true")
		sleep(2)
	for(var/obj/DummyClothes/S in dummyclothinglist)
		del(S)

mob/proc/pickclothes()
	var/clthcost
	var/obj/items/objtype
	switch(selection)
		if("Gi Top")
			clthcost=5
			objtype=new/obj/items/clothes/Gi_Top
		if("Gi Bottom")
			clthcost=5
			objtype=new/obj/items/clothes/Gi_Bottom
		if("Wristband")
			clthcost=5
			objtype=new/obj/items/clothes/Wristband
		if("Tank Top")
			clthcost=5
			objtype=new/obj/items/clothes/TankTop
		if("Short Sleeve Shirt")
			clthcost=10
			objtype=new/obj/items/clothes/ShortSleeveShirt
		if("Shoes")
			clthcost=5
			objtype=new/obj/items/clothes/Shoes
		if("Sash")
			clthcost=5
			objtype=new/obj/items/clothes/Sash
		if("Pants")
			clthcost=10
			objtype=new/obj/items/clothes/Pants
		if("Long Sleeve Shirt")
			clthcost=20
			objtype=new/obj/items/clothes/LongSleeveShirt
		if("Jacket")
			clthcost=50
			objtype=new/obj/items/clothes/Jacket
		if("Headband")
			clthcost=5
			objtype=new/obj/items/clothes/Headband
		if("Belt")
			clthcost=10
			objtype=new/obj/items/clothes/Belt
		if("Cape")
			clthcost=100
			objtype=new/obj/items/clothes/Cape
		if("Hood")
			clthcost=5
			objtype=new/obj/items/clothes/Hood
		if("Waist Robe")
			clthcost=5
			objtype=new/obj/items/clothes/WaistRobe
		if("Shades")
			clthcost=50
			objtype=new/obj/items/clothes/Shades
		if("Namekian Scarf")
			clthcost=5
			objtype=new/obj/items/clothes/NamekianScarf
		if("Turban")
			clthcost=5
			objtype=new/obj/items/clothes/Turban
		if("Boots")
			clthcost=5
			objtype=new/obj/items/clothes/Boots
		if("Boba Helmet")
			clthcost=50
			objtype=new/obj/items/clothes/Boba
		if("Broly Waistrobe")
			clthcost=10
			objtype=new/obj/items/clothes/BrolyWaistrobe
		if("Arm Pads")
			clthcost=5
			objtype=new/obj/items/clothes/ArmPads
		if("Backpack")
			clthcost=5
			objtype=new/obj/items/clothes/Backpack
		if("Daimaou")
			clthcost=10
			objtype=new/obj/items/clothes/Daimaou
		if("Guardian")
			clthcost=10
			objtype=new/obj/items/clothes/Guardian
		if("Kaio Suit")
			clthcost=20
			objtype=new/obj/items/clothes/KaioSuit
		if("Kung Fu Shirt")
			clthcost=5
			objtype=new/obj/items/clothes/KungFu
		if("Tuxedo")
			clthcost=500
			objtype=new/obj/items/clothes/Tux
		if("Demon Arm")
			clthcost=5
			objtype=new/obj/items/clothes/DemonArm
		if("Kimono")
			clthcost=5
			objtype=new/obj/items/clothes/Kimono
		if("Neko")
			clthcost=5
			objtype=new/obj/items/clothes/Neko
		if("Ninja Mask")
			clthcost=5
			objtype=new/obj/items/clothes/NinjaMask
		if("Saiyan Gloves")
			clthcost=10
			objtype=new/obj/items/clothes/SaiyanGloves
		if("Saiyan Shoes")
			clthcost=10
			objtype=new/obj/items/clothes/SaiyanShoes
		if("Saiyan Suit")
			clthcost=10
			objtype=new/obj/items/clothes/SaiyanSuit
			//Don't lose your place fugger
		if("Angel Wings")
			clthcost=777
			objtype=new/obj/items/clothes/Angelwings
		if("Gray Ninja Suit")
			clthcost=200
			objtype=new/obj/items/clothes/Graysuit
		if("Tech Helmet")
			clthcost=100
			objtype=new/obj/items/clothes/Weirdhelmet
		if("Crane Outfit")
			clthcost=35
			objtype=new/obj/items/clothes/Crane
		if("Arm Bands")
			clthcost=10
			objtype=new/obj/items/clothes/Armbands
		if("Bustier")
			clthcost=25
			objtype=new/obj/items/clothes/Bustier
		if("Windblown Cape")
			clthcost=30
			objtype=new/obj/items/clothes/Cape2
		if("Celes Robe")
			clthcost=55
			objtype=new/obj/items/clothes/Celes
		if("SOLDIER Suit")
			clthcost=100
			objtype=new/obj/items/clothes/SOLDIER
		if("Cross Gi")
			clthcost=25
			objtype=new/obj/items/clothes/CGi
		if("Jacket and Pants")
			clthcost=10
			objtype=new/obj/items/clothes/Jacketandpants
		if("Windblown Headband")
			clthcost=10
			objtype=new/obj/items/clothes/Headband2
		if("Hit Robe")
			clthcost=10
			objtype=new/obj/items/clothes/Hitrobe
		if("Hooded Cloak")
			clthcost=100
			objtype=new/obj/items/clothes/Hoodedcloak
		if("XIII Hooded Cloak")
			clthcost=1300
			objtype=new/obj/items/clothes/Thirteen
		if("XIII Cloak")
			clthcost=1300
			objtype=new/obj/items/clothes/Thirteennohood
		if("Kai Suit")
			clthcost=30
			objtype=new/obj/items/clothes/Kaisuit2
		if("Vegeta Cape")
			clthcost=100000
			objtype=new/obj/items/clothes/Vegetacape
		if("Long Coat")
			clthcost=100
			objtype=new/obj/items/clothes/Longcoat
		if("Ronin")
			clthcost=25
			objtype=new/obj/items/clothes/Roningi
		if("Red and Blue Mask")
			clthcost=10
			objtype=new/obj/items/clothes/Oddmask
		if("Long Scarf")
			clthcost=10
			objtype=new/obj/items/clothes/Longscarf
		if("Large Sunglasses")
			clthcost=10
			objtype=new/obj/items/clothes/Coolglasses
		if("Tank Top and Pants")
			clthcost=10
			objtype=new/obj/items/clothes/Tanktopandpants
		if("Turtle Suit")
			clthcost=10
			objtype=new/obj/items/clothes/Turtle
		if("Time Patrol Coat")
			clthcost=10
			objtype=new/obj/items/clothes/Timepatrol
		if("Warrior Pants")
			clthcost=10
			objtype=new/obj/items/clothes/Warriorpants
		if("Assassin Suit")
			clthcost=10
			objtype=new/obj/items/clothes/Ass
		if("Assassin Hoodless")
			clthcost=10
			objtype=new/obj/items/clothes/Assass
		if("Book")
			clthcost=10
			objtype=new/obj/items/clothes/Book
		if("Small Cloak")
			clthcost=10
			objtype=new/obj/items/clothes/Smallcloak
		if("Daimaou Cape")
			clthcost=10
			objtype=new/obj/items/clothes/Dimeowcape
		if("Female Gi")
			clthcost=10
			objtype=new/obj/items/clothes/Gifemale
		if("Yardrat")
			clthcost=10
			objtype=new/obj/items/clothes/Yardrat
		if("Short Shorts")
			clthcost=10
			objtype=new/obj/items/clothes/Shortfemale
		if("Short Shirt")
			clthcost=10
			objtype=new/obj/items/clothes/Shirtfemale
		if("Goggles")
			clthcost=10
			objtype=new/obj/items/clothes/Goggles
		if("Kai Shirt")
			clthcost=10
			objtype=new/obj/items/clothes/Kaishirt
		if("Namek Jacket")
			clthcost=10
			objtype=new/obj/items/clothes/Namekjacket
		if("Ninja Mask 2")
			clthcost=10
			objtype=new/obj/items/clothes/Ninjamask2
		if("Big Hat")
			clthcost=10
			objtype=new/obj/items/clothes/Bighat
		if("Underwear")
			clthcost=10
			objtype=new/obj/items/clothes/Underwear
		if("Wolf Hermit")
			clthcost=10
			objtype=new/obj/items/clothes/Wolf
		if("Drab Wolf Hermit")
			clthcost=10
			objtype=new/obj/items/clothes/Drabwolf
		if("Dark Jango")
			clthcost=10
			objtype=new/obj/items/clothes/Django
		if("El Hermano")
			clthcost=10
			objtype=new/obj/items/clothes/Elhermano
		if("Left Eye Patch")
			clthcost=10
			objtype=new/obj/items/clothes/EyePatch
		if("Right Eye Patch")
			clthcost=10
			objtype=new/obj/items/clothes/EyePatch1
		if("Flowing Cape")
			clthcost=25
			objtype=new/obj/items/clothes/anotherfuckingcape
		if("Hat")
			clthcost=10
			objtype=new/obj/items/clothes/Hat
		if("Piccolo Cape")
			clthcost=20
			objtype=new/obj/items/clothes/Picklecape
		if("Sunshades")
			clthcost=50
			objtype=new/obj/items/clothes/Shades3
		//if("Closed Jacket")
			//clthcost=20
			//objtype=new/obj/items/clothes/JACKET2
		if("Jumpsuit")
			clthcost=20
			objtype=new/obj/items/clothes/Jumpsuit
		if("Collar")
			clthcost=10
			objtype=new/obj/items/clothes/Collar
		if("Phoenix Full")
			clthcost=100
			objtype=new/obj/items/clothes/Phoenixfull
		if("Phoenix Full Makyo")
			clthcost=100
			objtype=new/obj/items/clothes/Phoenixfullmakyo
		if("Phoenix Full Moon")
			clthcost=100
			objtype=new/obj/items/clothes/Phoenixfullmoon
		if("Phoenix Full Negative")
			clthcost=100
			objtype=new/obj/items/clothes/Phoenixfullnega
		if("Phoenix Full Nega-makyo")
			clthcost=100
			objtype=new/obj/items/clothes/Phoenixfullnegamakyo
		if("Pride Trooper")
			clthcost=1337
			objtype=new/obj/items/clothes/Pridesuit
		if("Side Cape")
			clthcost=10
			objtype=new/obj/items/clothes/Sidecape
		if("Tien Clothes")
			clthcost=20
			objtype=new/obj/items/clothes/Tien
		if("Energy Wings")
			clthcost=550
			objtype=new/obj/items/clothes/Toswings
		if("Tuffle")
			clthcost=30
			objtype=new/obj/items/clothes/Tuffle
		if("Tunic")
			clthcost=10
			objtype=new/obj/items/clothes/Tunic
		if("Gauntlet")
			clthcost=10
			objtype=new/obj/items/clothes/Gauntlet
// Now go fucking edit Clothes.dm-- Tomorrow once you actually've had some sleep.
	if(selection)
		usr.Clothes(clthcost,objtype)

mob/proc/Clothes(var/clthcost,var/obj/items/objtype)
	//set waitfor = 0
	switch(input("This will cost [clthcost] zenni, accept?", "", text) in list ("Yes", "No",))
		if("Yes")
			if(usr.zenni>=clthcost)
				usr.zenni-=clthcost
				var/newrgb
				newrgb=input("Choose a color.","Color",0) as color
				var/list/oldrgb=0
				oldrgb=hrc_hex2rgb(newrgb,1)
				while(!oldrgb)
					sleep(1)
					oldrgb=hrc_hex2rgb(newrgb,1)
				objtype.icon += rgb(oldrgb[1],oldrgb[2],oldrgb[3])
				usr.contents+=objtype
			else
				usr<<"You do not have enough money."
				del(objtype)