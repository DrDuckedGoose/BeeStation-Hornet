//Space imunity
/datum/organ_mutation/lungs/space_adaption
	name = "Exothermic Respiration"
	desc = "When exposed to adrenaline, the user's lungs will produce heat, enough to survive the vacuum of space."
	text_gain_indication = "<span class='notice'>Your body feels warm!</span>"
	quality = 2
	weight = 50
	///How long space immunity lasts for after each pulse
	var/protection_length = 8 SECONDS
	///Reference to timer - used for stopping on loss
	var/protection_timer
	///Flag for when owner is invunerable to space - used to disable protection on loss
	var/is_protected = FALSE

/datum/organ_mutation/lungs/space_adaption/trigger()
	if(..() || is_protected)
		return
	//Stat changes - make owner immune to space
	ADD_TRAIT(carbon_owner, TRAIT_RESISTCOLD, "space_adaptation")
	ADD_TRAIT(carbon_owner, TRAIT_RESISTLOWPRESSURE, "space_adaptation")
	//Visual changes - make owner glow
	//TODO

	is_protected = TRUE
	protection_timer = addtimer(CALLBACK(src, .proc/finish_trigger), protection_length, TIMER_STOPPABLE)

/datum/organ_mutation/lungs/space_adaption/proc/finish_trigger()
	REMOVE_TRAIT(carbon_owner, TRAIT_RESISTCOLD, "space_adaptation")
	REMOVE_TRAIT(carbon_owner, TRAIT_RESISTLOWPRESSURE, "space_adaptation")
	deltimer(protection_timer)

	is_protected = FALSE

/datum/organ_mutation/lungs/space_adaption/on_loss()
	if(..() || !is_protected)
		return
	REMOVE_TRAIT(carbon_owner, TRAIT_RESISTCOLD, "space_adaptation")
	REMOVE_TRAIT(carbon_owner, TRAIT_RESISTLOWPRESSURE, "space_adaptation")
	deltimer(protection_timer)
