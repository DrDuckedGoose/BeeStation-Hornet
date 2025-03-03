/datum/plant_need
	///Daddy-o
	var/datum/plant_feature/parent

/datum/plant_need/New(datum/plant_feature/_parent)
	. = ..()
	parent= _parent

/datum/plant_need/proc/check_need()
	return
