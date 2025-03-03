/datum/plant_feature/body/corn_stalk
	icon_state = "corn_stalk"
	overlay_positions = list(list(16, 27))

/datum/plant_feature/body/corn_stalk/apply_fruit_overlay(obj/effect/fruit_effect, offset_x, offset_y)
	. = ..()
	fruit_effect.transform = fruit_effect.transform.Scale(1, -1)
