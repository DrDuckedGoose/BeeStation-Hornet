/datum/endo_assembly/item/signaler
	item_requirment = /obj/item/assembly/signaler
	assembly_integral = TRUE

/datum/endo_assembly/item/proximity_sensor
	item_requirment = /obj/item/assembly/prox_sensor
	assembly_integral = TRUE

/datum/endo_assembly/item/analyzer
	item_requirment = /obj/item/analyzer

/datum/endo_assembly/item/oxygen
	item_requirment = /obj/item/tank/internals/oxygen

/datum/endo_assembly/item/toolbox
	item_requirment = /obj/item/storage/toolbox

/datum/endo_assembly/item/welder
	item_requirment = /obj/item/weldingtool

/datum/endo_assembly/item/stun_baton
	item_requirment = /obj/item/melee/baton
	assembly_integral = TRUE


/datum/endo_assembly/item/healthanalyzer
	item_requirment = /obj/item/healthanalyzer

/datum/endo_assembly/item/eyes
	item_requirment = /obj/item/organ/eyes
	poll_path = /obj/item/organ/eyes
	allow_poll = TRUE

/datum/endo_assembly/item/access_module
	item_requirment = /obj/item/access_module
	poll_path = /obj/item/access_module
	allow_poll = TRUE

/datum/endo_assembly/item/cell
	item_requirment = /obj/item/stock_parts/cell
	poll_path = /obj/item/stock_parts/cell
	allow_poll = TRUE

/datum/endo_assembly/item/cell/transform_machine
	item_requirment = /obj/item/stock_parts/cell/upgraded/plus

/datum/endo_assembly/item/tiles
	item_requirment = /obj/item/stack/tile

/datum/endo_assembly/item/tiles/add_part(datum/source, obj/item/I, mob/living/L)
	var/obj/item/stack/tile/stack = I
	if(istype(stack) && stack.amount < 10)
		return
	return ..()

//Handles MMIs and Posibrains
/datum/endo_assembly/item/mmi
	item_requirment = /obj/item/mmi
	poll_path = /obj/item/mmi
	allow_poll = TRUE

/datum/endo_assembly/item/mmi/pre_check_assemble(datum/source, obj/item/I)
	var/datum/endo_assembly/item/ai_controller/ai_assembly = locate(/datum/endo_assembly/item/ai_controller) in part_parent.required_assembly
	if(!ispath(ai_assembly) && (ai_assembly?.check_completion() & ENDO_ASSEMBLY_COMPLETE))
		return
	return ..()

//Ai controller
/datum/endo_assembly/item/ai_controller
	item_requirment = /obj/item/mmi/ai_brain
	poll_path = /obj/item/mmi/ai_brain
	allow_poll = TRUE

/datum/endo_assembly/item/ai_controller/New(datum/parent)
	. = ..()
	RegisterSignal(part_parent.parent, COMSIG_ENDO_ASSEMBLE, PROC_REF(catch_assembly))

/datum/endo_assembly/item/ai_controller/pre_check_assemble(datum/source, obj/item/I)
	var/datum/endo_assembly/item/mmi/mmi_assembly = locate(/datum/endo_assembly/item/mmi) in part_parent.required_assembly
	if(!ispath(mmi_assembly) && (mmi_assembly?.check_completion() & ENDO_ASSEMBLY_COMPLETE))
		return
	return ..()

/datum/endo_assembly/item/ai_controller/remove_part(datum/source, obj/item/I)
	. = ..()
	UnregisterSignal(part_parent.parent, COMSIG_ENDO_ASSEMBLE)
	//TODO: Add logic to remove the AI stuff - Racc

/datum/endo_assembly/item/ai_controller/proc/catch_assembly(datum/source, mob/M)
	SIGNAL_HANDLER

	if(!M || !length(parts))
		return
	var/mob/living/silicon/new_robot/R = M
	var/obj/item/mmi/ai_brain/ai_controller = parts[1]
	if(!istype(R))
		return
	R.name = "[R.designation || M] ||  AI Shell [rand(100,999)]"
	R.real_name = R.name
	ai_controller.undeployment_action.Grant(R)
	GLOB.available_ai_shells |= M
	if(!QDELETED(R.builtInCamera))
		R.builtInCamera.c_tag = R.real_name	//update the camera name too
	R.diag_hud_set_aishell()
	R.notify_ai(AI_SHELL)

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

/datum/endo_assembly/item/radio/remove_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!radio || !hud)
		return
	radio.hud = null
	hud.static_inventory -= radio
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

/datum/endo_assembly/item/lamp/add_part(datum/source, obj/item/I, mob/living/L)
	. = ..()
	if(.)
		lamp_functional = TRUE

/datum/endo_assembly/item/lamp/poll_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!.)
		return
	//Radio
	if(!lamp)
		lamp = new(null, src)
		lamp.screen_loc = ui_borg_lamp
	lamp.hud = hud
	hud.static_inventory += lamp
	//Update hud
	hud.show_hud(HUD_STYLE_STANDARD)

/datum/endo_assembly/item/lamp/remove_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!lamp || !hud)
		return
	lamp.hud = null
	hud.static_inventory -= lamp
	hud.show_hud(HUD_STYLE_STANDARD)

/datum/endo_assembly/item/lamp/append_monitor(datum/source, list/data)
	. = ..()
	data["lamp"] = "It's ogre"

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
	//Module
	if(!module)
		module = new(null, parts[1])
		var/obj/item/new_robot_module/item_module = parts[1]
		item_module.module_hud = module
		module.icon_state = item_module.module_icon
		module.screen_loc = ui_borg_module
	module.hud = hud
	hud.static_inventory += module
	//Update hud
	hud.show_hud(HUD_STYLE_STANDARD)

/datum/endo_assembly/item/item_module/remove_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!module || !hud)
		return
	module.hud = null
	hud.static_inventory -= module
	hud.show_hud(HUD_STYLE_STANDARD)

/datum/endo_assembly/item/item_module/build_ideal_part()
	for(var/i in 1 to amount_required)
		var/obj/item/I = new /obj/item/new_robot_module/standard(get_turf(part_parent.parent))
		if(!part_parent.attach_part(src, I, null))
			qdel(I)

/datum/endo_assembly/item/item_module/remove_part(datum/source, obj/item/I)
	. = ..()
	var/obj/item/new_robot_module/item_module = parts[1]
	item_module.module_hud = null
	QDEL_NULL(module)

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

	for(var/obj/item/new_robot_module/module as() in parts)
		if(new_state)
			module.show_module_items(MODULE_ITEM_CATEGORY_EMAGGED)
		else
			module.hide_module_items(MODULE_ITEM_CATEGORY_EMAGGED)
