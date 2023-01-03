#define MUT_INPUT 1
#define MUT_OUTPUT 0

#define ORGAN_MUT_TRIGGER "organ_mut_trigger"

/datum/organ_mutation
	var/name = "mutation"
	var/desc = "A mutation"
	///Mob & organ owners
	var/mob/living/carbon/carbon_owner
	var/obj/item/organ/organ_owner
	///Message sent to owner when inserting / uninserting organ
	var/text_gain_indication = ""
	var/text_lose_indication = ""
	///List of species that aren't allowed to use this mutation
	var/list/species_blacklist = list()
	///The numeric quality of this mutation, increases / decreases available mutation slots in an organ
	var/quality = 0
	///The rarity of this mutation, 0 / 100
	var/weight = 100
	///The mutation type operator - [input, output] - [powers = output] - [triggers = input]
	var/operator_type = MUT_OUTPUT
	///variable to override visuals and let the mutation handle it itself
	var/override_visuals = FALSE

/datum/organ_mutation/New(obj/item/organ/_organ_owner)
	..()
	organ_owner = _organ_owner

/datum/organ_mutation/proc/on_gain()
	carbon_owner = organ_owner?.owner
	
	if(!carbon_owner || !organ_owner || locate(carbon_owner?.dna?.species) in species_blacklist)
		return TRUE
	if(!override_visuals)
		handle_visuals()
	to_chat(carbon_owner, text_gain_indication)
	//Register signal with organ to listen for trigger
	RegisterSignal(organ_owner, ORGAN_MUT_TRIGGER, .proc/trigger)
	return

/datum/organ_mutation/proc/on_loss()
	if(!carbon_owner || !organ_owner || locate(carbon_owner?.dna.species) in species_blacklist)
		return TRUE
	if(!override_visuals)
		handle_visuals(TRUE)
	to_chat(carbon_owner, text_lose_indication)
	UnregisterSignal(organ_owner, ORGAN_MUT_TRIGGER)
	return

/datum/organ_mutation/proc/trigger()
	if(!carbon_owner || locate(carbon_owner?.dna.species) in species_blacklist)
		return TRUE
	return

/datum/organ_mutation/proc/handle_visuals(remove = FALSE)
	return
