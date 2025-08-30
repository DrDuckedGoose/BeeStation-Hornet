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
//Catalyst
	if(!catalyst)
		to_chat(user, "<span class='warning'>No catalyst inserted!</span>")
		return
	var/datum/component/radioactive/radiation = catalyst.GetComponent(/datum/component/radioactive)
	if(!radiation || !radiation.strength) //TODO: Revise how this works, how much rads we need, and how we spend it - Racc
		return
//Plant
	if(!plant)
		to_chat(user, "<span class='warning'>No plant inserted!</span>")
		return
	var/datum/plant_feature/feature = tgui_input_list(user, "Choose feature to mutate.", "Mutate", plant_component.plant_features)
	if(!feature)
		return
	if(!length(feature.mutations))
		return
	var/datum/plant_feature/new_feature = pick(feature.mutations)
	plant_component.plant_features -= feature
	qdel(feature)
	new_feature = new new_feature(plant_component)
	if(!QDELING(new_feature))
		plant_component.plant_features += new_feature
	//Reset species id so a new one can be made
	plant_component.compile_species_id()
	//TODO: Make the plant's fruit drop off or be destroyed - Racc
	//Reset the plant's growth
	for(var/datum/plant_feature/body/body_feature in plant_component.plant_features)
		body_feature.growth_time_elapsed = 0
		body_feature.current_stage = 0

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
