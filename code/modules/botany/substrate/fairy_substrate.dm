/*
	Fairy Substrate

*/

/datum/plant_subtrate/fairy
	name = "fairy substrate"
	substrate_flags = PLANT_SUBSTRATE_DIRT | PLANT_SUBSTRATE_SAND |  PLANT_SUBSTRATE_CLAY | PLANT_SUBSTRATE_DEBRIS

/datum/plant_subtrate/fairy/New()
	. = ..()
	RegisterSignal(tray_parent, COMSIG_ATOM_ENTERED, PROC_REF(catch_tray_entered))

/datum/plant_subtrate/fairy/proc/catch_tray_entered(datum/source, atom/entered)
	SIGNAL_HANDLER

	var/datum/component/plant/plant_component = entered.GetComponent(/datum/component/plant)
	if(!istype(plant_component))
		return
	//TODO: Then do something cool - Racc
