/*
	Sub-component for chests
	blah blah blah
*/
/datum/component/endopart/chest
	name = "chest"
	required_assembly = list(/datum/endo_assembly/item/cell, /datum/endo_assembly/item/item_module)
	offset_key = ENDO_OFFSET_KEY_CHEST(1)
	///How efficient are we at reducing ambient draw? Higher is better
	var/ambient_reduction = 1

/datum/component/endopart/chest/attach_to(datum/source, obj/item/I)
	. = ..()
	//If the, presumably, chassis we're attached to tries to consume energy
	var/datum/component/endopart/E = I.GetComponent(/datum/component/endopart)
	RegisterSignal(E, COMSIG_ROBOT_CONSUME_ENERGY, PROC_REF(consume_energy))

/datum/component/endopart/chest/remove_from(datum/source, obj/item/I)
	. = ..()
	var/datum/component/endopart/E = I.GetComponent(/datum/component/endopart)
	UnregisterSignal(E,  COMSIG_ROBOT_CONSUME_ENERGY)

/datum/component/endopart/chest/consume_energy(datum/source, amount)
	. = ..()
	var/list/cells = list()
	SEND_SIGNAL(src, COMSIG_ENDO_LIST_PART, /obj/item/stock_parts/cell, cells)
	for(var/obj/item/stock_parts/cell/C as() in cells)
		if(C.charge >= amount)
			C.charge -= amount
			return TRUE
	return FALSE

/datum/component/endopart/chest/poll_life(datum/source, mob/M)
	. = ..()
	//This pretty much just handles borgs ambient draw. Things like lamp parts will ask us for energy themselves
	if(M.stat == DEAD)
		return
	var/mob/living/silicon/new_robot/R = assembled_mob
	if(!istype(R))
		return
	if(R.consume_energy(R.ambient_draw/ambient_reduction)) //We handle ambient in chests so we can attribute behaviour like this
		//Speed buddy back up, if we slowed him down before
		M.clear_alert("nocell")
		M.remove_movespeed_modifier(/datum/movespeed_modifier/nopowercell)
		R.powered = TRUE
		return
	else
		R.powered = FALSE
	//If we got no juice, slow buddy down
	M.throw_alert("nocell", /atom/movable/screen/alert/nocell)
	M.add_movespeed_modifier(/datum/movespeed_modifier/nopowercell)

//Transform machine
/datum/component/endopart/chest/transform_machine
	required_assembly = list(/datum/endo_assembly/item/cell/transform_machine, /datum/endo_assembly/item/item_module)
