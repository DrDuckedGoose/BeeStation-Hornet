///atom/movable/screen/robot
//	icon = 'icons/mob/screen_cyborg.dmi'

/datum/hud/new_robot
	ui_style = 'icons/mob/screen_cyborg.dmi'

/datum/hud/new_robot/New(mob/owner)
	..()
	var/mob/living/silicon/new_robot/R = mymob
	//Add some common stuff
	R.overlay_fullscreen("see_through_darkness", /atom/movable/screen/fullscreen/see_through_darkness)

/*
	Other hud stuff
*/
/atom/movable/screen/new_robot
	icon = 'icons/mob/screen_cyborg.dmi'

/atom/movable/screen/new_robot/Click()
	if(isobserver(usr))
		return FALSE
	return TRUE

//Lamp
/atom/movable/screen/new_robot/lamp
	name = "headlamp"
	icon_state = "lamp_off"
	///Ref to the lamp assembly for some logics
	var/datum/endo_assembly/item/lamp/lamp

/atom/movable/screen/new_robot/lamp/Initialize(mapload, _lamp)
	. = ..()
	lamp = _lamp

/atom/movable/screen/new_robot/lamp/Click()
	. = ..()
	if(!.) //Don't allow observers to fuck with this
		return
	var/mob/living/R = usr
	if(!istype(R))
		return
	toggle_headlamp(R)
	update_icon()

/atom/movable/screen/new_robot/lamp/proc/toggle_headlamp(mob/M, turn_off = FALSE, update_color = FALSE)
	if(!M || !lamp)
		return
	//if both lamp is enabled AND the update_color flag is on, keep the lamp on. Otherwise, if anything listed is true, disable the lamp.
	if(!(update_color && lamp.lamp_enabled) && (turn_off || lamp.lamp_enabled || update_color || !lamp.lamp_functional || M.stat))
		M.set_light_on(FALSE)
		lamp.lamp_enabled = FALSE
		M.update_icons()
		return
	M.set_light_range(lamp.lamp_intensity)
	M.set_light_color(lamp.lamp_color)
	M.set_light_on(TRUE)
	lamp.lamp_enabled = TRUE
	M.update_icons()

/atom/movable/screen/new_robot/lamp/update_icon()
	if(lamp.lamp_enabled)
		icon_state = "lamp_on"
	else
		icon_state = "lamp_off"

//Radio
/atom/movable/screen/new_robot/radio
	name = "radio"
	icon_state = "radio"
	///Ref to the radio we're rocking with
	var/obj/item/radio/radio

/atom/movable/screen/new_robot/radio/Initialize(mapload, _radio)
	. = ..()
	radio = _radio

/atom/movable/screen/new_robot/radio/Click()
	. = ..()
	//Don't check parent, allow observers to look at this
	radio?.interact(usr)

//Item module
/atom/movable/screen/new_robot/module
	name = "cyborg module"
	icon_state = "nomod"
	///Ref to the particular item module we represent
	var/obj/item/new_robot_module/module
	///Our pretty background we layer the items ontop of
	var/atom/movable/screen/modules_background
	///Are we displaying or hiding the module
	var/display_module = FALSE

/atom/movable/screen/new_robot/module/Initialize(mapload, _module)
	. = ..()
	module = _module
	//Build background
	modules_background = new()
	modules_background.icon_state = "block"
	modules_background.plane = HUD_PLANE
	var/display_rows = CEILING(length(module.all_items) / 8, 1)
	modules_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"

/atom/movable/screen/new_robot/module/Click()
	. = ..()
	if(!. || !module)
		return
	var/mob/M = usr
	update_inventory(M, !display_module)

/atom/movable/screen/new_robot/module/proc/update_inventory(mob/M, display)
	display_module = display
//Handle our background
	if(display_module)
		M.client.screen += modules_background
	else
		M.client.screen -= modules_background
//Handle our items
	var/x = -4	//Start at CENTER-4,SOUTH+1
	var/y = 1
	for(var/atom/movable/A in module.all_items)
		//Display logic
		if(display_module && !(A in module.equipped_items))
			M.client.screen += A
		else
			M.client.screen -= A
		//Positioning
		if(x < 0)
			A.screen_loc = "CENTER[x]:16,SOUTH+[y]:7"
		else
			A.screen_loc = "CENTER+[x]:16,SOUTH+[y]:7"
		A.plane = ABOVE_HUD_PLANE
		//TODO: Revisit this code and make sure this is the best it can be, it looks stinky - Racc
		x++
		if(x == 4)
			x = -4
			y++

//Hands
/atom/movable/screen/new_robot/hand
	name = "module"
	icon_state = "inv1"
	///Reference to our arm part
	var/obj/item/bodypart/arm

/atom/movable/screen/new_robot/hand/Initialize(mapload, _arm)
	. = ..()
	arm = _arm

/atom/movable/screen/new_robot/hand/Click()
	. = ..()
	if(!. || !arm)
		return
	var/mob/living/silicon/new_robot/R = usr
	if(istype(R))
		R.active_hand_index = R.get_hand_index(arm)
		//TODO: Selected visuals - Racc

