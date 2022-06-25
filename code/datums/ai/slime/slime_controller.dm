//Frankensteins a fair amount of dog AI, look there for extra documentation
/datum/ai_controller/slime
	blackboard = list(\
		BB_SLIME_ORDER_MODE = DOG_COMMAND_NONE,\
		BB_DOG_FRIENDS = list(),\
		)
	ai_movement = /datum/ai_movement/jps
	planning_subtrees = list(/datum/ai_planning_subtree/dog)

	COOLDOWN_DECLARE(heel_cooldown)
	COOLDOWN_DECLARE(command_cooldown)
