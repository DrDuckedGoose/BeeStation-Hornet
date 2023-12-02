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
	///How much does this event affect spectral gain, positive reduces gain & negative increases gain
	var/gain_modifier = 0.3
	///The holy favour reward for beating this event
	var/holy_reward = 100
	///The spectral reduction reward for beating this event
	var/spectral_reward = -TRESPASS_LARGE
	///The message for this event
	var/event_message = "A terrible chill runs up your spine..."

/datum/spooky_event/New()
	. = ..()
	SSspooky.gain_rate -= gain_modifier

/datum/spooky_event/Destroy(force, ...)
	. = ..()
	//Reward for doing this event
	var/datum/religion_sect/R = GLOB.religious_sect
	R?.adjust_favor(holy_reward)
	SSspooky.adjust_trespass(src, spectral_reward, FALSE, TRUE)
	//undo gain reduction
	SSspooky.gain_rate += gain_modifier

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
