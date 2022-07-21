#define BB_ALLIES "bb_allies"
#define BB_ENEMIES "bb_enemies"

#define SLIME_ATTACK "slime_attack"
#define SLIME_TAP "slime_tap" //love tap, barely hit someone

/datum/ai_controller/slime
	blackboard = list(\
		BB_ALLIES = list(),\
		BB_ENEMIES = list(),\
		BB_ATTACK_TARGET = null,\
		)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = /datum/ai_planning_subtree/slime
	///List of items that wont aggro slimes
	var/list/item_whitelist = list()

/datum/ai_controller/slime/process(delta_time)
	if(ismob(pawn))
		var/mob/living/living_pawn = pawn
		movement_delay = living_pawn.cached_multiplicative_slowdown
	return ..()

/datum/ai_controller/slime/TryPossessPawn(atom/new_pawn)
	. = ..()
	if(!isliving(new_pawn))
		return AI_CONTROLLER_INCOMPATIBLE

	//signals, calls to behaviour handles
	RegisterSignal(new_pawn, COMSIG_PARENT_ATTACKBY, .proc/append_target) //append allies / enemies
	RegisterSignal(new_pawn, COMSIG_ATOM_ATTACK_HAND, .proc/append_target)

/datum/ai_controller/slime/UnpossessPawn(destroy)
	UnregisterSignal(pawn, list(COMSIG_ATOM_ATTACK_HAND, COMSIG_PARENT_QDELETING))
	return ..() //Run parent at end

/datum/ai_controller/slime/proc/append_target(datum/source, obj/item, mob/living, params)
	var/mob/real_user = (isliving(item) ? item : living) //If the item is living, someone man handled us
	var/list/enemies = blackboard[BB_ENEMIES]
	var/list/friends = blackboard[BB_ALLIES]
	if(real_user.a_intent == (INTENT_HARM || INTENT_DISARM)) //Append target to enemies
		enemies[real_user] = TRUE
		friends[real_user] = FALSE
		prepare_action(SLIME_ATTACK, real_user)
	else if(real_user.a_intent == (INTENT_HELP)) //Append target to friends
		friends[real_user] = TRUE
		enemies[real_user] = FALSE
		CancelActions()

///Used to do behaviours while also working with behaviour mutations, data contains contextual info, like target ect.
/datum/ai_controller/slime/proc/prepare_action(action, data)
	var/mob/living/target = (isliving(data) ? data : null)
	CancelActions()
	switch(action)
		if(SLIME_ATTACK)
			var/datum/weakref/attack_ref = WEAKREF(data)
			blackboard[BB_ATTACK_TARGET] = attack_ref
			current_movement_target = target
			queue_behavior(/datum/ai_behavior/attack)
	switch(action)
		if(SLIME_TAP)
			var/datum/weakref/attack_ref = WEAKREF(data)
			blackboard[BB_ATTACK_TARGET] = attack_ref
			current_movement_target = target
			queue_behavior(/datum/ai_behavior/attack/once)

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
