#define SIMIAN_HAND_SLOWDOWN 0.3

/datum/species/monkey/simian
	name = "Simian"
	id = SPECIES_SIMIAN
	bodyflag = FLAG_SIMIAN
	species_traits = list(
		EYECOLOR,
		MUTCOLORS,
		NOSOCKS
	)
	inherent_traits = list(
		TRAIT_VENTCRAWLER_NUDE,
	)
	mutant_bodyparts = list("tail_monkey")
	forced_features = list("tail_monkey" = "Simian")
	default_features = list("tail_monkey" = "Simian")
	species_language_holder = /datum/language_holder/simian
	species_l_arm = /obj/item/bodypart/l_arm/simian
	species_r_arm = /obj/item/bodypart/r_arm/simian
	species_head = /obj/item/bodypart/head/simian
	species_l_leg = /obj/item/bodypart/l_leg/simian
	species_r_leg = /obj/item/bodypart/r_leg/simian
	species_chest = /obj/item/bodypart/chest/simian

/datum/species/monkey/simian/check_roundstart_eligible()
	. = ..()
	return TRUE

/datum/species/monkey/simian/random_name(gender, unique, lastname, attempts)
	if(gender == MALE)
		. = pick(GLOB.first_names_male)
	else
		. = pick(GLOB.first_names_female)

	if(lastname)
		. += " [lastname]"
	else
		. += " [pick(GLOB.last_names)]"

	if(unique && attempts < 10)
		. = .(gender, TRUE, lastname, ++attempts)

/datum/species/monkey/simian/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	//Fix our tail
	if(!H.dna.features["tail_monkey"] || H.dna.features["tail_monkey"] == "None" || H.dna.features["tail_monkey"] == "Monkey")
		H.dna.features["tail_monkey"] = "Simian"
		handle_mutant_bodyparts(H)
	//Catch equips
	RegisterSignal(H, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(catch_equipped))
	RegisterSignal(H, COMSIG_MOB_DROPPED_ITEM, PROC_REF(catch_equipped))

/datum/species/monkey/simian/get_species_description()
	return "Simians are a distant relative of the Monkey, much like Humans. However, unlike Humans, \
	Simians didn't diverge quite as far from their ancestors, retaining more of their predecessor's \
	features."

/datum/species/monkey/simian/get_species_lore()
	return list(
		"Simians come from the future!!! Kinda...",
	)

/datum/species/monkey/simian/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Vent Crawling",
			SPECIES_PERK_DESC = "[name]s can crawl through the vent and scrubber networks while wearing no clothing. \
				Stay out of the kitchen!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "hand",
			SPECIES_PERK_NAME = "Prehensile Feet",
			SPECIES_PERK_DESC = "[name]s have prehensile feet, and can use them to pick-up, carry, and use items. \
			However, holding items like this will slow them down.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "Foot",
			SPECIES_PERK_NAME = "Animal Feet",
			SPECIES_PERK_DESC = "Most footwear wont fit your unique feet. Watch out for broken glass!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "Arm",
			SPECIES_PERK_NAME = "Weak Arms",
			SPECIES_PERK_DESC = "Your arms aren't quite strong enough to properly weild most objects, like shotguns.",
		)
	)

	return to_add

/datum/species/monkey/simian/monkey_language_perk()
	return

/datum/species/monkey/simian/proc/catch_equipped(datum/source, obj/item, slot)
	SIGNAL_HANDLER

	var/mob/living/carbon/M = source
	var/current_hand_weight = 0
	for(var/i in list(3, 4)) //Which hands we're checking, which is the feet hands in this case
		current_hand_weight += M.get_item_for_held_index(i) ? 1 : 0
	M.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/simian_hand_content,  multiplicative_slowdown=current_hand_weight*SIMIAN_HAND_SLOWDOWN)

/datum/movespeed_modifier/simian_hand_content
	movetypes = ~FLYING
	variable = TRUE

#undef SIMIAN_HAND_SLOWDOWN
