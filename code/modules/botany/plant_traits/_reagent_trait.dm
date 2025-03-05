/datum/plant_trait/reagent
	///What reagent are we adding
	var/datum/reagent/reagent
	///How much of that reagent are we adding
	var/volume = 1

/datum/plant_trait/reagent/New()
	. = ..()
	name = "[reagent]"
	desc = "Adds [volume] units of [reagent] to produced fruit"
	if(!parent)
		return
	RegisterSignal(parent.parent, COMSIG_PLANT_FRUIT_BUILT, PROC_REF(catch_fruit))

/datum/plant_trait/reagent/proc/catch_fruit(datum/source, list/fruits)
	SIGNAL_HANDLER

	for(var/obj/fruit as anything in fruits)
		fruit.reagents?.add_reagent(reagent, volume)
