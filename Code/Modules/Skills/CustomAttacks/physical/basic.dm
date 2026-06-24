datum/skill/tree/Custom_Attacks //will eventually move everything to here.
	name = "Melee Attacks"
	desc = "The ability to create and use custom melee attacks."
	maxtier = 3
	tier=3
	enabled=1
	allowedtier = 3
	constituentskills = list(new/datum/skill/CustomAttack/Melee/Melee_Attack1,new/datum/skill/CustomAttack/Melee/Melee_Attack4,new/datum/skill/CustomAttack/Melee/Melee_Attack5,
		new/datum/skill/CustomAttack/Melee/Melee_Attack2,new/datum/skill/CustomAttack/Melee/Melee_Attack3,new/datum/skill/CustomAttack/Melee/Melee_Attack6,
		new/datum/skill/CustomAttack/Melee/Melee_Attack1,new/datum/skill/CustomAttack/Melee/Melee_Attack8,new/datum/skill/CustomAttack/Melee/Melee_Attack7,
		new/datum/skill/CustomAttack/Melee/Melee_Attack9,new/datum/skill/CustomAttack/Melee/Melee_Attack10)
	can_refund = FALSE

/datum/skill/CustomAttack/Melee
	var/melee_attack_type = "Basic" //"Chain","Long","Punch","Wide" are all options
	skilltype = "Physical"
	attacktype = "Melee"


/datum/skill/CustomAttack/Melee/Melee_Attack1
	verb_type = /mob/keyable/verb/Custom_Melee_Attack1

/datum/skill/CustomAttack/Melee/Melee_Attack2
	verb_type = /mob/keyable/verb/Custom_Melee_Attack2

/datum/skill/CustomAttack/Melee/Melee_Attack3
	verb_type = /mob/keyable/verb/Custom_Melee_Attack3

/datum/skill/CustomAttack/Melee/Melee_Attack4
	verb_type = /mob/keyable/verb/Custom_Melee_Attack4

/datum/skill/CustomAttack/Melee/Melee_Attack5
	verb_type = /mob/keyable/verb/Custom_Melee_Attack5

/datum/skill/CustomAttack/Melee/Melee_Attack6
	verb_type = /mob/keyable/verb/Custom_Melee_Attack6

/datum/skill/CustomAttack/Melee/Melee_Attack7
	verb_type = /mob/keyable/verb/Custom_Melee_Attack7

/datum/skill/CustomAttack/Melee/Melee_Attack8
	verb_type = /mob/keyable/verb/Custom_Melee_Attack8

/datum/skill/CustomAttack/Melee/Melee_Attack9
	verb_type = /mob/keyable/verb/Custom_Melee_Attack9

/datum/skill/CustomAttack/Melee/Melee_Attack10
	verb_type = /mob/keyable/verb/Custom_Melee_Attack10

mob/keyable/verb/Custom_Melee_Attack1()
	set category = "Skills"
	CustomAttackHandler(1)

mob/keyable/verb/Custom_Melee_Attack2()
	set category = "Skills"
	CustomAttackHandler(2)

mob/keyable/verb/Custom_Melee_Attack3()
	set category = "Skills"
	CustomAttackHandler(3)

mob/keyable/verb/Custom_Melee_Attack4()
	set category = "Skills"
	CustomAttackHandler(4)

mob/keyable/verb/Custom_Melee_Attack5()
	set category = "Skills"
	CustomAttackHandler(5)

mob/keyable/verb/Custom_Melee_Attack6()
	set category = "Skills"
	CustomAttackHandler(6)

mob/keyable/verb/Custom_Melee_Attack7()
	set category = "Skills"
	CustomAttackHandler(7)

mob/keyable/verb/Custom_Melee_Attack8()
	set category = "Skills"
	CustomAttackHandler(8)

mob/keyable/verb/Custom_Melee_Attack9()
	set category = "Skills"
	CustomAttackHandler(9)

mob/keyable/verb/Custom_Melee_Attack10()
	set category = "Skills"
	CustomAttackHandler(10)
