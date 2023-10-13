/datum/spooky_event/possession
	name = "possession"
	///The corpse we're responsible for
	var/mob/living/corpse_owner

/datum/spooky_event/possession/Destroy(force, ...)
	. = ..()
	corpse_owner = null

/datum/spooky_event/possession/setup(datum/controller/subsystem/spooky/SS)
	var/mob/living/corpse = pick_weight(SS?.corpses)
	//logging
	if(!corpse || HAS_TRAIT(corpse, TRAIT_POSSESSED))
		log_game("[name]([src]) failed to create at [world.time]. No corpse available.")
		qdel(src)
		return FALSE
	log_game("[name]([src]) was created at [world.time], possessed [corpse].")
	//Our unique logic
	corpse.ai_controller = /datum/ai_controller/monkey/angry
	corpse.revive(TRUE, TRUE)
	corpse.InitializeAIController()
	ADD_TRAIT(corpse, TRAIT_POSSESSED, TRAIT_GENERIC)
	corpse_owner = corpse

	return TRUE
