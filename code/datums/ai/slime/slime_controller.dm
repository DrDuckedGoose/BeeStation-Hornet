//todo: consider inheriting from dog
//Frankensteins a fair amount of dog AI, look there for extra documentation.
//Slimes really are just squishy good boys

/datum/ai_controller/slime
	blackboard = list(\
		BB_DOG_ORDER_MODE = DOG_COMMAND_NONE,\
		BB_DOG_FRIENDS = list(),\
		BB_DOG_HARASS_TARGET = null,\
		BB_FOLLOW_TARGET = null,\
		BB_SLIME_TEAM = null,\
		BB_SLIME_OWNER
		)
	ai_movement = /datum/ai_movement/jps

	COOLDOWN_DECLARE(command_cooldown)

/datum/ai_controller/slime/process(delta_time)
	if(ismob(pawn))
		var/mob/living/living_pawn = pawn
		movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..()

/datum/ai_controller/slime/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	//set the owner to slimes party master
	if(istype(new_pawn, /mob/living/simple_animal/slime_uni))
		var/mob/living/simple_animal/slime_uni/S = new_pawn
		blackboard[BB_SLIME_OWNER] = (S?.slime_team?.owner ? S?.slime_team?.owner : S?.slime_team?.parent)
		blackboard[BB_SLIME_TEAM] = (S?.slime_team)
		RegisterSignal(S?.slime_team, SLIME_TEAM_UPDATE, .proc/update_team)

	//signals, calls to behaviour handles
	RegisterSignal(new_pawn, COMSIG_CLICK_ALT, .proc/check_altclicked) //command menu
	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, .proc/update_team) //owner setup

/datum/ai_controller/slime/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_PARENT_EXAMINE, COMSIG_CLICK_ALT, COMSIG_MOB_DEATH, COMSIG_PARENT_QDELETING))
	return ..() //Run parent at end

/datum/ai_controller/slime/able_to_run()
	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return FALSE
	return ..()

/datum/ai_controller/slime/get_access()
	var/mob/living/simple_animal/simple_pawn = pawn
	if(!istype(simple_pawn))
		return
	return simple_pawn.access_card

/datum/ai_controller/slime/PerformIdleBehavior(delta_time)
	var/mob/living/living_pawn = pawn
	if(!isturf(living_pawn.loc) || living_pawn.pulledby)
		return

/// Update follow target to slime team owner, whenever that happens...
/datum/ai_controller/slime/proc/update_team(datum/source, var/obj/item/I, var/mob/living/new_friend)
	SIGNAL_HANDLER

	if(istype(I, /obj/item/reagent_containers/syringe))
		var/list/friends = blackboard[BB_DOG_FRIENDS]
		var/datum/weakref/friend_ref = WEAKREF(new_friend)
		if(!blackboard[BB_SLIME_OWNER]) //first friend is always owner
			blackboard[BB_SLIME_OWNER] = new_friend
		if(friends[friend_ref])
			return
		friends[friend_ref] = TRUE
		RegisterSignal(new_friend, COMSIG_MOB_SAY, .proc/check_verbal_command)

/// Someone alt clicked us, see if they're someone we should show the radial command menu to
/datum/ai_controller/slime/proc/check_altclicked(datum/source, mob/living/clicker)
	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return
	if(!istype(clicker) || !(blackboard[BB_SLIME_OWNER] == clicker))
		return
	INVOKE_ASYNC(src, .proc/command_radial, clicker)

/// Show the command radial menu
/datum/ai_controller/slime/proc/command_radial(mob/living/clicker)
	var/list/commands = list(
		COMMAND_FOLLOW = image(icon = 'icons/mob/xenobiology/slime_team.dmi', icon_state = "team_follow"),
		COMMAND_STOP = image(icon = 'icons/mob/xenobiology/slime_team.dmi', icon_state = "team_stay"),
		COMMAND_FETCH = image(icon = 'icons/mob/xenobiology/slime_team.dmi', icon_state = "team_go"),
		COMMAND_WANDER = image(icon = 'icons/mob/xenobiology/slime_team.dmi', icon_state = "team_wander"),
		)
	var/choice = show_radial_menu(clicker, pawn, commands, custom_check = CALLBACK(src, .proc/check_menu, clicker), tooltips = TRUE)
	if(!choice || !check_menu(clicker))
		return
	set_command_mode(clicker, choice)

/datum/ai_controller/slime/proc/check_menu(mob/user)
	if(!istype(user))
		CRASH("A non-mob is trying to issue an order to [pawn].")
	if(user.incapacitated() || !can_see(user, pawn))
		return FALSE
	return TRUE

/// One of our friends said something, see if it's a valid command, and if so, take action
/datum/ai_controller/slime/proc/check_verbal_command(mob/speaker, speech_args)
	SIGNAL_HANDLER

	if(!blackboard[BB_SLIME_OWNER] == speaker)
		return

	if(!COOLDOWN_FINISHED(src, command_cooldown))
		return

	var/mob/living/living_pawn = pawn
	if(IS_DEAD_OR_INCAP(living_pawn))
		return

	var/spoken_text = speech_args[SPEECH_MESSAGE] // probably should check for full words
	var/command
	if(findtext(spoken_text, "follow") || findtext(spoken_text, "come"))
		command = COMMAND_FOLLOW
	else
		return

	if(!can_see(pawn, speaker, length=AI_DOG_VISION_RANGE))
		return
	set_command_mode(speaker, command)

/// Whether we got here via radial menu or a verbal command, this is where we actually process what our new command will be
/datum/ai_controller/slime/proc/set_command_mode(mob/commander, command)
	COOLDOWN_START(src, command_cooldown, AI_DOG_COMMAND_COOLDOWN)
	var/mob/living/simple_animal/slime_uni/living_pawn = pawn
	if(living_pawn.pulling)
		living_pawn.stop_pulling(living_pawn.pulling)

	switch(command)
		if(COMMAND_FOLLOW) //follow master
			living_pawn.wander = FALSE
			blackboard[BB_DOG_ORDER_MODE] = COMMAND_FOLLOW
			current_movement_target = blackboard[BB_SLIME_OWNER]
			blackboard[BB_FOLLOW_TARGET] = blackboard[BB_SLIME_OWNER]
			CancelActions()
			queue_behavior(/datum/ai_behavior/slime_follow)
		if(COMMAND_STOP) //Just sit still
			living_pawn.wander = FALSE
			blackboard[BB_DOG_ORDER_MODE] = COMMAND_STOP
			blackboard[BB_DOG_ORDER_MODE] = DOG_COMMAND_NONE
			CancelActions()
			queue_behavior(/datum/ai_behavior/slime_sit)
		if(COMMAND_WANDER)
			living_pawn.wander = TRUE
			blackboard[BB_DOG_ORDER_MODE] = COMMAND_WANDER
			blackboard[BB_DOG_ORDER_MODE] = COMMAND_WANDER
			CancelActions()
		if(COMMAND_FETCH)
			living_pawn.wander = FALSE
			blackboard[BB_DOG_ORDER_MODE] = COMMAND_FETCH
			current_movement_target = blackboard[BB_SLIME_OWNER]
			blackboard[BB_FOLLOW_TARGET] = blackboard[BB_SLIME_OWNER]
			CancelActions()
			queue_behavior(/datum/ai_behavior/move_to_target)
