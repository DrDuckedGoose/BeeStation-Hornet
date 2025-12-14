/datum/plant_need/reagent/buff
	buff = TRUE

/datum/plant_need/reagent/buff/check_need(_delta_time)
	. = ..()
//Reverse buff
	if(buff_applied)
		remove_buff()
		buff_applied = FALSE
//Flight checks
	if(!.)
		return
	if(buff_applied)
		return
//Apply buff
	apply_buff()
	buff_applied = TRUE

/datum/plant_need/reagent/buff/proc/apply_buff()
	return

/datum/plant_need/reagent/buff/proc/remove_buff()
	return
