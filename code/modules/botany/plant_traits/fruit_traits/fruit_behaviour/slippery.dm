/*
	Slippery, guess what this does asshole
*/

/datum/plant_trait/fruit/slippery
	name = "Slippery"
	desc = "The fruit becomes slippery. Slipping a mob will trigger the fruit."
	///Ref to our slip component
	var/datum/component/slippery/slip_component
	//TODO: Blacklist certain fruit from being slippery, like bananas - Racc

/datum/plant_trait/fruit/slippery/New(datum/plant_feature/_parent)
	. = ..()
	if(!fruit_parent)
		return
	slip_component = fruit_parent.AddComponent(/datum/component/slippery, 60, NONE, CALLBACK(src, PROC_REF(handle_slip), fruit_parent))

/datum/plant_trait/fruit/slippery/Destroy(force, ...)
	QDEL_NULL(slip_component)
	return ..()

/datum/plant_trait/fruit/slippery/proc/handle_slip(obj/item/fruit, mob/M)
	if(QDELING(src))
		return
	//TODO: Logging - Racc
	SEND_SIGNAL(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, src, M)

