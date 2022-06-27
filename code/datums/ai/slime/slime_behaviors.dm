/// Slime's copy of follow target
///Moves to target then finishes
/datum/ai_behavior/slime_follow
	behavior_flags = AI_BEHAVIOR_REQUIRE_MOVEMENT

/datum/ai_behavior/slime_follow/perform(delta_time, datum/ai_controller/controller)
	var/mob/living/pawn = controller.pawn
	//if pawn being pulled and sees a team member pull them too
	if(pawn.pulledby)
		var/list/AS = oview(2, pawn) //all entities
		for(var/mob/living/S in AS)
			if(istype(S, /mob/living/simple_animal/slime_uni) && !(S?.pulling))
				pawn.pulled(S)
				break
	//If pawn can't access target, finish
	if(!get_turf(controller.blackboard[BB_FOLLOW_TARGET]) || get_dist(pawn, controller.blackboard[BB_FOLLOW_TARGET]) > 10)
		finish_action(controller, TRUE)
	..()

/datum/ai_behavior/slime_follow/finish_action(datum/ai_controller/controller, succeeded, ...)
	..()

/// This behavior involves attacking a target.
/datum/ai_behavior/slime_sit/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/simple_animal/simple_pawn = controller.pawn
	if(!istype(simple_pawn))
		return

	if(DT_PROB(0.5, delta_time))
		finish_action(controller, TRUE)

/datum/ai_behavior/slime_sit/finish_action(datum/ai_controller/controller, succeeded)
	. = ..()
	var/mob/living/simple_animal/simple_pawn = controller.pawn
	if(!istype(simple_pawn) || simple_pawn.stat)
		return
