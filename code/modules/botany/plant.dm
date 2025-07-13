/*
	The plant component is basically a central hub for plant features to send signals from
	The majority of implementation should happen in the plant feature datums
*/

/datum/component/plant
	///The object acting as our plant
	var/obj/item/plant_item
	///Species ID, used for stuff like book keeping
	var/species_id
	///Our plant feature limits - this can typically be improved by traits
	//TODO: Implement this - Racc
	var/list/plant_feature_limits = list()
	///Our plant features
	var/list/plant_features = list(/datum/plant_feature/body, /datum/plant_feature/fruit, /datum/plant_feature/roots)
	///Do we skip the growing phase
	var/skip_growth

//Appearance
	///Used to toggle if we want to use body feature's appearances. You can toggle this off if you want to make something with an existing appearance a plant
	var/use_body_appearance = TRUE
	///Do we exist over the water? See _plant_body.dm for more details, this is overridden by our body - QUICK ACCESS
	var/draw_below_water
	///Do we use the mouse offset when planting - QUICK ACCESS
	var/use_mouse_offset = FALSE

/datum/component/plant/Initialize(obj/item/_plant_item, list/_plant_features, _species_id, _skip_growth)
	. = ..()
	plant_item = _plant_item
	skip_growth = _skip_growth
//Setup signals for spade behaviour
	RegisterSignal(plant_item, COMSIG_PARENT_ATTACKBY, PROC_REF(catch_attackby))
//Species ID setup
	if(!_species_id)
		compile_species_id()
	else
		species_id = _species_id
//Plant features
	if(length(_plant_features))
		populate_features(_plant_features)
//Add discoverable component for discovering this discoverable discovery
	plant_item.AddComponent(/datum/component/discoverable/plant, 500) //TODO: Consider making this variable / sane - Racc

/datum/component/plant/Destroy(force, silent)
	SEND_SIGNAL(src, COMSIG_PLANT_UPROOTED,  null, null, plant_item.loc)
	for(var/feature as anything in plant_features)
		qdel(feature)
	return ..()

///Item interactions for plants that aren't covered by the individual plant_features
/datum/component/plant/proc/catch_attackby(datum/source, obj/item, mob/living/user, params)
	SIGNAL_HANDLER

//Spade interaction, allows us to dig up plants
	if(istype(item, /obj/item/shovel/spade))
		INVOKE_ASYNC(src, PROC_REF(async_catch_attackby), item, user, params)

/datum/component/plant/proc/async_catch_attackby(obj/item, mob/living/user, params)
	playsound(plant_item, 'sound/effects/shovel_dig.ogg', 60)
	if(do_after(user, 2.5 SECONDS, plant_item))
		//Remove the plant from it's old home
		var/atom/movable/AM = plant_item.loc
		if(istype(AM))
			AM.vis_contents -= plant_item
		//Move to new home
		SEND_SIGNAL(src, COMSIG_PLANT_UPROOTED, user, item, plant_item.loc)
		plant_item.forceMove(item)
		item.vis_contents += plant_item
		RegisterSignal(item, COMSIG_ITEM_AFTERATTACK, PROC_REF(catch_spade_attack))

//Follow up for spade interaction
/datum/component/plant/proc/catch_spade_attack(datum/source, atom/target, mob/user, params)
	SIGNAL_HANDLER

	if(target == plant_item)
		return
	var/obj/item/spade = source
	var/obj/obj_target = target
	if(!SEND_SIGNAL(src, COMSIG_PLANT_POLL_TRAY_SIZE, target))
		to_chat(user, "<span class='warining'>There's no room to plant [src] here!</span>")
		return
	UnregisterSignal(spade, COMSIG_ITEM_AFTERATTACK)
	SEND_SIGNAL(src, COMSIG_PLANT_PLANTED, target)
	plant_item.forceMove(target)
	obj_target.vis_contents += plant_item
	spade.vis_contents -= plant_item

/datum/component/plant/proc/populate_features(list/_features)
	plant_features = _features?.Copy() || plant_features
	for(var/datum/plant_feature/feature as anything in plant_features)
		plant_features -= feature
		if(ispath(feature))
			plant_features += new feature(src)
		else
			plant_features += feature
			feature.setup_parent(src)

///This generates a unqiue species ID for us. Call this when a plant is modified or created or whatever
/datum/component/plant/proc/compile_species_id()
	var/new_species_id = "[get_species_id()]"
	if(new_species_id in SSbotany.plant_species)
		return FALSE
	SSbotany.plant_species |= new_species_id
	species_id = new_species_id
	return TRUE

//Formatted like "[feature](trait-types)-[feature](trait-types)-[feature](trait-types)"
///Use this to generate a species ID based on our feature's and their traits
/datum/component/plant/proc/get_species_id()
	var/new_species_id = ""
	for(var/datum/plant_feature/feature as anything in plant_features)
		var/traits = ""
		for(var/datum/plant_trait/trait as anything in feature.plant_traits)
			traits = "[traits]-[trait?.get_id()]"
		new_species_id = "[new_species_id][feature?.species_name]-([traits])-"
	return new_species_id
