#define PLANT_DATA(title, data) list("data_title" = title, "data_field" = data)

/datum/plant_feature
	///The 'scientific' name for our plant feature
	var/species_name = "test"

	///Reference to component daddy
	var/datum/component/plant/parent

	///What traits are we rockin'?
	var/list/plant_traits = list()

	///
	var/list/plant_needs = list()

//Appearance
	var/icon = 'icons/obj/hydroponics/features/generic.dmi'
	var/icon_state = ""
	var/mutable_appearance/feature_appearance

/datum/plant_feature/New(datum/component/plant/_parent)
	. = ..()
	//Build our initial appearance
	feature_appearance = mutable_appearance(icon, icon_state)
	//Setup parent stuff
	setup_parent(_parent)
	//Build initial traits
	for(var/trait as anything in plant_traits)
		plant_traits -= trait
		plant_traits += new trait(src)
	//Build initial needs
	for(var/need as anything in plant_needs)
		plant_needs -= need
		plant_needs += new need(src)

//generic common stats
/datum/plant_feature/proc/get_ui_stats()
	return list("species_name" = species_name, "key" = REF(src), "feature_appearance" = icon2base64(feature_appearance))

//personalized info
/datum/plant_feature/proc/get_ui_data()
	return list(PLANT_DATA("Species Name", species_name), PLANT_DATA(null, null))

//our traits
/datum/plant_feature/proc/get_ui_traits()
	if(!length(plant_traits))
		return
	var/list/trait_ui = list()
	for(var/datum/plant_trait/trait as anything in plant_traits)
		trait_ui += list(list("trait_name" = trait.name, "trait_desc" = trait.desc, "trait_ref" = REF(trait)))
	return trait_ui

///Copies the plant's unique data - This is mostly, if not entirely, for randomized stuff & custom player made plants
/datum/plant_feature/proc/copy(datum/component/plant/_parent, datum/plant_feature/_feature)
	var/datum/plant_feature/new_feature = _feature || new type(_parent)
//Copy traits & needs - The reason we do this is to handle randomized traits & needs, make them the same as this one
	//traits
	for(var/trait as anything in new_feature.plant_traits)
		new_feature.plant_traits -= trait
		qdel(trait)
	for(var/datum/plant_trait/trait as anything in plant_traits)
		new_feature.plant_traits += trait.copy(new_feature)
	//needs
	for(var/need as anything in new_feature.plant_needs)
		new_feature.plant_needs -= need
		qdel(need)
	for(var/datum/plant_need/need as anything in plant_needs)
		new_feature.plant_needs += need.copy(new_feature)
	return new_feature

/datum/plant_feature/proc/setup_parent(_parent, reset_features = TRUE)
	//Remove our initial parent
	if(parent?.plant_item)
		UnregisterSignal(parent.plant_item, COMSIG_PARENT_EXAMINE)
	//Shack up with the new rockstar
	parent = _parent
	if(parent?.plant_item)
		RegisterSignal(parent.plant_item, COMSIG_PARENT_EXAMINE, PROC_REF(catch_examine))
	SEND_SIGNAL(src, COMSIG_PLANT_ATTACHED_PARENT)

/datum/plant_feature/proc/remove_parent()
	setup_parent(null)

/datum/plant_feature/proc/check_needs()
	for(var/datum/plant_need/need as anything in plant_needs)
		if(ispath(need))
			continue
		if(!need?.check_need())
			return FALSE
	return TRUE

/datum/plant_feature/proc/catch_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	//Info
	return
