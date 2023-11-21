/*
	Abstract for spooky events like possession and ghosts
*/

/datum/spooky_event
	///Name of this event
	var/name = ""
	///Does this event require an active chaplain?
	var/requires_chaplain = FALSE
	///How much does this event cost?
	var/cost = 0
	///The holy favour reward for beating this event
	var/reward = 100

/datum/spooky_event/New()
	. = ..()
	
/datum/spooky_event/Destroy(force, ...)
	. = ..()
	//Reward for doing this event
	var/datum/religion_sect/R = GLOB.religious_sect
	R?.adjust_favor(reward)

/*
	This kinda also applies to spooky_behaviour.dm, there's only one spooky subsystem, but I have the
	inclination that this might save me in the future, or allow for admin goofs.
*/
/datum/spooky_event/proc/setup(datum/controller/subsystem/spooky/SS)
	notify_ghosts("The ([SS]) has attempted to create a '[name]' event!")
	return

///Used with curio stuff
/datum/spooky_event/proc/get_location()
	return
