//flags: Human, Namekian, Alien, Android, Meta, Demigod, Heran, Kai, Ogre, Yardrat, Spirit Doll, Saibaman, Makyo, Frost Demon, Bio-Android.
//special flag(s): Bio-Android, Frost Demon
datum/genetics
	proc
		returnIcons()
			var/list/skin_list = list()
			for(var/v in alternate_icon_flags)
				switch(v)
					if("Frost Demon") skin_list += list('BaseCooler.dmi','Changling - Form 1.dmi') //just in case, really.
					if("Bio-Android") skin_list += list('Bio Android 1.dmi','BioAndroid1(Spore).dmi') //same as above.
					if("Namekian") skin_list += 'Namek Young.dmi'
					if("Alien")
						skin_list+= 'Metamori.dmi'
						skin_list+= 'Konatsu.dmi'
						skin_list+= 'Yukenojin.dmi'
						skin_list+= 'Hatchiyack.dmi'
						skin_list+= 'Bio Experiment.dmi'
						skin_list+= 'Immecka.dmi'
						skin_list+= 'BuffFrog.dmi'
						skin_list+= 'Kratos.dmi'
						skin_list+= 'Goron.dmi'
						skin_list+= 'Zora.dmi'
						skin_list+='Base_Skully.dmi'
						skin_list+='cat.dmi'
						skin_list+='dog.dmi'
						skin_list+='bat.dmi'
						skin_list+='bunny.dmi'
						skin_list+='Demon1.dmi'
						skin_list+='Demon2.dmi'
						skin_list+='Demon3.dmi'
						skin_list+='Majin1.dmi'
						skin_list+='Jiren.dmi'
						skin_list+='El Hermano.dmi'
						skin_list+='Kanassan.dmi'
						skin_list+='Arlian.dmi'
					if("Yardrat") skin_list+='Yardrat.dmi'
					if("Spirit Doll") skin_list+='Spirit Doll.dmi'
					if("Saibamen") skin_list+='Saibaman - Form 1.dmi'
					if("Makyo") skin_list+='Makyojin.dmi'
					else //if you're not a alien with a spehscial icon, then you're one of below.
						switch(gender)
							if("Male")
								switch(v)
									if("Meta") skin_list+='MetaM.dmi'
									if("Android") skin_list+='GochekAndroid.dmi'
									if("Demigod")skin_list+='Custom_Icon.dmi'
									if("Heran")skin_list+='spacepirate.dmi'
									if("Kai")
										skin_list+='Kaio.dmi'
										skin_list+='Kai - Purple.dmi'
										skin_list+='Kai - Red.dmi'
										skin_list+='Kai - Supreme.dmi'
										skin_list+='Kai - King.dmi'
										skin_list+='Kai - Grand.dmi'
									if("Ogre")
										skin_list+='ogre base.dmi'
								if(!v in list("Meta","Android","Demigod","Heran","Kai","Ogre"))//extremely lazy way but fuck you
									skin_list+='White Male.dmi'
									skin_list+='Tan Male.dmi'
									skin_list+='Black Male.dmi'
									skin_list+='BaseWhiteMale.dmi'
									skin_list+='BaseTanMale.dmi'
									skin_list+='BaseBlackMale.dmi'
							if("Female")
								switch(v)
									if("Meta") skin_list+='MetaF.dmi'
									if("Android") skin_list+='GochekAndroid.dmi'
									if("Demigod")skin_list+='Custom_Icon_Female.dmi'
									if("Kai")
										skin_list+='Kai - Female.dmi'
										skin_list+='Chronoa.dmi'
									if("Ogre")
										skin_list+='orge female.dmi'
								if(!v in list("Meta","Android","Demigod","Heran","Kai","Ogre"))//extremely lazy way but fuck you
									skin_list+='Whitefemale.dmi'
									skin_list+='BaseWhiteFemale.dmi'
									skin_list+='BaseTanFemale.dmi'
									skin_list+='BaseBlackFemale.dmi'
			if(!skin_list.len)
				switch(gender)
					if("Male")
						skin_list+='White Male.dmi'
						skin_list+='Tan Male.dmi'
						skin_list+='Black Male.dmi'
						skin_list+='BaseWhiteMale.dmi'
						skin_list+='BaseTanMale.dmi'
						skin_list+='BaseBlackMale.dmi'
					if("Female")
						skin_list+='Whitefemale.dmi'
						skin_list+='BaseWhiteFemale.dmi'
						skin_list+='BaseTanFemale.dmi'
						skin_list+='BaseBlackFemale.dmi'
			return skin_list
		do_Transforming()
			return
			/*for(var/v in alternate_icon_flags)
				switch(v)
					
///////////////	
					
					
if(Race=="Alien"||Class=="Shapeshifter"||Race=="Demon"||Race=="Majin")
				skin_list+= 'Metamori.dmi'
				skin_list+= 'Konatsu.dmi'
				skin_list+= 'Yukenojin.dmi'
				skin_list+= 'Hatchiyack.dmi'
				skin_list+= 'Bio Experiment.dmi'
				skin_list+= 'Immecka.dmi'
				skin_list+= 'BuffFrog.dmi'
				skin_list+= 'Kratos.dmi'
				skin_list+= 'Goron.dmi'
				skin_list+= 'Zora.dmi'
				skin_list+='Base_Skully.dmi'
				skin_list+='cat.dmi'
				skin_list+='dog.dmi'
				skin_list+='bat.dmi'
				skin_list+='bunny.dmi'
				skin_list+='Demon1.dmi'
				skin_list+='Demon2.dmi'
				skin_list+='Demon3.dmi'
				skin_list+='Majin1.dmi'
				skin_list+='Jiren.dmi'
				skin_list+='El Hermano.dmi'
				skin_list+='Kanassan.dmi'
				skin_list+='Arlian.dmi'
			switch(pgender)
				if("Male")
					if(Race=="Meta") skin_list+='MetaM.dmi'
					if(Race=="Android") skin_list+='GochekAndroid.dmi'
					skin_list+='White Male.dmi'
					skin_list+='Tan Male.dmi'
					skin_list+='Black Male.dmi'
					skin_list+='BaseWhiteMale.dmi'
					skin_list+='BaseTanMale.dmi'
					skin_list+='BaseBlackMale.dmi'
					if(Race=="Demigod")skin_list+='Custom_Icon.dmi'
					if(Race=="Heran")skin_list+='spacepirate.dmi'
					if(Race=="Kai")
						skin_list+='Kaio.dmi'
						skin_list+='Kai - Purple.dmi'
						skin_list+='Kai - Red.dmi'
						skin_list+='Kai - Supreme.dmi'
						skin_list+='Kai - King.dmi'
						skin_list+='Kai - Grand.dmi'
					if(Race=="Ogre")
						skin_list+='ogre base.dmi'
				if("Female")
					if(Race=="Meta") skin_list+='MetaF.dmi'
					if(Race=="Android") skin_list+='GochekAndroid.dmi'
					skin_list+='Whitefemale.dmi'
					skin_list+='BaseWhiteFemale.dmi'
					skin_list+='BaseTanFemale.dmi'
					skin_list+='BaseBlackFemale.dmi'
					if(Race=="Demigod")skin_list+='Custom_Icon_Female.dmi'
					if(Race=="Kai")
						skin_list+='Kai - Female.dmi'
						skin_list+='Chronoa.dmi'
					if(Class=="Ogre")
						skin_list+='orge female.dmi'
			if(Race=="Yardrat") skin_list+='Yardrat.dmi'
			if(Race=="Spirit Doll") skin_list+='Spirit Doll.dmi'
			if(Race=="Saibamen") skin_list+='Saibaman - Form 1.dmi'
			if(Race=="Makyo") skin_list+='Makyojin.dmi'	
				*/
				