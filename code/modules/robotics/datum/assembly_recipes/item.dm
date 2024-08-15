/datum/endo_assembly/item/bucket
	item_requirment = /obj/item/reagent_containers/glass/bucket
	assembly_integral = TRUE

/datum/endo_assembly/item/proximity_sensor
	item_requirment = /obj/item/assembly/prox_sensor
	assembly_integral = TRUE

/datum/endo_assembly/item/medkit
	item_requirment = /obj/item/storage/firstaid
	assembly_integral = TRUE

/datum/endo_assembly/item/healthanalyzer
	item_requirment = /obj/item/healthanalyzer
	assembly_integral = TRUE

/datum/endo_assembly/item/eyes
	item_requirment = /obj/item/organ/eyes
	poll_path = /obj/item/organ/eyes
	allow_poll = TRUE

//Handles MMIs and Posibrains
//TODO: Consider making a seperate thing for posibrains - Racc
/datum/endo_assembly/item/mmi
	item_requirment = /obj/item/mmi
	poll_path = /obj/item/mmi
	allow_poll = TRUE

/datum/endo_assembly/item/access_module
	item_requirment = /obj/item/access_module
	poll_path = /obj/item/access_module
	allow_poll = TRUE

/datum/endo_assembly/item/cell
	item_requirment = /obj/item/stock_parts/cell
	poll_path = /obj/item/stock_parts/cell
	allow_poll = TRUE

//Ai controller
//TODO: Make this and the MMI assembly not work if the other is fufilled - Racc
/datum/endo_assembly/item/ai_controller
	item_requirment = /obj/item/food/bbqribs/ai_brain
	poll_path = /obj/item/food/bbqribs/ai_brain
	allow_poll = TRUE

/datum/endo_assembly/item/ai_controller/New(datum/parent)
	. = ..()
	//TODO: Add case to remove assembly - Racc
	RegisterSignal(part_parent.parent, COMSIG_ENDO_ASSEMBLE, PROC_REF(catch_assembly))

/datum/endo_assembly/item/ai_controller/proc/catch_assembly(datum/source, mob/M)
	SIGNAL_HANDLER

	if(!M || !length(parts))
		return
	var/mob/living/silicon/new_robot/R = M
	if(!istype(R)) //The idea here is me tryng to both future proof, and cover my ass if someone manages to use this on non robots
		R = null
	M.name = "[R?.designation || M] ||  AI Shell [rand(100,999)]"
	M.real_name = M.name
	GLOB.available_ai_shells |= M
	//TODO: Maybe make this an assembly thing - Racc
	//if(!QDELETED(builtInCamera))
	//	builtInCamera.c_tag = real_name	//update the camera name too
	R?.diag_hud_set_aishell()
	R?.notify_ai(AI_SHELL)

//Radio
/datum/endo_assembly/item/radio
	item_requirment = /obj/item/radio
	poll_path = /obj/item/radio
	allow_poll = TRUE
//Hud stuff
	///Reference to our radio hud stuff
	var/atom/movable/screen/new_robot/radio/radio

/datum/endo_assembly/item/radio/poll_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!.)
		return
	//Radio
	if(!radio)
		//TODO: this is kinda hacky and will need a fix - Racc
		var/obj/item/radio/borg/R = new(hud.mymob)
		radio = new(null, R)
	radio.screen_loc = ui_borg_radio
	radio.hud = hud
	hud.static_inventory += radio
	//Update hud
	hud.show_hud(HUD_STYLE_STANDARD)

//Lamp
/datum/endo_assembly/item/lamp
	item_requirment = /obj/item/flashlight
	poll_path = /obj/item/flashlight
	allow_poll = TRUE
//State stuff for our lamp
	///If the lamp isn't broken.
	var/lamp_functional = TRUE
	///If the lamp is turned on
	var/lamp_enabled = FALSE
	///Set lamp color
	var/lamp_color = COLOR_WHITE
	///Lamp brightness. Starts at 3, but can be 1 - 5.
	var/lamp_intensity = 3
//Hud stuff
	///Reference to our lamp hud stuff
	var/atom/movable/screen/new_robot/lamp/lamp

/datum/endo_assembly/item/lamp/poll_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!.)
		return
	//Radio
	if(!lamp)
		lamp = new(null, src) //TODO: This looks for a robot lamp and runtimes, make it more modular - Racc
	lamp.screen_loc = ui_borg_lamp
	lamp.hud = hud
	hud.static_inventory += lamp
	//Update hud
	hud.show_hud(HUD_STYLE_STANDARD)

//Module
/datum/endo_assembly/item/item_module
	item_requirment = /obj/item/new_robot_module
	poll_path = /obj/item/new_robot_module
	allow_poll = TRUE
//Hud stuff
	///Reference to our module hud stuff
	var/atom/movable/screen/new_robot/module/module

/datum/endo_assembly/item/item_module/New(datum/parent)
	. = ..()
	RegisterSignal(part_parent, COMSIG_ROBOT_SET_EMAGGED, PROC_REF(set_emagged))
	RegisterSignal(part_parent, COMSIG_ENDO_ASSEMBLE, PROC_REF(add_module_parent))
	RegisterSignal(part_parent, COMSIG_ENDO_UNASSEMBLE, PROC_REF(remove_module_parent))

/datum/endo_assembly/item/item_module/poll_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!.)
		return
	//TODO: Cover case for this being removed and such - Racc
	//Module
	if(!module)
		module = new(null, parts[1])

		var/obj/item/new_robot_module/item_module = parts[1]
		item_module.module_hud = module
	module.screen_loc = ui_borg_module
	module.hud = hud
	hud.static_inventory += module
	//Update hud
	hud.show_hud(HUD_STYLE_STANDARD)

/datum/endo_assembly/item/item_module/build_ideal_part()
	for(var/i in 1 to amount_required)
		var/obj/item/I = new /obj/item/new_robot_module/standard(get_turf(part_parent.parent))
		if(!part_parent.attach_part(src, I, null))
			qdel(I)

/datum/endo_assembly/item/item_module/remove_part(datum/source, obj/item/I)
	. = ..()
	var/obj/item/new_robot_module/module = I
	module.remove_parent()

/datum/endo_assembly/item/item_module/proc/add_module_parent(datum/source)
	SIGNAL_HANDLER

	for(var/obj/item/new_robot_module/module as() in parts)
		module.add_parent(part_parent.assembled_mob)

/datum/endo_assembly/item/item_module/proc/remove_module_parent(datum/source)
	SIGNAL_HANDLER

	for(var/obj/item/new_robot_module/module as() in parts)
		module.remove_parent()

/datum/endo_assembly/item/item_module/proc/set_emagged(datum/source, new_state)
	SIGNAL_HANDLER

	//TODO: Add a handler for if the new_state is undoing the emag - Racc
	for(var/obj/item/new_robot_module/module as() in parts)
		if(new_state)
			module.show_module_items(MODULE_ITEM_CATEGORY_EMAGGED)
		else
			module.hide_module_items(MODULE_ITEM_CATEGORY_EMAGGED)

//TODO: Change this to an interaction - Racc
//Hey fucko, you can't use more than two of these in a given component, because wire merges with itself inside locs, which breaks the system a lil
/datum/endo_assembly/item/wire
	item_requirment = /obj/item/stack/cable_coil
	///How much cable do we use?
	var/consumed_stacks = 1

/datum/endo_assembly/item/wire/modify_part(obj/item/I, mob/living/L)
	. = ..()
	if(!.)
		return
	INVOKE_ASYNC(src, PROC_REF(async_modify), I, L)

/datum/endo_assembly/item/wire/proc/async_modify(obj/item/I, mob/living/L)
	var/obj/item/stack/cable_coil/C = I
	if((istype(C) && C?.amount <= consumed_stacks))
		return
	//This is fine... I'm sure
	var/obj/item/stack/cable_coil/new_cable = new(get_turf(L || I), C.amount-consumed_stacks, C.color)
	L?.put_in_hands(new_cable)
	if(start_finished)
		qdel(new_cable)
	C.amount = consumed_stacks
	C.update_icon()

/datum/endo_assembly/item/wire
