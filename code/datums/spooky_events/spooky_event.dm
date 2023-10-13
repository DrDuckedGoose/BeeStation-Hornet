/*
	Abstract for spooky events like possession and ghosts
*/

/datum/spooky_event
	///Name of this event
	var/name = ""
	///Cost of this event
	var/cost = 1

/*
	This kinda also applies to spooky_behaviour.dm, there's only one spooky subsystem, but I have the
	inclination that this might save me in the future, or allow for admin goofs.
*/
/datum/spooky_event/New()
	. = ..()
	
/datum/spooky_event/proc/setup(datum/controller/subsystem/spooky/SS)
	return

//Move this later
/datum/spooky_event/possession
	name = "possession"

/datum/spooky_event/possession/setup(datum/controller/subsystem/spooky/SS)
	var/mob/living/corpse = pick_weight(SS?.corpses)
	//logging
	if(!corpse)
		log_game("[name]([src]) failed to create at [world.time].")
		qdel(src)
		return FALSE
	log_game("[name]([src]) was created at [world.time], possessed [corpse].")
	//Our unique logic
	var/matrix/n_transform = corpse.transform
	n_transform.Scale(2, 2)
	corpse.transform = n_transform

	return TRUE
