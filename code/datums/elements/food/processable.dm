// If an item has the processable item, it can be processed into another item with a specific tool. This adds generic behavior for those actions to make it easier to set-up generically.
/datum/element/processable
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	///The type of atom this creates when the processing recipe is used. e.g. list(/obj/item/food/meat/rawcutlet/plain = 3)
	var/list/result_atom_types
	///The tool behaviour for this processing recipe
	var/tool_behaviour
	///Time to process the atom
	var/time_to_process
	///Amount of the resulting actor this will create
	var/amount_created
	///Whether or not the atom being processed has to be on a table or tray to process it
	var/table_required

/datum/element/processable/Attach(datum/target, tool_behaviour, result_atom_types, time_to_process = 20, table_required = FALSE)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.tool_behaviour = tool_behaviour
	src.amount_created = amount_created
	src.time_to_process = time_to_process
	src.result_atom_types = result_atom_types
	src.table_required = table_required

	RegisterSignal(target, COMSIG_ATOM_TOOL_ACT(tool_behaviour), PROC_REF(try_process))

/datum/element/processable/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_ATOM_TOOL_ACT(tool_behaviour))

/datum/element/processable/proc/try_process(datum/source, mob/living/user, obj/item/I, list/mutable_recipes)
	//SIGNAL_HANDLER

	if(table_required)
		var/obj/item/found_item = source
		var/found_location = found_item.loc
		var/found_turf = isturf(found_location)
		var/found_table = locate(/obj/structure/table) in found_location
		var/found_tray = locate(/obj/item/storage/bag/tray) in found_location
		if(!found_turf && !istype(found_location, /obj/item/storage/bag/tray) || found_turf && !(found_table || found_tray))
			to_chat(user, "<span class='notice'>You cannot make this here! You need a table or at least a tray.</span>")
			return

	//build choice list
	var/atom/result_atom_type
	if(length(result_atom_types) > 1)
		var/choices = list()
		for(var/i in result_atom_types)
			var/atom/A = new i()
			choices += list(A.type = image(icon = A.icon, icon_state = A.icon_state))
			qdel(A)
		result_atom_type = show_radial_menu(user, I, choices, require_near = TRUE, tooltips = TRUE)
	else if(length(result_atom_types) > 0)
		result_atom_type = result_atom_types[1]
	if(!result_atom_type)
		return
	user.say(result_atom_type)
	var/amount_created = result_atom_types[result_atom_type]
	mutable_recipes += list(list(TOOL_PROCESSING_RESULT = result_atom_type, TOOL_PROCESSING_AMOUNT = amount_created, TOOL_PROCESSING_TIME = time_to_process))
