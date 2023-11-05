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
	var/obj/item/I = new result(get_turf(user))
	user.put_in_active_hand(I)
	//'consume' ingredients, if we should
	if(consumes_ingredients)
		for(var/atom/i in loc.contents)
			if(istype(i, /obj/item/toy/plush))
				var/turf/T = get_turf(user)
				new /obj/effect/decal/cleanable/ash(T)
				crafting_effect(i, T)
				qdel(i)
				return
