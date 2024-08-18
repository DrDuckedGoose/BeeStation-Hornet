/mob/living/silicon/new_robot/get_item_for_held_index(i)
	var/obj/item/arm_item = available_hands[i]
	var/datum/component/endopart/arm/arm_component = arm_item.GetComponent(/datum/component/endopart/arm)
	return arm_component?.holding

//TODO: Make sure overwriting this isn't a problem - Racc
/mob/living/silicon/new_robot/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!length(available_hands))
		return
	var/obj/item/arm_item = available_hands[active_hand_index]
	return SEND_SIGNAL(arm_item, COMSIG_ENDO_POLL_EQUIP, I)

/mob/living/silicon/new_robot/proc/get_hand_index(obj/item/bodypart/B)
	var/index = 1
	for(var/obj/item/bodypart/part as() in available_hands)
		if(part == B)
			return index
		index++

/mob/living/silicon/new_robot/proc/try_equip(atom/A)
	if(!length(available_hands))
		return
	var/obj/item/arm_item = available_hands[active_hand_index]
	return SEND_SIGNAL(arm_item, COMSIG_ROBOT_PICKUP_ITEM, A)

/mob/living/silicon/new_robot/proc/set_hand_index(_index)
	//TODO: Probably just make this a signal - Racc
	active_hand_index = _index
	for(var/obj/item/bodypart/part as() in available_hands)
		var/datum/component/endopart/arm/A = part?.GetComponent(/datum/component/endopart/arm)
		if(get_hand_index(part) == active_hand_index)
			A?.select()
			continue
		A?.deselect()
