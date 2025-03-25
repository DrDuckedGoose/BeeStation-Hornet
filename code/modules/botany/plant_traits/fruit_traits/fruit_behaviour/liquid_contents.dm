/*
	Liquid contents, makes the fruit activate when used or thrown. Delete when activated.
*/

/datum/plant_trait/fruit/liquid_contents
	name = "Liquid Contents"
	desc = "The fruit squishes when thrown, used, or triggered. Triggers when squished."
	///Do we delete ourselves after impact
	var/impact_del = TRUE

/datum/plant_trait/fruit/liquid_contents/New(datum/plant_feature/_parent)
	. = ..()
	if(!fruit_parent)
		return
	//We're chill to re-use the catch impact and qdel procs, the argument line up fine
	RegisterSignal(fruit_parent, COMSIG_MOVABLE_IMPACT, PROC_REF(catch_impact))
	RegisterSignal(fruit_parent, COMSIG_ATOM_INTERACT, PROC_REF(catch_impact))

	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_NO_CONTEXT, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))

/datum/plant_trait/fruit/liquid_contents/proc/catch_impact(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	if(QDELING(src))
		return
	SEND_SIGNAL(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, src, hit_atom)
	//TODO: The fruit imparts it's chemicals on the target, but only after sending the signal - Racc
	if(impact_del)
		qdel(fruit_parent)

/datum/plant_trait/fruit/liquid_contents/catch_activate(datum/source)
	. = ..()
	//TODO: add squash message and effects - Racc
	if(!QDELING(src) && impact_del)
		qdel(src)

/*
	Sensitive contents, makes the fruit activate when used or thrown.
*/

/datum/plant_trait/fruit/liquid_contents/sensitive
	name = "sensitive contents"
	desc = "The fruit triggers when thrown or used."
	impact_del = FALSE
	///Cooldown between triggers
	COOLDOWN_DECLARE(trigger)
	var/trigger_cooldown = 5 SECONDS

/datum/plant_trait/fruit/liquid_contents/sensitive/catch_impact(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!COOLDOWN_FINISHED(src, trigger))
		return
	COOLDOWN_START(src, trigger, trigger_cooldown)
	return ..()
