/datum/spooky_event/ghost
	name = "ghost"
	///The ghost we made
	var/mob/ghost

/datum/spooky_event/ghost/Destroy(force, ...)
	QDEL_NULL(ghost)
	return ..()

/datum/spooky_event/ghost/setup(datum/controller/subsystem/spooky/SS)
	..()
	//logging
	var/area/A = pick_weight(SS?.areas)
	if(!A)
		log_game("[name]([src]) failed to create at [world.time]. No area available.")
		qdel(src)
		return FALSE
	log_game("[name]([src]) was created at [world.time], located in [A].")
	//Our unique logic
	//Pick a random corpse for this ghost to impersonate for style points of course
	var/mob/living/corpse = pick_weight(SS?.corpses)
	if(corpse)
		var/mob/living/simple_animal/hostile/retaliate/ghost/G = new(pick(A.contained_turfs))
		RegisterSignal(G, COMSIG_MOB_DEATH, PROC_REF(handle_ghost)) //Do I even need this?
		RegisterSignal(G, COMSIG_PARENT_QDELETING, PROC_REF(handle_ghost))
		ghost = G
		G.appearance = corpse.appearance
		G.alpha = 128
		G.name = "ghost of [corpse.name]" //TODO: Consider letting only the chap and curator read the names - Racc
		//Corpses are typically on their sides, so we need to make them upright
		var/matrix/n_transform = G.transform
		n_transform.Turn(-90)
		G.transform = n_transform
		//Build the fade effect / filter
		var/icon/I = icon('icons/mob/mob.dmi', "ghost_fade")
		G.add_filter("fade", 1, alpha_mask_filter(icon = I))
		//Inform ghosts
		notify_ghosts("The [G.name] has appeared in [A]!", source = G, action = NOTIFY_ORBIT)
		return TRUE
		//TODO: Implement ghost traits from design doc - Racc
	return FALSE

/datum/spooky_event/ghost/proc/handle_ghost(datum/source)
	SIGNAL_HANDLER

	qdel(src)
