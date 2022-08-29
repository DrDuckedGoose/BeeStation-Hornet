// ===== Monster spawner =====
/datum/telescience_effect/blocked/incurson
	name = "Biodimensional Incursion"
	desc = "An entity has emerged from the portal."
	///The type of entity to spawn
	var/mob/living/simple_animal/product_entity

/datum/telescience_effect/blocked/incurson/action(/obj/structure/teleporter_door/T)
	product_entity = new(get_turf(T))
