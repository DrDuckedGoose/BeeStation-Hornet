SUBSYSTEM_DEF(food)
	name = "Food"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ACHIEVEMENTS+1
	//List of recipes, keyed by reqs
	var/list/recipes = list()

/datum/controller/subsystem/food/Initialize(timeofday)
	populate_recipes()
	return ..()

/datum/controller/subsystem/food/proc/populate_recipes()
	for(var/datum/food_recipe/f as() in subtypesof(/datum/food_recipe))
		f = new f()
		recipes += list(f.text_reqs = f)
