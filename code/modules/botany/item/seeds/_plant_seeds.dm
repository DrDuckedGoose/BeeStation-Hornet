#define PLANT_X_CLAMP -8
#define PLANT_Y_CLAMP 4

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
	//Is this even a planter?
	var/datum/component/planter/tray_component = target.GetComponent(/datum/component/planter)
	if(!tray_component)
		to_chat(user, "<span class='warining'>You can't plant [src] here!</span>")
		return
	//Check if our roots fuck with the substrate we're planting it in
	if(!SEND_SIGNAL(src, COMSIG_SEEDS_POLL_ROOT_SUBSTRATE, tray_component.substrate))
		to_chat(user, "<span class='warining'>You can't plant [src] in this substrate!</span>")
		return
	if(!SEND_SIGNAL(src, COMSIG_SEEDS_POLL_TRAY_SIZE, target))
		to_chat(user, "<span class='warining'>There's no room to plant [src] here!</span>")
		return
	//Plant it
	to_chat(user, "<span class='notice'>You begin to plant [src] into [target].</span>")
	if(!do_after(user, 2.3 SECONDS, target))
		return
	var/obj/item/plant_item/plant = new(get_turf(target), plant_features, species_id)
	var/datum/component/plant/plant_component = plant.GetComponent(/datum/component/plant)
	//Unassociate
	for(var/datum/plant_feature/feature as anything in plant_component.plant_features)
		feature.unassociate_seeds(src)
	//Plant appearance stuff
	plant.name = name_override || plant.name
	plant.forceMove(target) //forceMove instead of creating it inside to proc Entered()
	SEND_SIGNAL(plant_component, COMSIG_PLANT_PLANTED, target)
	var/obj/vis_target = target
	vis_target.vis_contents |= plant
	//Decrement seeds until it's depleted
	seeds--
	if(seeds <= 0)
		qdel(src)
	//Mouse offset
	if(!plant_component?.use_mouse_offset)
		return
	var/list/modifiers = params2list(click_parameters)
	if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
		return
	//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the planting turf)
	plant.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, PLANT_X_CLAMP, PLANT_Y_CLAMP)

//basically a direct copy from the plant component, sue me
/obj/item/plant_seeds/proc/get_species_id()
	var/new_species_id = ""
	for(var/datum/plant_feature/feature as anything in plant_features)
		var/traits = ""
		for(var/datum/plant_trait/trait as anything in feature.plant_traits)
			traits = "[traits]-[trait?.get_id()]"
		new_species_id = "[new_species_id][feature?.species_name]-([traits])-"
	return new_species_id

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
	species_id = get_species_id()
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

#undef PLANT_X_CLAMP
#undef PLANT_Y_CLAMP
