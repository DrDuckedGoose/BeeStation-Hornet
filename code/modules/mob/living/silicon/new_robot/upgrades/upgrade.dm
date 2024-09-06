/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/obj/module.dmi'
	icon_state = "cyborg_upgrade"
	///What modules do we work with? Leave this blank if we work with everything
	var/list/compatible_modules
	///Does this upgrade require the robbit be alive?
	var/requires_living = TRUE
	///Bitflags listing module compatibility. Used in the exosuit fabricator for creating sub-categories.
	var/module_flags = NONE
	///Is this module deleted after successful use?
	var/one_use = FALSE
	///Module we're installed on
	var/obj/item/new_robot_module/parent_module

/obj/item/borg/upgrade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	//Case for living borgs
	var/mob/living/silicon/new_robot/R = target
	if(istype(R) && find_module(R, user))
		return
	//Case for module item
	var/obj/item/new_robot_module/module = target
	if(istype(module) && install(module, null, user))
		return
	//If we can't install it on the borg or module, just go ahead
	return ..()

/obj/item/borg/upgrade/examine(mob/user)
	. = ..()
	if(requires_living)
		. += "<span class='warning'>This module can only be installed on an active cyborg!</span>"
	else
		. += "<span class='notice'>This module can be installed onto a cyborg module.</span>"

//Get a module we can install on
/obj/item/borg/upgrade/proc/find_module(mob/living/silicon/new_robot/R, user = usr)
	if(R.stat == DEAD && requires_living)
		to_chat(user, "<span class='warning'>[src] will not function on a deceased cyborg!</span>")
		return
	if(!R.cover_open)
		to_chat(user, "<span class='warning'>[R]'s cover is closed!.</span>")
		return
	//Run through all the robots modules, and find one we like
	var/list/modules = list()
	SEND_SIGNAL(R.chassis, COMSIG_ENDO_LIST_PART, /obj/item/new_robot_module, modules)
	var/obj/item/new_robot_module/target_module //This CANNOT be nudged one line up, try it. Poots an error and I'm too krunked on the bob to figure it out
	if(!length(modules))
		return
	if(!compatible_modules)
		target_module = modules[1]
	for(var/obj/item/new_robot_module/module as() in modules)
		if(is_type_in_list(module, compatible_modules))
			target_module = module
			break
	if(!target_module)
		to_chat(R, "<span class='warning'>Upgrade mounting error!  No suitable hardpoint detected!</span>")
		to_chat(user, "<span class='warning'>There's no mounting point for the module!</span>")
		return
	//Install to this module
	if(install(target_module, R, user))
		return TRUE

/obj/item/borg/upgrade/proc/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	if(requires_living && !R)
		to_chat(user, "<span class='warning'>This module can only be installed on an active cyborg!</span>")
		return
	. = TRUE
	parent_module = module
	if(one_use)
		qdel(src)
		return
	forceMove(module)

/obj/item/borg/upgrade/proc/remove(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	parent_module = null
	return TRUE

/*
	Template for just adding an item
*/
/obj/item/borg/upgrade/item
	requires_living = FALSE
	///What item are we adding to the module
	var/obj/item/upgrade_item = /obj/item/paper

/obj/item/borg/upgrade/item/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	upgrade_item = new upgrade_item(module)
	module.prepare_item(upgrade_item, TRUE)

/obj/item/borg/upgrade/item/remove(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	module.remove_item(upgrade_item)
	QDEL_NULL(upgrade_item)
