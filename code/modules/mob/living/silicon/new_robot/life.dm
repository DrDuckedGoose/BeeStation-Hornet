/mob/living/silicon/new_robot
	var/mutable_appearance/fire_overlay

/mob/living/silicon/new_robot/Life(delta_time, times_fired)
	set invisibility = 0
	if(src.notransform)
		return
	..()
	adjustOxyLoss(-10)
	//Let our individual parts boogey
	SEND_SIGNAL(chassis, COMSIG_ENDO_APPLY_LIFE, src)

//TODO: Refine this - Racc
/mob/living/silicon/new_robot/updatehealth()
	if(status_flags & GODMODE)
		return
	var/total_burn	= 0
	var/total_brute	= 0
	var/list/bodyparts = list()
	SEND_SIGNAL(chassis, COMSIG_ENDO_LIST_PART, /datum/component/endopart, bodyparts)
	for(var/obj/item/bodypart/BP as() in bodyparts)
		total_brute	+= (BP.brute_dam * BP.body_damage_coeff)
		total_burn	+= (BP.burn_dam * BP.body_damage_coeff)
	set_health(round(maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute, DAMAGE_PRECISION))
	update_stat()
	diag_hud_set_status()
	diag_hud_set_health()
	//TODO: Do we want this? - Racc
	/*
	if(stat == SOFT_CRIT)
		add_movespeed_modifier(/datum/movespeed_modifier/carbon_softcrit)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/carbon_softcrit)
	*/
	SEND_SIGNAL(src, COMSIG_LIVING_UPDATE_HEALTH)

/mob/living/silicon/new_robot/handle_fire()
	. = ..()
	if(.) //if the mob isn't on fire anymore
		return
	if(fire_stacks > 0)
		fire_stacks--
		fire_stacks = max(0, fire_stacks)
	else
		ExtinguishMob()
		return TRUE

/mob/living/silicon/new_robot/update_fire()
	cut_overlay(fire_overlay)
	if(on_fire)
		fire_overlay = mutable_appearance('icons/mob/OnFire.dmi', "Generic_mob_burning")
		add_overlay(fire_overlay)
