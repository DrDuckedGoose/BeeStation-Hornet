#define LIFETIME_STAGE_0 0 MINUTES
#define LIFETIME_STAGE_1 3 MINUTES
#define LIFETIME_STAGE_2 5 MINUTES
#define LIFETIME_STAGE_3 8 MINUTES

/datum/spooky_event/haunt_room
	name = "haunted room"
	cost = 50
	event_message = "Something takes hold in the darkness..."
	///Area we're responsible for haunting
	var/area/target_room
	///When did the spook first spook?
	var/initial_time
	///What stage of spook are we at? - used for heart override
	var/stage = 0
	///Are we on timeout for crimes against the crew?
	var/timeout = FALSE
	///The origin point for the curator to attack
	var/obj/origin
	///Reference to the skull overlay
	var/mutable_appearance/skull_overlay
	///Do we cut the origin's spooky mask
	var/cut_appearance = TRUE
	//TODO: Add a blacklist for items we cant choose as origins - Racc

/datum/spooky_event/haunt_room/New()
	. = ..()
	skull_overlay = mutable_appearance('icons/obj/religion.dmi', "skull_pattern", ABOVE_ALL_MOB_LAYER, GAME_PLANE)
	skull_overlay.filters += filter(type = "alpha", render_source = GAME_PLANE_RENDER_TARGET)

/datum/spooky_event/haunt_room/Destroy(force, ...)
	. = ..()
	target_room?.cut_overlay(skull_overlay)
	if(cut_appearance)
		origin?.cut_spectral_appearance()
	qdel(skull_overlay)
	target_room = null
	origin = null

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
	//Setup the origin - a little overhead-ish
	var/list/options = list()
	for(var/obj/item/I in target_room.contents)
		if(!HAS_TRAIT(I, TRAIT_HOLY) && !I.spectral_appearance)
			options += I
	if(!length(options))
		return FALSE
	origin = pick(options)
	if(origin.spectral_appearance)
		cut_appearance = FALSE
	//TODO: Also add an animation, like pulsating or sum - Racc
	origin.build_spectral_appearance()
	RegisterSignal(origin, COMSIG_PARENT_QDELETING, PROC_REF(handle_targets))
	RegisterSignal(origin, COMSIG_PARENT_ATTACKBY, PROC_REF(handle_attack))
	return TRUE

//TODO: Implement options from design doc - Racc
/datum/spooky_event/haunt_room/process(delta_time)
	if(timeout)
		return
	timeout = TRUE
	var/current_stage_time = abs(initial_time-world.time)
	var/timeout_total = 0
	//First stage - flicker lights
	if(current_stage_time >= LIFETIME_STAGE_0 || stage >= 0)
		//Possible overhead
		//TODO: Optimize? - Racc
		for(var/obj/machinery/light/L in target_room.contents)
			addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, flicker), rand(3, 6)), rand(0, 15))
		timeout_total += 5 SECONDS

	//Second stage - freeze room
	if(current_stage_time >= LIFETIME_STAGE_1 || stage >= 1)
		var/turf/T = pick(target_room.contained_turfs)
		var/datum/gas_mixture/environment = T?.return_air()
		environment?.set_temperature(min(environment.return_temperature(), T0C))
		timeout_total += 5 SECONDS

	//Third stage - spook mobs in the room with whispering
	if(current_stage_time >= LIFETIME_STAGE_2 || stage >= 2) //The heart will never override stage past here, but admins can
		//Possible overhead
		for(var/mob/living/L in target_room.contents)
			SEND_SOUND(L, 'sound/effects/ghost.ogg')
			L.Stun(3 SECONDS)
			L.Shake(duration = 3 SECONDS)
		timeout_total += 5 SECONDS
		
	//Final stage - add skull overlay to the area
	if(current_stage_time >= LIFETIME_STAGE_3 || stage >= 3)
		if(SSspooky.active_chaplain && SSspooky.active_chaplain.stat != DEAD)
			target_room.cut_overlay(skull_overlay)
			target_room.add_overlay(skull_overlay)
		else //Don't make the crew suffer without a big strong & brave chaplain
			qdel(src)

	//handle timer
	addtimer(CALLBACK(src, PROC_REF(toggle_timeout)), timeout_total)

/datum/spooky_event/haunt_room/get_location()
	return origin

/datum/spooky_event/haunt_room/proc/toggle_timeout(state = FALSE)
	timeout = state

/datum/spooky_event/haunt_room/proc/handle_targets(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/spooky_event/haunt_room/proc/handle_attack(datum/source, obj/item/I, mob/living/user, params)
	SIGNAL_HANDLER

	if(I && (HAS_TRAIT(I, TRAIT_HOLY) || istype(I, /obj/item/nullrod)) || HAS_TRAIT(origin, TRAIT_HOLY) || istype(I, /obj/item/storage/book/bible))
		SEND_SOUND(user, 'sound/magic/ethereal_enter.ogg')
		qdel(src)

#undef LIFETIME_STAGE_0
#undef LIFETIME_STAGE_1
#undef LIFETIME_STAGE_2
#undef LIFETIME_STAGE_3
