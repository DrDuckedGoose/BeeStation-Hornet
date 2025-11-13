//TODO: Consider giving these unique stats, and fix the sprites - Racc
/*
	Corn Stalk
*/
/datum/plant_feature/body/corn_stalk
	species_name = "aureum culmus"
	name = "corn stalk"
	icon_state = "corn_stalk"
	overlay_positions = list(list(16, 27))
	yields = PLANT_BODY_YIELD_MICRO
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_SLOW //Doesn't really matter, we only get one
	max_harvest = PLANT_BODY_HARVEST_MICRO
	upper_fruit_size = PLANT_FRUIT_SIZE_SMALL
	seeds = 5

/datum/plant_feature/body/corn_stalk/apply_fruit_overlay(obj/effect/fruit_effect, offset_x, offset_y)
	. = ..()
	fruit_effect.transform = fruit_effect.transform.Scale(1, -1)

/*
	Rice Stalk
*/
/datum/plant_feature/body/corn_stalk/rice
	species_name = "stipula alba"
	name = "rice stalk"
	icon_state = "missing"
	overlay_positions = list(list(16, 27))

/*
	Wheat Stalk
*/
/datum/plant_feature/body/corn_stalk/wheat
	species_name = "bracchium aurum"
	name = "wheat stalk"
	icon_state = "missing"
	overlay_positions = list(list(16, 27))

/*
	Pineapple Stalk
*/
/datum/plant_feature/body/corn_stalk/pineapple
	species_name = "bracchium spinosum"
	name = "pineapple stalk"
	icon_state = "missing"
	overlay_positions = list(list(16, 27))

/*
	Sun Stalk
*/
/datum/plant_feature/body/corn_stalk/sunflower
	species_name = "sol culmo"
	name = "sunflower stalk"
	icon_state = "missing"
	overlay_positions = list(list(16, 27))

