proc/convert_mag_to_norm_e(input)
	. = (input) - 273.15
	if(. < 0) return input / 273.15
	return .

proc/convert_mag_to_ki_e(input)
	. = (((input) - 273.15) * 1.8) + 32
	if(. < 0) return (((input) / 273.15) * 1.8) + 32
	return .

proc/convert_norm_to_magic_e(input)
	return (input) + 273.15

proc/convert_norm_to_ki_e(input)
	return ((input) * 1.8) + 32

proc/convert_ki_to_norm_e(input)
	. = (input - 32) / 1.8
	if(. < 0) return (input / 32) / 1.8
	return (input - 32) / 1.8

proc/convert_ki_to_magic_e(input)
	. = (input - 32)
	if(. > 0) return (. / 1.8) + 273.15
	else if(. == 0) return 273.15
	else return ((input / 32) / 1.8) + 273.15

//electricity is special
proc/convert_norm_to_elec_e(input)
	return ((input) + 273.15) / 1.8
proc/convert_elec_to_norm_e(input)
	return (input * 1.8) + 273.15
proc/convert_mag_to_elec_e(input)
	return (input) / 1.8
proc/convert_elec_to_mag_e(input)
	return input * 1.8
//
var
	list/power_word_dictionary = list("arg","do","toch","reme","hege","frat","gg","set","fiore","zios","viin","quea","kra","mon","bry","uru","forti",
										"gy","ama","nec","cantio","gittah","kangs","weigh","toki","yo","tomare","dio","er","n/a","cavere","un'ltd","p'wah","staune","el nath",
										"clang","biruz","ni","bennar","wuz","scyar","at","oni","soma","sti","kaly","kn'a'ftaghu'puck'bthink","aulie","USA","patriotic","rac'wa",
										"gin'yu","we","capan","buy","game","todd","oo","ee","ting","ah","walla","bing","bang","shazam")
	list/p_power_words = list()
	list/t_power_words = list()
	list/e_power_words = list()
	list/power_words_p_activations = list()
	list/power_words_t_activations = list()
	list/power_words_e_activations = list()
//
/atom/movable
	var/
		stored_energy = 1 //how much normal energy does this thing have? Gets converted to ritual energy (magic)
		Ki=1
		Magic=0
		var/list/mag_effects[3] //what magic effects do these things have?

mob
	mag_effects = list("p_magnify","t_tar_m_all_p","e_summon")
	var
		element_type = "" //Can be: Fire, Earth, Air (wind), Water.
		//Estoric Elements: Lightning (aspect of Fire and Wind), Mud (Water + Earth), Lava (Earth + Fire), Sand (Earth + Air), Steam (Fire+Water), Cloud (Air+Water)
		//Super Elements: (available after ascension) Hellfire, Steel Ice, Atmosphere (super varient of Wind. Enjoy turning a local planet into a gas giant?), Primordial (Super Duper Earth. Benchpress planets.)
		estoric_element = ""
		can_est_el = 0
		super_element = ""
		can_sup_el = 0
		fireskill = 0
		earthskill = 0
		airskill = 0
		waterskill = 0
		//magiskill, from 1 to 10, is the measure of your knowledge of magic.
		//level 1 you unlock using magic items (runes, talismans, artifacts)
		//level 2 you can use rituals, learn spells, and etc.
		//at level 3 you can make runes/talismans
		//at level 4+ you have access to technically all magic.
		//spells are just words said with power, you have several seperate "custom magic verbs" where you input a word, and upon using them,
		//magic can happen.
		tmp/word_power = 0//if you're speaking with power or not
		tmp/mana_setting = 0.08
		ritual_power =0 //if you can activate rituals
		list/preset_words = list("","","","","","","","","","")
		list/known_words = list()


mob/keyable/verb/Elemental_Options()
	set category = "Other"
	element_type = input(usr,"Select your element.") in list("Fire","Earth","Air","Water")
	if(can_est_el)
		estoric_element = input(usr,"Select your estoric element.") in list("Lightning","Mud","Lava","Sand","Steam","Cloud")
	if(can_sup_el)
		super_element = input(usr,"Select your super element. Super elements are better if your element type is the same.") in list("Hellfire","Steel Ice","Atmosphere","Primordial")
/datum/skill/SElemental
	skilltype="Ki"
	icon='support.jpg'
	name="Super Element"
	desc=""
	tier=2
	enabled=1
	skillcost=1
	can_forget= FALSE
	common_sense = FALSE
	after_learn()
		savant <<"The basic elements have chosen you as their champion."
		savant.can_sup_el = 1
		savant.magiBuff += 0.5

mob/keyable/verb/Magic_Words()
	set category = "Other"
	switch(input(usr,"Change your preset magic phrases? Or check your words?","Magic Phrases","Cancel") in list("Cancel","Magic Phrases","Toggle Ritual Words","View Known Words","View Known Ritual Words"))
		if("Cancel")
		if("Magic Phrases")
			gotobegin
			switch(input(usr,"Select the phrase number.","Magic Phrases","Cancel") in list("One","Two","Three","Four","Five","Six","Seven","Eight","Nine","Ten","Cancel"))
				if("Cancel") goto gotoend
				if("One") preset_words[1] = input(usr,"Insert a phrase. This text string will be said with power upon use.","Magic Phrases") as text
				if("Two") preset_words[2] = input(usr,"Insert a phrase. This text string will be said with power upon use.","Magic Phrases") as text
				if("Three") preset_words[3] = input(usr,"Insert a phrase. This text string will be said with power upon use.","Magic Phrases") as text
				if("Four") preset_words[4] = input(usr,"Insert a phrase. This text string will be said with power upon use.","Magic Phrases") as text
				if("Five") preset_words[5] = input(usr,"Insert a phrase. This text string will be said with power upon use.","Magic Phrases") as text
				if("Six") preset_words[6] = input(usr,"Insert a phrase. This text string will be said with power upon use.","Magic Phrases") as text
				if("Seven") preset_words[7] = input(usr,"Insert a phrase. This text string will be said with power upon use.","Magic Phrases") as text
				if("Eight") preset_words[8] = input(usr,"Insert a phrase. This text string will be said with power upon use.","Magic Phrases") as text
				if("Nine") preset_words[9] = input(usr,"Insert a phrase. This text string will be said with power upon use.","Magic Phrases") as text
				if("Ten") preset_words[10] = input(usr,"Insert a phrase. This text string will be said with power upon use.","Magic Phrases") as text
			goto gotobegin
			gotoend
			reinitialize_words()
		if("Toggle Ritual Words")
			if(ritual_power)
				ritual_power=0
				view(src) << "[src]'s voice carries less power..."
			else
				ritual_power=1
				view(src) << "[src]'s voice carries more power..."
		if("View Known Words")
			for(var/a, a <= known_words.len, a++)
				a = max(1,a)
				usr<<"Known Word: [known_words[known_words[a]]] Effect: [known_words[a]]"
mob/keyable/verb/Word_Power()
	set category = "Other"
	if(!word_power)
		view(src) << "[src]'s voice carries more power..."
		word_power = 1
	else
		view(src) << "[src]'s voice is empty of magic power..."
		word_power = 0

mob/proc/reinitialize_words()
	for(var/a, a <= preset_words.len,a++)
		if(preset_words[a] != "")
			switch(a)
				if(1) assignverb(/mob/keyable/verb/Phrase_1)
				if(2) assignverb(/mob/keyable/verb/Phrase_2)
				if(3) assignverb(/mob/keyable/verb/Phrase_3)
				if(4) assignverb(/mob/keyable/verb/Phrase_4)
				if(5) assignverb(/mob/keyable/verb/Phrase_5)
				if(6) assignverb(/mob/keyable/verb/Phrase_6)
				if(7) assignverb(/mob/keyable/verb/Phrase_7)
				if(8) assignverb(/mob/keyable/verb/Phrase_8)
				if(9) assignverb(/mob/keyable/verb/Phrase_9)
				if(10) assignverb(/mob/keyable/verb/Phrase_10)
	for(var/a, a <= known_words.len, a++)
		a = max(1,a)
		var/word = known_words[known_words[a]]
		var/word_type = known_words[a]
		if(word_type in p_spell_index)
			//power_words_p_activations[word]
			known_words[a] = power_words_p_activations[word]
			known_words[power_words_p_activations[word]] = word
		if(word_type in t_spell_index)
			//power_words_t_activations[word]
			known_words[a] = power_words_t_activations[word]
			known_words[power_words_t_activations[word]] = word
		if(word_type in e_spell_index)
			//power_words_e_activations[word]
			known_words[a] = power_words_e_activations[word]
			known_words[power_words_e_activations[word]] = word

mob/keyable/verb/Phrase_1()
	set category = "Skills"
	sayType("[preset_words[1]]",3)
mob/keyable/verb/Phrase_2()
	set category = "Skills"
	sayType("[preset_words[2]]",3)
mob/keyable/verb/Phrase_3()
	set category = "Skills"
	sayType("[preset_words[3]]",3)
mob/keyable/verb/Phrase_4()
	set category = "Skills"
	sayType("[preset_words[4]]",3)
mob/keyable/verb/Phrase_5()
	set category = "Skills"
	sayType("[preset_words[5]]",3)
mob/keyable/verb/Phrase_6()
	set category = "Skills"
	sayType("[preset_words[6]]",3)
mob/keyable/verb/Phrase_7()
	set category = "Skills"
	sayType("[preset_words[7]]",3)
mob/keyable/verb/Phrase_8()
	set category = "Skills"
	sayType("[preset_words[8]]",3)
mob/keyable/verb/Phrase_9()
	set category = "Skills"
	sayType("[preset_words[9]]",3)
mob/keyable/verb/Phrase_10()
	set category = "Skills"
	sayType("[preset_words[10]]",3)

mob/proc/power_Test(var/MsgToOutput)
	if(word_power)
		var/used_word_p
		var/used_word_t
		var/used_word_e
		var/finders_text = 1
		for(var/a, a <= p_power_words.len, a++)
			a = max(a,1)
			//world << "p1[p_power_words[a]]"
			if(p_power_words[a] != "")
				if(findtext(MsgToOutput,p_power_words[a]))
					//world << "p2found"
					used_word_p = p_power_words[a]
					finders_text = findtext(MsgToOutput,p_power_words[a]) + 1
					break
		for(var/a, a <= t_power_words.len, a++)
			a = max(a,1)
			//world << "t1[t_power_words[a]]"
			if(t_power_words[a] != "")
				if(findtext(MsgToOutput,t_power_words[a],finders_text))
					//world << "t2found"
					used_word_t = t_power_words[a]
					finders_text = findtext(MsgToOutput,t_power_words[a],finders_text) + 1
					break
		for(var/a, a <= e_power_words.len, a++)
			a = max(a,1)
			//world << "e1[e_power_words[a]]"
			if(e_power_words[a] != "")
				if(findtext(MsgToOutput,e_power_words[a],finders_text))
					//world << "e2found"
					used_word_e = e_power_words[a]
					break
		if(used_word_p && used_word_t && used_word_e)
			activate_magic(src,used_word_p,used_word_t,used_word_e)
			return
	if(ritual_power)
		for(var/obj/Ritual/nR in view(1))
			if(findtext(MsgToOutput,nR.activator_word))
				nR.invoker = src
				nR.activate_ritual(src)
				return
proc/activate_magic(atom/movable/source,word1,word2,word3)
	var/obj/Ritual/nR = new(source.loc)
	nR.visual_activation()
	nR.SaveItem = 0
	var/mob/nM
	if(ismob(source))
		nR.invoker = source
		nM = source
		nM.Magic -= (nM.Magic / nM.Emagiskill) * nM.mana_setting
		nR.Magic += source.Magic * nM.mana_setting
	else
		source.Magic -= source.Magic
		nR.Magic += source.Magic
	var/emag =1.2
	if(nM != null)
		emag = nM.Emagiskill
	var/magnitude = max(1,log(7,nR.Magic*10)) * emag
	var/cost = effect_price_lookup(power_words_p_activations[word1]) * effect_price_lookup(power_words_t_activations[word2]) * effect_price_lookup(power_words_e_activations[word3])
	nR.ritual_cost += cost * max(1,log(1.5,nR.Magic*10)) / emag
	//world << "test [nR]. rc[nR.ritual_cost],se[nR.Magic],m[magnitude],so[source]"
	if(nR.ritual_cost <= nR.Magic)
		nR.Magic -= nR.ritual_cost
		sleep(10)
		nR.do_primary(power_words_p_activations[word1],magnitude)
		magnitude = max(1,log(7,nR.Magic*10)) * emag //we're calculating magnitude again since Magic can change.
		nR.do_secondary(power_words_t_activations[word2],magnitude)
		magnitude = max(1,log(7,nR.Magic*10)) * emag
		//world << "activation 2"
		nR.do_tietary(power_words_e_activations[word3],magnitude)
		//world << "activation 3"
		sleep(10)
		nR.post_ritual()
	del(nR)
	return
var/generatedspells

proc/generate_spells()
	if(!generatedspells || !power_words_p_activations.len || !power_words_t_activations.len || !power_words_e_activations.len)
		power_words_p_activations = list()
		p_power_words = list()
		power_words_t_activations = list()
		t_power_words = list()
		power_words_e_activations = list()
		e_power_words = list()
		generatedspells=1
		for(var/a,a <= p_spell_index.len,a++)
			var/list/newlist = power_word_dictionary
			newlist -= p_power_words
			if(newlist.len)
				var/lucky_word = pick(newlist)
				p_power_words += lucky_word
				//world << "p1[lucky_word]"
				//world << "p2[p_spell_index[a]]"
				power_words_p_activations[lucky_word] = p_spell_index[a]
				//world << "p3[power_words_p_activations[lucky_word]]"

		for(var/a,a <= t_spell_index.len,a++)
			var/list/newlist = power_word_dictionary
			newlist -= t_power_words
			if(newlist.len)
				var/lucky_word = pick(newlist)
				t_power_words += lucky_word
				//world << "t1[lucky_word]"
				//world << "t2[t_spell_index[a]]"
				power_words_t_activations[lucky_word] = t_spell_index[a]
				//world << "t3[power_words_t_activations[lucky_word]]"

		for(var/a,a <= e_spell_index.len,a++)
			var/list/newlist = power_word_dictionary
			newlist -= e_power_words
			if(newlist.len)
				var/lucky_word = pick(newlist)
				e_power_words += lucky_word
				//world << "e1[lucky_word]"
				//world << "e2[e_spell_index[a]]"
				power_words_e_activations[lucky_word] = e_spell_index[a]
				//world << "e3[power_words_e_activations[lucky_word]]"

mob/Admin3/verb/Reinitialize_Spells()
	set category="Admin"
	generatedspells=0
	generate_spells()

mob/Admin3/verb/View_Spell_Index()
	set category="Admin"
	for(var/a, a <= p_power_words.len, a++)
		a = max(1,a)
		if(p_power_words[a] != "")
			usr<<"word: [p_power_words[a]] : [power_words_p_activations[p_power_words[a]]]"
	for(var/a, a <= t_power_words.len, a++)
		a = max(1,a)
		if(t_power_words[a] != "")
			usr<<"word: [t_power_words[a]] : [power_words_t_activations[t_power_words[a]]]"
	for(var/a, a <= e_power_words.len, a++)
		a = max(1,a)
		if(e_power_words[a] != "")
			usr<<"word: [e_power_words[a]] : [power_words_e_activations[e_power_words[a]]]"

//temp
/obj/Materialization
	New()
		..()
		del(src)