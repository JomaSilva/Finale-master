atom/proc/return_random_ingredient()
	var/list/ingredientlist = list()
	ingredientlist += typesof(/obj/items/Material)
	ingredientlist -= /obj/items/Material
	ingredientlist -= /obj/items/Material/Alchemy
	ingredientlist -= /obj/items/Material/Alchemy/Misc
	ingredientlist -= /obj/items/Material/Plant
	ingredientlist -= /obj/items/Material/Alchemy/Animal
	ingredientlist -= /obj/items/Material/Alchemy/Plant
	ingredientlist -= /obj/items/Material/Wood
	ingredientlist -= /obj/items/Material/Corpse
	ingredientlist -= /obj/items/Material/Ore
	ingredientlist -= /obj/items/Material/Enchanting
	ingredientlist -= /obj/items/Material/Enchanting/Catalyst
	ingredientlist -= /obj/items/Material/Enchanting/Source
	var/random_pick = pick(ingredientlist)
	return new random_pick(loc)

//magic items
/obj/items/Material/Alchemy/Misc
	SaveItem=0
	icon = 'magic_items.dmi'
	icon_state = "potionflask"
	fragile = 1
	Magic = 5
	stored_energy = 1
	Ki = 5
	techcost = 40
	New()
		ingredtype = name
		..()
		magnitude*=(1+(quality-50)/100)
		duration*=(1+(quality-50)/100)
		for(var/obj/items/Material/Alchemy/A in alchemyprototypes)//for potionmaking
			if(A.type == src.type)
				src.Effects=A.Effects
				break
	Feather
		name = "Feather"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m_w","e_speed")
		Magic = 10

	Aconite
		name = "Aconite"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_p_all_r","e_burn")
		Magic = 70

	African_Red_Pepper
		name = "African Red Pepper"
		techcost = 40
		mag_effects = list("p_add","t_tar_m","e_empower")
		Magic = 40

	Frog_Brain
		name = "Frog Brain"
		techcost = 40
		mag_effects = list("p_subtract","t_tar_m","e_consume")
		Magic = 30

	Ginger
		name = "Ginger"
		techcost = 40
		mag_effects = list("p_magnify","t_duplicate","e_damage")
		Magic = 20

	Gillyweed
		name = "Gillyweed"
		techcost = 40
		mag_effects = list("p_dissociate","t_tar_r_all_p","e_poison")
		Magic = 20

	Angel_Tear
		name = "Angel Tear"
		techcost = 40
		mag_effects = list("p_siphon","t_tar_p_all_r","e_pacify")
		Magic = 100

	Beetle_Eye
		name = "Beetle Eye"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_r_w","e_appear")
		Magic = 20

	Belladonna
		name = "Belladonna"
		techcost = 40
		mag_effects = list("p_siphon","t_tar_p_all_p","e_disappear")
		Magic = 80

	Horseradish
		name = "Horseradish"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_r_all_r","e_density")
		Magic = 10

	Hair
		name = "Hair"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_p","e_icon")
		Magic = 20

	Lichen
		name = "Lichen"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_p_w","e_physoff")
		Magic = 50

	Lizard_Leg
		name = "Lizard Leg"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m","e_technique")
		Magic = 10

	Cinnamon
		name = "Cinnamon"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m_all_r","e_kioff")
		Magic = 20


	Silverush
		name = "Silverush"
		techcost = 40
		mag_effects = list("p_disappear","t_funnel","e_regenerate")
		Magic = 70

	Moonseed
		name = "Moonseed"
		techcost = 40
		mag_effects = list("p_moonlight_magnify","t_tar_m_w","e_full_moon")
		Magic = 70

	Mercury
		name = "Mercury"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m_all_r","e_activate_ritual")
		Magic = 60

	Dragon_Blood
		name = "Dragon_Blood"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m_all_p","e_empower_p")
		Magic = 140

	Eel_Eye
		name = "Eel_Eye"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_o","e_magic")
		Magic = 40

	Occamy
		name = "Occamy"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_r","e_heal")
		Magic = 100

	Essence_Of_Time
		name = "Essence_Of_Time"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m_all_p","e_teleport")
		Magic = 240

	Nux_Myristica
		name = "Nux_Myristica"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_o","e_kiregen")
		Magic = 120

	Octopus_Juice
		name = "Octopus_Juice"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_o_all_r","e_destroy")
		Magic = 10


	Essence_Of_Space
		name = "Essence_Of_Space"
		techcost = 40
		mag_effects = list("p_siphon","t_tar_m_all_p","e_portal")
		Magic = 100

	Flitter_Fly
		name = "Flitter_Fly"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_r_all_p","e_summon")
		Magic = 80

	Fae_Dust
		name = "Fae_Dust"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_r_w","e_depower")
		Magic = 170
	
	Bezoar
		name = "Bezoar"
		techcost = 40
		mag_effects = list("p_siphon","t_tar_m_all_r","e_regenerate")
		Magic = 60
	
	Foxglove
		name = "Foxglove"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_o","e_feed")
		Magic = 10
	
	Blood
		name = "Blood"
		techcost = 40
		mag_effects = list("p_add","t_tar_m","e_anger")
		Magic = 40
	Vinger
		name = "Vinger"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m","e_power_magic")
		Magic = 40
	
	Microchip
		name = "Microchip"
		techcost = 40
		mag_effects = list("p_siphon","t_tar_p","e_intelligence")
		Magic = 40
	
	Hippogriff_Fat
		name = "Hippogriff Fat"
		techcost = 40
		mag_effects = list("p_magnify","t_duplicate","e_change_weather")
		Magic = 25
	
	Sundrop
		name = "Sundrop"
		techcost = 40
		mag_effects = list("p_sunlight_magnify","t_funnel","e_day_noon")
		Magic = 35
	
	Demon_Horn
		name = "Demon Horn"
		techcost = 40
		mag_effects = list("p_makyo_magnify","t_tar_p","e_take_soul_body")
		Magic = 45
	
	Angel_Blossom
		name = "Angel Blossom"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m","e_resurrect")
		Magic = 60
	
	Night_Princess
		name = "Night Princess"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m_all_p","e_night_mid")
		Magic = 25
	
	Moonstone
		name = "Moonstone"
		techcost = 40
		mag_effects = list("p_add","t_tar_o_all_r","e_seal")
		Magic = 25
	
	Molly
		name = "Molly"
		techcost = 40
		mag_effects = list("p_siphon","t_tar_p_w","e_silence")
		Magic = 25
	
	Shard_of_Outer_Reality
		name = "Shard of Outer Reality"
		techcost = 40
		mag_effects = list("p_disappear","t_tar_p_all_r","e_seal_s")
		Magic = 25

	Moondew
		name = "Moondew"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m","e_etherial_form")
		Magic = 25
	
	Unicorn_Teeth
		name = "Unicorn Teeth"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m_all_p","e_telepathy")
		Magic = 25
	
	Cursed_Blood
		name = "Cursed Blood"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_p_w","e_vampirification")
		Magic = 25
	
	Cursed_Wolf_Tooth
		name = "Cursed Wolf Tooth"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_m_w","e_werewolfication")
		Magic = 25
	
	Minor_Aspect_of_Time
		name = "Minor Aspect of Time"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_o","e_change_time")
		Magic = 25
	
	Soul_Flower
		name = "Soul Flower"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_r","e_give_soul_body")
		Magic = 25
	
	Polyflower
		name = "Polyflower"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_r_all_r","e_polymorph")
		Magic = 25
	
	Minor_Aspect_of_God
		name = "Minor Aspect of God"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_r_all_p","e_timestop")
		Magic = 25
	
	Rotten_Flesh
		name = "Rotten Flesh"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_r_w","e_zombification")
		Magic = 25
	
	Monkey_Tail
		name = "Monkey Tail"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_p_all_p","e_blutz_emit")
		Magic = 25

	Banshee_Essence
		name = "Banshee Essence"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_p","e_soul_rip")
		Magic = 25
	
	Archangel_Essence
		name = "Archangel Essence"
		techcost = 40
		mag_effects = list("p_magnify","t_tar_p","e_soul_restore")
		Magic = 25
