/*
	Recipes for the witch table
*/

/datum/witch_recipe
	///Name of this recipe
	var/name = ""
	///Description of this recipe
	var/desc = "Makes jack fuckin' shit."
	///Icon for this recipe, pretty stuff
	var/icon = 'icons/obj/items_and_weapons.dmi'
	var/icon_state = "towel"
	///Result of this recipe - typically an item, but you can get fancy with the produce() proc
	var/atom/result = /obj/item/candle
	///The required items for this recipe - can also get fancy with the get_recipe() proc
	var/list/recipe = list(/obj/item/candle = 1)
	///Does this recipe consume the ingredients
	var/consumes_ingredients = TRUE

///Used to check the given loc for the items we need
/datum/witch_recipe/proc/check_recipe(atom/loc)
	var/list/available = recipe.Copy()
	//Compile all the contents in the format we want
	for(var/atom/i in loc.contents)
		if(available[i.type])
			available[i.type] -= 1
	//See if 'that sparks'
	for(var/i in available)
		if(available[i] != 0)
			return FALSE
	return TRUE

///Used to 'give' the item, or effect to the goober we owe it to
/datum/witch_recipe/proc/produce(mob/user, atom/loc)
	var/obj/item/I = new result(get_turf(user))
	user.put_in_active_hand(I)
	//'consume' ingredients, if we should
	if(consumes_ingredients)
		var/list/available = recipe.Copy()
		for(var/i in loc.contents)
			if(available[i.type])
				available[i.type] -= 1
				new /obj/effect/decal/cleanable/ash(get_turf(loc))
				qdel(i)
