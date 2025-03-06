/datum/plant_trait/reagent
	///What reagent are we adding
	var/datum/reagent/reagent
	///How much of that reagent are we adding
	var/volume = 1 //TODO: Change this to a % - Racc

/datum/plant_trait/reagent/New()
	. = ..()
	name = "[reagent]"
	desc = "Adds [volume] units of [reagent] to produced fruit"
	if(!parent)
		return
	RegisterSignal(parent.parent, COMSIG_PLANT_FRUIT_BUILT, PROC_REF(catch_fruit))

/datum/plant_trait/reagent/proc/catch_fruit(datum/source, obj/fruit)
	SIGNAL_HANDLER

	fruit.reagents?.add_reagent(reagent, volume)
