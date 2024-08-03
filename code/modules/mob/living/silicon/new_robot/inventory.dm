/mob/living/silicon/new_robot/get_item_for_held_index(i)
	var/obj/item/arm_item = available_hands[i]
	var/datum/component/endopart/arm/arm_component = arm_item.GetComponent(/datum/component/endopart/arm)
	return arm_component?.holding

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
	return SEND_SIGNAL(arm_item, COMSIG_ENDO_ATTACK_UNARMED, A)

//TODO: Make sure overwriting this isn't a problem - Racc
/mob/living/silicon/new_robot/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!length(available_hands))
		return
	var/obj/item/arm_item = available_hands[active_hand_index]
	return SEND_SIGNAL(arm_item, COMSIG_ENDO_POLL_EQUIP, I)
