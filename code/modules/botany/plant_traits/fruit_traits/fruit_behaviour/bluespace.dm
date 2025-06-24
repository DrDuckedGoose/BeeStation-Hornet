/*
	Bluespace Activity, this trait makes the fruit teleport targets.
*/

/datum/plant_trait/fruit/bluespace
	name = "Bluespace Activity"
	desc = "The fruit exhibits bluespace activity. Triggering the fruit will teleport the target \
	to a random location nearby, or the fruit itself if there is no target."
	///How far we teleport
	var/teleport_radius = 10 //TODO: Considering scaling this somehow - Racc

/datum/plant_trait/fruit/bluespace/New(datum/plant_feature/_parent)
	. = ..()
	if(!fruit_parent)
		return
	//TODO: Maybe some visuals - Racc
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_NO_CONTEXT, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))

/datum/plant_trait/fruit/bluespace/catch_activate(datum/source, datum/plant_trait/trait, mob/living/target)
	. = ..()
	if(QDELING(src))
		return
	var/atom/movable/focus = target
	if(!target || !isliving(target))
		focus = fruit_parent //If there's nothing to TP, TP ourselves
	var/turf/T = get_turf(focus)
	new /obj/effect/decal/cleanable/molten_object(T) //Leave a pile of goo behind for dramatic effect...
	do_teleport(focus, T, teleport_radius, channel = TELEPORT_CHANNEL_BLUESPACE)
	//TODO: logging - Racc
