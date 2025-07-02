#define SEPERATED_CONTENTS_DEFAULT_VOLUME 50

/*
	Keep reagents in the fruit seperated until something triggers it
	Juts uses NO_REACT flags
*/

/datum/plant_trait/seperated_contents
	name = "Seperated Contents"
	desc = "The fruit's chemical reagent's are seperated until triggered."
	plant_feature_compat = /datum/plant_feature/fruit

/datum/plant_trait/seperated_contents/setup_component_parent(datum/source)
	. = ..()
	if(!parent)
		return
	RegisterSignal(parent.parent, COMSIG_FRUIT_PREPARE, PROC_REF(prepare_fruit))

/datum/plant_trait/seperated_contents/proc/prepare_fruit(datum/source, obj/item/fruit)
	SIGNAL_HANDLER

	//Reset the reagents to have the no-react flag
	fruit.create_reagents(fruit.reagents?.maximum_volume || SEPERATED_CONTENTS_DEFAULT_VOLUME, NO_REACT)
	RegisterSignal(fruit, COMSIG_FRUIT_ACTIVATE_TARGET, PROC_REF(catch_activate))
	RegisterSignal(fruit, COMSIG_FRUIT_ACTIVATE_NO_CONTEXT, PROC_REF(catch_activate))

/datum/plant_trait/seperated_contents/proc/catch_activate(datum/source)
	INVOKE_ASYNC(src, PROC_REF(async_catch_activate), source)

/datum/plant_trait/seperated_contents/proc/async_catch_activate(datum/source)
	var/obj/item/fruit = source
	if(!istype(fruit))
		return
	//Sleep for a bit to give people time to react
	fruit?.visible_message("<span class='warning'>[fruit] starts to mix its contents!</span>")
	playsound(fruit, 'sound/effects/bubbles.ogg', 45)
	sleep(2 SECONDS)
	//Recreate fruit reagents without the NO_REACT flag
	//TODO: There's probably a better way to copy reagents - Racc
	var/list/reagents = list()
	for(var/datum/reagent/reagent_index as anything in fruit.reagents.reagent_list)
		if(QDELETED(reagent_index))
			continue
		reagents += list(reagent_index.type = reagent_index.volume)
	fruit.create_reagents(fruit.reagents?.maximum_volume || SEPERATED_CONTENTS_DEFAULT_VOLUME)
	fruit.reagents.add_reagent_list(reagents)

#undef SEPERATED_CONTENTS_DEFAULT_VOLUME
