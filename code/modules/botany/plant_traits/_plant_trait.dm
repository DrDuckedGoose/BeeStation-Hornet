/datum/plant_trait
//Identity
	var/name = ""
	var/desc = ""
//
	///Daddy-o
	var/datum/plant_feature/parent
	//Traits we're incompatible with
	var/list/blacklist = list()
	//Traits we're exclusively compatible with - leave blank to allow this trait to work with all traits
	var/list/whitelist = list()
	///What kind of plant feature are we compatible with
	var/plant_feature_compat = /datum/plant_feature

/datum/plant_trait/New(datum/plant_feature/_parent)
	. = ..()
	if(!istype(_parent, plant_feature_compat))
		return INITIALIZE_HINT_QDEL
	setup_parent(_parent)

/datum/plant_trait/proc/get_ui_stats()
	return list(list("trait_name" = name, "trait_desc" = desc, "trait_ref" = REF(src)))

/datum/plant_trait/proc/copy(datum/plant_feature/_parent, datum/plant_trait/_trait)
	var/datum/plant_trait/new_trait = _trait || new type(_parent)
	return new_trait

/datum/plant_trait/proc/setup_parent(_parent)
	parent = _parent
	if(!parent?.parent)
		RegisterSignal(parent, COMSIG_PLANT_ATTACHED_PARENT, PROC_REF(setup_component_parent))
	else
		setup_component_parent(parent.parent)

/datum/plant_trait/proc/setup_component_parent(datum/source)
	SIGNAL_HANDLER

	return
