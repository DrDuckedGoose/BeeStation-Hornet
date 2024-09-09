/*
	Sub-component for arms
	handles item holding
*/
/datum/component/endopart/arm
	name = "arm"
	required_assembly = list(/datum/endo_assembly/item/interaction/stack/wire)
	///What are we currently holding, if anything
	var/obj/item/holding
	///Overlay for held items
	var/mutable_appearance/held_overlay
	var/held_side
	///Reference to our hand hud
	var/atom/movable/screen/new_robot/hand/hand
	///At what speed do we equip items
	var/equip_speed = 8 SECONDS
	COOLDOWN_DECLARE(equip_timer)
	///Should we paralyze this arm if it's incomplete
	var/paralyze = TRUE

/datum/component/endopart/arm/Initialize(_start_finished, _offset_key = ENDO_OFFSET_KEY_ARM(1))
	. = ..()
	offset_key = _offset_key
	held_side = istype(parent, /obj/item/bodypart/r_arm)
	held_overlay = new()
	RegisterSignal(parent, COMSIG_ROBOT_PICKUP_ITEM, PROC_REF(catch_unarmed))
	RegisterSignal(parent, COMSIG_ENDO_POLL_EQUIP, PROC_REF(poll_equip))

/datum/component/endopart/arm/apply_assembly(datum/source, mob/target)
	//Add this arm to the borgs available ones, and set it as current if there isn't one
	var/mob/living/silicon/new_robot/R = target
	if(!istype(R))
		return
	R.available_hands += parent
	if(!R.active_hand_index)
		R.set_hand_index(R.get_hand_index(parent))
	return ..()

/datum/component/endopart/arm/remove_assembly(datum/source, mob/target)
	holding?.dropped(assembled_mob)
	//Handle the borg's hand index
	var/mob/living/silicon/new_robot/R = target
	if(!istype(R))
		return
	R.available_hands -= parent
	return ..()

/datum/component/endopart/arm/refresh_assembly(datum/source, mob/target)
	. = ..()
	if(!(check_completion() & ENDO_ASSEMBLY_INCOMPLETE))
		return
	var/obj/item/bodypart/B = parent
	if(istype(B) && paralyze)
		ADD_TRAIT(B, TRAIT_PARALYSIS, src)
		B.update_disabled()

/datum/component/endopart/arm/apply_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!hud)
		return
	if(!hand)
		hand = new(null, parent)
	hand.hud = hud
	hud.static_inventory |= hand
	//Get our screenposition
	var/mob/living/silicon/new_robot/R = assembled_mob
	if(istype(R))
		var/hand_index = (R.get_hand_index(parent))*-1
		hand.screen_loc = "CENTER [hand_index]:16,SOUTH:[5 + FLOOR(hand_index, 3)]"
	//Select this hand, if it's the active one, for the one time it isn't after init. Don't think about it, bro
		if(R.active_hand_index == R.get_hand_index(parent))
			hand.select()
	//Update hud
	hud.show_hud(HUD_STYLE_STANDARD)

/datum/component/endopart/arm/remove_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!hud || !hand)
		return
	hand.hud = null
	hud.static_inventory -= hand
	hud.show_hud(HUD_STYLE_STANDARD)

///
/datum/component/endopart/arm/proc/catch_unarmed(datum/source, obj/item/item)
	SIGNAL_HANDLER

	if(holding || !COOLDOWN_FINISHED(src, equip_timer))
		return FALSE
//Technical setup
	holding = item
	COOLDOWN_START(src, equip_timer, equip_speed)
	RegisterSignal(item, COMSIG_CLICK, PROC_REF(catch_click))
	RegisterSignal(item, COMSIG_ITEM_DROPPED, PROC_REF(catch_dropped))
//Equip Visuals
	hand.vis_contents += holding
	//hand.select() //just incase it isn't selected already, like at the start
	//animashun
	holding.pixel_x = 0
	holding.pixel_y = 28
	holding.color = "#000"
	animate(holding, pixel_y = 0, time = equip_speed, easing = CIRCULAR_EASING | EASE_OUT)
	animate(holding, color = "#fff", time = equip_speed, easing = CIRCULAR_EASING | EASE_OUT)
	addtimer(CALLBACK(src, PROC_REF(cool_sound)), equip_speed)
//Overlay stuff
	assembled_mob.cut_overlay(held_overlay)
	held_overlay = holding.build_worn_icon(assembled_mob, default_icon_file = (held_side ? holding.righthand_file : holding.lefthand_file), isinhands = TRUE)
	assembled_mob.add_overlay(held_overlay)
	return TRUE

/datum/component/endopart/arm/proc/cool_sound()
	playsound(assembled_mob, 'sound/vehicles/clowncar_fart.ogg', 25, TRUE)

/datum/component/endopart/arm/proc/catch_dropped(datum/source)
	SIGNAL_HANDLER

	if(!holding)
		return FALSE
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)
	UnregisterSignal(source, COMSIG_CLICK)
	hand.vis_contents -= holding
	assembled_mob.cut_overlay(held_overlay)
	holding = null
	return TRUE

/datum/component/endopart/arm/proc/poll_equip(datum/source, atom/A)
	SIGNAL_HANDLER

	if(check_completion() & ENDO_ASSEMBLY_INCOMPLETE)
		to_chat(assembled_mob, "<span class='warning'>You can't seem to move [parent]!</span>")
		return FALSE
	return !(holding)

/datum/component/endopart/arm/proc/select()
	hand?.select()

/datum/component/endopart/arm/proc/deselect()
	hand?.deselect()

/datum/component/endopart/arm/proc/catch_click(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER

	var/mob/living/silicon/new_robot/R = assembled_mob
	if(!R || user != R)
		return
	R.set_hand_index(R.get_hand_index(parent))

/datum/component/endopart/arm/proc/get_holding()
	if(!assembled_mob)
		return
	if(!COOLDOWN_FINISHED(src, equip_timer))
		assembled_mob.balloon_alert(assembled_mob, "<span class='warning'>[parent] hasn't finished its equipping cycle!</span>", "#ff7777")
		return
	return holding
