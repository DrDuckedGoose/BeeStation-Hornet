/*
	Doll recipe - /obj/item/curio/doll
*/

/datum/witch_recipe/doll
	name = "subsume doll"
	desc = "Subsumes a spirit into a doll container."
	result = /obj/item/curio/doll

//Overwrite parent to make it work with anydoll
/datum/witch_recipe/doll/check_recipe(atom/loc)
	//Compile all the contents in the format we want
	for(var/atom/i in loc.contents)
		if(istype(i, /obj/item/toy/plush))
			return TRUE
	return FALSE

//Also overwrite
/datum/witch_recipe/doll/produce(mob/user, atom/loc)
	for(var/atom/i in loc.contents)
		if(istype(i, /obj/item/toy/plush))
			var/turf/T = get_turf(user)
			//make the thing
			var/obj/item/curio/doll/I = new result(T, i)
			user.put_in_active_hand(I)
			//kill the thing
			new /obj/effect/decal/cleanable/ash(T)
			crafting_effect(i)
			qdel(i)
			return

/*
	Compass recipe - /obj/item/curio/compass
*/

/datum/witch_recipe/compass
	name = "subsume compass"
	desc = "Subsumes a spirit into a compass container."
	result = /obj/item/curio/compass
	recipe = list(/obj/item/gps = 1)
