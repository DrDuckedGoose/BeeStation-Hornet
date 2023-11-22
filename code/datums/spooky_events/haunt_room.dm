#define LIFETIME_STAGE_0 0 MINUTES
#define LIFETIME_STAGE_1 3 MINUTES
#define LIFETIME_STAGE_2 5 MINUTES
#define LIFETIME_STAGE_3 8 MINUTES

/datum/spooky_event/haunt_room
	name = "haunted room"
	cost = 50
	///Area we're responsible for haunting
	var/area/target_room
	///When did the spook first spook?
	var/initial_time
	///What stage of spook are we at? - used for heart override
	var/stage = 0
	///Are we on timeout for crimes against the crew?
	var/timeout = FALSE
	///The origin point for the curator to attack
	var/obj/effect/haunted_heart/origin
	///Reference to the skull overlay
	var/mutable_appearance/skull_overlay

/datum/spooky_event/haunt_room/Destroy(force, ...)
	. = ..()
	if(origin && !QDELETED(origin))
		QDEL_NULL(origin)
	if(skull_overlay)
		target_room?.cut_overlay(skull_overlay)
		qdel(skull_overlay)
	target_room = null

/datum/spooky_event/haunt_room/setup(datum/controller/subsystem/spooky/SS)
	..()
	//logging
	var/area/A = pick_weight(SS?.areas) || pick(GLOB.the_station_areas)
	if(!A)
		log_game("[name]([src]) failed to create at [world.time]. No area available.")
		qdel(src)
		return FALSE
	log_game("[name]([src]) was created at [world.time], located in [A].")
	//Our unique logic
	target_room = A
	RegisterSignal(target_room, COMSIG_PARENT_QDELETING, PROC_REF(handle_targets))
	initial_time = world.time
	START_PROCESSING(SSobj, src)
	//Inform ghosts
	var/turf/T = pick(A.contained_turfs)
	notify_ghosts("[A] has been haunted!", source = T, action = NOTIFY_JUMP)
	//Setup the origin
	origin = new(T, src)
	RegisterSignal(origin, COMSIG_PARENT_QDELETING, PROC_REF(handle_targets))
	return TRUE

//TODO: Implement options from design doc - Racc
/datum/spooky_event/haunt_room/process(delta_time)
	if(timeout)
		return
	timeout = TRUE
	var/current_stage_time = abs(initial_time-world.time)
	//First stage - flicker lights
	if(current_stage_time >= LIFETIME_STAGE_0 || stage >= 0)
		//Possible overhead
		for(var/obj/machinery/light/L in target_room.contents)
			addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, flicker), rand(3, 6)), rand(0, 15))
		//Timeout logic
		addtimer(CALLBACK(src, PROC_REF(toggle_timeout)), 15 SECONDS)

	//Second stage - flicker lights
	if(current_stage_time >= LIFETIME_STAGE_1 || stage >= 1)
		//Possible overhead
		for(var/obj/machinery/light/L in target_room.contents)
			addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, flicker), rand(3, 6)), rand(0, 15))
		//Timeout logic
		addtimer(CALLBACK(src, PROC_REF(toggle_timeout)), 10 SECONDS)

	//Third stage - flicker lights
	if(current_stage_time >= LIFETIME_STAGE_2 || stage >= 2) //The heart will never override stage past here, but admins can
		for(var/obj/machinery/light/L in target_room.contents)
			addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, flicker), rand(3, 6)), rand(0, 15))
		//Timeout logic
		addtimer(CALLBACK(src, PROC_REF(toggle_timeout)), 5 SECONDS)
		
	//Final stage - add skull overlay to the area
	if(current_stage_time >= LIFETIME_STAGE_3 || stage >= 3)
		if(!SSspooky.active_chaplain || SSspooky.active_chaplain.stat == DEAD)
			return
		skull_overlay = mutable_appearance('icons/obj/religion.dmi', "skull_pattern")
		target_room.add_overlay(skull_overlay)

/datum/spooky_event/haunt_room/get_location()
	return origin

/datum/spooky_event/haunt_room/proc/toggle_timeout(state = FALSE)
	timeout = state

/datum/spooky_event/haunt_room/proc/handle_targets(datum/source)
	SIGNAL_HANDLER

	qdel(src)

//Effect for the chaplain to interact with, to beat this event
/obj/effect/haunted_heart
	desc = "The heart of a haunted room, it beats to a melancholy tune."
	///What stage of destruction is this heart at
	var/destruction_stage = 0
	///Ref to our parent
	var/datum/spooky_event/haunt_room/parent

/obj/effect/haunted_heart/Initialize(mapload, _parent)
	. = ..()
	parent = _parent
	//Add appearance only the chap can see
	var/image/I = image(icon = 'icons/obj/religion.dmi', icon_state = "cross_bad", layer = ABOVE_MOB_LAYER, loc = src)
	add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/holyAware, "spectral trespass", I)
	//Animate beating
	var/matrix/n_transform = transform
	var/matrix/o_transform = transform
	n_transform.Scale(1.3)
	animate(src, transform = n_transform, time = 0.5 SECONDS, easing = BACK_EASING, loop = -1)
	animate(transform = o_transform, time = 1 SECONDS)

/obj/effect/haunted_heart/attackby(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/storage/book/bible) || istype(weapon, /obj/item/nullrod))
		//Move stages along
		destruction_stage += 1
		if(parent.stage <= 2)
			parent?.stage += 1
		//Jump to a new turf
		var/turf/T = pick(parent?.target_room?.contained_turfs)
		if(T)
			forceMove(T)
		//Defeat logic
		if(destruction_stage > 3)
			qdel(src)
	return ..()

#undef LIFETIME_STAGE_0
#undef LIFETIME_STAGE_1
#undef LIFETIME_STAGE_2
#undef LIFETIME_STAGE_3
