#define OCEAN_REAGENTS list(/datum/reagent/toxin/acid, /datum/reagent/blood, /datum/reagent/water)

SUBSYSTEM_DEF(deep_water)
	name = "Deep Water"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_DEEP_WATER
	///What reagent our ocean is comprised of
	var/datum/reagent/ocean_reagent

/datum/controller/subsystem/deep_water/Initialize(timeofday)
	ocean_reagent = pick(OCEAN_REAGENTS)

//Change all deep_water's liquid contents
/datum/controller/subsystem/deep_water/proc/change_water(datum/reagent/new_reagent)
	ocean_reagent = new_reagent
	SEND_SIGNAL(src, COMSIG_ACTION_TRIGGER, new_reagent)

#undef OCEAN_REAGENTS
