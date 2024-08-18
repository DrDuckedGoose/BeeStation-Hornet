/*
	Datums we use for endo recipe stuff, more flexible & efficient than type lists and looping
*/
/datum/endo_assembly
	///
	var/datum/component/endopart/part_parent
	///How many of this thing we need
	var/amount_required = 1
	var/list/parts = list()
	///Recipe hint info
	var/list/hint_data = list("name" = "", "image" = null)
	///Is this step integral to assembly?
	var/assembly_integral = FALSE
	///What typepath do we using for part polling
	var/poll_path
	///Do we allow our parts to be polled?
	var/allow_poll = FALSE
	///Do we generate pre-done?
	var/start_finished = FALSE

/datum/endo_assembly/New(datum/parent)
	. = ..()
	part_parent = parent

	//Setup Signals
	RegisterSignal(part_parent, COMSIG_ENDO_ASSEMBLY_POLL_PART, PROC_REF(pre_check_assemble))

	RegisterSignal(part_parent, COMSIG_ENDO_ASSEMBLY_ADD, PROC_REF(add_part))
	RegisterSignal(part_parent, COMSIG_ENDO_ASSEMBLY_REMOVE, PROC_REF(remove_part))

	RegisterSignal(part_parent, COMSIG_ENDO_LIST_PART, PROC_REF(poll_part))

	RegisterSignal(part_parent, COMSIG_ENDO_APPLY_HUD, PROC_REF(poll_hud))

	if(start_finished)
		build_ideal_part()

///Throw your precheck addition logic here, since most check_assembly() procs will have custom behaviour
/datum/endo_assembly/proc/pre_check_assemble(datum/source, obj/item/I)
	SIGNAL_HANDLER

	if(length(parts) >= amount_required)
		return
	//make sure another assembly didn't use this part first
	if(SEND_SIGNAL(I, ENDO_ASSEMBLY_IN_USE))
		return
	return check_assembly(I)
///Collect a part to satisfy our needs
/datum/endo_assembly/proc/add_part(datum/source, obj/item/I, mob/living/L)
	SIGNAL_HANDLER

	if(!pre_check_assemble(source, I))
		return
	parts += I
	modify_part(I, L)
	RegisterSignal(I, ENDO_ASSEMBLY_IN_USE, PROC_REF(item_consumed))
	RegisterSignal(I, COMSIG_PARENT_QDELETING, PROC_REF(remove_part))
	return TRUE

///Throw your precheck removal logic here
/datum/endo_assembly/proc/remove_part(datum/source, obj/item/I)
	SIGNAL_HANDLER

	if(length(parts) <= 0)
		return
	if(!(I in parts))
		return
	parts -= I
	UnregisterSignal(I, ENDO_ASSEMBLY_IN_USE)
	UnregisterSignal(I, COMSIG_PARENT_QDELETING)

///Check if a part matches our needs
/datum/endo_assembly/proc/check_assembly(obj/item/I)
	return

///Used to display hint stuff
/datum/endo_assembly/proc/get_recipe_hint()
	return hint_data

///Used to check completion
/datum/endo_assembly/proc/check_completion()
	if(start_finished)
		return ENDO_ASSEMBLY_COMPLETE
	var/outcome = ENDO_ASSEMBLY_INCOMPLETE
	if((length(parts) >= amount_required))
		outcome = ENDO_ASSEMBLY_COMPLETE
	if(!assembly_integral)
		outcome |= ENDO_ASSEMBLY_NON_INTEGRAL
	return outcome

///Used to modify stuff like cable coils, so we don't use whole stacks
/datum/endo_assembly/proc/modify_part(obj/item/I, mob/living/L)
	//Make sure no-one else is using this part already
	if(SEND_SIGNAL(I, ENDO_ASSEMBLY_IN_USE))
		return FALSE
	return TRUE

/datum/endo_assembly/proc/item_consumed(datum/source)
	SIGNAL_HANDLER

	return TRUE

/datum/endo_assembly/proc/poll_part(datum/source, type, list/population_list)
	SIGNAL_HANDLER

	if(istype(src, type))
		population_list += src
		return
	if(type != (poll_path) || !allow_poll) //TODO: Consider a better way of doing this - Racc
		return
	for(var/part as() in parts)
		population_list += part

//TODO: Remove hud stuff when the part/s are removed - Racc
///Add hud elements
/datum/endo_assembly/proc/poll_hud(datum/source, datum/hud/hud)
	SIGNAL_HANDLER

	if(!hud || (check_completion() & ENDO_ASSEMBLY_INCOMPLETE))
		return FALSE
	return TRUE

///Used for pre-made stuff
/datum/endo_assembly/proc/build_ideal_part()
	return

/*
	variant for item parts
*/
/datum/endo_assembly/item
	///What kind of item do we need?
	var/item_requirment = /obj/item/stack/cable_coil

/datum/endo_assembly/item/New(datum/parent)
	. = ..()
	poll_path = poll_path || item_requirment
	//Build hint data
	var/obj/item/I = new item_requirment()
	var/image/image = new()
	image.appearance = I.appearance
	hint_data = list("name" = I.name, "image" = image)

/datum/endo_assembly/item/check_assembly(obj/item/I)
	. = ..()
	if(istype(I, item_requirment))
		return TRUE

/datum/endo_assembly/item/build_ideal_part()
	for(var/i in 1 to amount_required)
		var/obj/item/I = new item_requirment(get_turf(part_parent.parent))
		if(!part_parent.attach_part(src, I, null))
			qdel(I)

/*
	Variant for endo components
*/
/datum/endo_assembly/endopart
	///What kind of endo component do we need?
	var/component_requirment = /datum/component/endopart
	///What item do we use for ideal pre builds
	var/obj/item/ideal_part_parent = /obj/item/endopart

/datum/endo_assembly/endopart/New(datum/parent)
	. = ..()
	poll_path = poll_path || component_requirment
	//Build hint data
	var/image/image = image('icons/obj/robotics/endo.dmi', null, "")
	var/datum/component/endopart/part = component_requirment
	hint_data = list("name" = initial(part.name), "image" = image)

/datum/endo_assembly/endopart/check_assembly(obj/item/I)
	. = ..()
	var/datum/component/endopart/part = I.GetComponent(component_requirment)
	if(istype(part, component_requirment))
		return TRUE

/datum/endo_assembly/endopart/build_ideal_part()
	for(var/i in 1 to amount_required)
		var/obj/item/I = new ideal_part_parent(get_turf(part_parent.parent))
		I.AddComponent(component_requirment, TRUE)
		if(!part_parent.attach_part(src, I, null))
			qdel(I)

/*
	Variant for interaction steps
*/
/datum/endo_assembly/item/interaction
	///How long does it take to perform this step?
	var/perform_time = 1 SECONDS
	///Has this interactionbeen completed?
	var/completed = FALSE

/datum/endo_assembly/item/interaction/New(datum/parent)
	. = ..()
	UnregisterSignal(parent, COMSIG_ENDO_ASSEMBLY_POLL_PART)
	UnregisterSignal(parent, COMSIG_ENDO_ASSEMBLY_ADD)
	UnregisterSignal(parent, COMSIG_ENDO_ASSEMBLY_REMOVE)
	//Rebuild hint data
	var/obj/item/I = new item_requirment()
	var/image/image = new()
	image.appearance = I.appearance
	var/mutable_appearance/MA = mutable_appearance('icons/obj/robotics/endo.dmi', "interaction", alpha = 180)
	image.add_overlay(MA)
	hint_data = list("name" = I.name, "image" = image)
	//Setup new signals
	RegisterSignal(parent, COMSIG_ENDO_ASSEMBLY_POLL_INTERACTION, PROC_REF(pre_check_assemble))
	RegisterSignal(parent, COMSIG_ENDO_ASSEMBLY_INTERACT, PROC_REF(interact))

/datum/endo_assembly/item/interaction/pre_check_assemble(datum/source, obj/item/I)
	if(completed)
		return
	return ..()

/datum/endo_assembly/item/interaction/check_completion(datum/source)
	var/outcome = ENDO_ASSEMBLY_INCOMPLETE
	if(completed)
		outcome = ENDO_ASSEMBLY_COMPLETE
	if(!assembly_integral)
		outcome |= ENDO_ASSEMBLY_NON_INTEGRAL
	return outcome

/datum/endo_assembly/item/interaction/proc/interact(datum/source, obj/item/I, mob/living/L)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(async_interact), source, I, L)

/datum/endo_assembly/item/interaction/proc/async_interact(datum/source, obj/item/I, mob/living/L)
	if(!pre_check_assemble(source, I))
		return
	RegisterSignal(I, ENDO_ASSEMBLY_IN_USE, PROC_REF(item_consumed))
	var/atom/A = part_parent.parent
	if(do_after(L, perform_time, A))
		completed = TRUE
	UnregisterSignal(I, ENDO_ASSEMBLY_IN_USE)

//Variant for tools
/datum/endo_assembly/item/interaction/tool
	///What kind of tool do we need?
	var/tool_type = TOOL_SCREWDRIVER

/datum/endo_assembly/item/interaction/tool/check_assembly(obj/item/I)
	if(I.tool_behaviour == tool_type)
		return TRUE
	return FALSE
