///How close something can be if we're tempted to be hangry
#define AGRO_RANGE 5
#define AGRO_COOLDOWN 30 SECONDS

/datum/ai_planning_subtree/slime
	COOLDOWN_DECLARE(hangry_cooldown)
	COOLDOWN_DECLARE(bored_cooldown)

/datum/ai_planning_subtree/slime/SelectBehaviors(datum/ai_controller/slime/controller, delta_time)
    var/mob/living/living_pawn = controller.pawn

    //Hangry
    if(istype(living_pawn, /mob/living/simple_animal/slime_uni) && COOLDOWN_FINISHED(src, hangry_cooldown)) //Some behaviours are dependant on being a slime
        var/mob/living/simple_animal/slime_uni/S = living_pawn
        if(S.saturation <= 0) //If we're super hungry, just bite someone
            var/mob/nearby_animal
            for(var/mob/M in oview(AGRO_RANGE, controller.pawn))
                if(prob(50))
                    nearby_animal = M
            if(nearby_animal) //If someone is nearby to bite
                COOLDOWN_START(src, hangry_cooldown, AGRO_COOLDOWN)
                controller.prepare_action(SLIME_TAP, nearby_animal)
                return

    //If we recognise an enemy nearby
    for(var/mob/living/M in oview(AGRO_RANGE, controller.pawn))
        if(locate(WEAKREF(M)) in controller.blackboard[BB_ENEMIES])
            controller.prepare_action(SLIME_ATTACK, M)
            return

