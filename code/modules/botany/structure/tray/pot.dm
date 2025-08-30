/obj/machinery/plumbing/tank/plant_tray/pot
	name = "plant pot"
	icon_state = "pot"
	use_indicators = FALSE
	density = FALSE
	//TODO: let people hide behind this - Racc

/*
	Variant that contains a random plant
	Used for hallway plants
*/
/obj/machinery/plumbing/tank/plant_tray/pot/random

/obj/machinery/plumbing/tank/plant_tray/pot/random/Initialize(mapload)
	. = ..()
//Plant
	var/obj/item/plant_item/random/random_plant = new(get_turf(src))
	var/datum/component/plant/plant_component = random_plant.GetComponent(/datum/component/plant)
	if(!SEND_SIGNAL(plant_component, COMSIG_PLANT_POLL_TRAY_SIZE, src)) //Just in case //TODO: Do something with this - Racc
		qdel(random_plant)
		return
	random_plant.forceMove(src) //forceMove instead of creating it inside to proc Entered()
	vis_contents += random_plant
	SEND_SIGNAL(plant_component, COMSIG_PLANT_PLANTED, src)
//Needs
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		for(var/datum/plant_need/need as anything in feature.plant_needs)
			need.fufill_need(src)
