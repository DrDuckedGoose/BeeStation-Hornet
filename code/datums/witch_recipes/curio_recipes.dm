/*
	Doll recipe - /obj/item/curio/doll
*/

/datum/witch_recipe/doll
	name = "subsume doll"
	desc = "Subsumes a spirit into a doll container, to make a guide."
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
	name = "subsume gps"
	desc = "Subsumes a spirit into a gps container, to make a wayfinder."
	result = /obj/item/curio/compass
	recipe = list(/obj/item/gps = 1)

/*
	Tally recipe - /obj/item/curio/tally
*/

/datum/witch_recipe/tally
	name = "subsume timer"
	desc = "Subsumes a spirit into a timer container, to make a counter."
	result = /obj/item/curio/tally
	recipe = list(/obj/item/assembly/timer = 1)

/*
	Water candle recipe - /obj/item/curio/water_candle
*/

/datum/witch_recipe/water_candle
	name = "subsume candle"
	desc = "Subsumes a spirit into a candle container, to make a spectral beacon."
	result = /obj/item/curio/water_candle
	recipe = list(/obj/item/candle = 1)
