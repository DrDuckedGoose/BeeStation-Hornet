SUBSYSTEM_DEF(food)
	name = "Food"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ACHIEVEMENTS+1
	
	var/list/recipes = list()

/datum/controller/subsystem/food/Initialize(timeofday)
	populate_recipes()
	recipes = GLOB.food_recipe_list
	return ..()

/proc/populate_recipes()
	//Chemical Reactions - Initialises all /datum/chemical_reaction into a list
	// It is filtered into multiple lists within a list.
	// For example:
	// chemical_reaction_list[/datum/reagent/toxin/plasma] is a list of all reactions relating to plasma

	if(GLOB.food_recipe_list)
		return

	var/paths = subtypesof(/datum/food_recipe)
	GLOB.food_recipe_list = list()

	for(var/path in paths)

		var/datum/food_recipe/FR = new path()
		var/list/ingredients = list()

		if(length(FR.reqs))
			for(var/ingredient in FR.reqs)
				ingredients += ingredient

		// Create filters based on each reagent id in the required reagents list
		for(var/id in ingredients)
			if(!GLOB.food_recipe_list[id])
				GLOB.food_recipe_list[id] = list()
			GLOB.food_recipe_list[id] += FR
			break // Don't bother adding ourselves to other reagent ids, it is redundant

/proc/check_recipes(datum/component/customizable_reagent_holder/RH)
	var/list/ingredients = RH.ingredients.Copy()
	ingredients += RH.parent
	for(var/atom/i in ingredients)
		//Check if this ingredient is apart of any recipe
		for(var/recipe in GLOB.food_recipe_list[i.type])
			var/datum/food_recipe/FR = recipe
			var/hits = 0
			//check if we have all, and exactly, the ingredients for this recipe
			for(var/atom/e in ingredients)
				if(FR.reqs[e.type])
					hits+=1
			if(hits == length(FR.reqs) && length(ingredients) == length(FR.reqs))
				return FR
