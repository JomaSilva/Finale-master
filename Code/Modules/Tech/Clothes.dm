obj/overlay/clothes/clothes_handler //specific item
	name = "Clothes" //unique name
	ID = 458 //unique ID Just realized it doesn't have to be a numero.
	EffectLoop()
		..()
		if(container.Apeshit)
			alpha = 1
		else alpha = 255

obj/items/clothes
	plane = CLOTHES_LAYER
	stackable=0
	layer = 5
	var/clothid
	New()
		..()
		if(!clothid) clothid = rand(1,100000)
	verb/Change_Icon()
		set category=null
		set src in view(1)
		if(!equipped)
			icon = input(usr,"Pick some clothing.","Pick a icon.",'Clothes_TankTop.dmi') as icon
			icon_state = input(usr,"Icon state, if applicable.") as text
			pixel_x = input(usr,"Pixel X","",pixel_x) as num
			pixel_y = input(usr,"Pixel Y","",pixel_y) as num
			switch(input(usr,"Plane? Clothes layer (under hair) or Hat layer (over hair)?" in list("Clothes","Hat")))
				if("Clothes") plane=CLOTHES_LAYER
				if("Hat") plane=HAT_LAYER
	verb/Rename()
		set category=null
		set src in view(1)
		name = input(usr,"Name?","Pick a name.","clothing") as text
	verb/Equip()
		set category=null
		set src in usr
		if(equipped==0)
			equipped=1
			suffix="*Equipped*"
			usr.updateOverlaycID(/obj/overlay/clothes/clothes_handler,icon,null,null,null,"[clothid]")
			usr.overlayStats(/obj/overlay/clothes/clothes_handler,"[clothid]",plane,pixel_x,pixel_y)
			usr<<"You put on the [src]."
		else
			equipped=0
			suffix=""
			usr.removeOverlayID(/obj/overlay/clothes/clothes_handler,"[clothid]")
			usr<<"You take off the [src]."
	turtleshell
		dropProbability=0.5
		icon='Turtle Shell 2.dmi'
	Belt
		icon='Clothes_Belt.dmi'
		NotSavable=1
	Cape
		icon='Clothes_Cape.dmi'
		NotSavable=1
	Gi_Bottom
		icon='Clothes_GiBottom.dmi'
		NotSavable=1
	Gi_Top
		icon='Clothes_GiTop.dmi'
		NotSavable=1
	Nocci_Suit
		icon='Red cool Custom Suit(edited).dmi'
		NotSavable=1
	Hood
		icon='Clothes_Hood.dmi'
		NotSavable=1
		plane=HAT_LAYER
	WaistRobe
		icon='Clothes_WaistRobe.dmi'
		NotSavable=1
	Shades
		icon='Clothes_Shades.dmi'
		NotSavable=1
		plane=HAT_LAYER
	RedMask
		icon='Clothing_WhiteandRedMask.dmi'
		NotSavable=1
		plane=HAT_LAYER
	EyePatch
		name="EyePatch Left"
		icon='EyePatchL.dmi'
		NotSavable=1
	EyePatch1
		name="EyePatch Right"
		icon='EyePatchR.dmi'
		NotSavable=1
	YellowSuit
		icon='Yellow suit.dmi'
		NotSavable=1
	BlueSuit
		icon='Blue suit.dmi'
		NotSavable=1
	GoldSuit
		icon='Guild Armor Gold.dmi'
		NotSavable=1

	Wristband
		icon='Clothes_Wristband.dmi'
		NotSavable=1
	Turban
		icon='Clothes_Turban.dmi'
		NotSavable=1
		plane=HAT_LAYER
	TankTop
		icon='Clothes_TankTop.dmi'
		NotSavable=1
	ShortSleeveShirt
		icon='Clothes_ShortSleeveShirt.dmi'
		NotSavable=1
	Shoes
		icon='Clothes_Shoes.dmi'
		NotSavable=1
	Sash
		icon='Clothes_Sash.dmi'
		NotSavable=1
	Pants
		icon='Clothes_Pants.dmi'
		NotSavable=1
	NamekianScarf
		icon='Clothes_NamekianScarf.dmi'
		NotSavable=1
	LongSleeveShirt
		icon='Clothes_LongSleeveShirt.dmi'
		NotSavable=1
	KaioSuit
		icon='Clothes Elder Kaio.dmi'
		NotSavable=1
	Jacket
		icon='Clothes_Jacket.dmi'
		NotSavable=1
	Headband
		icon='Clothes_Headband.dmi'
		NotSavable=1
		plane=HAT_LAYER
	Gloves
		icon='Clothes_Gloves.dmi'
		NotSavable=1
	Boots
		icon='Clothes_Boots.dmi'
		NotSavable=1
	Bandana
		icon='Clothes_Bandana.dmi'
		NotSavable=1
	Boba
		icon='BobaFett.dmi'
		NotSavable=1
	BrolyWaistrobe
		icon='BrolyWaistrobe.dmi'
		NotSavable=1
	ArmPads
		icon='Clothes Arm Pads.dmi'
		NotSavable=1
	Backpack
		icon='Clothes Backpack.dmi'
		NotSavable=1
	Daimaou
		icon='Clothes Daimaou.dmi'
		NotSavable=1
	Guardian
		icon='Clothes Guardian.dmi'
		NotSavable=1
	KungFu
		icon='Clothes Kung Fu Shirt.dmi'
		NotSavable=1
	Tux
		icon='Clothes Tuxedo.dmi'
		NotSavable=1
	DemonArm
		icon='Clothes, Demon Arm.dmi'
		NotSavable=1
	Kimono
		icon='Clothes, Kimono.dmi'
		NotSavable=1
	Neko
		icon='Clothes, Neko.dmi'
		NotSavable=1
	NinjaMask
		icon='Clothes, Ninja Mask.dmi'
		NotSavable=1
	SaiyanGloves
		icon='Clothes, Saiyan Gloves.dmi'
		NotSavable=1
	SaiyanShoes
		icon='Clothes, Saiyan Shoes.dmi'
		NotSavable=1
	SaiyanSuit
		icon='Clothes_SaiyanSuit.dmi'
		NotSavable=1
	Angelwings
		icon='Angel Wings.dmi'
		NotSavable=1
	Graysuit
		icon='Gray suit.dmi'
		NotSavable=1
	Weirdhelmet
		icon='Clothes Helmet.dmi'
		NotSavable=1
	Crane
		icon='ClothesTsurusennin.dmi'
		NotSavable=1
	Armbands
		icon='Clothes_ArmBands.dmi'
		NotSavable=1
	Bustier
		icon='Clothes_Bustier.dmi'
		NotSavable=1
	Cape2
		icon='Clothes_Cape2.dmi'
		NotSavable=1
	Celes
		icon='Clothes_CelesRobe.dmi'
		NotSavable=1
	SOLDIER
		icon='Clothes_CloudSOLDIER.dmi'
		NotSavable=1
	CGi
		icon='Clothes_GiCustom.dmi'
		NotSavable=1
	Jacketandpants
		icon='Clothes_GokuJacketandPants.dmi'
		NotSavable=1
	Headband2
		icon='Clothes_Headband2.dmi'
		NotSavable=1
	Hitrobe
		icon='Clothes_Hit.dmi'
		NotSavable=1
	Hoodedcloak
		icon='Clothes_Hooded Cloak 2.dmi'
		NotSavable=1
	Thirteen
		icon='Clothes_HoodedCloak.dmi'
		NotSavable=1
	Thirteennohood
		icon='Clothes_HoodlessCloak.dmi'
		NotSavable=1
	Kaisuit2
		icon='Clothes_Kaiosuit.dmi'
		NotSavable=1
	Vegetacape
		icon='Clothes_KingVegetaCape.dmi'
		NotSavable=1
	Longcoat
		icon='ClothesNeroJacket.dmi'
		NotSavable=1
	Roningi
		icon='Clothes_Ronin.dmi'
		NotSavable=1
	Oddmask
		icon='Clothes_SaiyanMask.dmi'
		NotSavable=1
	Longscarf
		icon='Clothes_Scarf.dmi'
		NotSavable=1
	Beltbuckle
		icon='Clothes_BeltBuckle.dmi'
		NotSavable=1
	Coolglasses
		icon='Clothes_ShadesCool.dmi'
		NotSavable=1
	Tanktopandpants
		icon='Clothes_TankTopandPants.dmi'
		NotSavable=1
	Turtle
		icon='Clothes_TurtleSuit.dmi'
		NotSavable=1
	Timepatrol
		icon='Clothes_TimePatrolCoat.dmi'
		NotSavable=1
	Warriorpants
		icon='Clothes_WarriorPants.dmi'
		NotSavable=1
	Ass
		icon='ClothesAssassin.dmi'
		NotSavable=1
	Assass
		icon='ClothesAssassinHoodless.dmi'
		NotSavable=1
	Book
		icon='ClothesBook.dmi'
		NotSavable=1
	Smallcloak
		icon='ClothesCape2.dmi'
		NotSavable=1
	Dimeowcape
		icon='ClothesDaimaouCape.dmi'
		NotSavable=1
	Gifemale
		icon='ClothesGiFemale.dmi'
		NotSavable=1
	Yardrat
		icon='ClothesFullYardrat.dmi'
		NotSavable=1
	Shortfemale
		icon='ClothesFemaleShorts.dmi'
		NotSavable=1
	Shirtfemale
		icon='ClothesFemaleShirt.dmi'
		NotSavable=1
	Goggles
		icon='ClothesGoggles.dmi'
		NotSavable=1
	Horns
		icon='ClothesHorns.dmi'
		NotSavable=1
	Kaishirt
		icon='ClothesKaioshirt.dmi'
		NotSavable=1
	Namekjacket
		icon='ClothesNamekJacket.dmi'
		NotSavable=1
	Ninjamask2
		icon='ClothesNinjaMask2.dmi'
		NotSavable=1
	Bighat
		icon='ClothesPimpHat.dmi'
		NotSavable=1
	Underwear
		icon='ClothesUnderwear.dmi'
		NotSavable=1
	Wolf
		icon='ClothesWolfHermit.dmi'
		NotSavable=1
	Drabwolf
		icon='Crane Hermit Suit.dmi'
		NotSavable=1
	Django
		icon='DarkJango.dmi'
		NotSavable=1
	Elhermano
		icon='El Hermano Suit.dmi'
		NotSavable=1
	anotherfuckingcape
		icon='FlowingCape.dmi'
		NotSavable=1
	Hat
		icon='Hat.dmi'
		NotSavable=1
	Picklecape
		icon='ItemPiccoloCape.dmi'
		NotSavable=1
	Shades3
		icon='ItemSunGlassess.dmi'
		NotSavable=1
	//JACKET2
	//	icon='Jacket 2.dmi'
	//	NotSavable=1
	Jumpsuit
		icon='Jumpsuit.dmi'
		NotSavable=1
	Collar
		icon='NekoCollar.dmi'
		NotSavable=1
	Phoenixfull
		icon='PhoenixFull.dmi'
		NotSavable=1
	Phoenixfullmakyo
		icon='PhoenixFullMakyo.dmi'
		NotSavable=1
	Phoenixfullmoon
		icon='PhoenixFullMoonlight.dmi'
		NotSavable=1
	Phoenixfullnega
		icon='PhoenixfullNegative.dmi'
		NotSavable=1
	Phoenixfullnegamakyo
		icon='PhoenixfullNegativeMakyo.dmi'
		NotSavable=1
	Pridesuit
		icon='Pride Trooper Suit.dmi'
		NotSavable=1
	Sidecape
		icon='Side Cape.dmi'
		NotSavable=1
	Tien
		icon='Tien Clothes.dmi'
		NotSavable=1
	Toswings
		icon='ToSWingsBlack.dmi'
		NotSavable=1
	Tuffle
		icon='TuffleTux.dmi'
		NotSavable=1
	Tunic
		icon='Tunic.dmi'
		NotSavable=1
	Gauntlet
		icon='VVGauntletBlack.dmi'
		NotSavable=1