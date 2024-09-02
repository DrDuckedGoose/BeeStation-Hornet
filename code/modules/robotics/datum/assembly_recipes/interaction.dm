/datum/endo_assembly/item/interaction/tool/screwdriver
	tool_type = TOOL_SCREWDRIVER
	item_requirment = /obj/item/screwdriver //Just using this for icon stuff
	perform_time = 3 SECONDS
	assembly_integral = TRUE

/datum/endo_assembly/item/interaction/wire
	perform_time = 0 SECONDS
	item_requirment = /obj/item/stack/cable_coil
	///How much cable do we use?
	var/consumed_stacks = 1

/datum/endo_assembly/item/interaction/wire/interact(datum/source, obj/item/I, mob/living/L)
	var/obj/item/stack/cable_coil/wire = I
	if(!istype(wire))
		return
	if(wire.amount < consumed_stacks)
		return
	wire.amount -= consumed_stacks
	return ..()
