//RPED
/obj/item/borg/upgrade/item/rped
	name = "engineering cyborg RPED"
	desc = "A rapid part exchange device for the engineering cyborg."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "borgrped"
	compatible_modules = list(/obj/item/new_robot_module/engineering, /obj/item/new_robot_module/saboteur)
	module_flags = BORG_MODULE_ENGINEERING
	upgrade_item = /obj/item/storage/part_replacer/cyborg

//Circuit manipulator
/obj/item/borg/upgrade/item/circuit_app
	name = "circuit manipulation apparatus"
	desc = "An engineering cyborg upgrade allowing for manipulation of circuit boards."
	icon_state = "cyborg_upgrade3"
	compatible_modules = list(/obj/item/robot_module/engineering, /obj/item/robot_module/saboteur)
	module_flags = BORG_MODULE_ENGINEERING
	upgrade_item = /obj/item/borg/apparatus/circuit
