/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "cyborg_upgrade3"

/obj/item/borg/upgrade/syndicate/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(!.)
		return
	if(R.emagged)
		return FALSE
	module.show_module_items(MODULE_ITEM_CATEGORY_EMAGGED)
	R.logevent("WARN: hardware installed with missing security certificate!") //A bit of fluff to hint it was an illegal tech item
	R.logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") //random eight digit hex value. Two are used because rand(1,4294967295) throws an error

	return TRUE

/obj/item/borg/upgrade/syndicate/remove(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(. && !R.emagged)
		module.hide_module_items(MODULE_ITEM_CATEGORY_EMAGGED)
