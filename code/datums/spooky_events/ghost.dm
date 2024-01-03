/datum/spooky_event/ghost
	name = "ghost"
	cost = 70
	event_message = "Something crosses the thin veil..."
	///The ghost we made
	var/mob/ghost

/datum/spooky_event/ghost/Destroy(force, ...)
	if(ghost)
		make_spooky_indicator(get_turf(ghost), TRUE)
		QDEL_NULL(ghost)
	return ..()

/datum/spooky_event/ghost/setup(datum/controller/subsystem/spooky/SS)
	..()
	//logging
	var/area/A = pick_weight(SS?.areas) || pick(GLOB.the_station_areas)
	if(!A)
		log_game("[name]([src]) failed to create at [world.time]. No area available.")
		qdel(src)
		return FALSE
	log_game("[name]([src]) was created at [world.time], located in [A].")
	//Our unique logic
	//Pick a random corpse for this ghost to impersonate for style points of course
	var/mob/living/corpse = pick_weight(SS?.corpses)
	if(corpse)
		//TODO: Stop ghosts spawning in walls - Racc
		var/mob/living/simple_animal/hostile/retaliate/ghost/G = new(pick(A.contained_turfs)) //TODO: Make a unique subtype with our stuff - Racc
		RegisterSignal(G, COMSIG_MOB_DEATH, PROC_REF(handle_ghost)) //Do I even need this?
		RegisterSignal(G, COMSIG_PARENT_QDELETING, PROC_REF(handle_ghost))
		ghost = G
		//Kinda weird, but we need to temporarily reset the target's transform
		var/matrix/o_transform = corpse.transform
		corpse.transform = null
		//Then just copy the appearance as normal
		G.appearance = corpse.appearance
		G.alpha = 200
		G.name = "ghost of [corpse.name]" //TODO: Definitely remove this - Racc
		//Build spooky mask
		var/mutable_appearance/MA = new()
		MA.appearance = corpse.appearance //TODO: Consider only letting the chaplain see this - Racc
		MA.plane = SPECTRAL_TRESPASS_PLANE
		G.add_overlay(MA)
		//Set transform back to normal
		corpse.transform = o_transform
		//Build the fade effect / filter
		var/icon/I = icon('icons/mob/mob.dmi', "ghost_fade")
		G.add_filter("fade", 1, alpha_mask_filter(icon = I))
		//Inform ghosts
		notify_ghosts("The [G.name] has appeared in [A]!", source = G, action = NOTIFY_ORBIT)
		return TRUE
		//TODO: Implement ghost traits from design doc - Racc
	return FALSE

/datum/spooky_event/ghost/get_location()
	return ghost

/datum/spooky_event/ghost/proc/handle_ghost(datum/source)
	SIGNAL_HANDLER

	qdel(src)
