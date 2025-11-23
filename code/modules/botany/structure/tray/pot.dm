/obj/item/plant_tray/pot
	name = "plant pot"
	icon_state = "pot"
	use_indicators = FALSE
	plumbing = FALSE
	density = FALSE
	layer = ABOVE_MOB_LAYER
	interaction_flags_item = INTERACT_ITEM_ATTACK_HAND_PICKUP
	layer_offset = 1.2

/obj/item/plant_tray/pot/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/tactical)
	AddComponent(/datum/component/two_handed, require_twohands=TRUE, force_unwielded=10, force_wielded=10)

/*
	Variant that contains a random plant
	Used for hallway plants
*/
/obj/item/plant_tray/pot/random

/obj/item/plant_tray/pot/random/Initialize(mapload)
	. = ..()
//Plant
	var/obj/item/plant_item/random/random_plant = new(get_turf(src))
	var/datum/component/plant/plant_component = random_plant.GetComponent(/datum/component/plant)
	random_plant.forceMove(src) //forceMove instead of creating it inside to proc Entered()
	vis_contents += random_plant
	SEND_SIGNAL(plant_component, COMSIG_PLANT_PLANTED, src)
//Needs
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		for(var/datum/plant_need/need as anything in feature.plant_needs)
			need.fufill_need(src)
