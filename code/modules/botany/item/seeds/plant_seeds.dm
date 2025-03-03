/obj/item/plant_seeds
	name = "seeds"
	///List of plant features for the plant we're... planting
	var/list/plant_features = list(/datum/plant_feature/body, /datum/plant_feature/fruit, /datum/plant_feature/roots)

/obj/item/plant_seeds/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/obj/item/plant_item/plant = new(target)
	plant.AddComponent(/datum/component/plant, plant, plant_features)

//Debug
