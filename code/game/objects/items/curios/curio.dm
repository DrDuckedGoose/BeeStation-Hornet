/*
	Abstract base for curator curio items
	TODO: Add an contribution guide here - Racc
*/
/obj/item/curio
	name = "curio"
	desc = "Generic and strange. Where did you find this?"
	icon_state = "towel"
	w_class = WEIGHT_CLASS_SMALL
	force = 1
	///The cost / effect of using this item
	var/spectral_effect = TRESPASS_LARGE
	///How often can this curio be used?
	var/item_cooldown = 5 SECONDS
	var/cooldown_timer
	///Do we need the user to be 'enlightened'?
	var/require_jones = TRUE

/obj/item/curio/interact(mob/user)
	. = ..()
	activate(user)

/obj/item/curio/proc/activate(datum/user, force)
	if((!cooldown_timer && (HAS_TRAIT(user, TRAIT_INDIANA_JONES) || !require_jones)) || force)
		if(cooldown_timer)
			deltimer(cooldown_timer)
		cooldown_timer = addtimer(CALLBACK(src, PROC_REF(handle_timer)), item_cooldown, TIMER_STOPPABLE)
	else
		if(!cooldown_timer)
			to_chat(user, "<span class='warning>[get_cooldown_message()]</span>")
		if(!HAS_TRAIT(user, TRAIT_INDIANA_JONES))
			if(prob(0.1))
				to_chat(user, "<span class='warning>[src] belongs in a museum!</span>")
			else
				to_chat(user, "<span class='warning>[src] baffles you!</span>")
		return FALSE
	SSspooky?.adjust_trespass(user, spectral_effect, force = TRUE)
	return TRUE

/obj/item/curio/proc/handle_timer()
	cooldown_timer = null

/obj/item/curio/proc/get_cooldown_message()
	return "[src] seems expired, for the moment..."
