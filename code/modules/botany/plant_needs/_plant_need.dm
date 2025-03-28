/*
	Each plant feature that uses needs implements it in its own way
	Typically, these are checked *every* tick, but stuff like roots probably don't
*/
//TODO: Add copying and whatever, like traits, to this - Racc
/datum/plant_need
	///Daddy-o
	var/datum/plant_feature/parent

/datum/plant_need/New(datum/plant_feature/_parent)
	. = ..()
	setup_parent(_parent)

/datum/plant_need/proc/setup_parent(_parent)
	parent = _parent
	if(!parent?.parent)
		RegisterSignal(parent, COMSIG_PLANT_ATTACHED_PARENT, PROC_REF(setup_component_parent))
	else
		setup_component_parent(parent.parent)

/datum/plant_need/proc/setup_component_parent(datum/source)
	SIGNAL_HANDLER

	return

/datum/plant_need/proc/copy(datum/plant_feature/_parent, datum/plant_need/_need)
	var/datum/plant_need/new_need = _need || new type(_parent)
	return new_need

/datum/plant_need/proc/check_need()
	return
