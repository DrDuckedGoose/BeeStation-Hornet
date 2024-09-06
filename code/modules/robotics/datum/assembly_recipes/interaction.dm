/datum/endo_assembly/item/interaction/tool/screwdriver
	tool_type = TOOL_SCREWDRIVER
	item_requirment = /obj/item/screwdriver //Just using this for icon stuff
	perform_time = 3 SECONDS
	assembly_integral = TRUE

/datum/endo_assembly/item/interaction/tool/welder
	tool_type = TOOL_WELDER
	item_requirment = /obj/item/weldingtool
	perform_time = 3 SECONDS
	assembly_integral = TRUE

/*
	Stack recipes
*/
/datum/endo_assembly/item/interaction/stack
	perform_time = 0 SECONDS
	///How much cable do we use?
	var/consumed_stacks = 1

/datum/endo_assembly/item/interaction/stack/interact(datum/source, obj/item/I, mob/living/L)
	var/obj/item/stack/stack = I
	if(!istype(stack))
		return
	if(stack.amount < consumed_stacks)
		return
	stack.amount -= consumed_stacks
	return ..()

//Wire
/datum/endo_assembly/item/interaction/stack/wire
	item_requirment = /obj/item/stack/cable_coil

//Wire
/datum/endo_assembly/item/interaction/stack/iron
	item_requirment = /obj/item/stack/sheet/iron
	assembly_integral = TRUE
