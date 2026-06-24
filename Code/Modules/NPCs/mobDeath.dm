mob/var
	dropsCorpse = 1


mob/proc/mobDeath()
	if(client || Player) return
	if(!istype(src,/mob/npc/Splitform))
		var/obj/Zenni/A=new/obj/Zenni
		A.zenni = rand(100,8000)
		if(dropsCorpse)
			var/obj/items/food/nC =new/obj/items/food/corpse
			nC.loc = loc
			nC.name = "[name] Meat"
			nC.mobkilled = name
			GenerateCorpse()
		if(isBoss)
			A.loc=locate(x,y,z)
			A.zenni=rand(500000,800000)
		A.name="[num2text(A.zenni,20)] zenni"
		A.icon_state="Zenni4"
		A.loc = locate(src.x,src.y,src.z)
		NPCDrop()
		sleep(2)
	src.loc = null
	globalNPCcount-=1
	src.deleteMe()