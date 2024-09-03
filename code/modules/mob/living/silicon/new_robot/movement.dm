//TODO: You'll need to add module items for ionpulse and magpulse - Racc
/mob/living/silicon/new_robot/Process_Spacemove(movement_dir = 0)
	. = ..()
	if(.)
		return TRUE
	if(has_jetpack_power(movement_dir, require_stabilization = FALSE))
		return TRUE
	return FALSE

/mob/living/silicon/new_robot/has_jetpack_power(movement_dir, thrust = THRUST_REQUIREMENT_SPACEMOVE, require_stabilization, use_fuel = TRUE)
	if(..())
		return TRUE
	if(SEND_SIGNAL(src, COMSIG_ROBOT_HAS_IONPULSE, thrust, use_fuel))
		return TRUE
	return FALSE

/mob/living/silicon/new_robot/mob_negates_gravity()
	return isspaceturf(get_turf(src)) ? FALSE : SEND_SIGNAL(src, COMSIG_ROBOT_HAS_MAGPULSE) //We don't mimick gravity on space turfs

/mob/living/silicon/new_robot/has_gravity(turf/T)
	return ..() || mob_negates_gravity()

/mob/living/silicon/new_robot/experience_pressure_difference(pressure_difference, direction)
	if(!SEND_SIGNAL(src, COMSIG_ROBOT_HAS_MAGPULSE))
		return ..()
