/datum/skill/tree/Magic
	name = "Magic"
	desc = "General Magical Ability"
	maxtier = 10
	tier=2
	constituentskills = list(new/datum/skill/Magic_Unleashed,new/datum/skill/Fuel_Ritual,new/datum/skill/Mana_Gathering,new/datum/skill/Magic_Words,\
		new/datum/skill/general/materialization,new/datum/skill/conjure,new/datum/skill/Research_Word,new/datum/skill/Research_Ingredient,new/datum/skill/Research_Ritual,\
		new/datum/skill/Magic_Workout,new/datum/skill/Magic_Absorption)
	allowedtier=1
	growbranches()
		..()
		if(invested<5)
			disableskill(/datum/skill/general/materialization)
		if(invested<6)
			disableskill(/datum/skill/conjure)
		if(invested)
			enableskill(/datum/skill/Fuel_Ritual)
			enableskill(/datum/skill/Mana_Gathering)
		allowedtier = max(invested+1,1)
		switch(invested)
			if(5) enableskill(/datum/skill/general/materialization)
			if(6) enableskill(/datum/skill/conjure)
		return

/datum/skill/Magic_Unleashed
	skilltype = "Magic"
	name = "Magic Unleashed"
	desc = "Your magical abilities start to awaken!!"
	can_forget = FALSE
	common_sense = TRUE
	teacher=TRUE
	skillcost=1
	maxlevel = 1
	tier = 1
	var/premagiskill = 0
	after_learn()
		savant<<"You feel your magic well up inside you!. To activate a freeform ritual, say 'Ritual of reality, activate'."
		savant.magiBuff = 1.5
		savant.word_power=1
		savant.ritual_power=1
		savant.known_words += "Ritual of reality, activate"
		savant.known_words["Ritual of reality, activate"] = "Generic ritual activation. Ingredients can have different effects. Be wary. Needs >3 ingredients to function."
		assignverb(/mob/keyable/verb/Magic_Words)
	before_forget()
		savant.magiBuff-=0.5
		savant.word_power=0
		savant.ritual_power=0
		unassignverb(/mob/keyable/verb/Magic_Words)
	login(mob/logger)
		..()
		assignverb(/mob/keyable/verb/Magic_Words)

/datum/skill/Fuel_Ritual
	skilltype = "Magic"
	name = "Fuel Ritual"
	desc = "Burn items to make magical power, which fuels other rituals. (Does not do anything without a ritual nearby)"
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	enabled=1
	skillcost=1
	maxlevel = 1
	prereqs = list()
	tier = 2
	after_learn()
		savant<<"You feel your magic well up inside you!."
		savant.known_ritual_de_types += /obj/Ritual/Fuel_Ritual
		savant.magiBuff+=0.1
		savant<<"You can now make burn stuff into energy!"
		savant<<"The magic words are 'burn energy'"
		savant.known_words += "burn energy"
		savant.known_words["burn energy"] = "Ritual of Give Energy. All ingredients are turned into energy. Gives it's energy to other rituals."
	before_forget()
		savant<<"Your magic vanishes..."
		savant.known_words -= "burn energy"
		savant.known_ritual_de_types -= /obj/Ritual/Fuel_Ritual
		savant.magiBuff-=0.1
/datum/skill/Mana_Gathering
	skilltype = "Magic"
	name = "Mana Gathering"
	desc = "Use a ritual to gain Magic energy."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	enabled=1
	skillcost=1
	maxlevel = 1
	prereqs = list()
	tier = 2
	after_learn()
		savant<<"You feel your magic well up inside you!."
		savant.known_ritual_de_types += /obj/Ritual/Mana_Gathering
		savant.magiBuff+=0.1
		savant.known_words += "give energy"
		savant.known_words["give energy"] = "Ritual of Gain Energy. All ingredients are turned into energy."
		savant<<"You can now get magical energy!"
		savant<<"The magic words are 'give energy'"
	before_forget()
		savant<<"Your magic vanishes..."
		savant.known_words -= "give energy"
		savant.known_ritual_de_types -= /obj/Ritual/Mana_Gathering
		savant.magiBuff-=0.1

/datum/skill/Magic_Workout
	skilltype = "Magic"
	name = "Magic Workout"
	desc = "Prime your magical abilities further, increasing your mana capacity and skill. (Estoric Skill+++, Magic Capcity+)"
	can_forget = FALSE
	common_sense = TRUE
	teacher=TRUE
	skillcost=1
	maxlevel = 1
	tier = 2
	var/premagiskill = 0
	after_learn()
		savant<<"You feel your magic well up inside you! You can store more mana within you now."
		savant.magiBuff += 1.5
		savant.mana_cap_mod += 1

	before_forget()
		savant.magiBuff -= 1.5
		savant.mana_cap_mod -= 1

/datum/skill/Magic_Absorption
	skilltype = "Magic"
	name = "Magic Absorption"
	desc = "Increase your magic capacity a bit further, and passively start to absorb mana."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	skillcost=1
	maxlevel = 4
	enabled=0
	prereqs = list(new/datum/skill/Magic_Workout)
	tier = 3
	var/premagiskill = 0
	after_learn()
		savant<<"You feel your magic well up inside you! You can store more mana within you now."
		savant.magiBuff += 0.5
		savant.mana_cap_mod += 1

	before_forget()
		savant<<"You feel your magic dwindling..."
		savant.magiBuff -= 0.5
		savant.mana_cap_mod -= 1
		switch(level)
			if(1) savant.mana_cap_mod -= 1
			if(2) savant.mana_cap_mod -= 2
			if(3) savant.mana_cap_mod -= 3
			if(4) savant.mana_cap_mod -= 4
	effector()
		if(savant.Magic < savant.MagicCap && prob(10))
			savant.Magic += max(0.1,0.25 * level)
		if(savant.Magic > savant.MagicCap)
			exp++
		switch(level)
			if(0)
				if(levelup) levelup=0
			else
				if(levelup)
					levelup=0
					savant<<"Your magic rises up inside of you, and your body makes it its own."
					savant.mana_cap_mod += 1


/datum/skill/Magic_Words
	skilltype = "Magic"
	name = "Magic Words"
	desc = "Learn how to push power through your own words, unleashing limitless possiblities."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	enabled=1
	skillcost=1
	maxlevel = 1
	tier = 3
	after_learn()
		savant<<"You feel your magic well up inside you!."
		assignverb(/mob/keyable/verb/Word_Power)
		savant.magiBuff+=0.5
	before_forget()
		savant<<"Your magic vanishes..."
		savant.magiBuff-=0.5
		unassignverb(/mob/keyable/verb/Word_Power)
	login(mob/logger)
		..()
		assignverb(/mob/keyable/verb/Word_Power)
		logger.reinitialize_words()

/datum/skill/Research_Word
	skilltype = "Magic"
	name = "Research Word"
	desc = "Research a single magical word using this ritual."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	enabled=0
	prereqs = list(new/datum/skill/Magic_Words)
	skillcost=1
	maxlevel = 1
	tier = 4
	after_learn()
		savant<<"You feel your magic well up inside you!."
		savant.known_ritual_ma_types += /obj/Ritual/Research_Word
		savant.magiBuff+=0.2
		savant.known_words += "cerebrus"
		savant.known_words["cerebrus"] = "Research Word. Req: Frog Brain and Essence of Time"
		savant<<"You can now research magic words!!"
		savant<<"The magic words are 'cerebrus'. You need to use a Frog Brain and Essence of Time"
	before_forget()
		savant<<"Your magic vanishes..."
		savant.known_words -= "cerebrus"
		savant.known_ritual_ma_types -= /obj/Ritual/Research_Word
		savant.magiBuff-=0.2


/datum/skill/Research_Ingredient
	skilltype = "Magic"
	name = "Research Ingredient"
	desc = "Research a single effect of a ingredient using this ritual."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	enabled=1
	skillcost=1
	maxlevel = 1
	tier = 4
	after_learn()
		savant<<"You feel your magic well up inside you!."
		savant.known_ritual_ma_types += /obj/Ritual/Research_Ingredient
		savant.magiBuff+=0.2
		savant.known_words += "ingredious"
		savant.known_words["ingredious"] = "Research Ingredient. Req: Frog Brain and Beetle Eye"
		savant<<"You can now research ingredients!"
		savant<<"The magic words are 'ingredious'. You need to use a Frog Brain and Beetle Eye."
	before_forget()
		savant<<"Your magic vanishes..."
		savant.known_words -= "ingredious"
		savant.known_ritual_ma_types -= /obj/Ritual/Research_Ingredient
		savant.magiBuff-=0.2


/datum/skill/general/materialization
	skilltype = "Magic"
	name = "Materialize"
	desc = "Learn a magic ritual to materialize items through Ki."
	can_forget = TRUE
	common_sense = FALSE
	teacher=TRUE
	tier = 1

/datum/skill/general/materialization/after_learn()
	savant<<"You feel your magic well up inside you!."
	savant.magiBuff+=1
	savant.known_ritual_ma_types += /obj/Ritual/Materialize_Item
	savant.known_words += "energy collesque"
	savant.known_words["energy collesque"] = "Materialization. Req: Gillyweed and Aconite."
	savant<<"You can now make stuff through energy!"
	savant<<"The magic words are 'energy collesque'. You need Gillyweed and Aconite."
/datum/skill/general/materialization/before_forget()
	savant.known_ritual_ma_types -= /obj/Ritual/Materialize_Item
	savant.known_words -= "energy collesque"
	savant<<"You've forgotten how to make stuff through energy!?"
	savant.magiBuff-=1

/datum/skill/conjure
	skilltype = "Magic"
	name = "Conjure Demon"
	desc = "Using a magic ritual, conjure a demon. Demons usually like being summoned."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 1

/datum/skill/conjure/after_learn()
	savant<<"You feel your magic well up inside you!."
	savant.magiBuff+=1
	savant.known_ritual_dm_types += /obj/Ritual/Ritual_of_Conjure_Demon
	savant.known_words += "Xisxisxis"
	savant.known_words["Xisxisxis"] = "Demon Conjure. Req: Dragon Blood and Essence of Space."
	savant<<"You've learned how to conjure Demons!!"
	savant<<"The magic words are 'Xisxisxis'. You need Dragon Blood and Essence of Space."
/datum/skill/conjure/before_forget()
	savant.known_ritual_dm_types -= /obj/Ritual/Ritual_of_Conjure_Demon
	savant.known_words -= "Xisxisxis"
	savant<<"You've forgotten how to conjure Demons!?"
	savant.magiBuff-=1


/datum/skill/Research_Ritual
	skilltype = "Magic"
	name = "Research Ritual"
	desc = "Ensure your dominance over reality by researching rituals to further your quest for magical application."
	can_forget = TRUE
	common_sense = TRUE
	teacher=TRUE
	tier = 6
	enabled = 0
	prereqs = list(new/datum/skill/Research_Ingredient,new/datum/skill/Mana_Gathering,new/datum/skill/Fuel_Ritual)
	skillcost=2
	after_learn()
		savant<<"You feel your magic well up inside you!."
		savant.magiBuff+=1
		savant.known_ritual_dm_types += /obj/Ritual/Research_Ritual
		savant.known_words += "ars cerebrus cortex magnifica magica"
		savant.known_words["ars cerebrus cortex magnifica magica"] = "Ritual Research. Req: Microchip, Essence of Time, Angel Tear, Moonseed, and a Eel Eye."
		savant<<"You've learned how to research Rituals!!"
		savant<<"The magic words are 'ars cerebrus cortex magnifica magica'. You need a Microchip, Essence of Time, Angel Tear, Moonseed, and a Eel Eye."
	before_forget()
		savant.known_ritual_dm_types -= /obj/Ritual/Research_Ritual
		savant.known_words -= "ars cerebrus cortex magnifica magica"
		savant<<"You've forgotten how to conjure Demons!?"
		savant.magiBuff-=1
