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
		return
	parent = _parent
