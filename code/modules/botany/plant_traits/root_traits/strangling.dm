/*
	Pauses progress on all neighbour plants
*/

/datum/plant_trait/roots/strangling
	name = "Strangling"
	desc = "Impedes the growth of plants, and their fruit."
	///Quick reference to the plant item
	var/obj/item/plant_item
	///Remember our old tray for signal cleanup
	var/atom/strangle_loc

/datum/plant_trait/roots/strangling/setup_component_parent(datum/source)
	. = ..()
	if(!parent)
		return
	plant_item = parent.parent.plant_item
	//Strangle our loc
	setup_strangle()
	//Reset our strangle loc
	RegisterSignal(plant_item, COMSIG_MOVABLE_MOVED, PROC_REF(setup_strangle))

/datum/plant_trait/roots/strangling/proc/setup_strangle(datum/source)
	SIGNAL_HANDLER

	if(strangle_loc)
		UnregisterSignal(strangle_loc, COMSIG_PLANT_NEEDS_PAUSE)
	strangle_loc = plant_item.loc //TODO: loc qdel cleanup - Racc
	RegisterSignal(strangle_loc, COMSIG_PLANT_NEEDS_PAUSE, PROC_REF(catch_pause))

/datum/plant_trait/roots/strangling/proc/catch_pause(datum/source, datum/component/plant/_plant)
	SIGNAL_HANDLER

	//Avoid strangling ourselves
	if(_plant == parent.parent)
		return
	return TRUE
