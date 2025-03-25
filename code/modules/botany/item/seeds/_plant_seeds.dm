//TODO: Consider making this a generic 'thing' and the actual seed part an element - Racc
/obj/item/plant_seeds
	name = "seeds"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "seeds"
	///List of plant features for the plant we're... planting
	var/list/plant_features = list()
	///How many seeds do we contain
	var/seeds = 1
	///Do / What name override do we use?
	var/name_override

/obj/item/plant_seeds/Initialize(mapload, list/_plant_features)
	. = ..()
	plant_features = _plant_features || plant_features
	for(var/feature as anything in plant_features)
		plant_features -= feature
		if(ispath(feature))
			plant_features += new feature()
		else
			plant_features += feature

/obj/item/plant_seeds/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!HAS_TRAIT(target, TRAIT_PLANTER)) //Add an override here for roots that let you plant on people
		return
	to_chat(user, "<span class='notice'>You begin to plant [src] into [target].</span>")
	if(!do_after(user, 2.3 SECONDS, target))
		return
	var/obj/item/plant_item/plant = new()
	plant.forceMove(target) //forceMove instead of creating it inside to proc Entered()
	if(!isturf(target) && isobj(target))
		var/obj/vis_target = target
		vis_target.vis_contents += plant
	plant.name = name_override || plant.name
	plant.AddComponent(/datum/component/plant, plant, plant_features)
	seeds--
	if(seeds <= 0)
		qdel(src)

//Debug
/obj/item/plant_seeds/debug
	name = "debug seeds"
	seeds = INFINITY

/obj/item/plant_seeds/debug/Initialize(mapload, list/_plant_features)
	. = ..()
	animate(src, color = "#ff0", time = 1 SECONDS, loop = -1)
	animate(color = "#0f0", time = 1 SECONDS)
	animate(color = "#0ff", time = 1 SECONDS)
	animate(color = "#00f", time = 1 SECONDS)
	animate(color = "#f0f", time = 1 SECONDS)
	animate(color = "#f00", time = 1 SECONDS)

/obj/item/plant_seeds/debug/interact(mob/user)
	. = ..()
	var/list/features = typesof(/datum/plant_feature)
	var/choice = tgui_input_list(user, "Add Feature", "Plant Features", features)
	if(choice)
		plant_features += choice

/obj/item/plant_seeds/debug/AltClick(mob/user)
	. = ..()
	plant_features = list()
