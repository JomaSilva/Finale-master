/datum/skill/MartialSkill/MartialArts
	skilltype = "Body Buff"
	name = "Martial Arts"
	desc = "Begin the journey of mastering your own Martial Arts.\n Allows you to learn a custom Martial Art (Style), modify, and improve it."
	can_forget = TRUE
	common_sense = TRUE
	maxlevel = 1
	tier = 1
	enabled = 1
	var/datum/style/BasicStyle/attachedstyle //Important if you want this to be able to be forgotten.

	login(mob/logger) //not needed if your skill path is /datum/skill/style/(whatever)
		..()
		if(!attachedstyle in logger.styleList)
			logger.styleList.Add(attachedstyle)
			attachedstyle.savant = logger
	after_learn()
		savant<<"You feel more complex in both body and movement."
		attachedstyle = new
		savant.styleList.Add(attachedstyle)
		savant.availableStyles += attachedstyle
		attachedstyle.savant = savant
		if(!savant.currentStyle)
			savant.currentStyle = attachedstyle //if no current style, change that shit nigga

	before_forget()
		savant<<"You feel like something neccessary was removed from your form."
		savant.styleList.Cut(attachedstyle)
		del(attachedstyle)

/datum/style/BasicStyle
	name="Basic Style"
	desc="A basic martial style. Nothing really special. You can only use one style at a time."
