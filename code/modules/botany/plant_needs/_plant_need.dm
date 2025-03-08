/datum/plant_need
	///Daddy-o
	var/datum/plant_feature/parent

/datum/plant_need/New(datum/plant_feature/_parent)
	. = ..()
	parent = _parent

/datum/plant_need/proc/copy(datum/plant_feature/_parent, datum/plant_need/_need)
	var/datum/plant_need/new_need = _need || new type(_parent)
	return new_need

/datum/plant_need/proc/check_need()
	return
