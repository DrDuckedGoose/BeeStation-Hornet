/*
	If your trait specifically interacts with the fruit datum's fruit, you'll want it to be a subtype of this
*/
/datum/plant_trait/fruit
	plant_feature_compat = /datum/plant_feature/fruit
	///Reference to our awesome fruit, atom, owner
	var/obj/item/fruit_parent

/datum/plant_trait/fruit/New(datum/plant_feature/_parent)
	fruit_parent = _parent
	if(!istype(fruit_parent))
		fruit_parent = null
		return ..()
	RegisterSignal(fruit_parent, COMSIG_PARENT_QDELETING, PROC_REF(catch_qdel))

/datum/plant_trait/fruit/setup_component_parent(datum/source)
	. = ..()
	if(!parent?.parent)
		return
	RegisterSignal(parent.parent, COMSIG_PLANT_FRUIT_BUILT, PROC_REF(catch_fruit))

/datum/plant_trait/fruit/proc/catch_fruit(datum/source, obj/item/fruit)
	SIGNAL_HANDLER

	copy(fruit)

/datum/plant_trait/fruit/proc/catch_qdel(datum/source)
	SIGNAL_HANDLER

	if(!QDELING(src))
		qdel(src)

/datum/plant_trait/fruit/proc/catch_activate(datum/source)
	SIGNAL_HANDLER

	return
