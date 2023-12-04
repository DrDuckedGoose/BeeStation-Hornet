/datum/spooky_event/possession
	name = "possession"
	cost = 80
	///The corpse we're responsible for
	var/mob/living/corpse_owner
	///How long it takes for the corpse to revive
	var/corpse_revive = 1 MINUTES
	var/corpse_revive_timer
	///Do we cut the corpse's spooky mask
	var/cut_appearance = TRUE

/datum/spooky_event/possession/Destroy(force, ...)
	if(corpse_owner && !QDELING(corpse_owner))
		QDEL_NULL(corpse_owner.ai_controller)
	if(corpse_revive_timer)
		deltimer(corpse_revive_timer)
	if(cut_appearance)
		corpse_owner.cut_spectral_appearance()
	REMOVE_TRAIT(corpse_owner, TRAIT_POSSESSED, TRAIT_GENERIC)
	corpse_owner = null
	return ..()

/datum/spooky_event/possession/setup(datum/controller/subsystem/spooky/SS)
	..()
	var/mob/living/corpse = pick_weight(SS?.corpses)
	//logging
	if(!corpse || HAS_TRAIT(corpse, TRAIT_POSSESSED)) //We usually remove possessed corpses from the list, but you never know... especially admins
		log_game("[name]([src]) failed to create at [world.time]. No corpse available.")
		qdel(src)
		return FALSE
	log_game("[name]([src]) was created at [world.time], possessed [corpse].")
	//Our unique logic
	RegisterSignal(corpse, COMSIG_MOB_DEATH, PROC_REF(handle_corpse))
	RegisterSignal(corpse, COMSIG_PARENT_QDELETING, PROC_REF(handle_death))
	corpse.ai_controller = /datum/ai_controller/monkey/angry //TODO: Implement AIs from design doc - Racc
	revive_corpse(corpse)
	corpse.InitializeAIController()
	ADD_TRAIT(corpse, TRAIT_POSSESSED, TRAIT_GENERIC) //This is removed in the mobs death code, becuase death is called after this is deleted
	SS.remove_corpse(corpse)
	corpse_owner = corpse
	if(corpse.spectral_appearance)
		cut_appearance = FALSE
	corpse.build_spectral_appearance()
	//Inform ghosts
	notify_ghosts("[corpse.name] has been possesed at [get_area(corpse)]!", source = corpse, action = NOTIFY_ORBIT)

	return TRUE

/datum/spooky_event/possession/get_location()
	return corpse_owner

/datum/spooky_event/possession/proc/handle_corpse(datum/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/spooky_event/possession/proc/handle_death(datum/source)
	SIGNAL_HANDLER

	corpse_revive_timer = addtimer(CALLBACK(src, PROC_REF(revive_corpse), corpse_owner), corpse_revive, TIMER_STOPPABLE)

//TODO: make this better, something like the old zombie content. Don't just revive the body :/ - Racc
/datum/spooky_event/possession/proc/revive_corpse(mob/living/target)
	if(HAS_TRAIT(target, TRAIT_POSSESSED))
		qdel(src)
		return
	target?.revive(TRUE, TRUE)
