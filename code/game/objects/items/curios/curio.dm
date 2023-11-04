/*
	Abstract base for curator curio items
	TODO: Add an contribution guide here - Racc
*/
/obj/item/curio
	name = "curio"
	desc = "Generic and strange. Where did you find this?"
	icon_state = "towel"
	w_class = WEIGHT_CLASS_SMALL
	force = 2
	///The cost / effect of using this item
	var/spectral_effect = TRESPASS_LARGE
	///How often can this curio be used?
	var/item_cooldown = 5 SECONDS
	var/cooldown_timer

/obj/item/curio/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(istype(target, /obj/structure/witch_table) && proximity_flag)
		activate(user)

/obj/item/curio/proc/activate(datum/user, force)
	if(!cooldown_timer || force)
		if(cooldown_timer)
			deltimer(cooldown_timer)
		cooldown_timer = addtimer(CALLBACK(src, PROC_REF(handle_timer)), item_cooldown, TIMER_STOPPABLE)
	else
		return FALSE
	SSspooky?.adjust_trespass(user, spectral_effect, force = TRUE)
	return TRUE

/obj/item/curio/proc/handle_timer()
	cooldown_timer = null
