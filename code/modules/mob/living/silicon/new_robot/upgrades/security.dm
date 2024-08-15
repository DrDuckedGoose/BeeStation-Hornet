/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/new_robot_module/security)
	module_flags = BORG_MODULE_SECURITY
	requires_living = FALSE

/obj/item/borg/upgrade/disablercooler/install(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(.)
		var/obj/item/gun/energy/disabler/cyborg/T = locate() in module.all_items
		if(!T)
			to_chat(user, "<span class='notice'>There's no disabler in this unit!</span>")
			return FALSE
		if(T.charge_delay <= 2)
			to_chat(R, "<span class='notice'>A cooling unit is already installed!</span>")
			to_chat(user, "<span class='notice'>There's no room for another cooling unit!</span>")
			return FALSE
		T.charge_delay = max(2 , T.charge_delay - 4)

/obj/item/borg/upgrade/disablercooler/remove(obj/item/new_robot_module/module, mob/living/silicon/new_robot/R, mob/user)
	. = ..()
	if(.)
		var/obj/item/gun/energy/disabler/cyborg/T = locate() in module.all_items
		if(!T)
			return FALSE
		T.charge_delay = initial(T.charge_delay)

