/obj/machinery/plant_mutator
	name = "plant mutator"
	desc = "An advanced device designed to gawk gawk."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "dnamod"
	density = TRUE
	pass_flags = PASSTABLE
	///Catalyst item we use for source of rads
	var/obj/item/catalyst
	///The plant we're michael-waving
	var/obj/item/plant
	var/datum/component/plant/plant_component

/obj/machinery/plant_mutator/attackby(obj/item/C, mob/user)
	. = ..()
	if(plant && catalyst)
		return
	//Accept Catalyst
	if(plant && !catalyst)
		catalyst = C
		C.forceMove(src)
		return
	//Accept Plant
	plant_component = C.GetComponent(/datum/component/plant)
	if(!plant_component)
		return
	plant = C
	C.forceMove(src)

/obj/machinery/plant_mutator/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	//TODO: Add catalyst radiation check and reduction - Racc
	if(!plant)
		to_chat(user, "<span class='warning'>No plant inserted!</span>")
		return
	var/datum/plant_feature/feature = tgui_input_list(user, "Choose feature to mutate.", "Mutate", plant_component.plant_features)
	if(!feature)
		return
	if(!length(feature.mutations))
		return
	var/datum/plant_feature/new_feature = pick(feature.mutations)
	QDEL_NULL(feature)
	new_feature = new new_feature(plant_component)
	if(!QDELING(new_feature))
		plant_component.plant_features += new_feature

/obj/machinery/plant_mutator/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(plant)
		plant.forceMove(get_turf(src))
		plant = null
		plant_component = null
		return
	if(catalyst)
		catalyst.forceMove(get_turf(src))
		catalyst = null
