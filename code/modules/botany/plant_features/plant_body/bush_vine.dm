//TODO: Consider giving these unique stats - Racc
/*
	Tomato Bush-Vine
*/
/datum/plant_feature/body/bush_vine
	species_name = "testus testium" //TODO: - Racc
	name = "test" //TODO: - Racc
	icon_state = "bush_vine"
	overlay_positions = list(list(10, 18), list(23, 17), list(16, 24), list(10, 10), list(23, 10), list(17, 17), list(17, 10))
	yields = PLANT_BODY_YIELD_MEDIUM
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_FAST
	max_harvest = PLANT_BODY_HARVEST_MEDIUM

/*
	Berry Bush
*/
/datum/plant_feature/body/bush_vine/berry
	species_name = "testus testium" //TODO: - Racc
	name = "test" //TODO: - Racc
	icon_state = "bush"
	random_plant = TRUE

/*
	Flower Bush
*/
/datum/plant_feature/body/bush_vine/flower
	species_name = "testus testium" //TODO: - Racc
	name = "test" //TODO: - Racc
	icon_state = "bush_flower"
	draw_below_water = FALSE
	random_plant = TRUE
	overlay_positions = list(list(11, 12), list(21, 17), list(18, 11), list(24, 9), list(9, 8))

/*
	Grape Vine
*/
/datum/plant_feature/body/bush_vine/grape
	species_name = "testus testium" //TODO: - Racc
	name = "test" //TODO: - Racc
	icon_state = "bush_vine"
	overlay_positions = list(list(13, 16), list(21, 16), list(13, 9), list(21, 9), list(13, 2), list(21, 2)) //TODO: Remember to update these - Racc

/*
	Ground Vine
*/
/datum/plant_feature/body/bush_vine/ground
	species_name = "testus testium" //TODO: - Racc
	name = "test" //TODO: - Racc
	icon_state = "vine_ground"
	draw_below_water = FALSE
	overlay_positions = list(list(24, 6))
