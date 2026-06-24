mob/var/Mutations=0
mob/var/MutationImmune=0
mob/proc/Variance() //Makes each character unique.
	while(prob(10))
		sleep(1)
		genome.add_to_stat("Potential",(rand(20,25)/10))
	if(prob(5))
		Elite()
mob/proc/AdminMutate() //Makes each character unique.
	sleep(1)
	while(prob(10))
		sleep(1)
		genome.add_to_stat("Potential",(rand(20,25)/10))
	if(prob(10)) Elite()
mob/var/elite=0
mob/proc/Elite()
	BP=AverageBP*(rand(11,25)/10)
	//elite=1
mob/Admin3/verb/SpawnZombies()
	set category="Admin"
	var/amount=input("How many? Probably shouldnt go past 1000") as num
	var/strength=input("How much BP each?") as num
	amount=round(amount)
	createZombies(amount,strength,x,y,z)

proc/createZombies(amount,strength,x,y,z)
	while(amount)
		var/mob/A=new/mob/npc/Enemy/Zombie
		A.BP=strength*0.1
		A.loc=locate(x+rand(-20,20),y+rand(-20,20),z)
		A.movespeed=rand(1,10)
		A.BP*=A.movespeed
		switch(rand(1,10))
			if(1)
				A.icon='Zombie Dog.dmi'
				A.BP=strength*2
			if(2)
				A.icon='Zombie Hunter.dmi'
				A.BP=strength*4
			if(3)
				A.icon='Zombie Licker.dmi'
				A.BP=strength*3
			if(4)
				A.icon='Zombie Nemesis.dmi'
				A.BP=strength*9
			if(5)
				A.icon='Zombie Thanatos.dmi'
				A.BP=strength*6
			if(6)
				A.icon='Zombie Tyrant.dmi'
				A.BP=strength*5
			if(7)
				A.icon='Zombie X.dmi'
				A.BP=strength*10
			if(8)
				A.icon='Zombie.dmi'
		amount-=1
		sleep(1+rand(10,100))