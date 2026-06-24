//list of weapons under the new equipment system
//relevant variables:
//damage: bonus damge per hit, additive
//penetration: ignores armor, additive
//accuracy: overcomes dodge, additive
//speed: how long it takes to swing, multiplicative, bigger number = slower
mob/var//what weapons do you have equipped?
	weaponeq
	list/WeaponEQ = list()
	twohanding = 0
	unarmed = 1
var/DevilArmsToggle = 1
var/mob/container = null
mob/var
	daattunement=0
	daequip=0
	dtthreshold=5000

mob/Admin3/verb/Toggle_Yamato()
	set category = "Admin"
	if(DevilArmsToggle)
		DevilArmsToggle=0
		for(var/obj/items/Equipment/Weapon/Sword/Yamato/S in world)
			del(S)
			world << "Yamato off. Yamato will now spawn upon clearing the Boss Rush."
	else
		DevilArmsToggle=1
		world << "Yamato on. Yamato will no longer spawn upon clearing the Boss Rush."

obj/items/Equipment/Weapon//variables for the base types
	slots= list(/datum/Body/Arm/Hand)
	weapon=1
	Sword
		icon='Sword_Trunks.dmi'
		wtype="Sword"
	Axe
		icon='Axe.dmi'
		wtype="Axe"
	Staff
		icon='Roshi Stick.dmi'
		wtype="Staff"
	Spear
		icon='spear.dmi'
		wtype="Spear"
	Club
		icon='Club.dmi'
		wtype="Club"
	Hammer
		icon='Hammer.dmi'
		wtype="Hammer"
	Shield
		icon='ShieldGrey.dmi'
		wtype="Shield"

obj/items/Equipment/Weapon/Sword//sword list
	Short_Sword
		name="Short Sword"
		desc="A basic sword."
		icon='Generic Knight Sword.dmi'
		damage=1
		accuracy=1

	Long_Sword
		name="Long Sword"
		desc="A sword with a long blade."
		icon='Sword_Trunks.dmi'
		damage=1.5
		accuracy=1
		penetration=1

	Great_Sword
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
		name="Great Sword"
		desc="A large sword that requires two hands to wield."
		icon='Sword1.dmi'
		damage=3.2
		accuracy=-2
		penetration=1
		speed=1.2

	Broad_Sword
		name="Broad Sword"
		desc="A sword with a wide blade."
		icon='Generic Knight Sword.dmi'
		rarity=2
		damage=2
		accuracy=1

	Katana
		name="Katana"
		desc="A sword with a curved blade. Faster than a normal sword."
		icon='ItemKatana.dmi'
		rarity=2
		damage=1.5
		penetration=3
		speed=0.9
//T7
	Master_Sword
		name="Master Sword"
		icon='HerosSword.dmi'
		icon_state=""
		desc="The Blade of Evil's Bane. A holy sword that can only be wielded by those with a courageous and righteous heart."
		rarity=7
		damage=10
		penetration=5
		accuracy=1
		speed=1.1
	Masamune
		name="Masamune"
		icon='ItemKatana.dmi'
		desc="A holy and venerated blade designed to combat evil. Attacking those with no affiliation to darkness will heal their wounds and potentially revive the dead."
		rarity=7
		damage=7
		penetration=8
		accuracy=1
		speed=0.8
	Dainsleif
		name="D�insleif"
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
		desc="A dark two-handed sword destined to take a life every time it is unsheathed. The sword can potentially inflict incurable wounds on an opponent."
		rarity=7
		damage=25
		penetration=6
		accuracy=-1.2
		speed=1.3

	Sparda
		name="Sparda"
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
		icon='YinYang.dmi'
		icon_state=""
		desc="A legendary demonic weapon. You feel it touch your very soul..."
		rarity=7
		damage=30
		penetration=4
		speed=1.1
		accuracy=1.1
	Rebellion
		name="Rebellion"
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
		icon='ItemSword1.dmi'
		icon_state=""
		desc="A legendary demonic weapon. You feel it touch your very soul..."
		rarity=7
		damage=20
		penetration=8
		speed=1.3
		accuracy=1
	Yamato
		slots= list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
		icon='Yamato.dmi'
		icon_state=""
		desc="A legendary demonic weapon that can cut through the fabric of reality. You feel it touch your very soul..."
		rarity=7
		damage=14
		penetration=10
		speed=0.8
		accuracy=1
		verb/Yamato_Unseal()
			set category="Skills"
			set src in usr
			if(!equipped)
				usr << "You must equip [src] before using this."
				return
			if(usr.isSealed==0)
				usr << "This abilty is for unsealing yourself if you have been sealed. You are currently not sealed, and thus cannot use the skill. (If this is not the case, contact an admin for help.)"
				return
			else if(usr.isSealed==1)
				var/choice = input("You can use the Yamato to unseal you from here, if you'd like.", "", text) in list ("Yes","No",)
				if(choice!="No")
					usr.UnSealMob()
		verb/Yamato_Teleport()
			set category="Skills"
			set src in usr
			if(!equipped)
				usr << "You must equip [src] before using this."
				return
			if(!usr.KO&&usr.canfight&&!usr.med&&!usr.train&&usr.Planet!="Sealed"&&!usr.inteleport)
				view(6)<<"[usr] grabs the hilt of sword and concentrates."
				var/choice = input("The Yamato can tear open a portal to Hell. The trip is one-way, however.", "", text) in list ("Hell","Nevermind",)
				if(choice!="Nevermind")
					view(6)<<"[usr] tears a hole in reality and suddenly disappears!"
					usr.inteleport=1
					usr.BRAllowed=0
					usr.emit_Sound('YamatoJudgementCut.wav')
					spawn for(var/mob/V in oview(1))
						view(6)<<"[V] suddenly disappears!"
						if(!V.inteleport)
							V.inteleport=1
							while(usr.inteleport)
								sleep(1)
							V.loc = locate(usr.x,usr.y,usr.z)
							V.inteleport=0
							V<<"[usr] brings you with them using teleportation."
							view(6)<<"[V] suddenly appears!"
					usr.GotoPlanet(choice)
					usr.inteleport=0
					usr.emit_Sound('YamatoJudgementCut.wav')
					spawn(1)
						view(6)<<"[usr] suddenly appears!"
				else return
			else usr<<"You need full ki and total concentration to use this."

obj/items/Equipment/Weapon/Axe//axe list
	Crude_Axe
		name="Crude Axe"
		desc="A shoddy axe."
		damage=1.5
		speed=1.05

	Heavy_Axe
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
		name="Heavy Axe"
		desc="A heavy axe, requiring two hands to use."
		damage=3
		accuracy=-2
		speed=1.2

	Hatchet
		name="Hatchet"
		desc="A small axe, used for chopping branches."
		rarity=2
		damage=1.5
		accuracy=2

	Battle_Axe
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
		name="Battle Axe"
		desc="A sharp axe intended for battle. Uses two hands."
		damage=3.5
		accuracy=-3
		speed=1.2

	Aymr
		name="Aymr"
		desc="An ancient war axe with freezing properties. It is said to devastate the earth in times of war."
		rarity=7
		damage=15
		accuracy=-1.3
		speed=1.1

obj/items/Equipment/Weapon/Staff//staff list
	Stick
		name="Stick"
		desc="A simple stick."
		damage=0.5
		accuracy=2
		speed=0.975

	Short_Staff
		name="Short Staff"
		desc="A short, carved rod used for smacking things."
		damage=0.75
		accuracy=1
		speed=0.95

	Staff
		name="Staff"
		desc="A piece of carved wood, used for supporting oneself."
		rarity=2
		damage=0.75
		accuracy=2
		speed=0.95

	Long_Staff
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
		name="Long Staff"
		desc="A tall staff. Would likely hurt to be hit with. Takes two hands to use effectively."
		rarity=2
		damage=1
		accuracy=4
		penetration=1

	Power_Pole
		name="Ruyi Jingu Bang"
		desc="A legendary staff that can stretch and shrink to any size."
		rarity=7
		damage=6
		accuracy=5
		speed=0.85

obj/items/Equipment/Weapon/Spear//spear list
	Simple_Spear
		name="Simple Spear"
		desc="A sharp rock tied to a stick."
		damage=1
		penetration=2

	Short_Spear
		name="Short Spear"
		desc="A relatively short spear, often used with a shield."
		damage=1
		penetration=3
		accuracy=1

	Long_Spear
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
		name="Long Spear"
		desc="A long spear. Requires two hands."
		rarity=2
		damage=2
		penetration=5
		speed=1.1

	Heavy_Spear
		name="Heavy Spear"
		desc="A spear made entirely of metal. Kind of slow."
		rarity=2
		damage=2.5
		penetration=5
		speed=1.2

	Gae_Buide
		name="G�e Buide"
		desc="An immensely powerful spear said to draw blood any time it is wielded."
		rarity=7
		damage=7
		penetration=20
		speed=1.2

obj/items/Equipment/Weapon/Club//club list
	Branch
		name="Branch"
		desc="A branch from a tree."
		damage=2
		speed=1.05
		accuracy=-2

	Wooden_Club
		name="Wooden Club"
		desc="A chunk of wood shaped into a weapon."
		damage=2.5
		accuracy=-3
		speed=1.1

	Thick_Club
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
		name="Thick Club"
		desc="A log with a handle carved into it. Requires two hands."
		rarity=2
		damage=3
		accuracy=-4
		speed=1.25

obj/items/Equipment/Weapon/Hammer//hammer list
	Makeshift_Hammer
		name="Makeshift Hammer"
		desc="A rock tied to a short stick."
		damage=1.5
		penetration=0.5

	Metal_Hammer
		name="Metal Hammer"
		desc="A hammer with a metal head."
		damage=2
		penetration=1
		accuracy=-1
		speed=1.025

	Warhammer
		slots=list(/datum/Body/Arm/Hand,/datum/Body/Arm/Hand)
		name="Warhammer"
		desc="A large hammer designed for war. Uses two hands."
		rarity=2
		damage=2.5
		penetration=2
		accuracy=-2
		speed=1.05

obj/items/Equipment/Weapon/Shield//shield list
	Buckler
		icon='ShieldGrey.dmi'
		name="Buckler"
		desc="A small shield."
		block = 3

	Iron_Shield
		icon='Knight shield.dmi'
		name="Iron Shield"
		desc="An iron shield typically used by rookie knights and warriors."
		rarity=2
		block = 6

	Sturdy_Shield
		icon='Hyrule Warriors Shield.dmi'
		name="Sturdy Shield"
		desc="A well-crafted shield."
		rarity=3
		block = 10

	Noble_Shield
		icon='shield3Blue.dmi'
		name="Noble Shield"
		desc="A prized shield often sought after by high-ranking elites."
		rarity=4
		block = 15

	Hexlock_Shield
		icon='shield3.dmi'
		name="Hexlock Shield"
		desc="A mighty shield."
		rarity=5
		block = 20

	Geo_Shield
		icon='shield3Geo.dmi'
		name="Geo Shield"
		desc="An almighty shield forged from deep within the earth."
		rarity=6
		block = 30

	Hyrule_Shield
		icon='Hyrule Shield.dmi'
		name="Hyrule Shield"
		desc="A mystical shield shield passed down from an ancient bloodline."
		rarity=7
		block = 50

	Mirror_Shield
		icon='Mirror_Shield.dmi'
		name="Mirror Shield"
		desc="A bizarre shield with a glimmering and reflective surface."
		rarity=7
		block = 40