/*
	Adds a reagent to the plant, typically fruit
*/
//TODO: Make blood reagents always o- - Racc
//TODO: make argument for init-ing this on a fruit - Racc
/datum/plant_trait/reagent
	genetic_cost = 0
	random_trait = FALSE
	///What reagent are we adding
	var/datum/reagent/reagent
	///How much of that reagent are we adding
	var/volume_percentage = 1

/datum/plant_trait/reagent/New(datum/plant_feature/_parent, _reagent, _percentage, copy_rule)
	reagent = _reagent || reagent
	volume_percentage = _percentage || volume_percentage
	. = ..()
	name = "[capitalize(initial(reagent.name))]"
	desc = "[volume_percentage*100]% of fruit reagents is [name]"
	//If we're a fast reagent, try add ourselves to the dictionary
	if(_reagent && _percentage && !copy_rule)
		SSbotany.append_reagent_trait(copy())

/datum/plant_trait/reagent/get_ui_stats()
	. = ..()
	var/list/data = .
	data[1]["dictionary_name"] = "[name] [volume_percentage*100]%"

/datum/plant_trait/reagent/setup_component_parent(datum/source)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent.parent, COMSIG_FRUIT_BUILT, PROC_REF(catch_fruit))

/datum/plant_trait/reagent/copy(datum/plant_feature/_parent, datum/plant_trait/_trait)
	//Support for custom reagents traits made with fast reagents
	var/datum/plant_trait/reagent/new_trait = _trait || new type(_parent, reagent, volume_percentage, TRUE)
	return new_trait

/datum/plant_trait/reagent/get_id()
	return "[reagent]-[volume_percentage]"

/datum/plant_trait/reagent/proc/catch_fruit(datum/source, obj/fruit)
	SIGNAL_HANDLER

	var/datum/plant_feature/fruit/fruit_feature = parent
	fruit.reagents?.add_reagent(reagent, volume_percentage * fruit_feature.total_volume)
