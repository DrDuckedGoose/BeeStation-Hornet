//Small incubator - for making organs
/obj/machinery/petri_incubator
	name = "incubator"
	desc = "An artificial isolated atmosphere generator used to incubate organs."
	density = TRUE
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	verb_say = "states"
	///List of inserted dishes
	var/list/inserted_dishes = list()
	///Limit to inserted dishes
	var/dish_limit = 9
	///Which dish sample are we incubating
	var/obj/item/reagent_containers/glass/petri_dish/current_dish

/obj/machinery/petri_incubator/Destroy()
	. = ..()
	//Move inserted dishes out, so they don't die with the ship
	var/turf/T = get_turf(src)
	for(var/obj/I as() in inserted_dishes)
		I.forceMove(T)

/obj/machinery/petri_incubator/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/reagent_containers/glass/petri_dish) && inserted_dishes?.len < dish_limit)
		inserted_dishes += I
		I.forceMove(src)
		//If we don't have a current dish, process this one
		if(!current_dish)
			incubate(I)

//Swap current dish and handle processing respectively
/obj/machinery/petri_incubator/proc/incubate(obj/item/reagent_containers/glass/petri_dish/new_dish)
	if(current_dish)
		STOP_PROCESSING(SSobj, current_dish)
		UnregisterSignal(current_dish, COMSIG_ACTION_TRIGGER)
	current_dish = new_dish
	START_PROCESSING(SSobj, current_dish)
	RegisterSignal(current_dish, COMSIG_ACTION_TRIGGER, .proc/finish_incubate)

/obj/machinery/petri_incubator/proc/finish_incubate()
	STOP_PROCESSING(SSobj, current_dish)
	UnregisterSignal(current_dish, COMSIG_ACTION_TRIGGER)
	var/obj/item/organ = current_dish.finish_organ()
	current_dish = null
	inserted_dishes += organ
	return

//Large incubator - for making mobs
/obj/machinery/petri_incubator/large
	name = "incubator"
	desc = "An artificial isolated atmosphere generator used to incubate lifeforms."
	dish_limit = 1
