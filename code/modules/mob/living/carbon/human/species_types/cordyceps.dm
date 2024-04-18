#define CORDYCEPS_HEAL_FACTOR 0.5

/datum/species/cordyceps
	name = "\improper Cordyceps"
	id = SPECIES_CORDYCEPS
	default_color = "FFFFFF"
	species_traits = list(NOEYESPRITES, LIPS)
	default_features = list("mcolor" = "FFF", "wings" = "None", "body_size" = "Normal")
	skinned_type = /obj/item/stack/sheet/animalhide/human
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	species_chest = /obj/item/bodypart/chest/cordyceps
	species_head = /obj/item/bodypart/head/cordyceps
	species_l_arm = /obj/item/bodypart/l_arm/cordyceps
	species_r_arm = /obj/item/bodypart/r_arm/cordyceps
	species_l_leg = /obj/item/bodypart/l_leg/cordyceps
	species_r_leg = /obj/item/bodypart/r_leg/cordyceps

	mutant_brain = /obj/item/organ/brain/cordyceps
	mutanttongue = /obj/item/organ/tongue/cordyceps

	burnmod = 1.25
	brutemod = 0.75

	speedmod = 0.35

//TODO: Add species sounds back - Racc

/datum/species/cordyceps/check_roundstart_eligible()
	return TRUE

//We don't like sodium
/datum/species/cordyceps/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	//Sodium case
	if(chem.type == /datum/reagent/sodium)
		H.adjustToxLoss(3)
		H.reagents.remove_reagent(chem.type, chem.metabolization_rate)
		return TRUE
	return ..()

/datum/species/cordyceps/spec_life(mob/living/carbon/human/H)
	. = ..()
	//Being fat actively heals our brute & burn
	if(H.nutrition >=  NUTRITION_LEVEL_FAT)
		H.adjust_nutrition(-5)
		H.adjustBruteLoss(CORDYCEPS_HEAL_FACTOR)
		H.adjustFireLoss(CORDYCEPS_HEAL_FACTOR)

/datum/species/cordyceps/get_species_description()
	return "These guys are fucked" //TODO: - Racc

/*
	Brain
*/
/obj/item/organ/brain/cordyceps
	actions_types = list(/datum/action/item_action/organ_action/cordyceps_escape)
/*
	Action
*/
/datum/action/item_action/organ_action/cordyceps_escape
	name = "Cordyceps Escape" //TODO: Rename this - Racc
	desc = "Leave this body, and enter your primitive form."
	icon_icon = 'icons/mob/actions.dmi'
	button_icon_state = "annihilate"
	transparent_when_unavailable = TRUE
	///How long it takes us to escape
	var/escape_timer = 5 SECONDS
	///How long users are prompted to escape before dying
	var/death_timer = 5 SECONDS

/datum/action/item_action/organ_action/cordyceps_escape/Trigger()
	if(!iscarbon(owner) || !do_after(owner, escape_timer, owner))
		return
	escape_action()

/datum/action/item_action/organ_action/cordyceps_escape/Grant(mob/M)
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_DEATH, PROC_REF(catch_death))

/datum/action/item_action/organ_action/cordyceps_escape/Remove(mob/M)
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_DEATH)

/datum/action/item_action/organ_action/cordyceps_escape/proc/escape_action()
	var/mob/living/simple_animal/cordyceps_crawler/new_body = new(get_turf(owner))
	//Transfer control
	owner.mind.transfer_to(new_body)
	//Yoink the owner's brain
	var/mob/living/carbon/C = owner
	var/obj/item/organ/brain/B = C.getorganslot(ORGAN_SLOT_BRAIN)
	B.Remove(C)
	new_body.take_brain(B)
	//Explode our heart
	var/obj/item/organ/heart/H = C.getorganslot(ORGAN_SLOT_HEART)
	H?.damage += H?.maxHealth*2

/datum/action/item_action/organ_action/cordyceps_escape/proc/catch_death(datum/source)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(catch_death_async))

/datum/action/item_action/organ_action/cordyceps_escape/proc/catch_death_async()
	var/option = tgui_alert(owner, "Do you want to escape this dying body?", "Escape Body", list("Yes", "No"), death_timer, TRUE)
	if(iscarbon(owner) && option == "Yes")
		escape_action()

/*
	Mob
*/
/mob/living/simple_animal/cordyceps_crawler
	name = "cordyceps homunculi"
	desc = "A wet lump of meat."
	icon_state = "butterfly"
	icon_living = "butterfly"
	icon_dead = "butterfly_dead"
	layer = BELOW_MOB_LAYER

	maxHealth = 2
	health = 2

	response_help = "shoos"
	response_disarm = "brushes aside"
	response_harm = "squashes"
	speak_emote = list("squelches")
	friendly = "caresses"
	verb_say = "squelches"
	verb_ask = "squelches inquisitively"
	verb_exclaim = "squelches intensely"

	density = FALSE
	movement_type = GROUND
	pass_flags = PASSTABLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	mob_biotypes = list(MOB_ORGANIC)

	///Ref to an internal brain for transfer stuff
	var/obj/item/organ/brain/brain_holder
	///How long it takes us to bore into someone
	var/bore_time = 10 SECONDS
	///What's the limit of damage we can heal?
	var/damage_limit = 100

/mob/living/simple_animal/cordyceps_crawler/Destroy()
	. = ..()
	if(brain_holder)
		brain_holder.forceMove(get_turf(src))

/mob/living/simple_animal/cordyceps_crawler/death(gibbed)
	. = ..()
	qdel(src)

/mob/living/simple_animal/cordyceps_crawler/UnarmedAttack(atom/A, proximity)
	. = ..()
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		var/obj/item/organ/brain/B = C.getorganslot(ORGAN_SLOT_BRAIN)
		if(C.client && !C.stat) //TODO: Do a proper check there - Racc
			to_chat(src, "<span class='warning'>There's something in here, and it stares back!</span>")
			return
		//Do some health checks
		if(C.stat == DEAD && C.getBruteLoss() >= damage_limit || C.getFireLoss() >= damage_limit || HAS_TRAIT(C, TRAIT_HUSK))
			to_chat(src, "<span class='warning'>This body is dead, and beyond what we can repair!</span>")
			return
		if(do_after(src, bore_time * (B ? 1 : 0.5), C))
			B?.Remove(C)
			B?.forceMove(get_turf(C))
			//Hand over controls
			mind.transfer_to(C)
			brain_holder.Insert(C)
			brain_holder.forceMove(C)
			//Insert reviving chemicals
			var/datum/reagents/R = new(5)
			R.add_reagent(/datum/reagent/medicine/strange_reagent, 5)
			R.trans_to(C, 5, method = TOUCH) //This process is required to make the chem work //TODO: Consider making a subtype that works whenever - Racc
			//Add the tranformation disease
			//TODO: Don't add the disease multiple times, and make cordyceps immune - Racc
			var/datum/disease/transformation/cordyceps/disease = new()
			disease.infect(C)
			//Unmake ourselves
			qdel(src)

/mob/living/simple_animal/cordyceps_crawler/proc/take_brain(obj/item/organ/brain/_brain)
	if(brain_holder)
		return FALSE
	brain_holder = _brain
	brain_holder.forceMove(src)
	maxHealth = brain_holder.maxHealth
	health = brain_holder.maxHealth-brain_holder.damage
	return TRUE

#undef CORDYCEPS_HEAL_FACTOR
