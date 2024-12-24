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
	. = ..()
	if(isobserver(usr))
		return FALSE
	return TRUE

//Lamp
/atom/movable/screen/new_robot/lamp
	name = "headlamp"
	icon_state = "lamp_off"
	screen_loc = ui_borg_lamp
	///Ref to the lamp assembly for some logics
	var/datum/endo_assembly/item/lamp/lamp

/atom/movable/screen/new_robot/lamp/Initialize(mapload, _lamp)
	. = ..()
	lamp = _lamp
	var/atom/movable/screen/new_robot/info/info = new(src, "Use the Modular Tablet to adjust lamp brightness.")
	vis_contents += info

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
	icon_state = "blank"
	screen_loc = ui_borg_module
	///Ref to the particular item module we represent
	var/obj/item/new_robot_module/module
	///Our pretty background we layer the items ontop of
	var/atom/movable/screen/modules_background
	///Are we displaying or hiding the module
	var/display_module = FALSE
	///What is our display index? Used to offset this hud stuff when we have multiple modules
	var/display_index = 0

/atom/movable/screen/new_robot/module/Initialize(mapload, _module, _display_index)
	. = ..()
	module = _module
	display_index = _display_index
//Visual
	var/obj/item/new_robot_module/module_item = module
	add_overlay(mutable_appearance(module_item.icon, module_item.icon_state, color = "#b2b2b2"))
	add_overlay(mutable_appearance(icon, module_item.module_icon, alpha = 200))
//Build background
	modules_background = new()
	modules_background.icon_state = "block"
	modules_background.plane = HUD_PLANE
	var/display_rows = CEILING(length(module.all_items) / 8, 1)
	modules_background.screen_loc = "CENTER-4:16,SOUTH+[1+display_index]:7 to CENTER+3:16,SOUTH+[display_index+display_rows]:7"
//Info stuff
	if(display_index)
		return
	var/atom/movable/screen/new_robot/info/info = new(src, "Press Q to return equipped items.")
	vis_contents += info

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
		A.plane = ABOVE_HUD_PLANE
		//Positioning. I thought these were the same, they're not
		if(x < 0)
			A.screen_loc = "CENTER[x]:16,SOUTH+[y+display_index]:7"
		else
			A.screen_loc = "CENTER+[x]:16,SOUTH+[y+display_index]:7"
		x++ //This is from the original robot code, mind you
		if(x == 4)
			x = -4
			y++

//Hands
/atom/movable/screen/new_robot/hand
	name = "module"
	icon_state = "blank"
	///Reference to our arm part
	var/obj/item/bodypart/arm

/atom/movable/screen/new_robot/hand/Initialize(mapload, _arm)
	. = ..()
	arm = _arm
	deselect()

/atom/movable/screen/new_robot/hand/Click()
	. = ..()
	if(!. || !arm)
		return
	var/mob/living/silicon/new_robot/R = usr
	if(istype(R))
		R.set_hand_index(R.get_hand_index(arm))

/atom/movable/screen/new_robot/hand/proc/select()
	color = "#fff"
	alpha = 255

/atom/movable/screen/new_robot/hand/proc/deselect()
	color = "#ffffff6d"

//Modular tablet
/atom/movable/screen/new_robot/modpc
	name = "Modular Interface"
	icon_state = "blank"
	screen_loc = ui_borg_tablet
	var/mob/living/silicon/new_robot/robot

/atom/movable/screen/new_robot/modpc/Click()
	. = ..()
	if(!.)
		return
	robot.modularInterface?.interact(robot)

//Health
/atom/movable/screen/healths/robot
	icon = 'icons/mob/screen_cyborg.dmi'
	screen_loc = ui_borg_health
	///Reference to the robot we're tacking health for
	var/mob/living/silicon/new_robot/robot

	var/list/cached_parts = list()
	var/list/cached_index = list()

/atom/movable/screen/healths/robot/Initialize(mapload, _robot)
	. = ..()
	robot = _robot
	//tooltip
	var/atom/movable/screen/new_robot/info/info = new(src, "Mouse over the health UI to see the integrity of individual parts.")
	vis_contents += info

//When moused over, show the health & status of our hardware
/atom/movable/screen/healths/robot/MouseEntered(location, control, params)
	. = ..()
	if(!robot)
		return
	//Get a list of our robot's hardware
	var/datum/component/endopart/chassis/chassis_component = robot.chassis_component
	var/list/parts = chassis_component.current_assembly
	//Build a visual asset for each part and display its health
	var/visual_index = -1
	for(var/atom/movable/part in parts)
		var/atom/movable/screen/screen_part = cached_parts["[REF(part)]"]
		if(screen_part)
			screen_part.maptext = MAPTEXT("<font color='#00ff00ff'>100%<font>")
			animate(screen_part, pixel_x = 32 * cached_index["[REF(part)]"], 0.25 SECONDS)
			continue
		//Visual asset
		screen_part = new(src)
		screen_part.appearance = part.appearance
		screen_part.underlays += icon('icons/mob/screen_cyborg.dmi', "blank")
		screen_part.plane = plane
		screen_part.layer = layer-0.1
		screen_part.maptext = MAPTEXT("<font color='#00ff00ff'>100%<font>")

		animate(screen_part, pixel_x = 32 * visual_index, 0.25 SECONDS)

		vis_contents += screen_part

		cached_parts["[REF(part)]"] = screen_part
		cached_index["[REF(part)]"] = visual_index

		visual_index -= 1

/atom/movable/screen/healths/robot/MouseExited(location, control, params)
	. = ..()
	if(!robot)
		return
	var/datum/component/endopart/chassis/chassis_component = robot.chassis_component
	var/list/parts = chassis_component.current_assembly
	for(var/atom/movable/part in parts)
		var/atom/movable/screen/screen_part = cached_parts["[REF(part)]"]
		if(!screen_part)
			continue
		animate(screen_part, pixel_x = 0, 0.25 SECONDS)

//Info help
/atom/movable/screen/new_robot/info
	icon_state = "info"
	///What awesome info does this cool thing divulge
	var/dialogue = ""

/atom/movable/screen/new_robot/info/Initialize(mapload, _dialogue)
	. = ..()
	dialogue = _dialogue

/atom/movable/screen/new_robot/info/MouseEntered(location, control, params)
	. = ..()
	openToolTip(usr, src, params, title = "Info", content = dialogue)
	//Animashun
	var/matrix/n_transform = transform
	n_transform.Scale(1.1)
	animate(src, transform = n_transform, time = 0.08 SECONDS)

/atom/movable/screen/new_robot/info/MouseExited(location, control, params)
	. = ..()
	closeToolTip(usr)
	animate(src, transform = new /matrix(), time = 0.08 SECONDS)

//Language menu
/atom/movable/screen/language_menu/robot
	screen_loc = ui_borg_language_menu
