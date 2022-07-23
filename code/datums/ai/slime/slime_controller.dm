#define BB_ALLIES "bb_allies"
#define BB_ENEMIES "bb_enemies"

//Behaviour cases
#define SLIME_ATTACK "slime_attack"
#define SLIME_TAP "slime_tap" //love tap, barely hit someone
#define SLIME_EAT "slime_eat"

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
	///Cooldown for ditzing
	COOLDOWN_DECLARE(slime_spin)
	COOLDOWN_DECLARE(eat_cooldown)

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
	var/atom/target = data
	var/datum/weakref/target_ref = WEAKREF(target)
	CancelActions()
	switch(action)
		if(SLIME_ATTACK)
			blackboard[BB_ATTACK_TARGET] = target_ref
			current_movement_target = target
			queue_behavior(/datum/ai_behavior/attack)
		if(SLIME_TAP)
			blackboard[BB_ATTACK_TARGET] = target_ref
			current_movement_target = target
			queue_behavior(/datum/ai_behavior/attack/once)
		if(SLIME_EAT)
			blackboard[BB_FOLLOW_TARGET] = target_ref
			current_movement_target = target
			queue_behavior(/datum/ai_behavior/follow/eat)

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

	if(COOLDOWN_FINISHED(src, slime_spin)) //Speeen
		COOLDOWN_START(src, slime_spin, 10 SECONDS)
		if(prob(1))
			living_pawn.emote("flip") //I lied, he flips
			living_pawn.visible_message("[living_pawn] flips in the air!")
	if(COOLDOWN_FINISHED(src, eat_cooldown) && istype(living_pawn, /mob/living/simple_animal/slime_uni) && !current_behaviors?.len) //Eat nearby food, if we're the real slime shady
		var/mob/living/simple_animal/slime_uni/S = living_pawn
		if(S.saturation <= SLIME_SATURATION_MAX && COOLDOWN_FINISHED(src, eat_cooldown))
			for(var/obj/item/reagent_containers/food/F in oview(3, S))
				COOLDOWN_START(src, eat_cooldown, 10 SECONDS)
				S.visible_message("[S] looks at [F] hungrily!")
				prepare_action(SLIME_EAT, F)
				return
