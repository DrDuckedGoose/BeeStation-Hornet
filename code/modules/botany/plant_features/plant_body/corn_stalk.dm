/datum/plant_feature/body/corn_stalk
	species_name = "testus testium" //TODO: - Racc
	name = "test" //TODO: - Racc
	icon_state = "corn_stalk"
	overlay_positions = list(list(16, 27))
	yields = PLANT_BODY_YIELD_MICRO
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_SLOW //Doesn't really matter
	max_harvest = PLANT_BODY_HARVEST_MICRO

/datum/plant_feature/body/corn_stalk/apply_fruit_overlay(obj/effect/fruit_effect, offset_x, offset_y)
	. = ..()
	fruit_effect.transform = fruit_effect.transform.Scale(1, -1)
