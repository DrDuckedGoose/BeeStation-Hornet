/*
	Sub-component for chests
	blah blah blah
*/
/datum/component/endopart/chest
	name = "chest"
	required_assembly = list(/datum/endo_assembly/item/cell, /datum/endo_assembly/item/item_module)
	offset_key = ENDO_OFFSET_KEY_CHEST(1)
	ambient_draw = 1
	///How much we reduce consumed energy
	var/energy_reduction = 1

//Becuase, as of now, we're the only part with a cell, we can easilly control stuff like energy reduction bonuses
/datum/component/endopart/chest/consume_energy(datum/source, amount)
	. = ..()
	var/list/cells = list()
	SEND_SIGNAL(src, COMSIG_ENDO_LIST_PART, /obj/item/stock_parts/cell, cells)
	var/reducted_amount = amount/energy_reduction
	for(var/obj/item/stock_parts/cell/C as() in cells)
		if(C.charge >= reducted_amount)
			C.charge -= reducted_amount
			return TRUE
	return FALSE

//Transform machine
/datum/component/endopart/chest/transform_machine
	required_assembly = list(/datum/endo_assembly/item/cell/transform_machine, /datum/endo_assembly/item/item_module)
