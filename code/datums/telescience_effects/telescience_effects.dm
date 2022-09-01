/datum/telescience_effect
	///Name for incident record
	var/name
	///Description for incident record
	var/desc

/datum/telescience_effect/proc/action(/obj/structure/T)
	return

// ===== Monster spawner =====
/datum/telescience_effect/incurson
	name = "Biodimensional Incursion"
	desc = "An entity has emerged from the portal."
	///The type of entity to spawn
	var/mob/living/simple_animal/product_entity = /mob/living/simple_animal/hostile/headcrab

/datum/telescience_effect/incurson/action(obj/structure/T)
	product_entity = new(get_turf(T))

// ===== Fire =====
/datum/telescience_effect/fire
	name = "Pyrodimensional Eruption"
	desc = "A wave of heat has erupted from the portal."
	///Size of fire
	var/size = 3

/datum/telescience_effect/fire/action(obj/structure/T)
	playsound(T, 'sound/effects/bamf.ogg', 50, TRUE)
	for(var/turf/open/turf in RANGE_TURFS(size, T))
		if(!locate(/obj/effect/safe_fire) in turf)
			new /obj/effect/safe_fire(turf)

// ===== Fire BEEEG =====
/datum/telescience_effect/fire/big
	name = "Giga Pyrodimensional Eruption"
	desc = "A massive wave of heat has erupted from the portal."
	size = 8
