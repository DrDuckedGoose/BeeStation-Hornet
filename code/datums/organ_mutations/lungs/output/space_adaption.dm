//Space imunity
/datum/organ_mutation/lungs/space_adaption
	name = "Exothermic Respiration"
	desc = "When exposed to adrenaline, the user's lungs will produce heat, enough to survive the vacuum of space."
	text_gain_indication = "<span class='notice'>Your body feels warm!</span>"
	quality = 2
	weight = 50
	override_visuals = TRUE
	///How long space immunity lasts for after each pulse
	var/protection_length = 8 SECONDS
	///Reference to timer - used for stopping on loss
	var/protection_timer

/datum/organ_mutation/lungs/space_adaption/handle_visuals(remove = FALSE)
	switch(remove)
		if(FALSE)
			var/color = "#ff9627"
			var/filter = carbon_owner?.get_filter("space_adaption_outline")
			if(!filter)
				carbon_owner?.add_filter("space_adaption_outline", 5, outline_filter(0.2, color))
		if(TRUE)
			carbon_owner?.remove_filter("space_adaption_outline")

/datum/organ_mutation/lungs/space_adaption/trigger()
	if(..())
		return
	//Stat changes - make owner immune to space
	ADD_TRAIT(carbon_owner, TRAIT_RESISTCOLD, "space_adaptation")
	ADD_TRAIT(carbon_owner, TRAIT_RESISTLOWPRESSURE, "space_adaptation")
	handle_visuals()

	deltimer(protection_timer)
	protection_timer = addtimer(CALLBACK(src, .proc/finish_trigger), protection_length, TIMER_STOPPABLE)

/datum/organ_mutation/lungs/space_adaption/proc/finish_trigger()
	REMOVE_TRAIT(carbon_owner, TRAIT_RESISTCOLD, "space_adaptation")
	REMOVE_TRAIT(carbon_owner, TRAIT_RESISTLOWPRESSURE, "space_adaptation")
	deltimer(protection_timer)
	handle_visuals(TRUE)

/datum/organ_mutation/lungs/space_adaption/on_loss()
	if(..())
		return
	finish_trigger()
