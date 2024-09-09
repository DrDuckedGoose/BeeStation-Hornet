/mob/living/silicon/new_robot/get_item_for_held_index(i)
	if(!length(available_hands))
		return
	var/obj/item/arm_item = available_hands[min(i, length(available_hands))]
	var/datum/component/endopart/arm/arm_component = arm_item.GetComponent(/datum/component/endopart/arm)
	return arm_component?.get_holding()

/mob/living/silicon/new_robot/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE)
	if(!length(available_hands))
		return
	var/obj/item/arm_item = available_hands[active_hand_index]
	return SEND_SIGNAL(arm_item, COMSIG_ENDO_POLL_EQUIP, I)

/mob/living/silicon/new_robot/can_interact_with(atom/A)
	//We can always interact with our own interface
	if(A == modularInterface)
		return TRUE
	//Otherwise, if we're outta juice, we can't do shit
	if(!powered)
		return FALSE
	//Distance interactions for cool stuff
	var/turf/T0 = get_turf(src)
	var/turf/T1 = get_turf(A)
	if(!T0 || !T1)
		return FALSE
	if(A.is_jammed(JAMMER_PROTECTION_WIRELESS))
		return FALSE
	//Shout out to Tad Hardesty who wrote this 6 years ago
	return ISINRANGE(T1.x, T0.x - interaction_range, T0.x + interaction_range) && ISINRANGE(T1.y, T0.y - interaction_range, T0.y + interaction_range)

/mob/living/silicon/new_robot/proc/get_hand_index(obj/item/bodypart/B)
	var/index = 1
	for(var/obj/item/bodypart/part as anything in available_hands)
		if(part == B)
			return index
		index++

/mob/living/silicon/new_robot/proc/try_equip(atom/A)
	if(!length(available_hands))
		return
	var/obj/item/arm_item = available_hands[active_hand_index]
	return SEND_SIGNAL(arm_item, COMSIG_ROBOT_PICKUP_ITEM, A)

/mob/living/silicon/new_robot/proc/set_hand_index(_index)
	active_hand_index = _index
	for(var/obj/item/bodypart/part as() in available_hands)
		var/datum/component/endopart/arm/A = part?.GetComponent(/datum/component/endopart/arm)
		if(get_hand_index(part) == active_hand_index)
			A?.select()
			continue
		A?.deselect()

/obj/item/proc/cyborg_unequip(mob/user)
	return
