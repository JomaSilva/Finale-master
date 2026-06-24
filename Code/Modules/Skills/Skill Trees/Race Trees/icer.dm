/datum/skill/tree/frostdemon
	name="Frost Demon Racials"
	desc="Given to all Frost Demons at the start."
	maxtier=2
	tier=0
	enabled=1
	allowedtier=2
	can_refund = FALSE
	compatible_races = list("Frost Demon","Half-Breed")
	var/prev_form
	var/got_decrease
	constituentskills = list(new/datum/skill/general/Hardened_Body,new/datum/skill/general/LankyLegs,new/datum/skill/general/Willed,new/datum/skill/icer/Better_Limits,new/datum/skill/icer/Golden_Form)
	growbranches()
		if(savant.KOcount >= 100 && savant.Age > 10 && savant.BP >= godki_at * 0.9) enableskill(/datum/skill/icer/Golden_Form)
		if(savant.KOcount >= 500 && savant.BP >= godki_at * 0.1) enableskill(/datum/skill/icer/Golden_Form)
		..()
	effector()
		if(savant.cur_icr_form > 1)
			savant.transBuff = max(0.01,1 - (1/(1+savant.cur_icr_form)))
		if(!AscensionStarted)
			savant.stamina -= 0.0005 * (4 - savant.cur_icr_form)
			var/oldkimod = savant.trueKiMod
			savant.trueKiMod = max(0.15,0.25 * savant.cur_icr_form)
			savant.Ki *= savant.trueKiMod/oldkimod
			if(savant.cur_icr_form != prev_form)
				var/form_diff = prev_form - savant.cur_icr_form
				savant.Tphysoff -= (0.12 * form_diff)
				savant.Tphysdef -= (0.12 * form_diff)
				savant.Tkioff -= (0.12 * form_diff)
				savant.Tkidef -= (0.12 * form_diff)
				savant.Tphysoff -= (0.12 * form_diff)
				savant.Tkiregen -= (0.12 * form_diff)
				prev_form = savant.cur_icr_form
		else
			var/oldkimod = savant.trueKiMod
			savant.trueKiMod = 1 + savant.cur_icr_form
			savant.Ki *= savant.trueKiMod/oldkimod
			if(got_decrease)
				got_decrease = 0
				var/form_diff = min(4 - savant.cur_icr_form,4)
				savant.Tphysoff += (0.12 * form_diff)
				savant.Tphysdef += (0.12 * form_diff)
				savant.Tkioff += (0.12 * form_diff)
				savant.Tkidef += (0.12 * form_diff)
				savant.Tphysoff += (0.12 * form_diff)
				savant.Tkiregen += (0.12 * form_diff)

	login()
		..()
		if(!AscensionStarted)
			got_decrease = 1
			var/form_diff = min(4 - savant.cur_icr_form,4)
			savant.Tphysoff -= (0.12 * form_diff)
			savant.Tphysdef -= (0.12 * form_diff)
			savant.Tkioff -= (0.12 * form_diff)
			savant.Tkidef -= (0.12 * form_diff)
			savant.Tphysoff -= (0.12 * form_diff)
			savant.Tkiregen -= (0.12 * form_diff)

mob/var/icer_limit_forms = 0
mob/var/list/icer_vars = list("Form 6 Seperate Icon"=1,"Form 6 base"=1,"Form 6 color"=list(231,228,62),"Form 6 Aura"='transformaura.dmi')

/datum/skill/icer/Better_Limits
	skilltype="misc"
	name="Better Limits"
	desc="As you may have noticed, your BP is already pretty large. Unfortunately, you might have also noticed your Ki isn't very large, nor is your stats any good. This adds a limiting form- your 'first' form, which makes your BP normal again. This also makes your Ki and Stats normal too, along with eliminating the extra stamina drain."
	can_forget = FALSE
	common_sense = FALSE
	skillcost = 1

	after_learn()
		savant.icer_limit_forms++
		assignverb(/verb/Icer_Form_Settings)
		savant << "You can assign your forms! You start with one."
	login()
		..()
		assignverb(/verb/Icer_Form_Settings)

verb/Icer_Form_Settings()
	set category = "Other"
	switch(input(usr,"Change forms or change form 6 attributes?","","Cancel") in list("Forms","Form 6 Attributes","Cancel"))
		if("Forms")
			switch(input(usr,"How many other forms do you want? More forms is mostly cosmetic. You'll be reverted to your normal form.") in list("One","Two","Three","Cancel"))
				if("One")
					usr.cur_icr_form = 1
					usr.icer_limit_forms = 1
				if("Two")
					usr.cur_icr_form = 1
					usr.icer_limit_forms = 2
				if("Three")
					usr.cur_icr_form = 1
					usr.icer_limit_forms = 3
		if("Form 6 Attributes")
			switch(input(usr,"You can either make form 6 a seperate icon, form 6 into a base you already have (form 1 to 5), and if it's off of a base, change its color. Changing its icon can be done in the Settings window.Oh, and if you want, you can also change your Golden Form aura.") in list("Make it a seperate icon","Select a base","Color","Golden Form Aura stuff.","Cancel"))
				if("Color")
					var/newrgb=input("Choose a color.","Color",0) as color
					var/list/oldrgb=0
					oldrgb=hrc_hex2rgb(newrgb,1)
					while(!oldrgb)
						sleep(1)
						oldrgb=hrc_hex2rgb(newrgb,1)
					usr.icer_vars["Form 6 color"][1] = oldrgb[1]
					usr.icer_vars["Form 6 color"][2] = oldrgb[2]
					usr.icer_vars["Form 6 color"][3] = oldrgb[3]
				if("Make it a seperate icon")
					if(usr.icer_vars["Form 6 Seperate Icon"] == TRUE)
						usr.icer_vars["Form 6 Seperate Icon"] = FALSE
						usr << "Form 6 now uses your default base (form 1)."
					else
						usr.icer_vars["Form 6 Seperate Icon"] = TRUE
						usr << "Form 6 now uses a seperate icon."
				if("Select a base")
					usr.icer_vars["Form 6 base"]=round(min(max(input(usr,"Put in a number 1 through 5, it'll use that icon as it's Golden Form base.","",1) as num,1),5))
				if("Golden Form Aura stuff.")
					switch(input(usr,"You can either change the Aura to default, or put in a custom icon.","","Cancel") in list("Cancel","Custom","Aura"))
						if("Custom") usr.icer_vars["Form 6 Aura"] = input(usr,"","Form 6 Aura",usr.icer_vars["Form 6 Aura"]) as icon
						if("Default") usr.icer_vars["Form 6 Aura"] = 'transformaura.dmi'
	usr.icer_poll_icon()

/datum/skill/icer/Golden_Form
	skilltype="Ki"
	name="Golden Form"
	desc="Tap into your Golden Form, granting you an even higher boost than form five. In addition, it'll give you God Ki energy (but not anything else) temporarily. Has a high strain on the body."
	can_forget = FALSE
	common_sense = FALSE
	skillcost = 1
	enabled=0

	after_learn()
		assignverb(/mob/keyable/verb/Golden_Form)
		savant << "Your body shimmers a bit, releasing a hue of gold light. The power within explodes, and a new godly tone empowers your body!"
	login()
		..()
		assignverb(/mob/keyable/verb/Golden_Form)

mob/keyable/verb/Golden_Form()
	set category = "Skills"
	if(isBuffed(/obj/buff/Golden_Form))
		startbuff(/obj/buff/Golden_Form)
	else stopbuff(/obj/buff/Golden_Form)