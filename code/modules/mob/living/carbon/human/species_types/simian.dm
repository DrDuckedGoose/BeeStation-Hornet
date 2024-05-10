/datum/species/monkey/simian
	name = "Simian"
	id = SPECIES_MONKEY
	species_traits = list(
		EYECOLOR,
		MUTCOLORS
	)
	inherent_traits = list(
		TRAIT_DISCOORDINATED,
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

/datum/species/monkey/simian/spec_unarmedattack(mob/living/carbon/human/user, atom/target)
	. = ..()
	if(user.restrained())
		if(!iscarbon(target))
			return TRUE
		var/mob/living/carbon/victim = target
		if(user.a_intent != INTENT_HARM || user.is_muzzled())
			return TRUE
		var/obj/item/bodypart/affecting = null
		if(ishuman(victim))
			var/mob/living/carbon/human/human_victim = victim
			affecting = human_victim.get_bodypart(pick(BODY_ZONE_CHEST, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		var/armor = victim.run_armor_check(affecting, MELEE)
		if(prob(25))
			victim.visible_message("<span class='danger'>[user]'s bite misses [victim]!</span>",
				"<span class='danger'>You avoid [user]'s bite!</span>", "<span class='hear'>You hear jaws snapping shut!</span>", COMBAT_MESSAGE_RANGE, user)
			to_chat(user, "<span class='danger'>Your bite misses [victim]!</span>")
			return TRUE
		///REMINDER TO MYSELF TO CORRECT THESE RAND VALUES LATER
		victim.apply_damage(rand(1, 3), BRUTE, affecting, armor)
		victim.visible_message("<span class='danger'>[name] bites [victim]!</span>",
			"<span class='userdanger'>[name] bites you!</span>", "<span class='hear'>You hear a chomp!</span>", COMBAT_MESSAGE_RANGE, name)
		to_chat(user, "<span class='danger'>You bite [victim]!</span>")
		if(armor >= 2)
			return TRUE
		for(var/d in user.diseases)
			var/datum/disease/bite_infection = d
			victim.ForceContractDisease(bite_infection)
		return TRUE
	target.attack_paw(user)
	return TRUE

/datum/species/monkey/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	H.pass_flags |= PASSTABLE
	H.butcher_results = knife_butcher_results
	if(!H.dna.features["tail_monkey"] || H.dna.features["tail_monkey"] == "None" || H.dna.features["tail_monkey"] == "Monkey")
		H.dna.features["tail_monkey"] = "Simian"
		handle_mutant_bodyparts(H)

	H.dna.add_mutation(RACEMUT, MUT_NORMAL)
	H.dna.activate_mutation(RACEMUT)


/datum/species/monkey/simian/get_species_description()
	return "Simians are a distant relative of the Monkey, much like Humans. However, unlike Humans, \
	Simians didn't diverge quite as far from their ancestors, retaining more of their features."

/datum/species/monkey/simian/get_species_lore()
	return list(
		"Monkeys are commonly used as test subjects on board Space Station 13. \
		But what if... for one day... the Monkeys were allowed to be the scientists? \
		What experiments would they come up with? Would they (stereotypically) be related to bananas somehow? \
		There's only one way to find out.",
	)

/datum/species/monkey/simian/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "spider",
			SPECIES_PERK_NAME = "Vent Crawling",
			SPECIES_PERK_DESC = "Monkeys can crawl through the vent and scrubber networks while wearing no clothing. \
				Stay out of the kitchen!",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "paw",
			SPECIES_PERK_NAME = "Primal Primate",
			SPECIES_PERK_DESC = "Monkeys are primitive humans, and can't do most things a human can do. Computers are impossible, \
				complex machines are right out, and most clothes don't fit your smaller form.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "capsules",
			SPECIES_PERK_NAME = "Mutadone Averse",
			SPECIES_PERK_DESC = "Monkeys are reverted into normal humans upon being exposed to Mutadone.",
		),
	)

	return to_add

/datum/species/monkey/simian/create_pref_language_perk()
	var/list/to_add = list()
	// Holding these variables so we can grab the exact names for our perk.
	var/datum/language/common_language = /datum/language/common
	var/datum/language/monkey_language = /datum/language/monkey

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "comment",
		SPECIES_PERK_NAME = "Primitive Tongue",
		SPECIES_PERK_DESC = "You may be able to understand [initial(common_language.name)], but you can't speak it. \
			You can only speak [initial(monkey_language.name)].",
	))

	return to_add
