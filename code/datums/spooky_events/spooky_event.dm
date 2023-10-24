/*
	Abstract for spooky events like possession and ghosts
*/

/datum/spooky_event
	///Name of this event
	var/name = ""

/datum/spooky_event/New()
	. = ..()
	
/*
	This kinda also applies to spooky_behaviour.dm, there's only one spooky subsystem, but I have the
	inclination that this might save me in the future, or allow for admin goofs.
*/
/datum/spooky_event/proc/setup(datum/controller/subsystem/spooky/SS)
	return
