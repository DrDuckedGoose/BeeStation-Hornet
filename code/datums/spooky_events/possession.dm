/datum/spooky_event/possession
	name = "possession"
	cost = 80
	event_message = "Something wakes from an eternal slumber..."
	///The corpse we're responsible for
	var/mob/living/corpse_owner
	///How long it takes for the corpse to revive
	var/corpse_revive = 1 MINUTES
	var/corpse_revive_timer
	///Do we cut the corpse's spooky mask
	var/cut_appearance = TRUE
	///Timer for chatter
	var/chatter_cooldown = 10 SECONDS
	var/chatter_cooldown_timer

/datum/spooky_event/possession/Destroy(force, ...)
	if(corpse_owner && !QDELETED(corpse_owner))
		QDEL_NULL(corpse_owner.ai_controller)
		REMOVE_TRAIT(corpse_owner, TRAIT_POSSESSED, TRAIT_GENERIC)
		make_spooky_indicator(get_turf(corpse_owner), TRUE)
	if(corpse_revive_timer)
		deltimer(corpse_revive_timer)
	if(chatter_cooldown_timer)
		deltimer(chatter_cooldown_timer)
	if(cut_appearance)
		corpse_owner?.cut_spectral_appearance()
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
	RegisterSignal(corpse, COMSIG_PARENT_QDELETING, PROC_REF(handle_corpse))
	RegisterSignal(corpse, COMSIG_MOB_DEATH, PROC_REF(handle_death))
	corpse.ai_controller = /datum/ai_controller/monkey/angry //TODO: Implement AIs from design doc - Racc
	corpse.InitializeAIController()
	ADD_TRAIT(corpse, TRAIT_POSSESSED, TRAIT_GENERIC) //This is removed in the mobs death code, becuase death is called after this is deleted
	revive_corpse(corpse)
	SS.remove_corpse(corpse)
	corpse_owner = corpse
	if(corpse.spectral_appearance)
		cut_appearance = FALSE
	corpse.build_spectral_appearance()
	chatter(corpse)
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
	if(!HAS_TRAIT(target, TRAIT_POSSESSED) || QDELETED(target) || QDELETED(src))
		qdel(src)
		return
	target?.revive(TRUE, TRUE)

/datum/spooky_event/possession/proc/chatter(mob/living/target, redo = TRUE)
	var/sound_file = pick(list('sound/creatures/possessed/preacher.wav', 'sound/creatures/possessed/whereishe.wav', 'sound/creatures/possessed/benotafraid.wav',, 'sound/creatures/possessed/father.wav', , 'sound/creatures/possessed/hello.wav', 'sound/creatures/possessed/helpme.wav'))
	playsound(target, sound_file)
	if(redo && !QDELETED(corpse_owner) && !QDELETED(src))
		chatter_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(chatter), corpse_owner), chatter_cooldown, TIMER_STOPPABLE)
