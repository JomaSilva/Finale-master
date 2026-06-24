obj/items
	FishingPole
		icon='FishingPole.dmi'
		verb/Fish()
			set category=null
			set src in usr
			set waitfor = 0
			if(!cooldown)
				cooldown+=1
				spawn(10)
				cooldown-=1
			else
				return
			if(usr.FishingSkill<1)
				usr<<"You don't know how to fish?"
				return
			if(!usr.fishing)
				usr.fishing = 1
				usr.nextFish=0
				var/waterNearby
				for(var/turf/T in view(2))
					if(T.Water)
						waterNearby+=1
				if(waterNearby)
					usr<<"You cast your line out. Don't move or else you'll scare the fish!"
					oview(usr) << "[usr] casts a line out."
					var/obj/bobber/nB = new (usr.loc)
					step(nB,usr.dir)
					nB.ownersig = usr.signature
					while(usr.fishing)
						var/caughtFish
						if(prob(10)) usr.nextFish++
						if(usr.nextFish>= 10 * log(max(usr.FishCaught,1)) / log(max(waterNearby,1)))
							if(log(max(usr.nextFish,1)) * usr.FishingSkill > (1+usr.FishCaught))
								caughtFish=1
								usr.nextFish = 0
						sleep(20)
						if(usr.fishing&&caughtFish)
							caughtFish = 0
							flick("fish",nB)
							emit_Sound('NEWSKILL.WAV')
							sleep(4)
							nB.icon_state = "fishstay"
							nB.fishup = 1
							sleep(50)
							if(nB && !nB.fishup)
								usr.FishCaught+=1
								usr.FishingSkill += 1
							nB.fishup = 0
							nB.icon_state = ""
						spawn(100)
							if(usr.FishCaught) usr.FishCaught-=1
					del(nB)
				else usr<<"You have to be near a body of water for this to work."
			else
				usr.fishing=0
				usr<<"You stop fishing."
		var
			cooldown
	food
		Fish
			icon='food.dmi'
			icon_state="fish"
			nutrition=10
			flavor="You eat the fish raw and feel your hunger slip away... Could've been cooked."
			cookable=1
			cookskill=1
			cooktype=/obj/items/food/Cooked_Fish

		Cooked_Fish
			icon='food.dmi'
			icon_state="fishcooked"
			nutrition=20
			flavor="You eat the fish and feel your hunger give way... It's delicious!"

		Trout
			icon='food.dmi'
			icon_state="fish"
			nutrition=15
			flavor="You eat the fish raw and feel your hunger slip away... Could've been cooked."
			cookable=1
			cookskill=10
			cooktype=/obj/items/food/Cooked_Trout

		Cooked_Trout
			icon='food.dmi'
			icon_state="fishcooked"
			nutrition=30
			flavor="You eat the fish and feel your hunger give way... It's delicious!"
		Salmon
			icon='food.dmi'
			icon_state="fish"
			nutrition=20
			flavor="You eat the fish raw and feel your hunger slip away... Could've been cooked."
			cookable=1
			cookskill=30
			cooktype=/obj/items/food/Cooked_Salmon

		Cooked_Salmon
			icon='food.dmi'
			icon_state="fishcooked"
			nutrition=40
			flavor="You eat the fish and feel your hunger give way... It's delicious!"

mob/var
	tmp/nextFish = 0
	tmp/FishCaught = 0

mob/proc/GenerateFish()
	var/fishchance = FishingSkill * rand(1,3)
	fishchance = min(60,fishchance)
	var/gottenfish
	if(FishingSkill>=35&&prob(fishchance/3))
		gottenfish = 3
	else if(FishingSkill>=15&&prob(fishchance/2)) gottenfish = 2
	else gottenfish = 1
	switch(gottenfish)
		if(1)
			var/obj/A=new/obj/items/food/Fish
			usr.contents+=A
		if(2)
			var/obj/A=new/obj/items/food/Trout
			usr.contents+=A
		if(3)
			var/obj/A=new/obj/items/food/Salmon
			usr.contents+=A
	return gottenfish


obj/bobber
	icon='bobber.dmi'
	IsntAItem = 1
	SaveItem = 0
	var/fishup
	var/ownersig
	Click()
		if(fishup && usr.signature == ownersig)
			icon_state = ""
			var/gain = usr.GenerateFish()
			AddExp(usr,/datum/mastery/Life/Fishing,100*gain)
			usr<<"You caught a fish!!"
			oview(usr) << "[usr] catches a fish!"
			fishup = 0