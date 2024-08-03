/*
	Sub-component for arms
	blah blah blah
*/
/datum/component/endopart/arm
	//TODO: make this disable bot hands if not complete - Racc
	name = "arm"
	required_assembly = list(/datum/endo_assembly/item/wire)
	///What are we currently holding, if anything
	var/obj/holding
	///Reference to our hand hud
	var/atom/movable/screen/new_robot/hand/hand

/datum/component/endopart/arm/Initialize(_offset_key = ENDO_OFFSET_KEY_ARM(1))
	. = ..()
	offset_key = _offset_key
	RegisterSignal(parent, COMSIG_ENDO_ATTACK_UNARMED, PROC_REF(catch_unarmed))
	RegisterSignal(parent, COMSIG_ENDO_POLL_EQUIP, PROC_REF(poll_equip))

/datum/component/endopart/arm/poll_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!hud)
		return
	if(!hand)
		hand = new(null, parent)
	hand.hud = hud
	hud.static_inventory += hand
	//Get out screenposition
	var/mob/living/silicon/new_robot/R = assembled_mob
	if(istype(R))
		var/hand_index = (R.get_hand_index(parent))*-1
		hand.screen_loc = "CENTER [hand_index]:16,SOUTH:[5 + FLOOR(hand_index, 3)]"
	//Update hud
	hud.show_hud(HUD_STYLE_STANDARD)

///
/datum/component/endopart/arm/proc/catch_unarmed(datum/source, obj/item/item)
	SIGNAL_HANDLER

	//TODO: make sure you add some checkers here for typical item can_pickup stuff - Racc
	if(holding)
		return FALSE
	holding = item
	hand.vis_contents += holding
	RegisterSignal(item, COMSIG_ITEM_DROPPED, PROC_REF(catch_dropped))
	return TRUE

/datum/component/endopart/arm/proc/catch_dropped(datum/source)
	SIGNAL_HANDLER

	if(!holding)
		return FALSE
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)
	hand.vis_contents -= holding
	holding = null
	return TRUE

/datum/component/endopart/arm/proc/poll_equip(datum/source, atom/A)
	SIGNAL_HANDLER

	if(check_completion() & ENDO_ASSEMBLY_INCOMPLETE)
		return FALSE
	return !(holding)
