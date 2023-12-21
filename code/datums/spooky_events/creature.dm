/datum/spooky_event/creature
	name = "Chupacabra"
	cost = 100
	event_message = "Something is loose..."
	requires_chaplain = TRUE
	gain_modifier = 1
	///Ref to the creature
	var/mob/living/simple_animal/hostile/chupacabra/creature

/datum/spooky_event/creature/Destroy(force, ...)
	. = ..()
	creature = null

/datum/spooky_event/creature/setup(datum/controller/subsystem/spooky/SS)
	var/area/A = pick_weight(SS?.areas) || pick(GLOB.the_station_areas)
	if(!A)
		log_game("[name]([src]) failed to create at [world.time]. No area available.")
		qdel(src)
		return FALSE
	creature = new creature(pick(A.contained_turfs))
	RegisterSignal(creature, COMSIG_MOB_DEATH, PROC_REF(handle_creature))
	log_game("[name]([src]) was created at [world.time], located in [A].")
	return TRUE

/datum/spooky_event/creature/get_location()
	return creature

/datum/spooky_event/creature/proc/handle_creature(datum/source)
	SIGNAL_HANDLER

	qdel(src)
