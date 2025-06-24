//TODO: Consider making this a generic 'thing' and the actual seed part an element - Racc
/obj/item/plant_seeds
	name = "seeds"
	icon = 'icons/obj/hydroponics/features/generic.dmi'
	icon_state = "seeds"
	///Species ID
	var/species_id
	///List of plant features for the plant we're... planting
	var/list/plant_features = list()
	///How many seeds do we contain
	var/seeds = 1
	///Do / What name override do we use?
	var/name_override

/obj/item/plant_seeds/Initialize(mapload, list/_plant_features, _species_id)
	. = ..()
	species_id = _species_id
	plant_features = length(_plant_features) ? _plant_features.Copy() : plant_features
	for(var/datum/plant_feature/feature as anything in plant_features)
		plant_features -= feature
		if(ispath(feature))
			feature = new feature()
		plant_features += feature
		feature?.associate_seeds(src)

/obj/item/plant_seeds/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	//Check if our roots fuck with the thing we're planting
	var/obj/machinery/plumbing/tank/plant_tray/tray = target
	/*
		If you want to plant plants elsewhere, that isnt a tray, make the substrate holder into an element or something
		TODO: Consider doing this - Racc
	*/
	var/substrate_flags = (istype(tray) ? tray.substrate : null)
	if(!SEND_SIGNAL(src, COMSIG_SEEDS_POLL_ROOT_SUBSTRATE, substrate_flags))
		to_chat(user, "<span class='warining'>You can't plant [src] here!</span>")
		return
	//Plant it
	to_chat(user, "<span class='notice'>You begin to plant [src] into [target].</span>")
	//TODO: Implement mouse offset planting for plants that use it - Racc
	//TODO: Implement planter size slots, to plant multiple plants on the same tile - Racc
	if(!do_after(user, 2.3 SECONDS, target))
		return
	var/obj/item/plant_item/plant = new()
	plant.forceMove(target) //forceMove instead of creating it inside to proc Entered()
	if(!isturf(target) && isobj(target))
		var/obj/vis_target = target
		vis_target.vis_contents += plant
	plant.name = name_override || plant.name
	plant.AddComponent(/datum/component/plant, plant, plant_features, species_id)
	seeds--
	if(seeds <= 0)
		qdel(src)

/*
	Preset
	This is used for making  preset species ids work at runtime
*/
/obj/item/plant_seeds/preset
	///What tier, in the plant catalogue, is this seed?
	var/tier = 1

/obj/item/plant_seeds/preset/Initialize(mapload, list/_plant_features, _species_id)
	. = ..()
	if(species_id) //Just in case someone uses it wrong
		return
	//TODO: Find a solution to this not being the same as regular IDs - Racc
	species_id = "preset-[name]"
	SSbotany.plant_species |= species_id

/*
	Debug
*/
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

/obj/item/plant_seeds/debug/examine(mob/user)
	. = ..()
	for(var/feature as anything in plant_features)
		to_chat(user, "<span class='notice'>[feature]</span>")

/obj/item/plant_seeds/debug/interact(mob/user)
	. = ..()
	var/list/features = typesof(/datum/plant_feature)
	var/choice = tgui_input_list(user, "Add Feature", "Plant Features", features)
	if(choice)
		plant_features += choice

/obj/item/plant_seeds/debug/AltClick(mob/user)
	. = ..()
	plant_features = list()
