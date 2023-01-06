/obj/machinery/organ_modifier
	name = "organ sample sequencer"
	desc = "Used to modify organ cell samples before incubation."
	density = TRUE
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_0"
	verb_say = "states"
	///Which dish sample are we modifying
	var/obj/item/reagent_containers/glass/petri_dish/current_dish

/obj/machinery/organ_modifier/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(istype(I, /obj/item/reagent_containers/glass/petri_dish))
		if(current_dish)
			current_dish.forceMove(get_turf(src))
		I.forceMove(src)
		current_dish = I
	
