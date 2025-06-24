/*
	Adds a reagent to the plant, typically fruit
*/
/datum/plant_trait/reagent
	///What reagent are we adding
	var/datum/reagent/reagent
	///How much of that reagent are we adding
	var/volume_percentage = 1

/datum/plant_trait/reagent/New(datum/plant_feature/_parent, _reagent, _percentage)
	reagent = _reagent || reagent
	volume_percentage = _percentage || volume_percentage
	. = ..()
	name = "[reagent]"
	desc = "[volume_percentage]% of fruit reagents is [reagent]"

/datum/plant_trait/reagent/setup_component_parent(datum/source)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent.parent, COMSIG_FRUIT_BUILT, PROC_REF(catch_fruit))

/datum/plant_trait/reagent/copy(datum/plant_feature/_parent, datum/plant_trait/_trait)
	//Support for custom reagents traits made with fast reagents
	var/datum/plant_trait/reagent/new_trait = _trait || new type(_parent, reagent, volume_percentage)
	return new_trait

/datum/plant_trait/reagent/get_id()
	return "[reagent]-[volume_percentage]"

/datum/plant_trait/reagent/proc/catch_fruit(datum/source, obj/fruit)
	SIGNAL_HANDLER

	var/datum/plant_feature/fruit/fruit_feature = parent
	fruit.reagents?.add_reagent(reagent, volume_percentage * fruit_feature.total_volume)
