/datum/plant_trait/roots/parasitic
	name = "parasitic"
	desc = "This gene causes roots to parasitically feed of a plant's fruit, depositing their reagents into their environment."
	///How much do we multiply cannibalized reagents?
	var/cannibal_multiplier = 1.5

/datum/plant_trait/roots/parasitic/New(datum/plant_feature/_parent)
	. = ..()

/datum/plant_trait/roots/parasitic/setup_component_parent(datum/source)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent.parent, COMSIG_FRUIT_BUILT, PROC_REF(catch_fruit))

/datum/plant_trait/roots/parasitic/proc/catch_fruit(datum/source, obj/fruit)
	SIGNAL_HANDLER

	var/list/available_reagents = list()
	SEND_SIGNAL(parent.parent, COMSIG_PLANT_REQUEST_REAGENTS, available_reagents, parent)
	if(QDELETED(fruit))
		return
	var/divided_reagents = (fruit?.reagents.total_volume || 1) / length(available_reagents)
	if(!fruit?.reagents.total_volume)
		qdel(fruit)
		return
	for(var/datum/reagents/reagents as anything in available_reagents)
		fruit.reagents.trans_to(reagents, divided_reagents, cannibal_multiplier)
	qdel(fruit)
	SEND_SIGNAL(parent.parent, COMSIG_PLANT_ACTION_HARVEST)
