SUBSYSTEM_DEF(food)
	name = "Food"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_ACHIEVEMENTS+1

/datum/controller/subsystem/food/Initialize(timeofday)
    return ..()
