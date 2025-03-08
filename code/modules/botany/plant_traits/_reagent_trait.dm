/datum/plant_trait/reagent
	///What reagent are we adding
	var/datum/reagent/reagent
	///How much of that reagent are we adding
	var/volume_percentage = 1 //TODO: Change this to a % - Racc

/datum/plant_trait/reagent/New()
	. = ..()
	name = "[reagent]"
	desc = "Adds [volume_percentage] units of [reagent] to produced fruit"

/datum/plant_trait/reagent/setup_component_parent(datum/source)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent.parent, COMSIG_PLANT_FRUIT_BUILT, PROC_REF(catch_fruit))

/datum/plant_trait/reagent/proc/catch_fruit(datum/source, obj/fruit)
	SIGNAL_HANDLER

	var/datum/plant_feature/fruit/fruit_feature = parent
	fruit.reagents?.add_reagent(reagent, volume_percentage * fruit_feature.total_volume)
