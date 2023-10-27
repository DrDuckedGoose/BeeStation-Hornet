/datum/spooky_event/possession
	name = "possession"
	///The corpse we're responsible for
	var/mob/living/corpse_owner

/datum/spooky_event/possession/Destroy(force, ...)
	if(!QDELING(corpse_owner))
		REMOVE_TRAIT(corpse_owner, TRAIT_POSSESSED, TRAIT_GENERIC)
		QDEL_NULL(corpse_owner.ai_controller)
	corpse_owner = null
	return ..()

/datum/spooky_event/possession/setup(datum/controller/subsystem/spooky/SS)
	..()
	var/mob/living/corpse = pick_weight(SS?.corpses)
	//logging
	if(!corpse || HAS_TRAIT(corpse, TRAIT_POSSESSED)) //We usually remove possessed corpses from the list, but you never know... especially admins
		log_game("[name]([src]) failed to create at [world.time]. No corpse available.")
		qdel(src)
		return FALSE
	log_game("[name]([src]) was created at [world.time], possessed [corpse].")
	//Our unique logic
	RegisterSignal(corpse, COMSIG_MOB_DEATH, PROC_REF(handle_corpse))
	RegisterSignal(corpse, COMSIG_PARENT_QDELETING, PROC_REF(handle_corpse))
	corpse.ai_controller = /datum/ai_controller/monkey/angry //TODO: Implement AIs from design doc - Racc
	corpse.revive(TRUE, TRUE)
	corpse.InitializeAIController()
	ADD_TRAIT(corpse, TRAIT_POSSESSED, TRAIT_GENERIC)
	SS.remove_corpse(corpse)
	corpse_owner = corpse
	//Inform ghosts
	notify_ghosts("[corpse.name] has been possesed at [get_area(corpse)]!", source = corpse)
	//Make the possessed corpse shake, for that freaky effect
	//TODO: - Racc

	return TRUE

/datum/spooky_event/possession/proc/handle_corpse(datum/source)
	SIGNAL_HANDLER

	qdel(src)
