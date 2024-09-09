/datum/endo_assembly/item/signaler
	item_requirment = /obj/item/assembly/signaler
	assembly_integral = TRUE

/datum/endo_assembly/item/proximity_sensor
	item_requirment = /obj/item/assembly/prox_sensor
	assembly_integral = TRUE

/datum/endo_assembly/item/vest
	item_requirment = /obj/item/clothing/suit/armor/vest
	assembly_integral = TRUE

/datum/endo_assembly/item/helmet
	item_requirment = /obj/item/clothing/head/helmet
	assembly_integral = TRUE

/datum/endo_assembly/item/analyzer
	item_requirment = /obj/item/analyzer

/datum/endo_assembly/item/clown_horn
	item_requirment = /obj/item/bikehorn

/datum/endo_assembly/item/hardhat
	item_requirment = /obj/item/clothing/head/utility/hardhat
	assembly_integral = TRUE

/datum/endo_assembly/item/oxygen
	item_requirment = /obj/item/tank/internals/oxygen

/datum/endo_assembly/item/toolbox
	item_requirment = /obj/item/storage/toolbox

/datum/endo_assembly/item/welder
	item_requirment = /obj/item/weldingtool

/datum/endo_assembly/item/stun_baton
	item_requirment = /obj/item/melee/baton
	assembly_integral = TRUE

/datum/endo_assembly/item/disabler
	item_requirment = /obj/item/gun/energy/disabler
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
	amount_required = 3

/datum/endo_assembly/item/access_module/New(datum/parent)
	. = ..()
	hint_data["name"] = "access module"

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

/datum/endo_assembly/item/mmi/New(datum/parent)
	. = ..()
	RegisterSignal(part_parent, COMSIG_ENDO_ASSEMBLE, PROC_REF(catch_assembly))
	RegisterSignal(part_parent.parent, COMSIG_ENDO_UNASSEMBLE, PROC_REF(catch_unassembly))

/datum/endo_assembly/item/mmi/pre_check_assemble(datum/source, obj/item/I)
	var/datum/endo_assembly/item/ai_controller/ai_assembly = locate(/datum/endo_assembly/item/ai_controller) in part_parent.required_assembly
	if(!ispath(ai_assembly) && (ai_assembly?.check_completion() & ENDO_ASSEMBLY_COMPLETE))
		return
	return ..()

/datum/endo_assembly/item/mmi/proc/catch_assembly(datum/source, mob/M)
	SIGNAL_HANDLER

	if(iscarbon(M)) //Don't allow MMIs to control humans, not yet
		return
	INVOKE_ASYNC(src, PROC_REF(async_catch_assembly), M)

/datum/endo_assembly/item/mmi/proc/async_catch_assembly(mob/M)
	var/obj/item/mmi/mmi = locate(/obj/item/mmi) in parts
	if(!mmi?.brainmob?.ckey || is_banned_from(mmi.brainmob.ckey, JOB_NAME_CYBORG) || mmi.brainmob.client.get_exp_living(TRUE) <= MINUTES_REQUIRED_BASIC)
		return
	mmi?.transfer_identity(M)

/datum/endo_assembly/item/mmi/proc/catch_unassembly(datum/source, mob/M)
	SIGNAL_HANDLER

	var/obj/item/mmi/mmi = locate(/obj/item/mmi) in parts
	if(!mmi)
		return
	var/mob/living/target = M
	//When a borg is admin spawned, it can be spawned in with an empty MMI, no bwain mawb
	mmi.brainmob = mmi.brainmob || new /mob/living/brain(mmi)
	target.mind.transfer_to(mmi.brainmob)
	mmi.update_icon()

//TODO: Revise this and how it interacts with MMI - Racc
//Ai controller
/datum/endo_assembly/item/ai_controller
	item_requirment = /obj/item/mmi/ai_brain
	poll_path = /obj/item/mmi/ai_brain
	allow_poll = TRUE

/datum/endo_assembly/item/ai_controller/New(datum/parent)
	. = ..()
	RegisterSignal(part_parent, COMSIG_ENDO_ASSEMBLE, PROC_REF(catch_assembly))

/datum/endo_assembly/item/ai_controller/pre_check_assemble(datum/source, obj/item/I)
	var/datum/endo_assembly/item/mmi/mmi_assembly = locate(/datum/endo_assembly/item/mmi) in part_parent.required_assembly
	if(!ispath(mmi_assembly) && (mmi_assembly?.check_completion() & ENDO_ASSEMBLY_COMPLETE))
		return
	return ..()

/datum/endo_assembly/item/ai_controller/remove_part(datum/source, obj/item/I)
	. = ..()
	UnregisterSignal(part_parent, COMSIG_ENDO_ASSEMBLE)
	//TODO: Add logic to remove the AI stuff - Racc

/datum/endo_assembly/item/ai_controller/proc/catch_assembly(datum/source, mob/M)
	SIGNAL_HANDLER

	if(!M || !length(parts))
		return
	var/mob/living/silicon/new_robot/R = M
	var/obj/item/mmi/ai_brain/ai_controller = locate(/obj/item/mmi/ai_brain) in parts
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

/datum/endo_assembly/item/radio/apply_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!.)
		return
	//Radio
	if(!radio)
		var/obj/item/radio/R = locate(/obj/item/radio) in parts
		radio = new(null, R)
		radio.screen_loc = ui_borg_radio
	radio.hud = hud
	hud.static_inventory |= radio
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

/datum/endo_assembly/item/lamp/apply_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!.)
		return
	//Radio
	if(!lamp)
		lamp = new(null, src)
	lamp.hud = hud
	hud.static_inventory |= lamp
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
	data["lampIntensity"] = lamp_intensity

//Module
/datum/endo_assembly/item/item_module
	item_requirment = /obj/item/new_robot_module
	poll_path = /obj/item/new_robot_module
	allow_poll = TRUE
	///Ref to all our module huds for cleanup
	var/list/module_huds = list()

/datum/endo_assembly/item/item_module/New(datum/parent)
	. = ..()
	RegisterSignal(part_parent, COMSIG_ROBOT_SET_EMAGGED, PROC_REF(set_emagged))
	RegisterSignal(part_parent, COMSIG_ENDO_ASSEMBLE, PROC_REF(add_module_parent))
	RegisterSignal(part_parent.parent, COMSIG_ENDO_UNASSEMBLE, PROC_REF(remove_module_parent))

/datum/endo_assembly/item/item_module/add_part(datum/source, obj/item/I, mob/living/L)
	. = ..()
	add_module_parent()

/datum/endo_assembly/item/item_module/apply_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!. || !length(parts))
		return
	var/index = 0
	for(var/obj/item/new_robot_module/item_module as anything in parts)
		var/atom/movable/screen/new_robot/module/module = new(null, item_module, index)
		module_huds += module
		RegisterSignal(module, COMSIG_CLICK, PROC_REF(catch_click))
		item_module.module_hud = module
	//Hud stuff
		module.icon_state = item_module.module_icon
		module.screen_loc = "CENTER+1:16,SOUTH+[index]:5"
		module.hud = hud
		hud.static_inventory |= module
		index++
	//Update hud
		hud.show_hud(HUD_STYLE_STANDARD)

/datum/endo_assembly/item/item_module/remove_hud(datum/source, datum/hud/hud)
	. = ..()
	if(!hud)
		return
	for(var/atom/movable/screen/new_robot/module/module as anything in module_huds)
		module.hud = null
		hud.static_inventory -= module
		hud.show_hud(HUD_STYLE_STANDARD)

/datum/endo_assembly/item/item_module/build_ideal_part()
	for(var/i in 1 to amount_required)
		var/obj/item/I = new /obj/item/new_robot_module/standard(get_turf(part_parent.parent))
		if(!part_parent.attach_part(src, I, null))
			qdel(I)

/datum/endo_assembly/item/item_module/remove_part(datum/source, obj/item/I)
	for(var/obj/item/new_robot_module/item_module as anything in parts)
		item_module.module_hud = null
		item_module.remove_parent()
	for(var/atom/movable/screen/new_robot/module/module as anything in module_huds)
		QDEL_NULL(module)
	return ..()

///Used to close the other module inventories when we focus a new one
/datum/endo_assembly/item/item_module/proc/catch_click(datum/source, location, control, params, mob/user)
	SIGNAL_HANDLER

	if(user != part_parent.assembled_mob)
		return
	var/atom/movable/screen/new_robot/module/exclusion = source
	for(var/atom/movable/screen/new_robot/module/module as anything in module_huds-exclusion)
		module.update_inventory(part_parent.assembled_mob, FALSE)

/datum/endo_assembly/item/item_module/proc/add_module_parent(datum/source)
	SIGNAL_HANDLER

	if(!part_parent.assembled_mob)
		return
	for(var/obj/item/new_robot_module/module as anything in parts)
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

/datum/endo_assembly/item/item_module/transform_machine
	amount_required = 3

/datum/endo_assembly/item/item_module/transform_machine/build_ideal_part()
	//This is semi-non-standard behaviour, so don't sweat it
	var/list/modules_we_want = list(/obj/item/new_robot_module/engineering, /obj/item/new_robot_module/standard, /obj/item/new_robot_module/medical)
	for(var/obj/item/new_robot_module/added_module as anything in modules_we_want)
		var/obj/item/I = new added_module(get_turf(part_parent.parent))
		if(!part_parent.attach_part(src, I, null))
			qdel(I)
