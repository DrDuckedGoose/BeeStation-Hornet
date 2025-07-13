/*
	Tuber, generic
*/
/datum/plant_feature/body/tuber
	species_name = "testus testium" //TODO: - Racc
	name = "test" //TODO: - Racc
	icon_state = "" //TODO: This should be nothing, invisible. Maybe cuts the fruit in half, visually, to make it look like it's in the dirt - Racc
	overlay_positions = list(list(16,6)) //TODO: Make this the middle - Racc
	yields = PLANT_BODY_YIELD_MICRO
	yield_cooldown_time = PLANT_BODY_YIELD_TIME_FAST
	max_harvest = PLANT_BODY_HARVEST_MICRO
	use_mouse_offset = TRUE
	slot_size = PLANT_BODY_SLOT_SIZE_SMALL
	///Pre-made mask for making fruits look burried
	var/icon/tuber_mask

/datum/plant_feature/body/tuber/New(datum/component/plant/_parent)
	. = ..()
	tuber_mask = icon(icon, "tuber_mask")

/datum/plant_feature/body/tuber/apply_fruit_overlay(obj/effect/fruit_effect, offset_x, offset_y)
	. = ..()
	fruit_effect.add_filter("tuber_mask", 1, alpha_mask_filter(icon = tuber_mask, flags = MASK_INVERSE))
