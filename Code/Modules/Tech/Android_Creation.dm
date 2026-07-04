// ============================================================================
// ANDROID CREATION MAINFRAME -- agora e a porta de entrada do sistema NOVO de
// androides / bio-androides (DNALabs.dm). Compre na arvore de tech, aparafuse
// (Bolt) e use "Instalar Laboratorio":
//   * Lab 1 - Android Lab: transforma VOCE em androide (Absorcao 1M / Energia
//     Infinita 2M -- ver DNALabs.dm).
//   * Lab 2 - Bio-Android Lab: ganha o DNA Extractor e gesta um Bio-Androide
//     a partir de amostras de DNA.
// O verb de instalacao vive em DNALabs.dm (usa o define DNL_INT_REQ de la --
// os includes sao re-ordenados alfabeticamente pelo DreamMaker, entao este
// arquivo nao pode depender daquele define).
// O sistema LEGADO (Upgrade/Create + android_creator_list/bio_creator_list,
// que criava personagens Android/Bio-Android novos aqui) foi REMOVIDO.
// ============================================================================
obj/Creatables
	Android_Creation_Mainframe
		icon = '64x64tech.dmi'
		icon_state="android_pod"
		cost=500000
		neededtech=50
		allowedRaces = list("Human") //so HUMANOS veem o mainframe na janela de tech (o TechWindow filtra por allowedRaces)
		desc = "Mainframe de criacao de androides. Aparafuse (Bolt) e INSTALE um laboratorio: Android Lab (transforme-se em androide por Absorcao ou Energia Infinita) ou Bio-Android Lab (extraia DNA de jogadores nocauteados e geste um Bio-Androide). A instalacao exige um Humano com muita inteligencia."
		create_type = /obj/items/Android_Creation_Mainframe

obj/items
	Android_Creation_Mainframe
		icon = '64x64tech.dmi'
		icon_state="android_pod"
		desc = "Aparafuse no chao (Bolt) e use 'Instalar Laboratorio' para ergue-lo como Android Lab ou Bio-Android Lab."
		verb/Bolt()
			set category=null
			set src in oview(1)
			if(x&&y&&z&&!Bolted)
				switch(input("Are you sure you want to bolt this to the ground so nobody can ever pick it up? Not even you?","",text) in list("Yes","No",))
					if("Yes")
						to_chat(view(src), "<font size=1>[usr] bolts the [src] to the ground.")
						Bolted=1
						boltersig=usr.signature
			else if(Bolted&&boltersig==usr.signature)
				switch(input("Unbolt?","",text) in list("Yes","No",))
					if("Yes")
						to_chat(view(src), "<font size=1>[usr] unbolts the [src] from the ground.")
						Bolted=0
