mob/var/signature
mob/var/backstory = "" //player-written character backstory (required at creation)
mob/verb/View_Backstory(mob/M in view())
	set category = "Other"
	set name = "Backstory"
	if(!M) M = src
	if(!M.backstory)
		to_chat(usr, "No backstory has been written.")
		return
	usr << browse("<html><body style='background:#1a1a1a;color:#dddddd;font-family:sans-serif;padding:10px'><h3>[M.name]'s Backstory</h3><p>[html_encode(M.backstory)]</p></body></html>","window=backstory;size=460x420")
mob
	proc
		New_Character()
			if(Created) return
			if(client) client.charcreationSpecial += 1
			else return
			if(client) client.show_map=0 //black void during creation; map restored after Locate() sends them to their planet
			loc=locate(rand(5,20),rand(3,19),30)
			html_race_pick() //tela HTML de planeta+raca (CreationUI.dm; substitui a janela nativa race_pick_act)
			Gender()
			Skin()
			Hair()
			Eyes()
			BodyType() //a IDADE agora entra no formulario HTML de texto (creation_text_form, junto de nome/historia)
			AuraR=rand(0,255)
			AuraG=rand(0,255)
			AuraB=rand(0,255)
			blastR=rand(0,255)
			blastG=rand(0,255)
			blastB=rand(0,255)
			see_in_dark=5
			var/aura='colorablebigaura.dmi'
			if(Race=="Demon"||(Parent_Race=="Demon"))
				Over=1
				aura='Black Demonflame.dmi'
			if(Race=="Makyo"||(Parent_Race=="Makyo"))
				Over=1
				aura='AuraKiia.dmi'
			aura+=rgb(AuraR,AuraG,AuraB)
			AURA=aura
			ssj4aura='Aura SSj4.dmi'
			ssj4aura+=rgb(AuraR,AuraG,AuraB)
			var/startingage=1
			if(Age<1)
				Age=startingage
				Body=startingage
			SAge=1
			//BP = 1
			if(BP<1)
				BP = 1
			if(Dragonball_Start)
				BP = 1
			if(Father_BP)
				BP += rand(round(Father_BP / InclineAge),round(Father_BP / 6))
				hiddenpotential += Father_BP
			if(Parent_BP)
				hiddenpotential += Parent_BP
				BP += rand(round(Parent_BP / InclineAge),round(Parent_BP / 6))
			CustomizeFurther()
			if(GravMastered>25)
				GravMastered=25
			creation_text_form() //janela HTML: nome + idade + historia num formulario so (CreationUI.dm)
			usr.AddHair() //o cabelo entra ANTES da foto do resumo
			if(!creation_summary()) //RESUMO FINAL (foto do personagem montado + Confirmar no canto inferior direito)
				if(client) client.mob = new /mob/lobby //guard: desconectar com o resumo aberto deixava client null -> runtime matava o proc e o mob virava limbo
				del(src)
				return
			if(client) //CONFIRMOU: personagem pronto -- so agora a musica do menu se despede
				client.TitleMusicOn = 0
				client.Music_Fade()
			if(Race != "Frost Demon" && !ChangieType) usr.form1icon = icon
			usr.originalicon = icon
			Locate()
			if(Class=="Legendary")
				legend_override=0
			move=1
			//
			Created=1
			dead=0
			/*if(Race=="Kai")
				var/obj/items/Potara_Earring/A = new
				A.name = "[name]'s Potara Earring (Left)"
				var/obj/items/Potara_Earring/B = new
				B.name = "[name]'s Potara Earring (Right)"
				contents+=A
				contents+=B*/
			MeditateGivesKiRegen=0
			Ki=0
			spawn(10)
				Ki=100
				HP=100
		//Name()/Backstory()/Age() antigos DELETADOS: viraram o formulario HTML creation_text_form()
		//(CreationUI.dm), que tambem gera a signature e valida com as mesmas regras
		Gender()
			if(Race=="Kanassa-Jin"|Race=="Makyo"|Race=="Namekian"|Race=="Yardrat"|Race=="Saibamen"||Parent_Race=="Namekian")
				//raca SEM sexo (Namek etc.): a etapa e PULADA por completo -- considerado Male p/ o jogo
				gender = MALE
				pgender = "Male" //o skip antigo so setava gender e o pgender vazio vazava pro Skin()/resto do fluxo
				genome?.gender = "Male"
			else
				var/Choice = ui_choose("GENERO", "Escolha o sexo do personagem.", list("Male","Female"), list(creation_gender_icon("Male"), creation_gender_icon("Female")), null) //icones da PROPRIA raca (Majin mostra corpo Majin etc.)
				switch(Choice)
					if("Female")
						pgender="Female"
						gender = FEMALE
						genome?.gender = "Female"
					if("Male")
						pgender="Male"
						gender = MALE
					else //client caiu no meio: mantem o fluxo vivo
						pgender="Male"
						gender = MALE
		Eyes()
			alert(usr,"Select your eye color.")
			var/newrgb
			newrgb=input("Choose a color.","Color",0) as color
			var/list/oldrgb=0
			oldrgb=hrc_hex2rgb(newrgb,1)
			while(!oldrgb)
				sleep(1)
				oldrgb=hrc_hex2rgb(newrgb,1)
			eyered = oldrgb[1]
			eyeblue = oldrgb[3]
			eyegreen = oldrgb[2]
			eyeicon += rgb(eyered,eyeblue,eyegreen)
			updateOverlay(/obj/overlay/eyes/default_eye)
		Aura_Color()
			set waitfor = 0
			newrgb=0
			alert("Choose a aura color.")
			var/rgbsuccess
			rgbsuccess=input("Choose a color.","Color",0) as color
			var/list/oldrgb=0
			oldrgb=hrc_hex2rgb(rgbsuccess,1)
			while(!oldrgb)
				sleep(1)
				oldrgb=hrc_hex2rgb(rgbsuccess,1)
			AuraR=oldrgb[1]
			AuraB=oldrgb[3]
			AuraG=oldrgb[2]
			var/aura='colorablebigaura.dmi'
			if(Race=="Demon"||(Parent_Race=="Demon"))
				Over=1
				aura='Black Demonflame.dmi'
			if(Race=="Makyo"||(Parent_Race=="Makyo"))
				Over=1
				aura='AuraKiia.dmi'
			aura+=rgb(AuraR,AuraG,AuraB)
			AURA=aura
			ssj4aura='Aura SSj4.dmi'
			ssj4aura+=rgb(AuraR,AuraG,AuraB)
		Blast_Color()
			set waitfor = 0
			alert("Customize your blast color")
			var/rgbsuccess
			rgbsuccess=input("Choose a color.","Color",0) as color
			var/list/oldrgb=0
			oldrgb=hrc_hex2rgb(rgbsuccess,1)
			while(!oldrgb)
				sleep(1)
				oldrgb=hrc_hex2rgb(rgbsuccess,1)
			blastR=oldrgb[1]
			blastB=oldrgb[3]
			blastG=oldrgb[2]
mob/var
	eye
	BodyType
mob/proc/BodyType()
	//cards com os trade-offs escritos (a confirmacao dupla antiga saiu: o card JA explica)
	var/Choice = ui_choose("TIPO DE CORPO", "Mudanca PERMANENTE de atributos -- leia com atencao.", \
		list("Medium","Small","Large"), null, list(\
		"Corpo padrao: nenhum ajuste de atributos.",\
		"Agil: acerta/esquiva/corre/recupera mais facil, MAS corte severo em forca e resistencia.",\
		"Gigante: resistencia e forca enormes, MAS mais lento, recupera devagar e e mais facil de acertar."))
	switch(Choice)
		if("Small")
			speedMod*=1.4
			kioffMod*=1.3
			physoffMod*=0.9
			physdefMod*=0.7
			kidefMod*=0.8
			kiregenMod+=0.6
			BodyType="Small"
		if("Large")
			speedMod*=0.7
			kioffMod*=1.1
			physoffMod*=1.1
			physdefMod*=1.3
			kidefMod-=0.2
			BodyType="Large"
		else //Medium (ou client caiu): corpo padrao
			BodyType="Medium"
mob/proc/NewCharacterStuff()
	verbs+=typesof(/mob/default/verb)
	Keyableverbs+=typesof(/mob/default/verb)
	contents+=new/obj/Crandal
	generatetrees(1)
	spawn Variance()
	TestMobParts()
	Generate_Droid_Parts()
	Savable=1
	var/hasZenni
	for(var/obj/Zenni/Z in src.contents) hasZenni = 1
	if(!hasZenni) contents+=new/obj/Zenni
	RandomizeText()
	Clear_Overlays()
	spawn(5) TryStats()
	CheckIncarnate()
	race_genome_post_init()
	spawn(10) class_hint() //tell the new player, indirectly, what class/power tier they were born into (their BP is hidden without a scouter)
	spawn(15) outfit_creation_prompt() //quer nascer vestido? (guarda-roupa cosmetico; Wardrobe.dm)

mob/proc/CustomizeFurther()
	if(Race == "Frost Demon" || (Parent_Race == "Frost Demon"))
		IcerCustomization()
	if(Race == "Bio-Android" || (Parent_Race=="Bio-Android"))
		BioCustomization()


mob/proc/CHECK()
		var/icount=0
		for(var/obj/items/o in src)count++
		if(icount>inven_max)src<<output("You have more items in your inventory than the allowed amount. Take this into attention or you will lose your save file.","output")
		inven_min=icount
		for(var/mob/M in world)if(M)M.InvenSet()
