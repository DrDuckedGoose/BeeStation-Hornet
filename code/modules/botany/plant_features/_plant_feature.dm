/datum/plant_feature
	///The 'scientific' name for our plant feature
	var/species_name = ""

	///Reference to component daddy
	var/datum/component/plant/parent

	///What traits are we rockin'?
	var/list/traits = list()

	///
	var/list/plant_needs = list()

//Appearance
	var/icon = 'icons/obj/hydroponics/features/generic.dmi'
	var/icon_state = ""
	var/mutable_appearance/feature_appearance

/datum/plant_feature/New(datum/component/plant/_parent)
	. = ..()
	//Setup parent stuff
	parent = _parent
	RegisterSignal(parent.plant_item, COMSIG_PARENT_EXAMINE, PROC_REF(catch_examine))
	//Build our initial appearance
	feature_appearance = mutable_appearance(icon, icon_state)
	//Build initial traits
	//Build initial needs
	for(var/need as anything in plant_needs)
		plant_needs -= need
		plant_needs += new need(src)

/datum/plant_feature/proc/check_needs()
	for(var/datum/plant_need/need as anything in plant_needs)
		if(!need.check_need())
			return FALSE
	return TRUE

/datum/plant_feature/proc/catch_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	//Info
	return
