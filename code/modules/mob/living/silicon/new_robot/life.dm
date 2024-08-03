/mob/living/silicon/new_robot/Life(delta_time, times_fired)
	//TODO: Look up what this actually even does? - Racc
	set invisibility = 0
	if(src.notransform)
		return
	..()
	adjustOxyLoss(-10) //TODO: Consider making a part handle this - Racc

	//

	//Let our individual parts boogey
	SEND_SIGNAL(chassis, COMSIG_ENDO_APPLY_LIFE, src)

	//Handle movement speed
	//TODO: Consider optimizing /cleaning this - Racc
	var/list/legs = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /datum/component/endopart/leg, legs)
	var/operable_legs = length(legs)
	for(var/atom/A as() in legs)
		var/datum/component/endopart/leg/L = A.GetComponent(/datum/component/endopart/leg)
		if(L?.check_completion() & ENDO_ASSEMBLY_INCOMPLETE)
			operable_legs--
	if(length(legs) != operable_legs)
		var/max_slowdown = 6
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/limbless, multiplicative_slowdown = ((length(legs)-operable_legs)/length(legs)*max_slowdown))
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/limbless)
