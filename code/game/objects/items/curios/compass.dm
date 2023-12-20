//Points to a spooky event
/obj/item/curio/compass
	name = "broken compass"
	desc = "A rough looking compass. The needle seems broken."
	icon_state = "compass"
	force = 0
	item_cooldown = 8 SECONDS
	w_class = WEIGHT_CLASS_TINY
	///Ref to the spooky event
	var/datum/spooky_event/event_target
	///Ref to the needle
	var/atom/movable/screen/needle

/obj/item/curio/compass/Initialize(mapload)
	. = ..()
	if(prob(0.01))
		name = "broken compiss"
	//generate needle
	needle = new()
	needle.appearance = mutable_appearance(icon, "compass_needle")
	needle.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_LAYER
	needle.SpinAnimation(parallel = FALSE)
	vis_contents += needle
	//Glass
	var/mutable_appearance/MA = mutable_appearance(icon, "compass_glass", layer+0.01)
	MA.blend_mode = BLEND_ADD
	add_overlay(MA)

/obj/item/curio/compass/Destroy()
	. = ..()
	QDEL_NULL(needle)

/obj/item/curio/compass/AltClick(mob/user)
	. = ..()
	activate(user)

/obj/item/curio/compass/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_INDIANA_JONES))
		. += "<span class='notice'>Interact to use the compass again, once activated.</span>"

/obj/item/curio/compass/activate(datum/user, force)
	. = ..()
	if(!.)
		return
	to_chat(user, "<span class='warning'>You begin to shake [src]...</span>")
	if(do_after(user, 2 SECONDS, src))
		if(!find_event() || !event_target.get_location())
			to_chat(user, "<span class='notice'>[src] spins pointlessly...</span>")
			return
		//Get the direction of the target
		display_message(user)
		do_punishment()
	else
		to_chat(user, "<span class='notice'>Better not...</span>")
		handle_timer()

/obj/item/curio/compass/interact(mob/user)
	. = ..()
	if(event_target && event_target.get_location())
		display_message(user)
		do_punishment(TRESPASS_MICRO) //Yes, something could technically spam this, but it's small and evil, so I'm cool with it
	else
		to_chat(user, "<span class='notice'>[src] spins pointlessly...</span>")

/obj/item/curio/compass/proc/find_event()
	if(!length(SSspooky.current_behaviour?.active_products))
		return FALSE
	var/datum/spooky_event/temp_target = pick(SSspooky.current_behaviour?.active_products)
	if(temp_target)
		event_target = temp_target
		RegisterSignal(temp_target, COMSIG_PARENT_QDELETING, PROC_REF(handle_event))
		return temp_target
	return FALSE

/obj/item/curio/compass/proc/handle_event()
	SIGNAL_HANDLER

	event_target = null
	//Alert the current holder, if we have one
	var/mob/M = loc
	if(ismob(M))
		to_chat(M, "<span class='notice'>[src] begins to spin once again...</span>")
		needle.SpinAnimation(parallel = FALSE)

/obj/item/curio/compass/proc/display_message(mob/user)
	if(!event_target?.get_location() || !user)
		return
	var/dist = get_dist(get_turf(src), get_turf(event_target.get_location()))
	var/n_dir = get_dir(get_turf(src), get_turf(event_target.get_location()))
	var/message = ""
	switch(dist)
		if(0 to 15)
			message += "very near, [dir2text(n_dir)]"
		if(16 to 31)
			message += "near, [dir2text(n_dir)]"
		if(32 to 127)
			message += "far, [dir2text(n_dir)]"
		else
			message += "very far"
	to_chat(user, "<span class='danger'>[src] points [dir2text(n_dir)]!</span>")
	balloon_alert(user, "[message]!")
	//Stop the needle
	needle.SpinAnimation(0, 0, parallel = FALSE)
	var/matrix/o_transform = needle.transform
	var/turf/t_source = get_turf(src)
	var/turf/t_target = get_turf(event_target.get_location())
	o_transform.Turn(get_angle(t_source, t_target))
	needle.transform = o_transform
