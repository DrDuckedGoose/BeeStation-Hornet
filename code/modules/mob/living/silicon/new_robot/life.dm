/mob/living/silicon/new_robot/Life(delta_time, times_fired)
	set invisibility = 0
	if(src.notransform)
		return
	..()
	adjustOxyLoss(-10)
	//Let our individual parts boogey
	SEND_SIGNAL(chassis, COMSIG_ENDO_APPLY_LIFE, src)
