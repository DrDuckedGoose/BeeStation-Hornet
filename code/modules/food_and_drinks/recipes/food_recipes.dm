/*
	Not really like a traditional crafting recipe, but similar enough.a
	Essentially, when the player combines food, if the combination is a set recipe, we set it to that recipe
*/
/datum/food_recipe
	///What we will rename this food item to
	var/name = ""
	///
	var/icon = 'icons/obj/food/burgerbread.dmi'
	///
	var/icon_state = "ERROR"
	///
	var/update_appearance = TRUE
	///What we will transform this food item into - Don't set this unless you must
	var/obj/item/food/food_item
	///What the combination requires to become this recipe
	var/list/reqs = list()

//Proc for swapping a food item for its recipe counterpart
/datum/food_recipe/proc/adjust_food(atom/target)
	//If we're supposed to completely replace the item
	if(food_item)
		food_item = new food_item(target.loc)
		qdel(target)
		return
	//naming
	target.name = name
	//Build new appearence
	//TODO: make this actually work
	if(update_appearance)
		target.cut_overlays()
		var/mutable_appearance/MA = mutable_appearance(icon, icon_state, target.layer, target.plane, target.alpha, target.appearance_flags, target.color)
		target.appearance = MA

/datum/food_recipe/meatball_burger
	name = "meatyball"
	reqs = list(/obj/item/food/meatball = 1, /obj/item/food/burger/empty = 1)

/datum/food_recipe/meatball_burger/two
	name = "meatyball two"
	reqs = list(/obj/item/food/meatball = 1, /obj/item/food/burger/empty = 1, /obj/item/food/meat/slab/monkey = 1)

/datum/food_recipe/meat
	name = "meat yeah!"
	reqs = list(/obj/item/food/burger/empty = 1, /obj/item/food/meat/slab/monkey = 1)

