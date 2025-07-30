/*
	bio-malignant, this trait makes the plant spawn an evil plant. Can be eaten to stop it.
*/

/datum/plant_trait/fruit/killer
	name = "Bio-Malignant"
	desc = "The fruit exhibits semi-sentient tendincies. Triggering the fruit will transform it into a blood \
	thirsty monster!"
	///Are we already awakening
	var/awakening = FALSE
	///What kinda of mob do we awaken to be?
	var/mob/living/awaken_mob = /mob/living/simple_animal/hostile/killertomato //Remake killer tomato into an ambiguous plant monster

/datum/plant_trait/fruit/killer/New(datum/plant_feature/_parent)
	. = ..()
	if(!fruit_parent)
		return
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_TARGET, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))
	RegisterSignal(fruit_parent, COMSIG_FRUIT_ACTIVATE_NO_CONTEXT, TYPE_PROC_REF(/datum/plant_trait/fruit, catch_activate))

/datum/plant_trait/fruit/killer/catch_activate(datum/source, datum/plant_trait/trait, mob/living/target)
	. = ..()
	if(QDELING(src))
		return
	if(awakening || isspaceturf(fruit_parent.loc))
		return
	fruit_parent.visible_message(span_notice("[fruit_parent] beings to awaken!"))
	awakening = TRUE
	log_game("[fruit_parent] was awakened at [AREACOORD(fruit_parent)].")
	addtimer(CALLBACK(src, PROC_REF(make_killer_tomato)), 30)

/datum/plant_trait/fruit/killer/proc/make_killer_tomato()
	if(QDELETED(src))
		return
	awaken_mob = new awaken_mob(get_turf(fruit_parent.loc))
	//TODO: - Racc
	//K.maxHealth += round(seed.endurance / 3)
	//K.melee_damage += round(seed.potency / 10)
	//K.move_to_delay -= round(seed.production / 50)
	//K.frenzythreshold -= round(seed.potency / 25)// max potency tomatoes will enter a frenzy more easily
	awaken_mob.health = awaken_mob.maxHealth
	awaken_mob.visible_message(span_notice("[awaken_mob] suddenly awakens!"))
	qdel(fruit_parent)

/*
	bio-malignant, this trait makes the plant spawn an evil plant. Can be eaten to stop it.
*/

/datum/plant_trait/fruit/killer/friendly
	name = "Bio-Benign"
	desc = "The fruit exhibits semi-sentient tendincies. Triggering the fruit will transform it into a benign monster."
	awaken_mob = /mob/living/simple_animal/butterfly //TODO: - Racc
	//TODO: Add the option for player control - Racc
