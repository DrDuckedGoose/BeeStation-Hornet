/*
	Mycelium, generic body for mushrooms
*/
/datum/plant_feature/body/mushroom
	species_name = "testus testium"
	name = "mycelium"
	icon_state = ""
	overlay_positions = list(list(16,6)) //TODO: various positions in the tray - Racc
	yields = PLANT_BODY_YIELD_FOREVER
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_FAST
	max_harvest = PLANT_BODY_HARVEST_SMALL
	slot_size = PLANT_BODY_SLOT_SIZE_MICRO
	genetic_budget = 1
	//Mushrooms have no needs
	plant_needs = list()
	//We can pair with only mushroom fruit, but any kind of roots
	whitelist_features = list(/datum/plant_feature/fruit/mushroom, /datum/plant_feature/roots)
