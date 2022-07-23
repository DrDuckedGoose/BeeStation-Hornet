//Attack target once, love tap
/datum/ai_behavior/attack/once/attack(datum/ai_controller/controller, mob/living/living_target)
	..()
	finish_action(controller, TRUE)

//Exclusively used to eat nearby food items
/datum/ai_behavior/follow/eat/perform(delta_time, datum/ai_controller/controller)
	. = ..()
	var/mob/living/living_pawn = controller.pawn
	var/datum/weakref/follow_ref = controller.blackboard[BB_FOLLOW_TARGET]
	var/atom/movable/follow_target = (istype(follow_ref) ? follow_ref?.resolve() : follow_ref)

	if(get_dist(living_pawn, follow_target) <= 2 && istype(follow_target, /obj/item/reagent_containers/food))
		var/obj/item/reagent_containers/food/F = follow_target
		living_pawn.visible_message("[living_pawn] absorbs [F]!")
		qdel(F)
		if(istype(living_pawn, /mob/living/simple_animal/slime_uni))
			var/mob/living/simple_animal/slime_uni/S = living_pawn
			S.saturation += 25
		finish_action(controller, TRUE)
		return
