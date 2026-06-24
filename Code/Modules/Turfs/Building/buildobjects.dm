obj/buildables
	canbuild=1
	mouse_opacity=1
	IsntAItem=1
	tpalm
		icon='turfs.dmi'
		icon_state="1"
		layer=MOB_LAYER+1
		New()
			..()
			icon=null
			icon_state=null
			var/amount=6
			while(amount)
				var/image/I=image(icon='turfs.dmi',icon_state="[amount]")
				if(amount==6)
					I.pixel_x+=16
					I.pixel_y+=64
				if(amount==5)
					I.pixel_x-=16
					I.pixel_y+=64
				if(amount==4)
					I.pixel_x+=16
					I.pixel_y+=32
				if(amount==3)
					I.pixel_x-=16
					I.pixel_y+=32
				if(amount==2) I.pixel_x+=16
				if(amount==1) I.pixel_x-=16
				overlays+=I
				amount-=1
	o37
		icon='Turf3.dmi'
		icon_state="168"
		density=1
	o38
		icon='Turf3.dmi'
		icon_state="169"
		density=1
	table
		icon='turfs.dmi'
		icon_state="Table"
		density=1
	grain1
		icon='Turfs 1.dmi'
		icon_state="grain1"
	Sign
		icon='Sign.dmi'
		density=1
		var/Message="<font color=#FF0000>Nothing is written on this sign..."
		Click() usr<<"[Message]"
		verb/ChangeMessage()
			set category=null
			set src in oview(1)
			Message=input("") as text
	Statue
		icon='Turf 57.dmi'
		icon_state="101"
		density=1
		var/Words="<font color=#FF0000>Nothing is written on this statue..."
		Click() usr<<"[Words]"
		verb/ChangeWords()
			set category=null
			set src in oview(1)
			Words=input("") as text
	glass1
		icon='Space.dmi'
		icon_state="glass1"
		density=1
		layer=MOB_LAYER+1
	tableL
		icon='Turfs 2.dmi'
		icon_state="tableL"
		density=1
	tableR
		icon='Turfs 2.dmi'
		icon_state="tableR"
		density=1
	tableM
		icon='Turfs 2.dmi'
		icon_state="tableM"
		density=1
	borderN
		icon='Misc.dmi'
		icon_state="N"
		density=1
	borderS
		icon='Misc.dmi'
		icon_state="S"
		density=1
	borderE
		icon='Misc.dmi'
		icon_state="E"
		density=1
	borderW
		icon='Misc.dmi'
		icon_state="W"
		density=1
	waterfall
		icon='Turfs 1.dmi'
		icon_state="waterfall"
		density=1
		layer=MOB_LAYER+1
	lightwaterfall
		icon='Turfs 1.dmi'
		icon_state="lightwaterfall"
		density=1
		layer=MOB_LAYER+1
	flowers
		icon='Turfs 1.dmi'
		icon_state="flowers"
	barrel
		icon='Turfs 2.dmi'
		icon_state="barrel"
		density=1
	chair
		icon='turfs.dmi'
		icon_state="Chair"
	strangetree
		icon='Turfs 1.dmi'
		icon_state="smalltree"
		density=1
	smalltree
		icon='Turfs 2.dmi'
		icon_state="treeb"
		density=1
	bedS
		icon='Turfs 2.dmi'
		icon_state="BEDL"
	bedN
		icon='Turfs 2.dmi'
		icon_state="BEDR"
	tree2
		icon='Turfs 5.dmi'
		icon_state="tree"
		density=1
	box2
		icon='Turfs 5.dmi'
		icon_state="box"
		density=1
	deadtree
		icon='Trees.dmi'
		icon_state="Dead Tree1"
		density=1
	tree2
		icon='Trees.dmi'
		icon_state="Tree1"
		density=1
	trees3
		icon='tree3.dmi'
		density=1
	trees2
		icon='turfs.dmi'
		icon_state="bush"
		density=1
	CURSES
		icon='Icons.dmi'
		icon_state="CURSES!"
		density=1
	trees1
		icon='turfs.dmi'
		icon_state="groundPlant"
		density=1
	Torch1
		icon='Turf2.dmi'
		icon_state="168"
		density=1
	Torch2
		icon='Turf2.dmi'
		icon_state="169"
		density=1
	o3
		icon='Turf1.dmi'
		icon_state="knife"
		density=1
	o4
		icon='Turf1.dmi'
		icon_state="axe"
		density=1
	o5
		icon='Turf1.dmi'
		icon_state="sword crisscross"
		density=1
	o6
		icon='Turf1.dmi'
		icon_state="ladder"
		density=0
	o7
		icon='Turf1.dmi'
		icon_state="bow"
		density=0
	o8
		icon='Turf1.dmi'
		icon_state="arrow"
		density=0
	o34
		icon='Turf3.dmi'
		icon_state="161"
	o35
		icon='Turf3.dmi'
		icon_state="163"
	o36
		icon='Turf3.dmi'
		icon_state="167"
	o50
		icon='Turfs 5.dmi'
		icon_state="computer"
	o52
		icon='Turfs 5.dmi'
		icon_state="ssystem"
	o53
		icon='Turfs 5.dmi'
		icon_state="micro"
	frozentree
		icon='Turfs 1.dmi'
		icon_state="frozentree"
		density=1
	brownrock
		icon='Turfs 1.dmi'
		icon_state="rock2"
		density=1
	earthrock
		icon='Turfs 2.dmi'
		icon_state="rock"
	Fire
		name="fire"
		icon='Turf 57.dmi'
		icon_state="82"
		density=1
		isFire=1
	TV
		name="TV"
		icon='Lab.dmi'
		icon_state="tv"
		density=1
	PC
		name="PC"
		icon='Lab.dmi'
		icon_state="pc"
	Stove
		name="Stove"
		icon='Lab.dmi'
		icon_state="Stove"
		density=1
	Microwave
		name="Microwave"
		icon='Lab.dmi'
		icon_state="micro"
	Console
		name="Console"
		icon='Lab.dmi'
		icon_state="console"
	Intercom
		name="Intercom"
		icon='Lab.dmi'
		icon_state="com"
	ATM
		name="ATM"
		icon='Lab.dmi'
		icon_state="ATM"
	Files
		name="Filing Cabients"
		icon='Lab.dmi'
		icon_state="Files"
	Computer2
		name="Computer2"
		icon='Lab.dmi'
		icon_state="Computer2"
	Bed
		name="Bed"
		icon='64x64tech.dmi'
		icon_state="Bed"
	Bookshelf
		name="Bookshelf"
		icon='64x64tech.dmi'
		icon_state="books"
	Cabient
		name="Cabient"
		icon='64x64tech.dmi'
		icon_state="cabient"
	Straps
		name="Straps"
		icon='64x64tech.dmi'
		icon_state="straps"
	miscdesk
		name="miscdesk"
		icon='64x64tech.dmi'
		icon_state="miscdesk"
	stoveside
		name="stoveside"
		icon='64x64tech.dmi'
		icon_state="stoveside"
		isFire=1
	sink
		name="sink"
		icon='64x64tech.dmi'
		icon_state="sink"
	drawer
		name="drawer"
		icon='!!!  house furniture.dmi'
		icon_state="drawer"
	piano
		name="piano"
		icon='!!!  house furniture.dmi'
		icon_state="piano"
		density=1
	stool
		name="stool"
		icon='!!!  house furniture.dmi'
		icon_state="stool"
	rtable
		name="rtable"
		icon='!!!  house furniture.dmi'
		icon_state="rtable"
		density=1
	basket
		name="basket"
		icon='!!!  house furniture.dmi'
		icon_state="basket"
	stove
		name="stove"
		icon='!!!  house furniture.dmi'
		icon_state="stove"
		isFire=1
		density=1
	lamp
		name="lamp"
		icon='!!!  house furniture.dmi'
		icon_state="lamp"
		isFire=1
	clock
		name="clock"
		icon='!!!  house furniture.dmi'
		icon_state="clock"
	thronewhite
		name="throne white"
		icon='Thrones.dmi'
		icon_state="white"
	thronered
		name="throne red"
		icon='Thrones.dmi'
		icon_state="red"
	throneyell
		name="throne yellow"
		icon='Thrones.dmi'
		icon_state="yellow"
	thronejade
		name="throne jade"
		icon='Thrones.dmi'
		icon_state="jade"
	throneblack
		name="throne black"
		icon='Thrones.dmi'
		icon_state="black"
	thronepink
		name="throne pink"
		icon='Thrones.dmi'
		icon_state="pink"
	throneblue
		name="throne blue"
		icon='Thrones.dmi'
		icon_state="blue"
	thronetie
		name="throne tiedye"
		icon='Thrones.dmi'
		icon_state="tiedye"
	thronegold
		name="throne gold"
		icon='Thrones.dmi'
		icon_state="gold"
	thronesilver
		name="throne silver"
		icon='Thrones.dmi'
		icon_state="silver"
	thronedragon
		name="throne dragon"
		icon='Thrones.dmi'
		icon_state="dragon"
	thronebronze
		name="throne bronze"
		icon='Thrones.dmi'
		icon_state="bronze"
	throneevil
		name="throne evil"
		icon='Thrones.dmi'
		icon_state="evil"
	thronesmallwhite
		name="throne small-white"
		icon='Thrones.dmi'
		icon_state="small-white"