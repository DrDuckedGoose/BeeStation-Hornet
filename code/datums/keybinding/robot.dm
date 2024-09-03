/datum/keybinding/robot
	category = CATEGORY_ROBOT
	weight = WEIGHT_ROBOT

/datum/keybinding/robot/can_use(client/user)
	return iscyborg(user.mob)

/datum/keybinding/robot/cycle_active_hand
	keys = list("X")
	name = "cycle_active_hand"
	full_name = "Cycle Active Hand"
	description = "Cycle your active hand as a robot."
	keybind_signal = COMSIG_KB_SILICON_CYCLEACTIVEHAND_DOWN

/datum/keybinding/robot/cycle_active_hand/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/new_robot/M = user.mob
	M.active_hand_index++
	if(M.active_hand_index > length(M.available_hands))
		M.active_hand_index = 1
	M.set_hand_index(M.active_hand_index)
	return TRUE

/datum/keybinding/robot/change_intent_robot
	keys = list("4", "1")
	name = "change_intent_robot"
	full_name = "Change Intent"
	description = "Change your intent as a robot."
	keybind_signal = COMSIG_KB_SILICON_CYCLEINTENT_DOWN

/datum/keybinding/robot/change_intent_robot/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/new_robot/M = user.mob
	M.a_intent_change(INTENT_HOTKEY_LEFT)
	return TRUE


/datum/keybinding/robot/unequip_module
	keys = list("Q")
	name = "unequip_module"
	full_name = "Unequip Module"
	description = "Unequip a robot module."
	keybind_signal = COMSIG_KB_SILICON_UNEQUIPMODULE_DOWN

/datum/keybinding/robot/unequip_module/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/living/silicon/new_robot/R = user.mob
	var/obj/item/I = R.get_active_held_item()
	I.dropped(R)
	I.cyborg_unequip(R)
	return TRUE
